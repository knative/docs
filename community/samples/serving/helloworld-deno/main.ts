import { serve } from "./deps.ts";
import "https://deno.land/x/dotenv/load.ts";

const PORT = Deno.env('PORT') || 8080;
const s = serve(`0.0.0.0:${PORT}`);
const body = new TextEncoder().encode("Hello Deno\n");

console.log(`Server started on port ${PORT}`);
for await (const req of s) {
  req.respond({ body });
}
