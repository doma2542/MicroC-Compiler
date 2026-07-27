# MicroC-Compiler

Coursework for CS348 – Implementation of Programming Languages Lab, covering the compilation pipeline from assembly programming through assemblers to lexical analysis and parsing for the nanoC language.

**Roll Number:** 230101038

***

## Repository Layout

| Directory | Topic |
| :--- | :--- |
| `230101038_Assignment1/` | x86-64 NASM assembly programs |
| `230101038_Assignment2/` | One-pass and two-pass assemblers in C |
| `230101038_Assignment3/` | Flex-based lexer for nanoC |
| `230101038_Assignment4/` | Bison/YACC parser for nanoC |

***

## Assignment 1 — Assembly Programming

x86-64 NASM programs linked against the C library.

| File | Description |
| :--- | :--- |
| `230101038_seta.asm` | Floating-point calculator (add / subtract / multiply / divide) |
| `230101038_setb1.asm` | Cycle detection on a graph given as an adjacency matrix |
| `230101038_setb2.asm` | Smallest and largest word in a file, by length |

```bash
nasm -f elf64 230101038_seta.asm -o seta.o
gcc seta.o -o seta -no-pie
./seta
\`\`\`

---

## Assignment 2 — Assemblers

| File | Description |
| :--- | :--- |
| \`230101038_onepass.c\` | One-pass assembler with forward-reference backpatching |
| \`230101038_twopass.c\` | Two-pass assembler with a separate symbol-resolution pass |

\`\`\`bash
gcc 230101038_onepass.c -o onepass && ./onepass
gcc 230101038_twopass.c -o twopass && ./twopass
\`\`\`

---

## Assignment 3 — nanoC Lexer

A Flex specification recognising all nanoC keywords, identifiers, constants, string literals, punctuators and comments. Emits a token stream and a symbol table.

\`\`\`bash
cd 230101038_Assignment3
make          # compile the lexer
make run      # run on the test file and print outputs
make clean    # remove generated files
\`\`\`

*See the assignment README for the full lexical rule set and output formats.*

---

## Assignment 4 — nanoC Parser

A Bison/YACC grammar for nanoC, including optional-non-terminal expansion and dangling-else resolution via precedence.

\`\`\`bash
cd 230101038_Assignment4
make          # build the parser (flex, yacc, gcc)
make run      # parse the test file
make clean    # remove generated files
\`\`\`

*See the assignment README for the grammar adaptations and test coverage.*

---

## Build Requirements

- \`nasm\` and \`gcc\` (Assignment 1)
- \`gcc\` (Assignment 2)
- \`flex\` (Assignment 3)
- \`flex\` and \`bison\`/\`yacc\` (Assignment 4)

**On Debian/Ubuntu:**
\`\`\`bash
sudo apt install nasm gcc flex bison make
\`\`\`
"@
