/*
 * Executavel proprio para as suas pastas magicas.
 *
 * Existe por um motivo so: o macOS (TCC) bloqueia o acesso a ~/Desktop para
 * processos disparados pelo launchd. Um script .sh nao pode receber permissao,
 * porque quem aparece para o sistema e o interpretador (/bin/zsh) — dar acesso
 * a ele seria dar acesso a qualquer script. Um binario dentro de um .app tem
 * identidade propria, entao da para liberar so ele em
 * Ajustes > Privacidade e Seguranca > Acesso total ao disco.
 *
 * O binario nao aceita script arbitrario: ele sempre roda o converter.sh que
 * mora em ~/Library/Application Support/minhas-pastas/. Os argumentos
 * recebidos (receita e pasta) sao repassados.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>

int main(int argc, char **argv) {
    const char *home = getenv("HOME");
    if (!home) { fprintf(stderr, "sem HOME\n"); return 1; }

    char script[PATH_MAX];
    int n = snprintf(script, sizeof(script),
                     "%s/Library/Application Support/minhas-pastas/converter.sh", home);
    if (n < 0 || n >= (int)sizeof(script)) { fprintf(stderr, "caminho longo demais\n"); return 1; }

    char *args[32];
    int a = 0;
    args[a++] = "/bin/zsh";
    args[a++] = script;
    for (int i = 1; i < argc && a < 30; i++) args[a++] = argv[i];
    args[a] = NULL;

    execv("/bin/zsh", args);
    perror("execv");
    return 127;
}
