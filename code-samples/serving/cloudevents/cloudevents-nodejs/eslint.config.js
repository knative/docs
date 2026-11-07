module.exports = [{
  files: ['*.js'],
  languageOptions: {
    ecmaVersion: 'latest',
    sourceType: 'commonjs',
    globals: Object.fromEntries([
      'require', 'module', 'process', 'console', '__dirname', 'setTimeout',
      'fetch', 'AbortSignal'
    ].map(name => [name, 'readonly']))
  },
  rules: {
    'no-undef': 'error',
    'no-unused-vars': 'error',
    'no-unreachable': 'error',
    eqeqeq: 'error',
    'valid-typeof': 'error',
    semi: ['error', 'never'],
    quotes: ['error', 'single'],
    indent: ['error', 2]
  }
}]
