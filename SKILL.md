---
name: faca-suas-pastas-magicas
description: "Entrevista a pessoa e cria, com ela, as pastas mágicas dela no Mac: pastas do Desktop que processam sozinhas o que cai dentro (converter vídeo, virar gif, tirar áudio, acelerar, cortar silêncio, transcrever, comprimir imagem, renomear, organizar — qualquer tarefa repetida). Use quando a pessoa disser 'quero uma pasta que faça X sozinha', 'quero automatizar uma tarefa', 'pastas mágicas', 'pasta que converte sozinha', 'quero criar uma pasta mágica', mesmo sem saber o que pedir, ou pedir para criar, editar ou consertar uma pasta vigiada do launchd. A primeira coisa que faz ao ser ativada é uma pergunta, nunca um comando. Só macOS."
---

# Faça suas pastas mágicas

Uma pasta mágica é uma pasta do Desktop com uma tarefa atrelada. O arquivo cai
dentro, o Mac processa sozinho, o resultado aparece em `pronto/`. Quem dispara é o
`launchd`, o agendador do macOS; nada fica rodando entre um arquivo e outro.

A base que já funciona está em `modelo/`, ao lado deste arquivo (é a pasta desta
skill: se ela foi instalada por `git clone`, é a própria pasta clonada). O seu
trabalho é **entrevistar a pessoa** e, com o que ela responder, escrever **a receita**
de cada pasta: um arquivo pequeno que diz quais extensões a pasta aceita e o que
fazer com cada arquivo.

## Regra número 1: primeiro você pergunta

Ao ser ativada, **a sua primeira mensagem é uma pergunta**. Não é um plano, não é uma
explicação da skill, não é um comando. Nada é instalado, criado ou executado antes
de a entrevista terminar e a pessoa dizer "sim" ao resumo.

- **Uma pergunta por mensagem.** Espere a resposta antes da próxima.
- **Opções numeradas sempre que couber.** A pessoa responde com um número. Ponha a
  sua recomendação em primeiro e diga que é a recomendação.
- **Antes de perguntar, releia o que ela já disse.** Se o pedido inicial já responde
  algumas perguntas ("uma pasta que comprime as fotos que eu jogar nela" já diz a
  tarefa, a entrada e a saída), ecoe o que entendeu numa frase e pergunte só o que
  falta. Perguntar o que ela acabou de dizer é o defeito que esta regra existe
  para evitar.
- **Ela não sabe o que pedir?** Isso é normal. Mostre as ideias (a tabela no fim
  deste arquivo, em linguagem de gente) e pergunte qual se parece com o dia dela.
- **Fale do incômodo, não da tecnologia.** A pessoa provavelmente não programa. Sem
  jargão; quando um termo for inevitável, defina em uma frase.
- **Não invente resposta por ela.** Pergunta sem resposta fica como pergunta.

## A entrevista

Siga esta ordem, pulando o que já foi respondido.

**1 · A tarefa.** *"Qual tarefa repetida você quer que aconteça sozinha quando um
arquivo cair numa pasta?"*

> 1. tirar o áudio de vídeos e receber mp3
> 2. transformar vídeo em gif
> 3. acelerar vídeo ou áudio
> 4. cortar os silêncios
> 5. transcrever vídeo ou áudio em texto
> 6. comprimir imagens
> 7. outra: conte o que você faz hoje à mão ("chega tal arquivo e eu faço tal coisa")

**2 · Entrada e saída.** *"O que você joga na pasta, e o que quer receber de
volta?"* Só pergunte se a resposta 1 não disse. Ofereça os tipos mais prováveis
como opções (mp4 ou mov; jpg ou png).

**3 · O que muda o resultado.** Um parâmetro por vez, só os que mudam de verdade o
que a pessoa recebe, sempre com um padrão recomendado. Exemplos: *"Acelerar
quanto? 1 = 1,15x (recomendado)  2 = 1,5x  3 = 2x"*; *"O gif fica com que largura?
1 = 640 px (recomendado, leve)  2 = 1080 px"*. Se a tarefa não tem escolha
relevante, não invente pergunta.

**4 · Local ou nuvem.** Se a tarefa roda no próprio Mac (a maioria roda), **não
pergunte**: diga numa frase que ela roda local, sem internet, sem custo e sem o
arquivo sair do computador, e siga. Só pergunte quando a tarefa exigir serviço
externo (transcrição na nuvem, isolar voz, IA de terceiros):

> Essa precisa de um serviço na nuvem. Três coisas antes de seguir: o arquivo
> **sai do seu computador** e vai para a empresa do serviço; você precisa de uma
> **chave de acesso sua**; e o serviço **pode cobrar por uso**.
> 1. fazer uma versão local (recomendado, se existir)
> 2. usar o serviço na nuvem, sabendo disso

Local é sempre o padrão. Pasta com serviço externo fica **marcada de vermelho** no
Finder, para lembrar.

**5 · O nome da pasta.** Sugira o formato `entrada>>saida`. *"Posso chamar de
`video>>gif`? 1 = sim  2 = outro nome"*. A pasta vai para o Desktop.

**6 · A confirmação.** Repita tudo numa frase e peça o aceite:

> *"Pasta `video>>gif` no Desktop: recebe mp4 e mov, devolve gif de 640 px, roda
> local, sem internet e sem custo. Certo? 1 = sim  2 = ajustar"*

**Só depois do sim** você segue para "Montar". No fim de tudo (pasta instalada e
testada), pergunte se ela quer **mais uma pasta**, e repita a entrevista para a
próxima. Uma pasta de cada vez.

## Montar

### 1. Conferir a máquina

```bash
uname -m                        # arm64 (Apple Silicon) ou x86_64
sw_vers -productVersion         # macOS 12 ou mais novo
which clang codesign ffmpeg     # clang vem de: xcode-select --install
                                # ffmpeg vem de: brew install ffmpeg
```

O `clang` é usado uma vez, para compilar o launcher de 30 linhas. O ffmpeg só é
necessário se alguma receita usar. Se a tarefa pedir `mlx-whisper`, ele só roda
em Apple Silicon e baixa o modelo na primeira execução (depois funciona offline).
Se faltar algo, diga o que é, para que serve, e peça licença antes de instalar.

### 2. Preparar a cópia de trabalho

Copie `modelo/` (que está ao lado deste arquivo) para `~/minhas-pastas-magicas`.
A pessoa edita a **cópia**, não a skill. Se `~/minhas-pastas-magicas` já existe, use
a que está lá e **acrescente**: nunca sobrescreva o que ela já tem.

### 3. Escrever a receita

Copie `receitas/_esqueleto.sh` para `receitas/<nome>.sh` (só minúsculas, números,
hífen e sublinhado). Preencha duas coisas:

- `EXTS_OK=(...)`: extensões aceitas, em minúscula e sem ponto;
- `processar ENTRADA SAIDADIR BASE`: faz o trabalho e grava o resultado em
  `SAIDADIR`. Retorna 0 se deu certo; qualquer outro número manda o original
  para `_erros/`.

`receitas/video2audio.sh` é um exemplo completo. Receita com parâmetro usa
dois-pontos em `pastas.conf` (`speed:1.15`) e lê `$PARAM`. Os parâmetros que a
pessoa escolheu na entrevista entram aqui.

Receita com serviço externo: a chave vai em
`~/Library/Application Support/minhas-pastas/.env` (`NOME=valor`) e chega à
receita como variável de ambiente. **Nunca peça a chave no chat**: mande a pessoa
abrir o arquivo (`open -e <caminho>`) e colar lá. Se a chave vazar em texto,
ela precisa ser trocada no site do serviço.

Receita em Python: use `"$PYTHON_BIN" script.py`, nunca `python3` solto, e liste
os módulos em `python-requisitos.txt`.

### 4. Testar antes de instalar

```bash
./testar.sh <receita> <arquivo de exemplo> [outro arquivo...]
```

O script roda a receita numa pasta temporária, sem instalar nada e sem mexer no
que já está ligado, e mostra onde cada arquivo foi parar (`pronto/`, `_erros/`,
`_originais/`) e o log. Os arquivos de exemplo originais ficam intactos.
Peça à pessoa um arquivo dela para o teste e **confira o conteúdo do resultado**.
Teste **também um arquivo que deve falhar**: é ele que prova que `_erros/` funciona.

### 5. Instalar

Acrescente uma linha em `pastas.conf`: `nome-da-pasta|receita|tag`, com `vermelha`
na tag se a receita usa serviço externo. Depois:

```bash
./instalar.sh
```

O instalador é idempotente. Rodar de novo só recarrega; é o que se faz depois de
editar qualquer receita, porque o agente lê a cópia em `Application Support`, não a
sua pasta de trabalho.

### 6. Verificar que funciona

**Não confie no código de saída do instalador.** Solte um arquivo na pasta e olhe o log:

```bash
tail -f ~/Library/Logs/minhas-pastas.log
```

Em segundos deve aparecer `processando` e `ok: pronto/...`. Abra o resultado e
confira o conteúdo, não só a existência do arquivo.

Se aparecer `Operation not permitted`, o macOS bloqueou o Desktop. **Essa parte só a
pessoa consegue fazer**, então conduza um passo por vez: Ajustes do Sistema >
Privacidade e Segurança > Acesso total ao disco > botão + > escolha
`~/Library/Application Support/minhas-pastas/MinhasPastas.app`. Depois solte o arquivo
de novo.

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

## Ideias para mostrar na entrevista

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
| `audio>>limpo` | isola a voz (ElevenLabs) | **não**: serviço externo, o arquivo sai do computador |
| `video>>melhorestrechos` | escolhe os melhores cortes (Gemini) | **não**: serviço externo, o arquivo sai do computador |

## Desinstalar

```bash
./desinstalar.sh     # para e remove os agentes; não apaga pasta nem arquivo
rm -rf ~/Library/Application\ Support/minhas-pastas   # apaga a instalação e as chaves
```
