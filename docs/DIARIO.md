# Diario — faca-suas-pastas-magicas

Historico de decisoes. Nao e carregado em toda sessao — lido sob demanda, pode crescer.
Entrada nova no topo, com data.

---

## 2026-09-30 — o repositorio virou a skill, e a skill passou a entrevistar

- **O repositorio e a skill.** `SKILL.md` foi da subpasta `skill/` para a raiz, ao lado de `modelo/`. Motivo: com a skill
  separada da base, ligar so o `SKILL.md` (como o README mandava) deixava o agente sem `modelo/`. Na raiz, um `git clone`
  dentro de `~/.claude/skills/` (ou `~/.agents/skills/`, no Codex) instala tudo de uma vez, e "Instale a seguinte skill:
  github.com/..." funciona com um clone.
- **Entrevista como regra numero 1.** A primeira mensagem ao ser ativada e uma pergunta; uma por vez, opcoes numeradas,
  recomendacao primeiro; o que a pessoa ja disse nao se pergunta de novo; quem nao sabe o que pedir ve a lista de ideias;
  nada e instalado antes do "sim" ao resumo. Local x nuvem so vira pergunta quando a tarefa exige servico externo.
- **`PASTAS_DESKTOP`** permite instalar as pastas fora do Desktop. Serve aos testes: instalar no Desktop real exige liberar
  "Acesso total ao disco" ao `.app`, que so a pessoa consegue fazer.
- **Licenca MIT**, titular Fernando Drudi (escolha do autor, 2026-09-30): sem licenca, os outros nao poderiam reutilizar o codigo.
- **Compatibilidade com o Codex:** a documentacao da OpenAI diz que o Codex usa skills em `SKILL.md` com `name` e
  `description`, guarda as pessoais em `$HOME/.agents/skills` e tem o `$skill-installer`.

---

## 2026-09-29 — kit generico criado a partir do pastas-magicas

Origem: um conjunto pessoal de 12 pastas que convertem sozinhas o que cai dentro delas.
Ele e pessoal e nao serve de kit. Este repo e a versao generica: uma base e uma skill
que conduz a pessoa a escrever a propria receita.

Decisoes:

- **Receita por arquivo.** No original, os modos moram num `case` do
  `converter.sh` e num `ferramentas.py` de 30 KB. Aqui cada pasta e um arquivo em
  `receitas/` com `EXTS_OK` e `processar()`. O conversor nao muda quando a pessoa
  cria uma pasta nova.
- **Prefixos proprios** (`minhas-pastas`, `local.minhaspastas`) para coexistir com outras
  automacoes do usuario na mesma maquina.
- **Local e o padrao, API e excecao declarada.** A skill avisa que o arquivo sai
  do computador e que ha custo, e marca a pasta de vermelho. Motivo: algumas
  tarefas so existem em servico externo (ElevenLabs, Gemini), entao "tudo local" seria falso.
- **`testar.sh`** existe porque testar uma receita sem instalar exigia montar um
  HOME falso a mao, o que uma pessoa que nao programa nao faz.

Verificado (converter.sh, em HOME temporario): video com audio virou mp3 em
`pronto/` e o original foi para `_originais/`; video sem audio foi para `_erros/`;
nome de receita `../x` foi recusado; `testar.sh` rodou de ponta a ponta. Dois
defeitos achados no teste e corrigidos: `grep` sem resultado matava o `instalar.sh`
sob `set -e`; o `trap` de limpeza usava um glob que quebrava o zsh.

Nao verificado: `instalar.sh` de ponta a ponta (compila o .app, assina, carrega
LaunchAgent, aplica tag). Ele mexe no launchd da maquina; so a sintaxe e a
compilacao do launcher foram checadas. Tambem nao testado: a skill conduzindo uma
conversa real com alguem que nao programa.
