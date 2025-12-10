# Agam Cloud Web UI

Modern web frontend for Agam Cloud built with Next.js, React, and TypeScript.

## Features

- 🔐 User authentication (login, registration with OTP)
- 📁 Vault management (create, list, delete vaults)
- 📤 File upload and management
- 🖼️ Image thumbnail previews
- 🎨 Modern, responsive UI with Tailwind CSS

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Backend API server running (see main README)

### Installation

1. Install dependencies:
   ```bash
   npm install
   ```

2. Create a `.env.local` file:
   ```bash
   NEXT_PUBLIC_API_URL=http://localhost:8080
   ```

3. Run the development server:
   ```bash
   npm run dev
   ```

4. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Structure

```
web-ui/
├── app/                    # Next.js app directory
│   ├── login/             # Login page
│   ├── register/          # Registration page
│   ├── dashboard/         # Main dashboard
│   └── vault/[id]/        # Vault file management
├── components/            # React components
│   └── protected-route.tsx
├── lib/                   # Utilities and API client
│   ├── api.ts            # API client functions
│   └── auth-context.tsx  # Authentication context
└── public/               # Static assets
```

## Available Scripts

- `npm run dev` – Start development server
- `npm run build` – Build for production
- `npm run start` – Start production server
- `npm run lint` – Run ESLint

## Environment Variables

- `NEXT_PUBLIC_API_URL` – Backend API base URL (default: `http://localhost:8080`)

## Tech Stack

- **Next.js 16** – React framework
- **TypeScript** – Type safety
- **Tailwind CSS** – Styling
- **React Context** – State management
