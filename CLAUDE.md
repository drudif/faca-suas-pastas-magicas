# faca-suas-pastas-magicas

Skill para uma IA de código (Claude Code ou Codex) entrevistar a pessoa e criar as pastas mágicas
dela no Mac: pasta do Desktop que processa sozinha o que cai dentro. O repositório inteiro é a skill.

## Stack
zsh + launchd (WatchPaths) + launcher em C dentro de um .app. Sem build, sem servidor.
`SKILL.md` na raiz (a entrevista e o passo a passo); base instalável em `modelo/`.

## Comandos
- `modelo/instalar.sh` — compila o .app, copia conversor e receitas, cria pastas, liga agentes
- `modelo/desinstalar.sh` — para os agentes; não apaga pasta nem arquivo
- `modelo/testar.sh <receita> <arquivo...>` — roda uma receita num HOME temporário, sem tocar no launchd
- `PASTAS_DESKTOP=<caminho> modelo/instalar.sh` — cria as pastas fora do Desktop (testes)

## Convenções
- A skill é o repositório: `git clone` dentro de `~/.claude/skills/` (ou `~/.agents/skills/`) instala.
  `SKILL.md` e `modelo/` têm de ficar lado a lado.
- A primeira mensagem da skill é sempre uma pergunta, uma por vez. Nada é instalado antes do "sim" ao resumo.
- Uma pasta = uma linha em `pastas.conf` + um arquivo em `receitas/`.
- Prefixos `minhas-pastas` / `local.minhaspastas`, para não colidir com outras automações do usuário.
- Saída em `pronto/`, original em `_originais/`, falha em `_erros/`. Nada é apagado.
- Local é o padrão; receita com serviço externo é exceção declarada, com tag vermelha.

## Armadilhas
- Nada de trava ou temporário dentro da pasta vigiada: WatchPaths redispara em loop.
- O python do launchd não é o do terminal: usar `"$PYTHON_BIN"`.
- `instalar.sh` usa `set -e`: `grep` sem resultado dentro de `$(...)` precisa de `|| true`.
- O launcher acha o `converter.sh` pelo `HOME` real do launchd: instalar com `HOME` falso não funciona.
- O `instalar.sh` real mexe no launchd; `testar.sh` só roda o `converter.sh`.

Histórico de decisões: `docs/DIARIO.md`
