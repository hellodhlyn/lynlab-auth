package datastore

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/duo-labs/webauthn/webauthn"
	"github.com/go-redis/redis"
	"github.com/google/uuid"
)

type User struct {
	ID          string                `json:"id"`
	Name        string                `json:"name"`
	DisplayName string                `json:"displayName"`
	Credentials []webauthn.Credential `json:"credentials"`
}

func (u *User) WebAuthnID() []byte {
	return []byte(u.ID)
}

func (u *User) WebAuthnName() string {
	return u.Name
}

func (u *User) WebAuthnDisplayName() string {
	return u.DisplayName
}

func (u *User) WebAuthnIcon() string {
	return ""
}

func (u *User) WebAuthnCredentials() []webauthn.Credential {
	return u.Credentials
}

func GetOrCreateUser(ctx context.Context, r *redis.Client, name string) (*User, error) {
	redisKey := userRedisKey(name)
	value, err := r.WithContext(ctx).Get(redisKey).Result()
	if err != nil && err != redis.Nil {
		return nil, err
	}
	if err == redis.Nil {
		return &User{
			ID:          uuid.NewString(),
			Name:        name,
			DisplayName: name,
			Credentials: []webauthn.Credential{},
		}, nil
	}

	var user User
	err = json.Unmarshal([]byte(value), &user)
	return &user, err
}

func SaveUser(ctx context.Context, r *redis.Client, user *User) error {
	redisKey := userRedisKey(user.Name)
	userJSON, _ := json.Marshal(user)
	return r.WithContext(ctx).Set(redisKey, userJSON, 0).Err()
}

func userRedisKey(name string) string {
	return fmt.Sprintf("auth.user.%s", name)
}
