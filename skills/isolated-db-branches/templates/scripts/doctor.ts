import { execSync } from 'node:child_process';

let ok = true;

function check(label: string, fn: () => boolean) {
  const pass = fn();
  console.log(`${pass ? 'ok' : 'FAIL'}  ${label}`);
  if (!pass) ok = false;
}

function commandExists(command: string): boolean {
  try {
    execSync(`command -v ${command}`, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

check('git installed', () => commandExists('git'));
check('neonctl installed', () => commandExists('neonctl'));
check('package manager installed', () => commandExists('pnpm') || commandExists('npm') || commandExists('bun'));
check('NEON_API_KEY set', () => Boolean(process.env.NEON_API_KEY));
check('NEON_PROJECT_ID set', () => Boolean(process.env.NEON_PROJECT_ID));
check('DATABASE_URL set', () => Boolean(process.env.DATABASE_URL));

process.exit(ok ? 0 : 1);
