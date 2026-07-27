%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ── Symbol Table ── */
#define ST_SIZE 1024
typedef struct { char name[256]; int first_line; } STEntry;
STEntry sym_table[ST_SIZE];
int st_count = 0;

int st_lookup(const char *name) {
    for (int i = 0; i < st_count; i++)
        if (strcmp(sym_table[i].name, name) == 0) return i;
    return -1;
}
void st_insert(const char *name, int lineno) {
    if (st_lookup(name) == -1 && st_count < ST_SIZE) {
        strncpy(sym_table[st_count].name, name, 255);
        sym_table[st_count].first_line = lineno;
        st_count++;
    }
}

FILE *tok_fp = NULL;
FILE *st_fp  = NULL;
%}

%option noyywrap
%option yylineno
%x BLOCK_COMMENT

DIGIT     [0-9]
ID        [a-zA-Z_][a-zA-Z0-9_]*
FLOAT     ([0-9]*\.[0-9]+)|([0-9]+\.)
INT       0|[1-9][0-9]*
ESC       \\['"?\\abfnrtv]
CHAR      \'({ESC}|[^\'\\\n])\'
STR       \"({ESC}|[^\"\\\n])*\"

%%

"/*"                    { BEGIN(BLOCK_COMMENT); }
<BLOCK_COMMENT>"*/"     { BEGIN(INITIAL); }
<BLOCK_COMMENT>\n       { }
<BLOCK_COMMENT><<EOF>>  { fprintf(tok_fp, "<ERROR, Unterminated block comment, Line %d>\n", yylineno); yyterminate(); }
<BLOCK_COMMENT>.        { }
"//"[^\n]*              { }

int|float|char|double|short|long|signed|unsigned|void|_Bool|if|else|for|while|do|return|break|continue|case|default|static {
    fprintf(tok_fp, "<KEYWORD, %s, Line %d>\n", yytext, yylineno);
}

{ID}    { st_insert(yytext, yylineno); fprintf(tok_fp, "<IDENTIFIER, %s, Line %d>\n", yytext, yylineno); }

{FLOAT} { fprintf(tok_fp, "<FLOAT_CONST, %s, Line %d>\n",    yytext, yylineno); }
{INT}   { fprintf(tok_fp, "<INTEGER_CONST, %s, Line %d>\n",  yytext, yylineno); }
{CHAR}  { fprintf(tok_fp, "<CHAR_CONST, %s, Line %d>\n",     yytext, yylineno); }
{STR}   { fprintf(tok_fp, "<STRING_LITERAL, %s, Line %d>\n", yytext, yylineno); }

"..."|"<<="|">>="|"->"|"++"|"--"|"<<"|">>"|"<="|">="|"=="|"!="|"&&"|"||"|"*="|"/="|"%="|"+="|"-="|"&="|"^="|"|=" {
    fprintf(tok_fp, "<PUNCTUATOR, %s, Line %d>\n", yytext, yylineno);
}
"["|"]"|"("|")"|"{"|"}"|"."|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<"|">"|"^"|"|"|"?"|":"|";"|"="|","|"#" {
    fprintf(tok_fp, "<PUNCTUATOR, %s, Line %d>\n", yytext, yylineno);
}

\n|[ \t\r]+  { }

. {
    fprintf(tok_fp, "<ERROR, Unexpected character '%s', Line %d>\n", yytext, yylineno);
    fprintf(stderr, "Lexical error: unexpected character '%s' at line %d\n", yytext, yylineno);
}

%%

int main(int argc, char *argv[]) {
    tok_fp = fopen("a3_230101038_token.txt", "w");
    if (!tok_fp) { perror("Cannot open token file"); return 1; }
    st_fp = fopen("a3_230101038_st.txt", "w");
    if (!st_fp)  { perror("Cannot open symbol-table file"); return 1; }

    yyin = (argc > 1) ? fopen(argv[1], "r") : stdin;
    if (!yyin) { perror("Cannot open input file"); return 1; }

    yylex();

    fprintf(st_fp, "%-5s  %-40s  %s\n", "S.No", "Identifier", "First Seen (Line)");
    fprintf(st_fp, "%-5s  %-40s  %s\n", "----", "----------", "-----------------");
    for (int i = 0; i < st_count; i++)
        fprintf(st_fp, "%-5d  %-40s  %d\n", i+1, sym_table[i].name, sym_table[i].first_line);

    fclose(tok_fp); fclose(st_fp);
    if (yyin != stdin) fclose(yyin);
    printf("Lexing complete.\n  Token file  : a3_230101038_token.txt\n  Symbol table: a3_230101038_st.txt\n");
    return 0;
}
