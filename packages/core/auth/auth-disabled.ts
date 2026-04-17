/**
 * When true, the web app skips login redirects and the API runs in MULTICA_DISABLE_AUTH mode.
 * Set NEXT_PUBLIC_MULTICA_DISABLE_AUTH=1 at build time; server needs MULTICA_DISABLE_AUTH=1.
 */
export function isAuthDisabledFromEnv(): boolean {
  if (typeof process === "undefined") return false;
  const v = process.env.NEXT_PUBLIC_MULTICA_DISABLE_AUTH;
  return v === "1" || v === "true" || v === "yes";
}
