import { execSync } from 'node:child_process';

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Missing env var: ${name}`);
  return value;
}

const parentBranch = process.env.NEON_PARENT_BRANCH ?? 'production';
const url = execSync(
  `neonctl connection-string ${parentBranch} --project-id ${required('NEON_PROJECT_ID')} --api-key ${required('NEON_API_KEY')}`,
  { encoding: 'utf8' },
).trim();

execSync('pnpm db:migrate', {
  stdio: 'inherit',
  env: { ...process.env, DATABASE_URL: url },
});

console.log('Migration retry succeeded. Update status/deploy if automation did not finish it.');
