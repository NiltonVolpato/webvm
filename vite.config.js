import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { viteStaticCopy } from 'vite-plugin-static-copy';

export default defineConfig({
  resolve: {
    alias: {
      '/config_terminal':
        { github: 'config_github.js', website: 'config_website.js' }[process.env.WEBVM_MODE] ?? 'config_public.js',
      '@leaningtech/cheerpx': process.env.CX_URL ? process.env.CX_URL : '@leaningtech/cheerpx',
    },
  },
  build: {
    target: 'es2022',
  },
  plugins: [
    sveltekit(),
    viteStaticCopy({
      targets: [
        { src: 'scrollbar.css', dest: '' },
        { src: 'serviceWorker.js', dest: '' },
        { src: 'login.html', dest: '' },
        { src: 'assets/', dest: '' },
      ],
    }),
  ],
});
