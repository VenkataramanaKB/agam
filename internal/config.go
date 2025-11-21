package internal

import (
	"log"
	"os"
)

type Config struct {
	DatabaseURL string
	MinioEndpoint string
	MinioAccessKey string
	MinioSecretKey string
	MinioBucket    string
}

func LoadConfig() Config {
	return Config{
		DatabaseURL:    os.Getenv("DATABASE_URL"),
		MinioEndpoint:  os.Getenv("MINIO_ENDPOINT"),
		MinioAccessKey: os.Getenv("MINIO_ACCESS_KEY"),
		MinioSecretKey: os.Getenv("MINIO_SECRET_KEY"),
		MinioBucket:    os.Getenv("MINIO_BUCKET"),
	}
}
