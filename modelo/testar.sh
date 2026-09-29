#!/bin/zsh
# Testa uma receita sem instalar nada e sem tocar nos agentes do launchd.
#   ./testar.sh <receita> <arquivo> [arquivo...]
# Usa um HOME temporario, copia os arquivos de teste (os originais ficam
# intactos) e mostra onde cada um foi parar, mais o log.
AQUI="${0:A:h}"
RECEITA="$1"; shift
[ -z "$RECEITA" ] || [ $# -eq 0 ] && { echo "uso: $0 <receita> <arquivo> [arquivo...]"; exit 1; }
[ -f "$AQUI/receitas/${RECEITA%%:*}.sh" ] || { echo "receita nao existe: receitas/${RECEITA%%:*}.sh"; exit 1; }

T="$(mktemp -d /tmp/teste-pasta.XXXXXX)"
B="$T/home/Library/Application Support/minhas-pastas"
mkdir -p "$B" "$T/home/Library/Logs" "$T/pasta"
cp "$AQUI/converter.sh" "$B/converter.sh"
cp -R "$AQUI/receitas" "$B/receitas"
[ -f "$HOME/Library/Application Support/minhas-pastas/.env" ] && cp "$HOME/Library/Application Support/minhas-pastas/.env" "$B/.env"
for f in "$@"; do cp "$f" "$T/pasta/"; done

HOME="$T/home" zsh "$B/converter.sh" "$RECEITA" "$T/pasta"

echo "--- resultado (pronto = deu certo, _erros = falhou, _originais = arquivo de entrada guardado)"
(cd "$T/pasta" && find . -type f | sort)
echo "--- log"
cat "$T/home/Library/Logs/minhas-pastas.log" 2>/dev/null
echo "--- pasta de teste: $T (apague quando quiser: rm -rf $T)"
