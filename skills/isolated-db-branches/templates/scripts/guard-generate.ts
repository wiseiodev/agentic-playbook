import { execSync } from 'node:child_process';

const parentBranch = process.env.NEON_PARENT_BRANCH ?? 'production';
const branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf8' }).trim();

if (branch !== parentBranch) {
  console.error(
    `db:generate is blocked on feature branches.\n` +
      `Migrations are generated after merge on '${parentBranch}'.\n` +
      `Use db:push to apply schema changes to your isolated branch database.`,
  );
  process.exit(1);
}
