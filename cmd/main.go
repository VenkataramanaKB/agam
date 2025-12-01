// @title Agam API
// @version 1.0
// @description API documentation for the Agam secure vault service.
// @schemes http
// @BasePath /
// @contact.name API Support
// @contact.email support@agam.local
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
package main

import (
	"log"
	"net/http"

	"github.com/joho/godotenv"
	_ "github.com/venkataramanakb/agam/docs"
	"github.com/venkataramanakb/agam/internal"
)

func main() {
	godotenv.Load()

	cfg := internal.LoadConfig()

	db := internal.InitDB(cfg)
	minioClient := internal.InitMinio(cfg)

	// Ensure JWT secret is set
	if cfg.JWTSecret == "" {
		log.Fatal("JWT_SECRET environment variable is required")
	}

	r := internal.SetupRouter(db, minioClient, cfg.MinioBucket, cfg.JWTSecret, cfg)

	log.Println("Server running on :8080")
	if err := http.ListenAndServe("0.0.0.0:8080", r); err != nil {
		log.Fatal(err)
	}
}
