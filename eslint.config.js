import js from '@eslint/js';
import globals from 'globals';

export default [
  js.configs.recommended,
  {
    languageOptions: { globals: globals.node },
    // Ningún comentario en el código cambia la configuración:
    // las reglas solo cambian aquí, y este fichero tiene dueño en CODEOWNERS.
    linterOptions: { noInlineConfig: true },
    rules: {
      eqeqeq: 'error',
      'no-console': 'error',
    },
  },
];
