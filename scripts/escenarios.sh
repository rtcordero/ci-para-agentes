#!/bin/sh
# Uso: docker run --rm -v "$PWD":/app:ro node:24.22.3 sh /app/scripts/escenarios.sh
# Formas de que un cambio con errores de lint llegue a main, en una copia desechable.
cp -r /app /work && cd /work && rm -rf .git
[ -d node_modules ] || npm ci --no-audit --no-fund --silent
git init -q -b main && git config user.email a@example.com && git config user.name Ejemplo && git config core.hooksPath .githooks
git add -A && git commit -qm base --no-verify
original=$(cat src/descuento.js)
restaurar() { git reset -q --hard "$1"; git clean -qfd src; }
trazar() {
  sed -i "3i\\  console.log('precioFinal', totalEnCentimos, esSocio);" src/descuento.js
  sed -i "s/if (esSocio \&\& /if (esSocio == true \&\& /" src/descuento.js
}
check() { npm run check --silent > /tmp/check.txt 2>&1; echo "npm run check: salida $?"; grep -E "  (error|warning)|problems" /tmp/check.txt | sed 's/  \+/  /g'; }

echo "=== A: git commit, con el hook activo"
trazar; git add -A
git commit -m "Añade una traza" > /tmp/a.txt 2>&1; echo "git commit: salida $?; commits: $(git rev-list --count HEAD)"
grep -E "  error|problems" /tmp/a.txt | sed 's/  \+/  /g'

echo "=== B: tres formas de saltarse el hook"
git commit -qm "Añade una traza" --no-verify; echo "git commit --no-verify: salida $?; commits: $(git rev-list --count HEAD)"
restaurar HEAD~1; trazar; git add -A
git commit -qm "Añade una traza" -n; echo "git commit -n: salida $?; commits: $(git rev-list --count HEAD)"
restaurar HEAD~1; trazar; git add -A
git -c core.hooksPath=/dev/null commit -qm "Añade una traza"; echo "git -c core.hooksPath=/dev/null commit: salida $?; commits: $(git rev-list --count HEAD)"
echo "--- lo que ejecuta la CI:"; check
restaurar HEAD~1

echo "=== C: un comentario que apaga las reglas en todo el fichero"
trazar; sed -i "1i/* eslint-disable no-console, eqeqeq */" src/descuento.js
echo "--- con noInlineConfig:"; check
sed -i "s|    linterOptions: { noInlineConfig: true },||" eslint.config.js
echo "--- sin noInlineConfig:"; check
restaurar HEAD

echo "=== D: cambiar la configuración"
trazar
sed -i "s|      eqeqeq: 'error',|      eqeqeq: 'off',|; s|      'no-console': 'error',|      'no-console': 'off',|" eslint.config.js
check; echo "ficheros cambiados: $(git diff --name-only | tr "\n" " ")"
restaurar HEAD

echo "=== E: otra configuración en una subcarpeta"
trazar
printf "export default [{ rules: { eqeqeq: 'off', 'no-console': 'off' } }];\n" > src/eslint.config.js
check; git status --short src
restaurar HEAD

echo "=== F: cambiar lo que ejecuta el check"
trazar
sed -i 's|"check": "npm run lint \&\& npm test"|"check": "npm test"|' package.json
check; echo "ficheros cambiados: $(git diff --name-only | tr "\n" " ")"
