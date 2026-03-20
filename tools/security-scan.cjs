#!/usr/bin/env node
/**
 * security-scan.cjs — Advisory secret scanner for Claude Code PreToolUse hooks.
 * Reads file content from stdin, scans for common secret patterns.
 * Exits 0 always (advisory only). Warnings go to stderr.
 */

const TEST_DIR_PATTERN = /(?:^|\/)(test|__tests?__|spec|fixtures)\//i;

const SECRET_PATTERNS = [
  { name: 'AWS Access Key', pattern: /AKIA[0-9A-Z]{16}/g },
  { name: 'OpenAI / Anthropic API Key', pattern: /sk-[a-zA-Z0-9]{20,}/g },
  { name: 'Stripe Live Secret Key', pattern: /sk_live_[a-zA-Z0-9]{20,}/g },
  { name: 'Stripe Live Publishable Key', pattern: /pk_live_[a-zA-Z0-9]{20,}/g },
  { name: 'Stripe Restricted Key', pattern: /rk_live_[a-zA-Z0-9]{20,}/g },
  { name: 'Stripe Test Secret Key', pattern: /sk_test_[a-zA-Z0-9]{20,}/g },
  { name: 'GitHub Token', pattern: /gh[psotr]_[a-zA-Z0-9]{36,}/g },
  { name: 'RSA Private Key', pattern: /BEGIN RSA PRIVATE KEY/g },
  { name: 'EC Private Key', pattern: /BEGIN EC PRIVATE KEY/g },
  { name: 'OpenSSH Private Key', pattern: /BEGIN OPENSSH PRIVATE KEY/g },
  { name: 'PostgreSQL Connection String', pattern: /postgresql:\/\/[^:]+:[^@]+@/gi },
  { name: 'MongoDB Connection String', pattern: /mongodb(\+srv)?:\/\/[^:]+:[^@]+@/gi },
  { name: 'Generic Secret Assignment', pattern: /(?:password|secret|token|api_key|apikey)\s*[=:]\s*["'][a-zA-Z0-9\/+_.~-]{16,}["']/gi },
];

function scan(content, filePath) {
  const findings = [];
  for (const { name, pattern } of SECRET_PATTERNS) {
    // Reset regex lastIndex for global patterns
    pattern.lastIndex = 0;
    const match = pattern.exec(content);
    if (match) {
      // Find the line number
      const lineNum = content.substring(0, match.index).split('\n').length;
      findings.push({ name, line: lineNum, snippet: match[0].substring(0, 40) });
    }
  }
  return findings;
}

async function main() {
  let input = '';
  for await (const chunk of process.stdin) {
    input += chunk;
  }

  // Try to parse as JSON (Claude Code hook format)
  let content = input;
  let filePath = '';
  try {
    const parsed = JSON.parse(input);
    content = parsed.content || parsed.file_content || input;
    filePath = parsed.file_path || parsed.path || '';
  } catch {
    // Not JSON — treat as raw file content
  }

  // Skip test directories
  if (filePath && TEST_DIR_PATTERN.test(filePath)) {
    process.exit(0);
  }

  const findings = scan(content, filePath);

  if (findings.length > 0) {
    process.stderr.write('\n=== SECURITY SCAN WARNING ===\n');
    if (filePath) {
      process.stderr.write(`File: ${filePath}\n`);
    }
    for (const f of findings) {
      process.stderr.write(`  [!] ${f.name} detected (line ${f.line}): ${f.snippet}...\n`);
    }
    process.stderr.write('Review before committing. Secrets should use .env files or a vault.\n');
    process.stderr.write('=============================\n\n');
  }

  process.exit(0);
}

main();
