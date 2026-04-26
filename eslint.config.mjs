import js from '@eslint/js';
import globals from 'globals';

export default [
  {
    ignores: ['coverage/**', 'doc/**', 'node_modules/**', 'vendor/**']
  },
  js.configs.recommended,
  {
    files: ['app/assets/javascripts/**/*.js', 'app/assets/javascripts/**/*.js.erb'],
    languageOptions: {
      ecmaVersion: 2022,
      globals: {
        ...globals.browser,
        _TABLE_: 'writable',
        Stradivari: 'writable'
      },
      sourceType: 'script'
    },
    rules: {
      'no-restricted-globals': [
        'error',
        { name: '$', message: 'Use native DOM APIs instead of jQuery.' },
        { name: 'jQuery', message: 'Use native DOM APIs instead of jQuery.' },
        { name: 'Bloodhound', message: 'Autocomplete/typeahead support has been removed.' }
      ],
      'no-restricted-properties': [
        'error',
        { object: 'window', property: '$', message: 'Use native DOM APIs instead of jQuery.' },
        { object: 'window', property: 'jQuery', message: 'Use native DOM APIs instead of jQuery.' },
        { property: 'typeahead', message: 'Autocomplete/typeahead support has been removed.' }
      ],
      'no-restricted-syntax': [
        'error',
        { selector: 'WithStatement', message: 'Use explicit object access instead of with statements.' }
      ],
      'no-var': 'error',
      'object-shorthand': 'error',
      'prefer-const': 'error',
      'prefer-template': 'error'
    }
  }
];