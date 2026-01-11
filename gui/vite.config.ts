import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "node:path";
import tailwindcss from "@tailwindcss/vite";
import { createHash } from "node:crypto";

// https://vite.dev/config/
export default defineConfig({
  base: "/apps/nostrill",
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },
  build: {
    rollupOptions: {
      output: {
        assetFileNames: (a) => {
          let hash = createHash("sha256");
          hash.update(a.source);
          hash.update(a.name);
          const str = hash.digest("hex").slice(0, 16);
          return `assets/${str}-${a.name.toLowerCase()}`;
        },
        entryFileNames: (c) => {
          let hash = createHash("sha256");
          for (let m of c.moduleIds) {
            hash.update(m);
          }
          const str = hash.digest("hex").slice(0, 16);
          return `assets/${str}-${c.name.toLowerCase()}.js`;
        },
        chunkFileNames: (c) => {
          let hash = createHash("sha256");
          for (let m of c.moduleIds) {
            hash.update(m);
          }
          const str = hash.digest("hex").slice(0, 16);
          return `assets/${str}-${c.name.toLowerCase()}.js`;
        },
      },
    },
  },
});
