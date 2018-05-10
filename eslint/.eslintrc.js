module.exports = {
  parser: 'babel-eslint',
  extends: 'airbnb',
  env: { browser: true, node: true },
  rules: {
    'arrow-parens': [2, 'as-needed'],
    'no-console': 0,
    'react/jsx-filename-extension': [1, { extensions: ['.js', '.jsx', '.mjs'] }],
    'space-in-parens': 0,
    'no-unused-expressions': ['error', { allowShortCircuit: true, allowTernary: true }],
    'react/prop-types': 0,
    'comma-dangle': ['error', {
      arrays: 'always-multiline',
      objects: 'always-multiline',
      imports: 'ignore',
      exports: 'ignore',
      functions: 'ignore',
    }],
  },
};
