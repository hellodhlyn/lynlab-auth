package main

import (
	"github.com/hellodhlyn/lynlab-auth/internal/server"
	"log"
)

func main() {
	s := server.NewServer()
	log.Fatal(s.Serve())
}
