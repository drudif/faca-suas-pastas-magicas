#!/bin/zsh
# Processa tudo que cai numa pasta vigiada. Chamado pelo LaunchAgent.
#   converter.sh <receita>[:parametro] <pasta>
#
# A receita e um arquivo em receitas/<nome>.sh que define duas coisas:
#   EXTS_OK=(mp4 mov ...)     extensoes que a pasta aceita
#   processar ENTRADA SAIDADIR BASE   faz o trabalho; tudo que produzir
#                                     vai para SAIDADIR; retorna 0 se deu certo
#
# REGRA DE OURO: nada de trabalho interno (trava, temporario) pode ser escrito
# dentro da pasta vigiada. Qualquer escrita ali altera a pasta e redispara o
# WatchPaths, criando loop infinito. Isso tudo mora em $BASE.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

RECEITA_FULL="$1"
PASTA="$2"
BASE="$HOME/Library/Application Support/minhas-pastas"
LOG="$HOME/Library/Logs/minhas-pastas.log"

RECEITA="${RECEITA_FULL%%:*}"      # speed:1.15 -> speed
PARAM="${RECEITA_FULL#*:}"         # speed:1.15 -> 1.15
[ "$PARAM" = "$RECEITA_FULL" ] && PARAM=""
export PARAM

[ -z "$RECEITA" ] || [ -z "$PASTA" ] && { echo "uso: $0 <receita> <pasta>"; exit 1; }
[ -d "$PASTA" ] || { echo "pasta nao existe: $PASTA"; exit 1; }
# so letras minusculas, numeros, hifen e sublinhado: impede sair de receitas/
[[ "$RECEITA" =~ ^[a-z0-9_-]+$ ]] || { echo "nome de receita invalido: $RECEITA"; exit 1; }

log() { print -r -- "$(date '+%Y-%m-%d %H:%M:%S') [$RECEITA_FULL] $*" >> "$LOG"; }

# O PATH do launchd resolve python3 para o do Homebrew, que nao tem os seus
# modulos. O interpretador certo e gravado pelo instalar.sh.
PYTHON_BIN="/usr/bin/python3"
[ -f "$BASE/python-bin" ] && PYTHON_BIN="$(cat "$BASE/python-bin")"
export PYTHON_BIN

# chaves de API, se existirem, ficam disponiveis como variaveis para a receita
if [ -f "$BASE/.env" ]; then set -a; source "$BASE/.env"; set +a; fi

ARQ_RECEITA="$BASE/receitas/$RECEITA.sh"
[ -f "$ARQ_RECEITA" ] || { log "receita nao encontrada: $RECEITA"; exit 1; }

NOTIFICAR=1
EXTS_OK=()
source "$ARQ_RECEITA"
(( ${#EXTS_OK} )) || { log "receita sem EXTS_OK: $RECEITA"; exit 1; }
typeset -f processar >/dev/null || { log "receita sem funcao processar: $RECEITA"; exit 1; }

notificar() {
  [ "$NOTIFICAR" = "1" ] || return 0
  osascript -e "display notification \"$1\" with title \"$2\"" >/dev/null 2>&1 || true
}

mkdir -p "$BASE/travas" "$BASE/tmp"

# --- trava: uma execucao por receita, FORA da pasta vigiada -------------------
TRAVA="$BASE/travas/${RECEITA_FULL//[:\/]/_}.lock"
if ! mkdir "$TRAVA" 2>/dev/null; then
  if [ -n "$(find "$TRAVA" -maxdepth 0 -mmin +240 2>/dev/null)" ]; then
    rmdir "$TRAVA" 2>/dev/null && mkdir "$TRAVA" 2>/dev/null || exit 0
  else
    exit 0
  fi
fi
trap 'rmdir "$TRAVA" 2>/dev/null; rm -rf "$BASE/tmp/run-$$"-*(N) 2>/dev/null' EXIT INT TERM

# arquivo so esta pronto quando o tamanho para de mudar (copia ainda em curso)
estavel() {
  local f="$1" a b i
  a=$(stat -f %z "$f" 2>/dev/null) || return 1
  for i in {1..30}; do
    sleep 1
    b=$(stat -f %z "$f" 2>/dev/null) || return 1
    [ "$a" = "$b" ] && [ "$b" -gt 0 ] && return 0
    a="$b"
  done
  return 1
}

nome_livre() {
  local dir="$1" base="$2" ext="$3" n=1 alvo
  if [ -n "$ext" ]; then alvo="$dir/$base.$ext"; else alvo="$dir/$base"; fi
  while [ -e "$alvo" ]; do
    if [ -n "$ext" ]; then alvo="$dir/$base-$n.$ext"; else alvo="$dir/$base-$n"; fi
    n=$((n+1))
  done
  print -r -- "$alvo"
}

guardar() {
  local arq="$1" destino="$PASTA/$2"
  mkdir -p "$destino"
  mv -f "$arq" "$destino/"
}

# --- varredura: repete ate nao sobrar nada ------------------------------------
while true; do
  fez_algo=0

  for arq in "$PASTA"/*(.N); do
    nome="${arq:t}"
    [[ "$nome" == .* ]] && continue
    ext="${${nome:e}:l}"
    base="${nome:r}"
    [[ -z "$ext" ]] && continue
    (( ${EXTS_OK[(Ie)$ext]} )) || continue

    if ! estavel "$arq"; then
      log "ainda copiando, deixo pra proxima: $nome"
      continue
    fi

    saidadir="$BASE/tmp/run-$$-${RANDOM}"
    rm -rf "$saidadir"; mkdir -p "$saidadir"

    log "processando: $nome"
    if processar "$arq" "$saidadir" "$base" 2>>"$LOG" && [ -n "$(ls -A "$saidadir" 2>/dev/null)" ]; then
      produzidos=()
      mkdir -p "$PASTA/pronto"
      for out in "$saidadir"/*(.N); do
        destino=$(nome_livre "$PASTA/pronto" "${out:t:r}" "${out:t:e}")
        mv -f "$out" "$destino"
        produzidos+=("${destino:t}")
      done
      guardar "$arq" "_originais"
      log "ok: pronto/${(j: pronto/:)produzidos}"
      notificar "${(j:, :)produzidos}" "pronto"
    else
      guardar "$arq" "_erros"
      log "FALHOU: $nome -> _erros"
      notificar "falhou: $nome" "minhas-pastas"
    fi
    rm -rf "$saidadir"
    fez_algo=1
  done

  [ "$fez_algo" -eq 0 ] && break
done

exit 0
