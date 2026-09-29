#!/bin/zsh
# Instala (ou reinstala) as suas pastas magicas:
#   1. compila o MinhasPastas.app (executavel proprio, por causa do TCC)
#   2. copia converter.sh e receitas/ para fora do Desktop
#   3. cria as pastas que faltam e marca de vermelho as que usam API
#   4. cria um LaunchAgent por pasta vigiada
# Idempotente: rodar de novo so recarrega. Faca isso depois de editar receita.
set -e
AQUI="${0:A:h}"
DESK="$HOME/Desktop"
BASE="$HOME/Library/Application Support/minhas-pastas"
APP="$BASE/MinhasPastas.app"
AGENTS="$HOME/Library/LaunchAgents"
LOGDIR="$HOME/Library/Logs"

for cmd in clang codesign launchctl plutil; do
  command -v "$cmd" >/dev/null || { echo "faltando: $cmd (rode: xcode-select --install)"; exit 1; }
done
mkdir -p "$BASE" "$AGENTS" "$LOGDIR"

# --- 1. app bundle -----------------------------------------------------------
mkdir -p "$APP/Contents/MacOS"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>MinhasPastas</string>
  <key>CFBundleDisplayName</key><string>Minhas Pastas</string>
  <key>CFBundleIdentifier</key><string>local.minhaspastas</string>
  <key>CFBundleExecutable</key><string>minhas-pastas</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSBackgroundOnly</key><true/>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
</dict>
</plist>
PLIST
clang -O2 -o "$APP/Contents/MacOS/minhas-pastas" "$AQUI/launcher.c"
codesign --force --sign - --identifier local.minhaspastas "$APP" 2>/dev/null
echo "app: $APP"

# --- 2. scripts (fora do Desktop, fora do bundle) ----------------------------
cp -f "$AQUI/converter.sh" "$BASE/converter.sh"
chmod +x "$BASE/converter.sh"
rm -rf "$BASE/receitas"
cp -R "$AQUI/receitas" "$BASE/receitas"

# Qual python tem os modulos das suas receitas? O PATH do launchd nao resolve
# isso sozinho. Liste os modulos, um por linha, em python-requisitos.txt.
# Sem arquivo (ou vazio), fica o /usr/bin/python3.
PY_OK=""
MODULOS=()
# "|| true": grep sai com 1 quando nao sobra linha, e o set -e mataria o script
if [ -f "$AQUI/python-requisitos.txt" ]; then
  MODULOS=(${(f)"$(grep -v '^\s*#' "$AQUI/python-requisitos.txt" | grep -v '^\s*$' || true)"})
fi
for py in /usr/bin/python3 /opt/homebrew/bin/python3 /usr/local/bin/python3 "$(command -v python3)"; do
  [ -x "$py" ] || continue
  ok=1
  for m in $MODULOS; do "$py" -c "import $m" >/dev/null 2>&1 || { ok=0; break; }; done
  if [ "$ok" = 1 ]; then PY_OK="$py"; break; fi
done
if [ -n "$PY_OK" ]; then
  print -r -- "$PY_OK" > "$BASE/python-bin"
  echo "python: $PY_OK"
else
  print -r -- "/usr/bin/python3" > "$BASE/python-bin"
  echo "aviso: nenhum python importa todos estes modulos: $MODULOS"
  echo "       instale com: /usr/bin/python3 -m pip install --user $MODULOS"
fi

if [ ! -f "$BASE/.env" ]; then
  cat > "$BASE/.env" <<'ENV'
# Chaves de API das pastas marcadas de vermelho. Formato: NOME=valor
# Este arquivo mora fora do Desktop e fora do git. Nunca cole chave em chat.

ENV
  chmod 600 "$BASE/.env"
  echo "criado: $BASE/.env (vazio)"
fi

# --- 3 e 4. pastas, tags e agentes -------------------------------------------
vermelhas=()
while IFS='|' read -r pasta receita tag; do
  [[ -z "$pasta" || "$pasta" == \#* ]] && continue
  [ -f "$AQUI/receitas/${receita%%:*}.sh" ] || { echo "receita nao existe: $receita (pasta $pasta)"; exit 1; }
  alvo="$DESK/$pasta"
  [ -d "$alvo" ] || { mkdir -p "$alvo"; echo "pasta criada: $pasta"; }

  [ "$tag" = "vermelha" ] && vermelhas+=("$alvo")

  label="local.minhaspastas.${receita//[:.]/-}"
  plist="$AGENTS/$label.plist"

  cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$APP/Contents/MacOS/minhas-pastas</string>
    <string>$receita</string>
    <string>$alvo</string>
  </array>
  <key>WatchPaths</key>
  <array><string>$alvo</string></array>
  <key>RunAtLoad</key><true/>
  <key>ThrottleInterval</key><integer>10</integer>
  <key>StandardOutPath</key><string>$LOGDIR/minhas-pastas.out.log</string>
  <key>StandardErrorPath</key><string>$LOGDIR/minhas-pastas.err.log</string>
</dict>
</plist>
PLIST

  plutil -lint "$plist" >/dev/null
  launchctl bootout "gui/$UID/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$UID" "$plist"
  echo "no ar: $pasta  ->  $receita"
done < "$AQUI/pastas.conf"

if (( ${#vermelhas} )); then
  python3 "$AQUI/tag-finder.py" vermelho "${vermelhas[@]}"
  echo "tag vermelha: ${#vermelhas} pastas (mandam arquivo para fora)"
fi

cat <<FIM

Pronto. Log: tail -f ~/Library/Logs/minhas-pastas.log

Se o log mostrar "Operation not permitted": Ajustes do Sistema > Privacidade e
Seguranca > Acesso total ao disco > botao +, e escolha
  $APP
FIM
