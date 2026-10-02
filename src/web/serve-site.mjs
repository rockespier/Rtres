// Serves the SSR build of every locale from one process: /es, /en, /it.
import express from 'express';

const locales = ['es', 'en', 'it'];
const port = process.env.PORT || 4000;
const server = express();

for (const locale of locales) {
  const { app } = await import(`./dist/site/server/${locale}/server.mjs`);
  server.use(`/${locale}`, app());
}

server.get('/', (_req, res) => res.redirect(302, '/es/'));

server.listen(port, () => console.log(`Site (${locales.join('/')}) on http://localhost:${port}/es/`));
