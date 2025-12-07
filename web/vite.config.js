import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import postcssImport from 'postcss-import';
import tailwindcss from 'tailwindcss';
import autoprefixer from 'autoprefixer';

export default defineConfig({
   base: './',
  plugins: [react()],
  publicDir: 'public',
  css: {
    postcss: {
      plugins: [
        tailwindcss(),
        autoprefixer(),
      ],
    },
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: path.resolve(__dirname, 'src/index.jsx'),
      output: {
        entryFileNames: 'bundle.js',
        assetFileNames: (assetInfo) => {
          // CSS sempre como styles.css
          if (assetInfo.name && assetInfo.name.endsWith('.css')) {
            return 'styles.css';
          }
          // Outros assets mantêm estrutura original
          return assetInfo.name || '[name].[ext]';
        },
      },
    },
    copyPublicDir: true,
  },
  server: {
    port: 3000,
  },
});
