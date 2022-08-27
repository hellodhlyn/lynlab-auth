package datastore

import (
	"errors"
	"github.com/golang-jwt/jwt/v4"
	"os"
	"time"
)

const (
	tokenValidHours = 30 * 24
	tokenIssuer     = "auth.lynlab.co.kr"
)

type AccessKeyClaims struct {
	UserID string `json:"id"`
	jwt.RegisteredClaims
}

func GenerateAccessKey(user *User) (string, error) {
	claims := AccessKeyClaims{
		user.ID,
		jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(tokenValidHours * time.Hour)),
			Issuer:    tokenIssuer,
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(getTokenSecret())
}

func ValidateAccessKey(key string) (string, error) {
	token, err := jwt.ParseWithClaims(key, &AccessKeyClaims{}, func(token *jwt.Token) (interface{}, error) {
		return getTokenSecret(), nil
	})
	if err != nil {
		return "", err
	}

	if claims, ok := token.Claims.(*AccessKeyClaims); ok && token.Valid {
		return claims.UserID, nil
	}
	return "", errors.New("invalid token")
}

func getTokenSecret() []byte {
	return []byte(os.Getenv("TOKEN_SECRET"))
}
