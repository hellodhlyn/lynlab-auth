package datastore

import (
	"context"
	"encoding/json"
	"github.com/duo-labs/webauthn/webauthn"
	"github.com/go-redis/redis"
	"time"
)

func GetSession(ctx context.Context, r *redis.Client, key string) *webauthn.SessionData {
	sessionJSON, err := r.WithContext(ctx).Get(key).Result()
	if err == redis.Nil {
		return nil
	}

	var session webauthn.SessionData
	_ = json.Unmarshal([]byte(sessionJSON), &session)
	return &session
}

func StoreSession(ctx context.Context, r *redis.Client, key string, session *webauthn.SessionData) {
	sessionJSON, _ := json.Marshal(session)
	r.WithContext(ctx).Set(key, sessionJSON, 60*time.Second)
}
