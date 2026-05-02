import { execSync } from 'node:child_process';

const parentBranch = process.env.NEON_PARENT_BRANCH ?? 'production';
const branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim();

if (branch === parentBranch) {
  throw new Error(`Refusing to reset the parent branch '${parentBranch}'.`);
}

const mode = process.argv[2] ?? '--soft';

if (mode === '--soft') {
  if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is not set.');
  execSync(
    `psql "$DATABASE_URL" --set ON_ERROR_STOP=1 -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'`,
    { stdio: 'inherit' },
  );
  execSync('pnpm db:push', { stdio: 'inherit' });
} else if (mode === '--hard') {
  execSync('pnpm db:branch:delete', { stdio: 'inherit' });
  execSync('pnpm db:branch:create', { stdio: 'inherit' });
  console.log('Branch recreated. Run db:push if the create command did not push schema.');
} else {
  throw new Error('Usage: reset.ts [--soft|--hard]');
}
