#!/usr/bin/env bash
# Publica este site no GitHub Pages em datainova/jym
# Uso:  bash publicar.sh
set -euo pipefail
cd "$(dirname "$0")"
REPO="datainova/jym"

command -v gh >/dev/null || { echo "Falta o GitHub CLI. Instale com:  brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Faça login primeiro:  gh auth login"; exit 1; }

echo "→ preparando o repositório local"
[ -d .git ] || git init -q -b main
git add -A
git diff --cached --quiet || git commit -q -m "Apresentação e protótipos do sistema — JYM Câmara Fria"

if gh repo view "$REPO" >/dev/null 2>&1; then
  echo "→ repositório já existe, enviando"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$REPO.git"
  git push -u origin main
else
  echo "→ criando $REPO"
  gh repo create "$REPO" --public --source=. --remote=origin --push
fi

echo "→ ligando o GitHub Pages"
gh api --method POST "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  || gh api --method PUT "repos/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  || echo "  (não consegui ligar por aqui — ative em Settings › Pages, branch main, pasta /root)"

OWNER="${REPO%%/*}"; NAME="${REPO##*/}"
echo
echo "Pronto. Em 1 a 2 minutos o endereço fica no ar:"
echo "   https://$OWNER.github.io/$NAME/"
