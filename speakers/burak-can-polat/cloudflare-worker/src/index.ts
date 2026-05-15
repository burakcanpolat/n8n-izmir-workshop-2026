import { isReadOnly } from './security';

export interface Env {
  DB: D1Database;
}

const CORS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function withCors(res: Response): Response {
  for (const [k, v] of Object.entries(CORS)) res.headers.set(k, v);
  return res;
}

async function run(sql: string, env: Env, limit?: number): Promise<Response> {
  const err = isReadOnly(sql);
  if (err) return Response.json({ error: err }, { status: 400 });

  const wrapped = limit
    ? `SELECT * FROM (${sql.replace(/;\s*$/, '')}) sub LIMIT ${limit}`
    : sql;

  try {
    const { results } = await env.DB.prepare(wrapped).all();
    return Response.json({ rows: results, count: results.length });
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    return Response.json({ error: msg }, { status: 400 });
  }
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method === 'OPTIONS') return withCors(new Response(null));
    if (req.method !== 'POST') return withCors(new Response('POST only', { status: 405 }));

    const url = new URL(req.url);
    const body = (await req.json().catch(() => null)) as { sql?: string } | null;
    if (!body?.sql) return withCors(Response.json({ error: 'Missing sql field.' }, { status: 400 }));

    if (url.pathname === '/test')    return withCors(await run(body.sql, env, 5));
    if (url.pathname === '/execute') return withCors(await run(body.sql, env));
    return withCors(new Response('Not found', { status: 404 }));
  },
} satisfies ExportedHandler<Env>;
