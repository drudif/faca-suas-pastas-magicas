# Esqueleto de receita. Copie para receitas/<nome>.sh (so minusculas, numeros,
# hifen e sublinhado) e preencha. Arquivos que comecam com _ nunca sao usados.

# Extensoes que a pasta aceita, em minuscula e sem ponto.
EXTS_OK=(mp4 mov)

# Chamada uma vez por arquivo.
#   $1  arquivo de entrada (dentro da pasta vigiada)
#   $2  diretorio de saida, temporario e fora da pasta vigiada
#   $3  nome do arquivo sem extensao
# Grave o resultado em $2. Retorne 0 se deu certo, qualquer outro numero se
# falhou (o original vai para _erros/). Mensagens de erro vao para stderr:
# aparecem no log.
#
# Disponiveis: $PARAM (o que vem depois de ":" em pastas.conf) e as chaves de
# ~/Library/Application Support/minhas-pastas/.env como variaveis.
# Python: use "$PYTHON_BIN" script.py, nunca "python3" solto.
processar() {
  local entrada="$1" saidadir="$2" base="$3"
  # exemplo: copia o arquivo sem mudar nada
  cp "$entrada" "$saidadir/$base.${entrada:e}"
}
