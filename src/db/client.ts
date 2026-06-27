import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";

function databaseUrl(): string {
  const url = process.env.DATABASE_URL?.trim();

  if (!url) {
    throw new Error("DATABASE_URL is required for database access.");
  }

  return url;
}

export const queryClient = postgres(databaseUrl(), {
  max: 5,
  prepare: false,
});

export const db = drizzle(queryClient, { schema });
