import { execSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const root = process.cwd();
const envFile = resolve(root, '.env');
const parentBranch = process.env.NEON_PARENT_BRANCH ?? 'production';

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Missing env var: ${name}`);
  return value;
}

function sh(command: string): string {
  return execSync(command, { encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
}

function gitBranch(): string {
  return sh('git rev-parse --abbrev-ref HEAD');
}

function neon(args: string): string {
  return sh(`neonctl ${args} --project-id ${required('NEON_PROJECT_ID')} --api-key ${required('NEON_API_KEY')}`);
}

function writeDatabaseUrl(url: string) {
  const line = `DATABASE_URL='${url}'`;
  if (!existsSync(envFile)) {
    writeFileSync(envFile, `${line}\n`);
    return;
  }

  const lines = readFileSync(envFile, 'utf8').split('\n');
  const index = lines.findIndex((entry) => entry.startsWith('DATABASE_URL='));
  if (index === -1) lines.push(line);
  else lines[index] = line;
  writeFileSync(envFile, lines.join('\n'));
}

const command = process.argv[2];
const branch = gitBranch();

if ((command === 'create' || command === 'delete') && branch === parentBranch) {
  throw new Error(`Refusing to ${command} the parent branch '${parentBranch}'.`);
}

switch (command) {
  case 'create': {
    try {
      neon(`branches get ${branch}`);
      console.log(`Neon branch '${branch}' already exists; reusing.`);
    } catch {
      neon(`branches create --name ${branch} --parent ${parentBranch}`);
      console.log(`Created Neon branch '${branch}'.`);
    }
    const url = neon(`connection-string ${branch}`);
    writeDatabaseUrl(url);
    console.log(`Wrote DATABASE_URL to ${envFile}`);
    break;
  }
  case 'delete':
    neon(`branches delete ${branch}`);
    console.log(`Deleted Neon branch '${branch}'.`);
    break;
  case 'list':
    console.log(neon('branches list'));
    break;
  case 'prune':
    console.log('Implement repo-specific prune policy here. Dry-run by default; require --yes to delete.');
    break;
  default:
    throw new Error('Usage: branch.ts <create|delete|list|prune> [--yes]');
}
