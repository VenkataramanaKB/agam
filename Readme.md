<p align="right">
  <a href="https://whencut.in" target="_blank" rel="noopener noreferrer">By whencut.in</a>
</p>

<p align="center">
  <a href="https://whencut.in" target="_blank" rel="noopener noreferrer">
    <img src="resources/agam.png" alt="Agam Logo" width="250" />
  </a>
</p>


---

Agam Cloud is a lightweight, self-hosted cloud platform designed to let you store, access, and manage your data without depending on any external cloud provider. It focuses on privacy, simplicity, and full ownership of your digital life.

**Agam** is a Tamil word meaning “inner self.” The platform embodies this principle by ensuring your files stay entirely within your control. 

Private, secure, and inaccessible to third parties.

Agam Cloud aims to provide the conveniences of major cloud storage services while keeping the architecture minimal, transparent, and easy to run on your own infrastructure.


## Features

- **Self-hosted storage**  
  Your data stays on your servers, systems, or local network.

- **Multi-device access**  
  Sync and access your files across devices without vendor lock-in.

- **Scalable design**  
  Built to function smoothly on small personal setups as well as larger self-hosted environments.

- **Lightweight architecture**  
  Minimal dependencies, clean structure, and efficient resource usage.


## Tech Stack

- **Go** – Backend services and APIs  
- **Next.js** – Modern web frontend with React and TypeScript
- **MinIO** – Object storage layer with S3-compatible interfaces  
- **PostgreSQL** – Reliable relational database for metadata and user management


## Project Structure

This is a monorepo containing:

- **`backend/`** – Go backend API server
  - `cmd/` – Main application entry point
  - `internal/` – Internal packages (handlers, models, services)
  - `docs/` – API documentation (Swagger)

- **`web-ui/`** – Next.js web frontend
  - Modern React application with TypeScript
  - Tailwind CSS for styling
  - Authentication and file management UI

## Architecture Overview

Agam Cloud uses a simple and modular design:

1. **Frontend (Next.js)**  
   Modern web interface for user authentication, vault management, and file operations.

2. **API Layer (Go)**  
   Handles authentication, file operations, metadata, sync logic, and background tasks.

3. **Object Storage (MinIO)**  
   Stores actual files and media with high performance and S3 compatibility.

4. **Database Layer (PostgreSQL)**  
   Manages user accounts, vaults, file metadata, previews, and sync tracking.


## Current Development Status

Development of the core platform is complete, including:

- User authentication  
- Vault and file management  
- Upload and download flows  
- Thumbnail generation for images  
- Basic mobile and desktop sync logic  
- **Web frontend (Next.js)** – Complete with authentication, vault management, and file operations UI

Testing is in progress, with optimizations and refinements underway.

## Getting Started

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Set up your environment variables in a `.env` file at the root of the project (see backend documentation for required variables).

3. Run the backend server:
   ```bash
   go run cmd/main.go
   ```

The API server will run on `http://localhost:8080`.

### Frontend Setup

1. Navigate to the web-ui directory:
   ```bash
   cd web-ui
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env.local` file:
   ```bash
   NEXT_PUBLIC_API_URL=http://localhost:8080
   ```

4. Run the development server:
   ```bash
   npm run dev
   ```

The web interface will be available at `http://localhost:3000`.

## Future Development 

The mobile frontend is still to be developed. If you'd like to contribute, you're more than welcome!

Will also add a How to use guide soon!

## License

Agam is Licensed under GNU AGPLv3


## Contributing

Contributions of all forms are welcome:

- Reporting issues  
- Suggesting improvements  
- Submitting pull requests  
- Improving documentation  
- Testing features in real-world environments  

If you're interested in helping shape the project, feel free to open an issue or start a conversation.

---

