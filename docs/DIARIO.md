# Diario — faca-suas-pastas-magicas

Historico de decisoes. Nao e carregado em toda sessao — lido sob demanda, pode crescer.
Entrada nova no topo, com data.

---

## 2026-09-29 — kit generico criado a partir do pastas-magicas

Origem: o carrossel "pastas magicas" (ver `conteudo/carrossel-pastas-magicas`)
promete que a pessoa instala e depois tudo roda local. O repo `pastas-magicas`
e privado e tem as 12 pastas pessoais, entao nao serve de kit. Este repo e a
versao generica: uma base e uma skill que conduz a pessoa a escrever a propria receita.

Decisoes:

- **Receita por arquivo.** No original, os modos moram num `case` do
  `converter.sh` e num `ferramentas.py` de 30 KB. Aqui cada pasta e um arquivo em
  `receitas/` com `EXTS_OK` e `processar()`. O conversor nao muda quando a pessoa
  cria uma pasta nova.
- **Prefixos proprios** (`minhas-pastas`, `local.minhaspastas`) para coexistir com o
  `pastas-magicas` pessoal na mesma maquina.
- **Local e o padrao, API e excecao declarada.** A skill avisa que o arquivo sai
  do computador e que ha custo, e marca a pasta de vermelho. Motivo: 2 das 12 pastas
  do original usam ElevenLabs e Gemini, entao "tudo local" seria falso.
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
