const FORBIDDEN = /\b(INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|REPLACE|ATTACH|DETACH|PRAGMA|VACUUM)\b/i;
const STARTS_WITH_SELECT = /^\s*(WITH\s+[\s\S]+?\)\s*)?SELECT\s/i;
const MAX_LEN = 4000;

/**
 * Returns null if the SQL is safe to run (read-only SELECT or WITH...SELECT).
 * Returns a user-facing error string otherwise.
 */
export function isReadOnly(sql: string): string | null {
  if (sql.length > MAX_LEN) return `Query exceeds ${MAX_LEN} characters.`;
  if (FORBIDDEN.test(sql)) return 'Only SELECT queries are allowed.';
  if (!STARTS_WITH_SELECT.test(sql)) return 'Query must start with SELECT (or WITH ... SELECT).';
  return null;
}
