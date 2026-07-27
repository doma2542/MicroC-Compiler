# Assignment 4: Parser for nanoC
## Roll Number: 230101038
## Course: CS348 - Implementation of Programming Languages Lab

---

## Files Included

| File | Description |
|------|-------------|
| `a4_230101038.l` | Flex lexer specification for nanoC |
| `a4_230101038.y` | Bison/YACC parser specification for nanoC |
| `a4_230101038_test.nc` | Test input file exercising all grammar rules |
| `Makefile` | Build automation |
| `README.md` | This file |

---

## How to Build and Run

```bash
make          # Builds the parser (runs flex, yacc, gcc)
make run      # Runs the parser on the test file
make clean    # Removes generated files
```

Or step by step:
```bash
flex a4_230101038.l
yacc -d a4_230101038.y
gcc lex.yy.c y.tab.c -o a.out
./a.out < a4_230101038_test.nc
```

Expected output on success:
```
Parsing successful!
```

---

## Grammar Changes Made

The nanoC grammar from the assignment spec was adapted as follows for Bison/YACC:

### 1. Optional non-terminals (subscript-`opt`)
Every `X_opt` in the grammar was implemented as a new non-terminal with two productions:
```
X_opt : X | /* empty */
```
Non-terminals introduced:
- `argument_expression_list_opt`
- `assignment_expression_opt`
- `init_declarator_list_opt`
- `declaration_specifiers_opt`
- `identifier_list_opt`
- `block_item_list_opt`
- `expression_opt`
- `designation_opt`

### 2. Dangling-else resolution
YACC/Bison reports a shift/reduce conflict for:
```
if (cond) if (cond2) stmt else stmt
```
This is resolved by the standard technique: declaring a dummy token `LOWER_THAN_ELSE` with `%prec` lower than `ELSE`, and giving the `if-without-else` production that precedence:
```yacc
selection_statement
    : IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;
```

### 3. Translation unit
A `translation_unit` top-level rule was added (as is standard for C parsers), consisting of `external_declaration`s which are either `function_definition`s or `declaration`s.

### 4. Function definitions
A minimal `function_definition` rule was added:
```
function_definition : declaration_specifiers declarator compound_statement
```

### 5. `switch` keyword not in nanoC
The `case` and `default` labels are retained as `labeled_statement` productions (as specified), but the `switch` keyword itself is not part of nanoC per the assignment grammar.

---

## Test File Coverage

`a4_230101038_test.nc` tests:
- All type specifiers: `void`, `char`, `short`, `int`, `long`, `float`, `double`, `signed`, `unsigned`, `_Bool`
- Storage class: `static`
- All unary operators: `& * + - ~ !`
- All assignment operators: `= *= /= %= += -= <<= >>= &= ^= |=`
- All relational and equality operators
- Bitwise, logical, shift operators
- Ternary conditional expression
- Comma expression
- All statement types: compound, expression, if, if-else, nested if-else, while, do-while, for (all variants), break, continue, return
- Labeled statements: identifier label, case, default
- Array declarations and subscripting
- Function calls with and without arguments
- Variadic functions (`...`)
- Initializer lists including designated initializers and nested braces
- Pointer declarations and dereferencing
- String literals and character constants
