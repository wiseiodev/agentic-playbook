const linearFooterLinePattern =
  /^(?:[Cc]lose|[Cc]loses|[Cc]losed|[Cc]losing|[Ff]ix|[Ff]ixes|[Ff]ixed|[Ff]ixing|[Rr]esolve|[Rr]esolves|[Rr]esolved|[Rr]esolving|[Cc]omplete|[Cc]ompletes|[Cc]ompleted|[Cc]ompleting)\s+[A-Z]+-\d+(?:,\s*[A-Z]+-\d+)*$/;
const conventionalTrailerPattern =
  /^(?:BREAKING CHANGE|[A-Za-z][A-Za-z-]*)(?: #\d+)?: .+$/;

module.exports = {
  extends: ['@commitlint/config-conventional'],
  plugins: [
    {
      rules: {
        'linear-footer': (parsed) => {
          const raw = parsed.raw ?? '';

          return [
            hasLinearFooter(raw),
            'commit footer must include exactly one Linear magic-word line like "Completes REV-123"',
          ];
        },
      },
    },
  ],
  rules: {
    'body-leading-blank': [2, 'always'],
    'footer-leading-blank': [2, 'always'],
    'linear-footer': [2, 'always'],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'type-empty': [2, 'never'],
  },
};

function hasLinearFooter(raw) {
  const normalized = raw.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  const matchingLinearLines = normalized
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => linearFooterLinePattern.test(line));
  const footerBlock =
    normalized
      .trim()
      .split(/\n{2,}/)
      .at(-1) ?? '';
  const lines = footerBlock
    .split('\n')
    .filter((line) => line.trim().length > 0);
  let hasLinearLine = false;
  let previousLineAllowsContinuation = false;

  const hasOnlyValidFooterLines = lines.every((line) => {
    if (/^[\t ]+/.test(line)) {
      return previousLineAllowsContinuation;
    }

    const trimmedLine = line.trim();
    if (linearFooterLinePattern.test(trimmedLine)) {
      hasLinearLine = true;
      previousLineAllowsContinuation = false;
      return true;
    }

    if (conventionalTrailerPattern.test(trimmedLine)) {
      previousLineAllowsContinuation = true;
      return true;
    }

    previousLineAllowsContinuation = false;
    return false;
  });

  return (
    hasLinearLine && hasOnlyValidFooterLines && matchingLinearLines.length === 1
  );
}
