#!/bin/zsh
# Para e remove os LaunchAgents. Nao apaga arquivo nenhum das pastas,
# nem as pastas, nem as chaves em .env.
AQUI="${0:A:h}"
AGENTS="$HOME/Library/LaunchAgents"
while IFS='|' read -r pasta receita tag; do
  [[ -z "$pasta" || "$pasta" == \#* ]] && continue
  label="local.minhaspastas.${receita//[:.]/-}"
  launchctl bootout "gui/$UID/$label" 2>/dev/null && echo "parado: $label"
  rm -f "$AGENTS/$label.plist"
done < "$AQUI/pastas.conf"
echo "removido. As pastas e os arquivos continuam onde estao."
