import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: "./src/test/setup.js",
    coverage: {
      reporter: ["text", "json", "html", "lcov"],
      exclude: [
        "node_modules/",
        "src/test/",
        "**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}",
        "**/*{.,-}test.{js,mjs,cjs,ts,mts,cts,jsx,tsx}",
        "**/*{.,-}spec.{js,mjs,cjs,ts,mts,cts,jsx,tsx}",
        "**/virtual:*",
        "**/{karma,rollup,webpack,vite,vitest,jest,ava,babel,nyc,cypress,tsup,build}.config.*",
        "**/node_modules/**",
        "**/dist/**",
        "**/cypress/**",
        "**/.{idea,git,cache,output,temp}/**",
        "**/{.storybook,storybook-static,coverage}/**",
      ],
    },
  },
});
