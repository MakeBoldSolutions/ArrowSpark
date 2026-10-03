// @ts-check
import { defineConfig } from 'astro/config';

// Static output only: no adapter, no server functions, no UI-framework integration.
// Styles and scripts ship as files (never inlined) so the production CSP needs no
// 'unsafe-inline'; see scripts/build-csp.mjs.
export default defineConfig({
  site: 'https://arrow.makeboldspark.com',
  output: 'static',
  trailingSlash: 'ignore',
  build: {
    format: 'directory',
    inlineStylesheets: 'never',
  },
  markdown: {
    // Highlighters emit inline style attributes, which the production CSP does not allow.
    syntaxHighlight: false,
  },
  vite: {
    build: {
      assetsInlineLimit: 0,
    },
  },
});
