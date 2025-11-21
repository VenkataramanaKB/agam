package internal

import (
	"github.com/go-chi/chi/v5"
)

func SetupRouter(db DB, minio MinioClient) *chi.Mux {
	r := chi.NewRouter()

	r.Post("/upload", UploadFileHandler(db, minio))
	r.Get("/files/{vaultID}", ListFilesHandler(db))
	r.Get("/sync/{vaultID}", DeltaSyncHandler(db))

	return r
}
