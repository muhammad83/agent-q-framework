#!/usr/bin/env node

// Agent Q Framework — Hook Profile Manager
// Controls which hooks run based on AGENT_Q_HOOK_PROFILE env var.
//
// Profiles: minimal, standard (default), strict
//
// Usage as module:
//   const { shouldRun } = require('./hook-profile.cjs');
//   if (shouldRun('security-scan')) { /* run hook */ }
//
// Usage as CLI:
//   node tools/hook-profile.cjs <hookName>
//   Exit 0 = should run, Exit 1 = should skip

const PROFILES = {
  minimal: {
    'statusline': true,
    'context-monitor': false,
    'security-scan': false,
    'pre-commit-verify': false,
    'lint-on-save': false,
  },
  standard: {
    'statusline': true,
    'context-monitor': true,
    'security-scan': true,
    'pre-commit-verify': false,
    'lint-on-save': false,
  },
  strict: {
    'statusline': true,
    'context-monitor': true,
    'security-scan': true,
    'pre-commit-verify': true,
    'lint-on-save': true,
  },
};

const VALID_HOOKS = [
  'statusline',
  'context-monitor',
  'security-scan',
  'pre-commit-verify',
  'lint-on-save',
];

function getProfile() {
  const name = (process.env.AGENT_Q_HOOK_PROFILE || 'standard').toLowerCase();
  if (!PROFILES[name]) {
    console.error(`[hook-profile] Unknown profile "${name}", falling back to "standard".`);
    return 'standard';
  }
  return name;
}

function shouldRun(hookName) {
  const profile = getProfile();
  const matrix = PROFILES[profile];
  if (!(hookName in matrix)) {
    // Unknown hook — default to not running
    return false;
  }
  return matrix[hookName];
}

// --- CLI mode ---
if (require.main === module) {
  const hookName = process.argv[2];

  if (!hookName) {
    console.error('Usage: node tools/hook-profile.cjs <hookName>');
    console.error(`Valid hooks: ${VALID_HOOKS.join(', ')}`);
    console.error(`Current profile: ${getProfile()}`);
    process.exit(1);
  }

  if (!VALID_HOOKS.includes(hookName)) {
    console.error(`[hook-profile] Unknown hook "${hookName}".`);
    console.error(`Valid hooks: ${VALID_HOOKS.join(', ')}`);
    process.exit(1);
  }

  const run = shouldRun(hookName);
  const profile = getProfile();

  if (run) {
    console.log(`[hook-profile] ${hookName}: ENABLED (profile: ${profile})`);
    process.exit(0);
  } else {
    console.log(`[hook-profile] ${hookName}: SKIPPED (profile: ${profile})`);
    process.exit(1);
  }
}

module.exports = { shouldRun, getProfile, PROFILES, VALID_HOOKS };
