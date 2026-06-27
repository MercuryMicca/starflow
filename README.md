# Starflow

Starflow is a spark-to-step operating system for life. It helps ADHD users turn any overwhelming spark into one kind, doable next step.

A spark can be a creative idea, a life admin obligation, an emotional overwhelm, a recurring habit, an urgent task, or a long-term dream. Starflow uses Gemini to understand the shape of the spark, ask only for the context it needs, and suggest the first action that feels possible right now.

For this hackathon, we are demoing Starflow through app-building because it is a clear example of a big, exciting, overwhelming spark. The same loop is designed to work across life admin, creative projects, health routines, relationships, school, work, and home care.

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

For the fastest local demo, set `GEMINI_API_KEY` from Google AI Studio. For Google Cloud mode, authenticate with ADC and set:

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

## Google Cloud Bootstrap

For Cloud Run with Gemini Enterprise Agent Platform:

1. Create or select a Google Cloud project.
2. Enable billing.
3. Enable the Agent Platform / Vertex AI API.
4. Grant the Cloud Run service account permission to call Gemini, such as `roles/aiplatform.user`.
5. Deploy with the environment variables below.

Recommended runtime variables:

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
  --set-env-vars GOOGLE_GENAI_USE_ENTERPRISE=true,GOOGLE_CLOUD_PROJECT=your-project-id,GOOGLE_CLOUD_LOCATION=global
```

Or build the included container:

```bash
gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT_ID/saskatoon/saskatoon-ai
gcloud run deploy saskatoon-ai \
  --image us-central1-docker.pkg.dev/PROJECT_ID/saskatoon/saskatoon-ai \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_GENAI_USE_ENTERPRISE=true,GOOGLE_CLOUD_PROJECT=PROJECT_ID,GOOGLE_CLOUD_LOCATION=global
```

## Checks

```bash
bun run typecheck
bun run lint
```
