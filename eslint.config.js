import js from '@eslint/js';
import globals from 'globals';

export default [
  js.configs.recommended,
  {
    languageOptions: { globals: globals.node },
    // Un comentario en el código no puede apagar una regla: las reglas solo cambian aquí.
    linterOptions: { noInlineConfig: true, reportUnusedDisableDirectives: 'error' },
    rules: {
      eqeqeq: 'error',
      'no-console': 'error',
    },
  },
];
