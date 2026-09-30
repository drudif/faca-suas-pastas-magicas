# Faça suas pastas mágicas

Pastas do Desktop que processam sozinhas o que cai dentro delas. Você arrasta um
vídeo para `video>>audio`, e o mp3 aparece em `pronto/`. Nada de abrir programa.

Este repositório é uma **skill**: um manual que ensina uma IA de código (Claude Code
ou Codex) a criar as pastas para você. Ela **entrevista você**, uma pergunta por
vez ("o que você faz hoje à mão?", "o que entra e o que sai?"), escreve a receita
de cada pasta, testa e instala. Você não precisa saber programar.

## Como usar

1. Peça ao seu agente de código:

   > Instale a seguinte skill: github.com/drudif/faca-suas-pastas-magicas

   Ou, à mão, clone o repositório **dentro da pasta de skills** do seu agente:

   ```bash
   # Claude Code
   git clone https://github.com/drudif/faca-suas-pastas-magicas ~/.claude/skills/faca-suas-pastas-magicas

   # Codex
   git clone https://github.com/drudif/faca-suas-pastas-magicas ~/.agents/skills/faca-suas-pastas-magicas
   ```

2. Diga o que você quer, do jeito que vier: *"quero criar uma pasta mágica"*, *"uma
   pasta que comprime as fotos que eu jogar nela"*. Se você não sabe o que pedir, a
   skill mostra ideias e pergunta qual se parece com o seu dia.

A IA e a internet são necessárias só nesta etapa, para montar e instalar. Depois
disso a pasta roda sozinha no seu Mac, sem chamar IA e sem custo por uso, e os
arquivos não saem do computador. **A exceção são as receitas que você mesmo decidir
ligar a um serviço externo** (transcrição na nuvem, por exemplo): a skill avisa
antes, pede chave própria e marca essa pasta de vermelho no Finder.

## Requisitos

- macOS 12 ou mais novo
- Command Line Tools (`xcode-select --install`)
- Para as receitas de vídeo e áudio: `brew install ffmpeg`
- Receitas com Whisper local (`mlx-whisper`) exigem Apple Silicon e baixam o modelo
  uma vez, na primeira execução
- No primeiro uso, o macOS pode bloquear o Desktop: Ajustes do Sistema > Privacidade e
  Segurança > Acesso total ao disco, e liberar o `MinhasPastas.app`. A skill conduz esse passo.

## Sem a skill

```bash
cd modelo
./instalar.sh     # cria ~/Desktop/video>>audio e liga o agente
```

Solte um vídeo em `~/Desktop/video>>audio` e acompanhe:
`tail -f ~/Library/Logs/minhas-pastas.log`. Para uma pasta nova, copie
`receitas/_esqueleto.sh`, preencha, teste com `./testar.sh <receita> <arquivo>`,
acrescente uma linha em `pastas.conf` e rode `./instalar.sh` de novo.
`PASTAS_DESKTOP=<caminho> ./instalar.sh` cria as pastas em outro lugar que não o Desktop.

## Como funciona

| Peça | Papel |
|---|---|
| `SKILL.md` | a entrevista e o passo a passo que a IA segue |
| `launchd` (`WatchPaths`) | o macOS avisa quando a pasta muda |
| `MinhasPastas.app` | executável próprio, porque o macOS bloqueia o Desktop para scripts soltos |
| `converter.sh` | varre a pasta, espera a cópia terminar, chama a receita |
| `receitas/*.sh` | o que cada pasta faz |

Original em `_originais/`, resultado em `pronto/`, falha em `_erros/`. Nenhum
arquivo é apagado.

Desinstalar: `./desinstalar.sh` (não apaga pastas nem arquivos).

## Licença

MIT. Veja o arquivo `LICENSE`.
