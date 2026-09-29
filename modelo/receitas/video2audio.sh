# Receita de exemplo: tira o audio de um video e entrega em mp3.
# Roda 100% local (ffmpeg). Serve de modelo para as suas.

EXTS_OK=(mp4 mov m4v mkv avi webm)

processar() {
  local entrada="$1" saidadir="$2" base="$3"

  # sem faixa de audio nao ha o que extrair: falha e o arquivo vai para _erros
  if [ -z "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$entrada" 2>/dev/null)" ]; then
    print -r -- "sem faixa de audio: $entrada" >&2
    return 1
  fi

  # -b:a e nao -q:a: no ffmpeg 8 o -q:a do libmp3lame produz 32kbps
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "$entrada" \
    -vn -map 0:a:0 -c:a libmp3lame -b:a 320k "$saidadir/$base.mp3"
}
