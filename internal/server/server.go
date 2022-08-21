package server

import (
	"fmt"
	"github.com/duo-labs/webauthn/webauthn"
	"github.com/go-redis/redis"
	"github.com/hellodhlyn/lynlab-auth/internal/connection"
	"github.com/julienschmidt/httprouter"
	"net/http"
)

type Server struct {
	webAuthn     *webauthn.WebAuthn
	router       *httprouter.Router
	sessionStore map[string]interface{}
	redis        *redis.Client
}

func NewServer() *Server {
	webAuthn, _ := webauthn.New(&webauthn.Config{
		RPDisplayName: "LYnLab",
		RPID:          "lynlab.co.kr",
	})
	router := httprouter.New()
	redisClient := connection.NewRedisClient()
	server := &Server{
		webAuthn:     webAuthn,
		router:       router,
		sessionStore: map[string]interface{}{},
		redis:        redisClient,
	}

	router.GET("/ping", server.ping)
	router.GET("/registration/:name", server.beginRegister)
	router.POST("/registration", server.finishRegister)
	router.GET("/assertion/:name", server.beginLogin)
	router.POST("/assertion", server.finishLogin)

	return server
}

func (s *Server) Serve() error {
	addr := "0.0.0.0:8080"
	httpServer := &http.Server{
		Addr:    addr,
		Handler: s.router,
	}

	fmt.Printf("Start listening %s\n", addr)
	return httpServer.ListenAndServe()
}
