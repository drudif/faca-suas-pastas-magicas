#!/usr/bin/env python3
"""Aplica (ou tira) uma tag de cor do Finder numa pasta.

    tag-finder.py <cor|nenhuma> <caminho> [caminho...]
    cores: vermelho laranja amarelo verde azul roxo cinza

A tag mora no xattr com.apple.metadata:_kMDItemUserTags, que guarda um plist
BINARIO de strings no formato "Nome\\nIndice". Escrever XML nao funciona: o
Finder ignora e a pasta fica sem cor.

O nome precisa bater com o nome localizado, senao o Finder cria uma tag nova
com o mesmo tom em vez de usar a que ja existe. Os nomes saem de
`defaults read com.apple.finder FavoriteTagNames`, que vem na ordem
vermelho, laranja, amarelo, verde, azul, roxo, cinza — ordem de exibicao, que
nao e a mesma dos indices de cor.
"""
import plistlib, subprocess, sys

# cor -> (indice de cor do Finder, posicao em FavoriteTagNames, nome em ingles)
CORES = {
    "vermelho": (6, 1, "Red"),
    "laranja":  (7, 2, "Orange"),
    "amarelo":  (5, 3, "Yellow"),
    "verde":    (2, 4, "Green"),
    "azul":     (4, 5, "Blue"),
    "roxo":     (3, 6, "Purple"),
    "cinza":    (1, 7, "Gray"),
}
ATTR = "com.apple.metadata:_kMDItemUserTags"

def nomes_do_sistema():
    r = subprocess.run(["defaults", "read", "com.apple.finder", "FavoriteTagNames"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        return []
    nomes = []
    for linha in r.stdout.splitlines():
        linha = linha.strip().rstrip(",").strip('"')
        if linha in ("(", ")"):
            continue
        nomes.append(linha)
    return nomes

def main():
    if len(sys.argv) < 3:
        print("uso: tag-finder.py <cor|nenhuma> <caminho>...", file=sys.stderr)
        sys.exit(1)
    cor, caminhos = sys.argv[1].lower(), sys.argv[2:]

    if cor in ("nenhuma", "none", ""):
        for caminho in caminhos:
            subprocess.run(["xattr", "-d", ATTR, caminho], capture_output=True, text=True)
        return

    if cor not in CORES:
        print(f"cor desconhecida: {cor}. use: {' '.join(CORES)}", file=sys.stderr)
        sys.exit(1)

    indice, posicao, nome_en = CORES[cor]
    nomes = nomes_do_sistema()
    nome = nomes[posicao] if len(nomes) > posicao and nomes[posicao] else nome_en
    valor = plistlib.dumps([f"{nome}\n{indice}"], fmt=plistlib.FMT_BINARY)

    for caminho in caminhos:
        r = subprocess.run(["xattr", "-wx", ATTR, valor.hex(), caminho],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print(f"falhou em {caminho}: {r.stderr.strip()}", file=sys.stderr)
            sys.exit(1)

if __name__ == "__main__":
    main()
