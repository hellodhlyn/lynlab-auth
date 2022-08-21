package connection

import (
	"github.com/go-redis/redis"
	"os"
)

func NewRedisClient() *redis.Client {
	return redis.NewClient(&redis.Options{
		Addr: os.Getenv("REDIS_ENDPOINT"),
	})
}
