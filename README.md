# CI para lo que el agente no puede saltarse

Código del artículo [Linters, tests de arquitectura y CI para lo que el agente no puede saltarse](https://rubentejera.com/hooks-y-ci-para-agentes/).

Un proyecto mínimo de Node con tres redes que no dependen de que un agente de IA (o una persona) se acuerde de usarlas:

| Red | Dónde | Qué para | Cómo se salta |
| --- | --- | --- | --- |
| ESLint con `noInlineConfig` | `eslint.config.js` | Errores de estilo y de lógica, sin comentarios que apaguen reglas | Cambiando la configuración |
| Hook `pre-commit` | `.githooks/pre-commit` | El commit, antes de que exista | `git commit --no-verify` |
| CI | `.github/workflows/ci.yml` | El cambio antes de llegar a `main` | Solo si la rama no exige que pase |

Y una cuarta para lo que las otras no ven: `.github/CODEOWNERS` pide la revisión de quien mantiene las redes cuando alguien cambia su configuración. Hace efecto si la rama protegida tiene activado «Require review from Code Owners».

`scripts/escenarios.sh` reproduce, en una copia desechable, cuatro formas de que un cambio con errores llegue a `main`: con el hook, con `--no-verify`, con un comentario `eslint-disable` y cambiando la configuración.

## Requisitos

Node.js 24.22.2 o posterior (`.node-version`), o solo Docker.

## Uso

```bash
npm ci
git config core.hooksPath .githooks   # activa el hook pre-commit
npm run check                          # lo mismo que hacen el hook y la CI
docker run --rm -v "$PWD":/app:ro node:24.22.2 sh /app/scripts/escenarios.sh
```

Probado el 13-11-2026 con Node 24.22.2, ESLint 10.14.0 y git 2.39.5 de la imagen oficial de Node.

## Cómo se ha hecho

Desarrollado con el enfoque [IA Limpia](https://rubentejera.com/que-es-la-ia-limpia/): un agente de IA escribe el código siguiendo los pasos del artículo, los tests validan cada paso y el resultado se revisa y se aprueba a mano antes de publicarlo.

## Licencia

MIT. Ver `LICENSE`.
