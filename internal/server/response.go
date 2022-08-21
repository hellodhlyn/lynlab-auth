package server

import (
	"encoding/json"
	"net/http"
)

func (s *Server) respondJSON(w http.ResponseWriter, body interface{}, status ...int) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Methods", "*")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	if len(status) == 1 {
		w.WriteHeader(status[0])
	}

	_ = json.NewEncoder(w).Encode(body)
}
