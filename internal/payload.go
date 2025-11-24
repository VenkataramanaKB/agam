package internal

import (
	"time"
)


// Defining the api payloads

type UserInput struct {
	Name     string `json:"name" example:"Alice"`
	Email    string `json:"email" example:"alice@example.com"`
	Phone    int    `json:"phone" example:"9199990000"`
	Password string `json:"password" example:"Secret123!"`
}

type VaultInput struct {
	Name     string 
	Type    string 
	UserID int64
}

// UserResponse is returned after user creation without nested relations.
type UserResponse struct {
	ID               int64     `json:"id"`
	Name             string    `json:"name"`
	Email            string    `json:"email"`
	Phone            int       `json:"phone"`
	CreatedTimestamp time.Time `json:"createdTimestamp"`
}

type DeviceInput struct{
	Name		string
	UserID		int64
}