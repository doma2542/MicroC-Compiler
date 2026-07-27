# CS348 – Assignment 3: Lexer for nanoC
**Roll Number:** 230101038
**Course:** Implementation of Programming Languages Lab (CS348)
**IIT Guwahati – 3rd Year CSE**

---

## Files

| File | Description |
|---|---|
| `a3_230101038.l` | Flex specification for the nanoC lexer |
| `Makefile` | Build and run targets |
| `a3_230101038_test.nc` | Test input covering all lexical rules |
| `README.md` | This file |

Output files generated at runtime:

| File | Description |
|---|---|
| `a3_230101038_token.txt` | Token stream with line numbers |
| `a3_230101038_st.txt` | Symbol table of all identifiers |

---

## Build and Run

```bash
make          # compile the lexer
make run      # run on test file and print outputs
make clean    # remove generated files
```

---

## Lexical Rules Implemented

### Keywords (21)
`int` `char` `float` `double` `void` `short` `long` `signed` `unsigned`
`if` `else` `while` `for` `do` `return` `break` `continue`
`case` `default` `static` `_Bool`

### Identifiers
Letters (a–z, A–Z), underscore, followed by letters/digits/underscore.
Each identifier is recorded in the symbol table with its first-seen line number.

### Constants
- **Integer:** decimal digits, e.g. `0`, `42`, `9999`
- **Float:** `3.14`, `.5`, `100.`
- **Character:** `'A'`, `'\n'`, `'\t'`, `'\\'`, etc. (all 12 escape sequences)
- **String:** `"hello"`, `"esc \n seq"`, `""` (empty)

### Punctuators (all 45+)
Multi-character operators matched before single-character ones:
`...` `<<=` `>>=` `->` `++` `--` `<<` `>>` `<=` `>=` `==` `!=` `&&` `||`
`*=` `/=` `%=` `+=` `-=` `&=` `^=` `|=`
`[ ] ( ) { } . & * + - ~ ! / % < > ^ | ? : ; = , #`

### Comments
- Block: `/* ... */` (non-nesting, tracks newlines for accurate line numbers)
- Line: `// ...`

### Errors
Unknown characters printed to `a3_230101038_token.txt` and `stderr` with line number.

---

## Token Format
```
<TOKEN_TYPE, lexeme, Line N>
```

## Symbol Table Format
```
S.No   Identifier                                First Seen (Line)
----   ----------                                -----------------
1      main_func                                 11
...
```
