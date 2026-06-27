# Saskatoon AI

Cloud Run-ready Bun + TypeScript webapp with a server-side Gemini integration.

## Stack

- Bun HTTP server with TypeScript.
- Google GenAI SDK (`@google/genai`) for Gemini.
- Static frontend served by the same process.
- Cloud Run container contract: listens on `0.0.0.0` and `PORT`.

## Local Setup

Install dependencies from the committed lockfile:

```bash
bun install --frozen-lockfile
```

Create local environment variables:

```bash
cp .env.example .env
```

For the fastest local demo, set `GEMINI_API_KEY` from Google AI Studio.

If you received Google hackathon / Agent Platform variables, put them in `.env`:

```bash
GOOGLE_AGENT_PLATFORM_KEY=your-agent-platform-key
GOOGLE_CLOUD_PROJECT=your-project-id
GEMINI_PROJECT_NUMBER=your-project-number
GEMINI_API_KEY=your-gemini-api-key
```

When `GOOGLE_AGENT_PLATFORM_KEY` is present, the app uses Gemini Enterprise Agent Platform mode. `GEMINI_API_KEY` remains useful as the local Developer API fallback if the Agent Platform key is removed.

For Google Cloud mode with Application Default Credentials or a Cloud Run service account, omit `GOOGLE_AGENT_PLATFORM_KEY`, authenticate with ADC, and set:

```bash
GOOGLE_GENAI_USE_ENTERPRISE=true
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=global
```

Run the app:

```bash
bun run dev
```

Open `http://localhost:3000`.

## Local Postgres

For agent context storage, local development uses Postgres 16 with `pgvector` in Docker:

```bash
bun run db:up
bun run db:migrate
```

Or start Postgres, apply migrations, and run the app in one command:

```bash
bun run dev:local
```

`dev:local` uses the Conductor-allocated `PORT` when available and stops the
local Postgres service when you press Ctrl-C.

The local scripts derive a worktree-specific Postgres port, so parallel Conductor workspaces do not all bind to `5432`. To inspect the generated values:

```bash
./scripts/local-env.sh env
```

The initial schema covers users, Google OAuth accounts, agent sessions/messages, memories, and `vector(768)` memory embeddings. Drizzle schema lives in `src/db/schema.ts`; the bootstrap SQL migration lives in `db/migrations/`.

## Google Cloud Bootstrap

For Cloud Run with Gemini Enterprise Agent Platform:

1. Create or select a Google Cloud project.
2. Enable billing.
3. Enable the Agent Platform / Vertex AI API.
4. Grant the Cloud Run service account permission to call Gemini, such as `roles/aiplatform.user`.
5. Deploy with either the Agent Platform key or service account variables below.

Agent Platform key runtime variables:

```bash
GOOGLE_AGENT_PLATFORM_KEY=your-agent-platform-key
GOOGLE_CLOUD_PROJECT=your-project-id
GEMINI_PROJECT_NUMBER=your-project-number
GEMINI_MODEL=gemini-2.5-flash
```

Service account / ADC runtime variables:

```bash
GOOGLE_GENAI_USE_ENTERPRISE=true
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_LOCATION=global
GEMINI_MODEL=gemini-2.5-flash
```

## Deploy

The examples below use `--allow-unauthenticated` for fast public hackathon demos. For production, remove that flag and put authentication, rate limiting, quota controls, or an application gateway in front of `/api/generate` to avoid unexpected Gemini spend or abuse.

Build and deploy from source with Google Cloud Buildpacks:

```bash
gcloud run deploy saskatoon-ai \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_AGENT_PLATFORM_KEY=your-agent-platform-key,GOOGLE_CLOUD_PROJECT=your-project-id,GEMINI_PROJECT_NUMBER=your-project-number
```

Or build the included container:

```bash
gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT_ID/saskatoon/saskatoon-ai
gcloud run deploy saskatoon-ai \
  --image us-central1-docker.pkg.dev/PROJECT_ID/saskatoon/saskatoon-ai \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_AGENT_PLATFORM_KEY=your-agent-platform-key,GOOGLE_CLOUD_PROJECT=PROJECT_ID,GEMINI_PROJECT_NUMBER=your-project-number
```

## Checks

```bash
bun run typecheck
bun run lint
```
