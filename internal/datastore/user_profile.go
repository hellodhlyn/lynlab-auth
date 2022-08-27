package datastore

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-redis/redis"
)

type UserProfile struct {
	UserID       string `json:"id"`
	Name         string `json:"name"`
	DisplayName  string `json:"displayName"`
	ProfileImage string `json:"profileImage"`
}

func NewUserProfile(id, name string) UserProfile {
	return UserProfile{
		UserID:       id,
		Name:         name,
		DisplayName:  name,
		ProfileImage: "https://imagedelivery.net/ow37D_OHIRrKbNlwamdRUg/926006f7-d8bb-485f-94a2-c7f6fddb8d00/thumbnail",
	}
}

func GetUserProfile(ctx context.Context, r *redis.Client, userID string) (*UserProfile, error) {
	value, err := r.WithContext(ctx).Get(userProfileRedisKey(userID)).Result()
	if err == redis.Nil {
		return nil, nil
	} else if err != nil {
		return nil, err
	}

	var profile UserProfile
	err = json.Unmarshal([]byte(value), &profile)
	return &profile, err
}

func SaveUserProfile(ctx context.Context, r *redis.Client, profile *UserProfile) error {
	profileJSON, _ := json.Marshal(profile)
	return r.WithContext(ctx).Set(userProfileRedisKey(profile.UserID), string(profileJSON), 0).Err()
}

func userProfileRedisKey(id string) string {
	return fmt.Sprintf("auth.user-profile.%s", id)
}
