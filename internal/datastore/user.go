package datastore

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/duo-labs/webauthn/webauthn"
	"github.com/go-redis/redis"
	"github.com/google/uuid"
)

const (
	userNameIDMapKey = "auth.user.__id-name-mappings"
)

type User struct {
	ID          string                `json:"id"`
	Credentials []webauthn.Credential `json:"credentials"`
	Profile     UserProfile           `json:"-"`
}

func (u *User) WebAuthnID() []byte {
	return []byte(u.ID)
}

func (u *User) WebAuthnName() string {
	return u.Profile.Name
}

func (u *User) WebAuthnDisplayName() string {
	return u.Profile.DisplayName
}

func (u *User) WebAuthnIcon() string {
	return ""
}

func (u *User) WebAuthnCredentials() []webauthn.Credential {
	return u.Credentials
}

func GetUser(ctx context.Context, r *redis.Client, id string) (*User, error) {
	value, err := r.WithContext(ctx).Get(userRedisKey(id)).Result()
	if err == redis.Nil {
		return nil, nil
	} else if err != nil {
		return nil, err
	}

	var user User
	err = json.Unmarshal([]byte(value), &user)
	return &user, err
}

func GetOrCreateUserByName(ctx context.Context, r *redis.Client, name string) (*User, error) {
	userID, err := getUserIDByName(ctx, r, name)
	if err != nil && err != redis.Nil {
		return nil, err
	}

	var user *User
	if userID != "" {
		user, err = GetUser(ctx, r, userID)
	}

	if err != nil && err != redis.Nil {
		return nil, err
	} else if user == nil {
		userID := uuid.NewString()
		return &User{
			ID:          userID,
			Credentials: []webauthn.Credential{},
			Profile:     NewUserProfile(userID, name),
		}, nil
	} else if err != nil {
		return nil, err
	}

	profile, err := GetUserProfile(ctx, r, user.ID)
	if err != nil {
		return nil, nil
	} else if profile == nil {
		user.Profile = NewUserProfile(user.ID, name)
	} else {
		user.Profile = *profile
	}

	return user, err
}

func SaveUser(ctx context.Context, r *redis.Client, user *User) error {
	userJSON, _ := json.Marshal(user)
	_, err := r.WithContext(ctx).TxPipelined(func(pipe redis.Pipeliner) error {
		if err := r.Set(userRedisKey(user.ID), userJSON, 0).Err(); err != nil {
			return err
		}
		if err := r.HSet(userNameIDMapKey, user.Profile.Name, user.ID).Err(); err != nil {
			return err
		}
		if err := SaveUserProfile(ctx, r, &user.Profile); err != nil {
			return err
		}
		return nil
	})
	return err
}

func getUserIDByName(ctx context.Context, r *redis.Client, name string) (string, error) {
	return r.WithContext(ctx).HGet(userNameIDMapKey, name).Result()
}

func userRedisKey(id string) string {
	return fmt.Sprintf("auth.user.%s", id)
}
