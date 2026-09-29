# faca-suas-pastas-magicas

Kit distribuivel para outras pessoas criarem as proprias pastas magicas no Mac
(pasta do Desktop que processa sozinha o que cai dentro). Versao generica do
projeto `pessoal/pastas-magicas`, que e o meu conjunto pessoal de 12 pastas.

## Stack
zsh + launchd (WatchPaths) + launcher em C dentro de um .app. Sem build, sem servidor.
Skill em `skill/SKILL.md`; base instalavel em `modelo/`.

## Comandos
- `modelo/instalar.sh` — compila o .app, copia conversor e receitas, cria pastas, liga agentes
- `modelo/desinstalar.sh` — para os agentes; nao apaga pasta nem arquivo
- `modelo/testar.sh <receita> <arquivo...>` — roda uma receita num HOME temporario, sem tocar no launchd

## Convencoes
- Uma pasta = uma linha em `pastas.conf` + um arquivo em `receitas/`.
- Prefixos `minhas-pastas` / `local.minhaspastas`, para nao colidir com o
  `pastas-magicas` pessoal se os dois estiverem na mesma maquina.
- Saida em `pronto/`, original em `_originais/`, falha em `_erros/`. Nada e apagado.
- Local e o padrao; receita com API e excecao declarada, com tag vermelha.
- Repo privado por enquanto; tornar publico e decisao do dono.

## Armadilhas
- Nada de trava ou temporario dentro da pasta vigiada: WatchPaths redispara em loop.
- O python do launchd nao e o do terminal: usar `"$PYTHON_BIN"`.
- `instalar.sh` usa `set -e`: `grep` sem resultado dentro de `$(...)` precisa de `|| true`.
- O `instalar.sh` real mexe no launchd; testes automatizados so rodam o `converter.sh`.

Historico de decisoes: `docs/DIARIO.md`
