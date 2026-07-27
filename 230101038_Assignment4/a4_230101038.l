%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
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

 /* ── Comments (same start-condition logic as A3) ── */
"/*"                    { BEGIN(BLOCK_COMMENT); }
<BLOCK_COMMENT>"*/"     { BEGIN(INITIAL); }
<BLOCK_COMMENT>\n       { }
<BLOCK_COMMENT><<EOF>>  { fprintf(stderr, "Error: Unterminated block comment at line %d\n", yylineno); yyterminate(); }
<BLOCK_COMMENT>.        { }
"//"[^\n]*              { }

 /* ── Keywords (same list as A3, mapped to parser tokens) ── */
"int"       { return INT; }
"float"     { return FLOAT_KW; }
"char"      { return CHAR_KW; }
"double"    { return DOUBLE; }
"short"     { return SHORT; }
"long"      { return LONG; }
"signed"    { return SIGNED; }
"unsigned"  { return UNSIGNED; }
"void"      { return VOID; }
"_Bool"     { return BOOL; }
"if"        { return IF; }
"else"      { return ELSE; }
"for"       { return FOR; }
"while"     { return WHILE; }
"do"        { return DO; }
"return"    { return RETURN; }
"break"     { return BREAK; }
"continue"  { return CONTINUE; }
"case"      { return CASE; }
"default"   { return DEFAULT; }
"static"    { return STATIC; }

 /* ── Identifiers (same pattern as A3) ── */
{ID}        { return IDENTIFIER; }

 /* ── Constants (same patterns as A3) ── */
{FLOAT}     { return FLOATING_CONSTANT; }
{INT}       { return INTEGER_CONSTANT; }
{CHAR}      { return CHARACTER_CONSTANT; }
{STR}       { return STRING_LITERAL; }

 /* ── Multi-character operators (same list as A3) ── */
"..."       { return ELLIPSIS; }
"<<="       { return LEFT_ASSIGN; }
">>="       { return RIGHT_ASSIGN; }
"++"        { return INC_OP; }
"--"        { return DEC_OP; }
"<<"        { return LEFT_OP; }
">>"        { return RIGHT_OP; }
"<="        { return LE_OP; }
">="        { return GE_OP; }
"=="        { return EQ_OP; }
"!="        { return NE_OP; }
"&&"        { return AND_OP; }
"||"        { return OR_OP; }
"*="        { return MUL_ASSIGN; }
"/="        { return DIV_ASSIGN; }
"%="        { return MOD_ASSIGN; }
"+="        { return ADD_ASSIGN; }
"-="        { return SUB_ASSIGN; }
"&="        { return AND_ASSIGN; }
"^="        { return XOR_ASSIGN; }
"|="        { return OR_ASSIGN; }

 /* ── Single-character punctuators (same as A3) ── */
"["  { return '['; }
"]"  { return ']'; }
"("  { return '('; }
")"  { return ')'; }
"{"  { return '{'; }
"}"  { return '}'; }
"."  { return '.'; }
"&"  { return '&'; }
"*"  { return '*'; }
"+"  { return '+'; }
"-"  { return '-'; }
"~"  { return '~'; }
"!"  { return '!'; }
"/"  { return '/'; }
"%"  { return '%'; }
"<"  { return '<'; }
">"  { return '>'; }
"^"  { return '^'; }
"|"  { return '|'; }
"?"  { return '?'; }
":"  { return ':'; }
";"  { return ';'; }
"="  { return '='; }
","  { return ','; }

 /* ── Whitespace ── */
\n|[ \t\r]+  { }

 /* ── Unexpected characters (same as A3) ── */
. {
    fprintf(stderr, "Lexical error: unexpected character '%s' at line %d\n", yytext, yylineno);
}

%%
