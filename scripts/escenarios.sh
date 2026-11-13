#!/bin/sh
# Uso: docker run --rm -v "$PWD":/app:ro node:24.22.2 sh /app/scripts/escenarios.sh
# Cuatro formas de que un cambio con errores de lint llegue a main, en una copia desechable.
cp -r /app /work && cd /work && rm -rf .git
[ -d node_modules ] || npm ci --no-audit --no-fund --silent
git init -q -b main && git config user.email a@example.com && git config user.name Ejemplo && git config core.hooksPath .githooks
git add -A && git commit -qm base --no-verify
trazar() {
  sed -i "3i\\  console.log('precioFinal', totalEnCentimos, esSocio);" src/descuento.js
  sed -i "s/if (esSocio \&\& /if (esSocio == true \&\& /" src/descuento.js
}
echo "=== A: git commit (el hook se ejecuta)"
trazar; git add -A
git commit -m "Añade una traza" > /tmp/a.txt 2>&1; echo "salida de git commit: $?"; grep -E "  error|problems" /tmp/a.txt; echo "commits: $(git rev-list --count HEAD)"
echo "=== B: git commit --no-verify"
git commit -qm "Añade una traza" --no-verify; echo "salida de git commit: $?; commits: $(git rev-list --count HEAD)"
echo "--- la CI, con el mismo npm run check:"
npm run check --silent > /tmp/b.txt 2>&1; echo "salida: $?"; grep -E "  error|problems" /tmp/b.txt
echo "=== C: un comentario que apaga las reglas"
sed -i "3i\\  // eslint-disable-next-line no-console, eqeqeq" src/descuento.js
npx eslint . 2>&1 | grep -E "  error|  warning|problems"
git checkout -q -- src
echo "=== D: cambiar la configuración"
sed -i "s|      eqeqeq: 'error',|      eqeqeq: 'off',|; s|      'no-console': 'error',|      'no-console': 'off',|" eslint.config.js
npm run check --silent > /dev/null 2>&1; echo "salida de npm run check: $?"; git diff --stat HEAD
