package server

import (
	"fmt"
	"github.com/duo-labs/webauthn/protocol"
	"github.com/duo-labs/webauthn/webauthn"
	"github.com/hellodhlyn/lynlab-auth/internal/datastore"
	"github.com/julienschmidt/httprouter"
	"net/http"
)

const (
	registrationSessionKey = "registration-session"
	loginSessionKey        = "login-session"
)

func (s *Server) ping(w http.ResponseWriter, _ *http.Request, _ httprouter.Params) {
	s.respondJSON(w, map[string]string{"result": "success"})
}

func (s *Server) beginRegister(w http.ResponseWriter, r *http.Request, p httprouter.Params) {
	user, err := datastore.GetOrCreateUser(r.Context(), s.redis, p.ByName("name"))
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
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

	// TODO - external session storage
	s.sessionStore[registrationSessionKey] = *session
	s.respondJSON(w, creation)
}

func (s *Server) finishRegister(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	session := s.sessionStore[registrationSessionKey].(webauthn.SessionData)
	user, err := datastore.GetOrCreateUser(r.Context(), s.redis, string(session.UserID))
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

	credential, err := s.webAuthn.CreateCredential(user, session, parsedResponse)
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
	user, err := datastore.GetOrCreateUser(r.Context(), s.redis, p.ByName("name"))
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

	// TODO - external session storage
	s.sessionStore[loginSessionKey] = *session
	s.respondJSON(w, assertion)
}

func (s *Server) finishLogin(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	session := s.sessionStore[registrationSessionKey].(webauthn.SessionData)
	user, err := datastore.GetOrCreateUser(r.Context(), s.redis, string(session.UserID))
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

	_, err = s.webAuthn.ValidateLogin(user, session, parsedResponse)
	if err != nil {
		fmt.Println(err)
		s.respondJSON(w, nil, http.StatusInternalServerError)
		return
	}

	s.respondJSON(w, user)
}
