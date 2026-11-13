# Linters, hooks y CI: lo que un agente no puede saltarse

Código del artículo [Linters, hooks y CI: lo que un agente no puede saltarse](https://rubentejera.com/hooks-y-ci-para-agentes/).

Un proyecto mínimo de Node con tres redes que no dependen de que un agente de IA (o una persona) se acuerde de usarlas, y una cuarta para lo que las otras no ven:

| Red | Dónde | Cómo se salta | Qué lo evita |
| --- | --- | --- | --- |
| ESLint | `eslint.config.js` | Un comentario `eslint-disable`; otra configuración en una subcarpeta; cambiar la configuración | `noInlineConfig`; CODEOWNERS |
| Hook `pre-commit` | `.githooks/pre-commit` | `git commit --no-verify` o `-n`; no tener `core.hooksPath` en ese clon | La CI, que repite lo mismo |
| CI | `.github/workflows/ci.yml` | Fusionar sin esperarla; cambiar el workflow o el script `check` en la misma pull request | Checks obligatorios en la rama; CODEOWNERS |
| CODEOWNERS | `.github/CODEOWNERS` | Que la revisión no sea obligatoria; que el agente use la cuenta del único dueño | «Require review from Code Owners»; otra identidad para el agente |

`scripts/escenarios.sh` reproduce, en una copia desechable, seis formas de que un cambio con errores llegue a `main`: el commit normal que para el hook, tres formas de saltarse el hook, un comentario `eslint-disable` con y sin `noInlineConfig`, cambiar la configuración, otra configuración en una subcarpeta y cambiar el script `check`.

## Requisitos

Node.js 24.22.3 o posterior (`.node-version`), o solo Docker.

## Uso

```bash
npm ci
git config core.hooksPath .githooks   # activa el hook pre-commit
npm run check                          # lo mismo que hacen el hook y la CI
docker run --rm -v "$PWD":/app:ro node:24.22.3 sh /app/scripts/escenarios.sh
```

Probado el 13-11-2026 con Node 24.22.3, ESLint 10.14.0 y git 2.39.5 de la imagen oficial de Node. CODEOWNERS y la protección de rama dependen de la configuración del repositorio en GitHub.

## Cómo se ha hecho

Desarrollado con el enfoque [IA Limpia](https://rubentejera.com/que-es-la-ia-limpia/): un agente de IA escribe el código siguiendo los pasos del artículo, los tests validan cada paso y el resultado se revisa y se aprueba a mano antes de publicarlo.

## Licencia

MIT. Ver `LICENSE`.
