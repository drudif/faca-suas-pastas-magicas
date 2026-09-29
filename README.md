# Faça suas pastas mágicas

Pastas do Desktop que processam sozinhas o que cai dentro delas. Você arrasta um
vídeo para `video>>audio`, e o mp3 aparece em `pronto/`. Nada de abrir programa.

Este repositório tem duas partes:

- **`modelo/`**: a base que funciona no macOS (launcher, conversor, instalador) com
  uma pasta de exemplo, `video>>audio`.
- **`skill/SKILL.md`**: instruções para uma IA (Claude Code) conduzir você a criar as
  suas próprias pastas: entrevista, receita, teste, instalação e verificação.

## Como usar

1. Instale o [Claude Code](https://claude.com/claude-code).
2. Clone este repositório e ative a skill:

   ```bash
   git clone <endereço deste repositório> ~/faca-suas-pastas-magicas
   mkdir -p ~/.claude/skills/faca-suas-pastas-magicas
   ln -s ~/faca-suas-pastas-magicas/skill/SKILL.md ~/.claude/skills/faca-suas-pastas-magicas/SKILL.md
   ```

3. Abra o Claude Code dentro da pasta clonada e diga o que quer automatizar:
   *"quero uma pasta que comprime as fotos que eu jogar nela"*.

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

## Sem a skill

```bash
cd modelo
./instalar.sh     # cria ~/Desktop/video>>audio e liga o agente
```

Solte um vídeo em `~/Desktop/video>>audio` e acompanhe:
`tail -f ~/Library/Logs/minhas-pastas.log`. Para uma pasta nova, copie
`receitas/_esqueleto.sh`, preencha, teste com `./testar.sh <receita> <arquivo>`,
acrescente uma linha em `pastas.conf` e rode `./instalar.sh` de novo.

## Como funciona

| Peça | Papel |
|---|---|
| `launchd` (`WatchPaths`) | o macOS avisa quando a pasta muda |
| `MinhasPastas.app` | executável próprio, porque o macOS bloqueia o Desktop para scripts soltos |
| `converter.sh` | varre a pasta, espera a cópia terminar, chama a receita |
| `receitas/*.sh` | o que cada pasta faz |

Original em `_originais/`, resultado em `pronto/`, falha em `_erros/`. Nenhum
arquivo é apagado.

Desinstalar: `./desinstalar.sh` (não apaga pastas nem arquivos).
