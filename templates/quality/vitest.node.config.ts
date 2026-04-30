import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: false,
    include: ['src/**/*.test.ts', 'src/**/*.spec.ts', 'test/**/*.spec.ts'],
    setupFiles: ['./test/setup.ts'],
  },
});
