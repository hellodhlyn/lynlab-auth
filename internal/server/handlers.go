package server

import (
	"fmt"
	"github.com/duo-labs/webauthn/protocol"
	"github.com/hellodhlyn/lynlab-auth/internal/datastore"
	"github.com/julienschmidt/httprouter"
	"net/http"
	"strings"
)

func (s *Server) ping(w http.ResponseWriter, _ *http.Request, _ httprouter.Params) {
	s.respondJSON(w, map[string]string{"result": "success"})
}

func (s *Server) beginRegister(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	user, err := datastore.GetOrCreateUserByName(r.Context(), s.redis, p.ByName("name"))
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}
	if len(user.Credentials) != 0 {
		s.respondJSON(w, map[string]string{"error": "User already exists"}, http.StatusBadRequest)
		return
	}

	err = datastore.SaveUser(r.Context(), s.redis, user)
	if err != nil {
		fmt.Println(err)
	}

	creation, session, err := s.webAuthn.BeginRegistration(user)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	datastore.StoreSession(r.Context(), s.redis, s.getRegistrationSessionKey(user.ID), session)
	s.respondJSON(w, creation)
}

func (s *Server) finishRegister(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	user, err := datastore.GetOrCreateUserByName(r.Context(), s.redis, p.ByName("name"))
	session := datastore.GetSession(r.Context(), s.redis, s.getRegistrationSessionKey(user.ID))
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	parsedResponse, err := protocol.ParseCredentialCreationResponseBody(r.Body)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	credential, err := s.webAuthn.CreateCredential(user, *session, parsedResponse)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	user.Credentials = append(user.Credentials, *credential)
	_ = datastore.SaveUser(r.Context(), s.redis, user)

	s.respondJSON(w, nil, http.StatusCreated)
}

func (s *Server) beginLogin(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	user, err := datastore.GetOrCreateUserByName(r.Context(), s.redis, p.ByName("name"))
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}
	if len(user.WebAuthnCredentials()) == 0 {
		s.respondJSON(w, map[string]string{"error": "User or credential not found"}, http.StatusBadRequest)
		return
	}

	assertion, session, err := s.webAuthn.BeginLogin(user)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	datastore.StoreSession(r.Context(), s.redis, s.getAssertionSessionKey(user.ID), session)
	s.respondJSON(w, assertion)
}

func (s *Server) finishLogin(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	user, err := datastore.GetOrCreateUserByName(r.Context(), s.redis, p.ByName("name"))
	session := datastore.GetSession(r.Context(), s.redis, s.getAssertionSessionKey(user.ID))
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	parsedResponse, err := protocol.ParseCredentialRequestResponseBody(r.Body)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	_, err = s.webAuthn.ValidateLogin(user, *session, parsedResponse)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	accessKey, err := datastore.GenerateAccessKey(user)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	s.respondJSON(w, map[string]string{"accessKey": accessKey}, http.StatusCreated)
}

func (s *Server) whoAmI(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	splits := strings.Split(r.Header.Get("Authorization"), " ")
	if len(splits) != 2 || splits[0] != "Bearer" {
		s.respondJSON(w, nil, http.StatusUnauthorized)
		return
	}

	userID, err := datastore.ValidateAccessKey(splits[1])
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusUnauthorized)
		return
	}

	profile, err := datastore.GetUserProfile(r.Context(), s.redis, userID)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}
	s.respondJSON(w, profile)
}

func (s *Server) getRegistrationSessionKey(id string) string {
	return fmt.Sprintf("auth.session.registration.%s", id)
}

func (s *Server) getAssertionSessionKey(id string) string {
	return fmt.Sprintf("auth.session.assertion.%s", id)
}
