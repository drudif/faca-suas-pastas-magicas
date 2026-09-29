---
name: faca-suas-pastas-magicas
description: "Conduz a pessoa a criar as próprias pastas mágicas no Mac: pastas do Desktop que processam sozinhas o que cai dentro delas (converter vídeo, comprimir imagem, transcrever áudio, renomear, organizar — qualquer tarefa repetida). Use quando o usuário disser 'quero uma pasta que faça X sozinha', 'automatizar essa tarefa arrastando arquivo numa pasta', 'pastas mágicas', 'pasta que converte sozinha', ou pedir para criar, editar ou consertar uma pasta vigiada do launchd. Só macOS."
---

# Faça suas pastas mágicas

Uma pasta mágica é uma pasta do Desktop com uma tarefa atrelada. O arquivo cai
dentro, o Mac processa sozinho, o resultado aparece em `pronto/`. Quem dispara é o
`launchd`, o agendador do macOS; nada fica rodando entre um arquivo e outro.

Este repositório traz a base que já funciona (`modelo/`). O seu trabalho é ajudar
a pessoa a escrever **a receita** de cada pasta dela: um arquivo pequeno que diz
quais extensões a pasta aceita e o que fazer com cada arquivo.

## Como conduzir

A pessoa provavelmente não programa. Fale do incômodo (o que ela faz à mão hoje),
não da tecnologia. Explique termo técnico em uma frase quando ele for inevitável.
**Uma pergunta por mensagem.** Não instale nada antes de a pasta estar definida.

### 1. Entrevista, uma pergunta por vez

1. **O que você faz hoje, à mão, que gostaria que acontecesse sozinho?**
   Peça um exemplo concreto: "chega um vídeo do celular e eu tiro o áudio".
2. **O que cai na pasta e o que deve sair?** Tipo de arquivo de entrada, tipo de saída.
3. **Precisa de internet?** Se a tarefa exige um serviço externo (transcrição na
   nuvem, IA de terceiros), diga antes de seguir:
   - o arquivo **sai do computador** e vai para a empresa do serviço;
   - normalmente exige chave de API e **cobra por uso**;
   - a pasta é marcada de **vermelho** no Finder para lembrar disso.
   Se existir jeito local (ffmpeg, Whisper local, Pillow), ofereça primeiro.
   Local é o padrão; API é exceção declarada.
4. **Que nome a pasta leva?** Sugira o formato `entrada>>saida` (`video>>audio`).

Com as respostas, repita numa frase: *"pasta `video>>audio`: recebe mp4 e mov,
devolve mp3, roda local. Certo?"* Só avance com o sim.

### 2. Conferir a máquina

```bash
uname -m                        # arm64 (Apple Silicon) ou x86_64
sw_vers -productVersion         # macOS 12 ou mais novo
which clang codesign ffmpeg     # clang vem de: xcode-select --install
                                # ffmpeg vem de: brew install ffmpeg
```

O `clang` é usado uma vez, para compilar o launcher de 30 linhas. O ffmpeg só é
necessário se alguma receita usar. Se a tarefa pedir `mlx-whisper`, ele só roda
em Apple Silicon e baixa o modelo na primeira execução (depois funciona offline).

### 3. Preparar a cópia de trabalho

Copie `modelo/` para onde a pessoa guarda projetos (por exemplo
`~/minhas-pastas-magicas`). Ela edita a **cópia**, não o repositório.

### 4. Escrever a receita

Copie `receitas/_esqueleto.sh` para `receitas/<nome>.sh` (só minúsculas, números,
hífen e sublinhado). Preencha duas coisas:

- `EXTS_OK=(...)`: extensões aceitas, em minúscula e sem ponto;
- `processar ENTRADA SAIDADIR BASE`: faz o trabalho e grava o resultado em
  `SAIDADIR`. Retorna 0 se deu certo; qualquer outro número manda o original
  para `_erros/`.

`receitas/video2audio.sh` é um exemplo completo. Receita com parâmetro usa
dois-pontos em `pastas.conf` (`speed:1.15`) e lê `$PARAM`.

Receita com API: a chave vai em
`~/Library/Application Support/minhas-pastas/.env` (`NOME=valor`) e chega à
receita como variável de ambiente. **Nunca peça a chave no chat**: mande a pessoa
abrir o arquivo (`open -e <caminho>`) e colar lá. Se a chave vazar em texto,
ela precisa ser trocada no site do serviço.

Receita em Python: use `"$PYTHON_BIN" script.py`, nunca `python3` solto, e liste
os módulos em `python-requisitos.txt`.

### 5. Testar antes de instalar

```bash
./testar.sh <receita> <arquivo de exemplo> [outro arquivo...]
```

O script roda a receita numa pasta temporária, sem instalar nada e sem mexer no
que já está ligado, e mostra onde cada arquivo foi parar (`pronto/`, `_erros/`,
`_originais/`) e o log. Os arquivos de exemplo originais ficam intactos.
Abra o resultado e confira o conteúdo. Teste **também um arquivo que deve
falhar**: é ele que prova que `_erros/` funciona.

### 6. Instalar

Acrescente uma linha em `pastas.conf`: `nome-da-pasta|receita|tag`, com `vermelha`
na tag se a receita usa API. Depois:

```bash
./instalar.sh
```

O instalador é idempotente. Rodar de novo só recarrega; é o que se faz depois de
editar qualquer receita, porque o agente lê a cópia em `Application Support`, não a
sua pasta de trabalho.

### 7. Verificar que funciona

**Não confie no código de saída do instalador.** Solte um arquivo na pasta e olhe o log:

```bash
tail -f ~/Library/Logs/minhas-pastas.log
```

Em segundos deve aparecer `processando` e `ok: pronto/...`. Abra o resultado e
confira o conteúdo, não só a existência do arquivo.

Se aparecer `Operation not permitted`, o macOS bloqueou o Desktop. Ajustes do
Sistema > Privacidade e Segurança > Acesso total ao disco > botão + > escolha
`~/Library/Application Support/minhas-pastas/MinhasPastas.app`.

## Armadilhas (cada uma já custou horas)

| Sintoma | Causa | Regra |
|---|---|---|
| Pasta se altera sozinha a cada 10 s | receita escreveu trava ou temporário dentro da pasta vigiada | nada de trabalho interno na pasta; o `converter.sh` já usa `Application Support` |
| Arquivo convertido de novo, sem parar | saída caiu na pasta vigiada com extensão que a pasta também aceita | saída sempre vai para `pronto/`, e o `converter.sh` faz isso |
| `No module named ...` | o python do launchd não é o do terminal | `python-requisitos.txt` + `"$PYTHON_BIN"` |
| `Operation not permitted` | TCC bloqueou `~/Desktop` | liberar o `.app`, nunca o `/bin/zsh` |
| Arquivo processado pela metade | o arquivo ainda estava sendo copiado | o `converter.sh` espera o tamanho parar de mudar |
| mp3 com 32 kbps | `-q:a` do libmp3lame no ffmpeg 8 | use `-b:a 320k` |
| `subtitles` do ffmpeg falha | ffmpeg do Homebrew sem libass | desenhe a legenda com Pillow |

Nenhum arquivo é apagado: o original vai para `_originais/`, o que falhou vai
para `_erros/`, o resultado fica em `pronto/`.

## Ideias para começar

| Pasta | O que faz | Roda local? |
|---|---|---|
| `video>>audio` | tira o áudio e entrega mp3 | sim |
| `video>>gif` | vira gif com paleta otimizada | sim |
| `video>>1.15x` | acelera sem mudar o tom | sim |
| `video>>semsilencio` | corta as pausas | sim |
| `video>>volumecerto` | normaliza o volume em -14 LUFS | sim |
| `video>>transcricao` | transcreve com Whisper | sim, com `mlx-whisper` em Apple Silicon |
| `imagem>>leve` | comprime e redimensiona | sim |
| `pdf>>texto` | extrai o texto | sim |
| `audio>>limpo` | isola a voz (ElevenLabs) | **não**: API, o arquivo sai do computador |
| `video>>melhorestrechos` | escolhe os melhores cortes (Gemini) | **não**: API, o arquivo sai do computador |

## Desinstalar

```bash
./desinstalar.sh     # para e remove os agentes; não apaga pasta nem arquivo
rm -rf ~/Library/Application\ Support/minhas-pastas   # apaga a instalação e as chaves
```
