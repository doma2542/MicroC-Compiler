%{
#include <stdio.h>
#include <stdlib.h>
extern int yylineno;


extern int yylex(void);

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}
%}

/* Token declarations */
%token IDENTIFIER INTEGER_CONSTANT FLOATING_CONSTANT CHARACTER_CONSTANT STRING_LITERAL

/* Keywords */
%token VOID CHAR_KW SHORT INT LONG FLOAT_KW DOUBLE SIGNED UNSIGNED BOOL STATIC
%token IF ELSE WHILE DO FOR CONTINUE BREAK RETURN CASE DEFAULT

/* Operators */
%token ELLIPSIS
%token RIGHT_ASSIGN LEFT_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token MOD_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token RIGHT_OP LEFT_OP INC_OP DEC_OP AND_OP OR_OP
%token LE_OP GE_OP EQ_OP NE_OP

/* Resolve dangling-else by giving ELSE higher precedence than plain IF */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start translation_unit

%%

/* ========================
   1. EXPRESSIONS
   ======================== */

primary_expression
    : IDENTIFIER
    | constant
    | STRING_LITERAL
    | '(' expression ')'
    ;

constant
    : INTEGER_CONSTANT
    | FLOATING_CONSTANT
    | CHARACTER_CONSTANT
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' argument_expression_list_opt ')'
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    ;

argument_expression_list_opt
    : argument_expression_list
    | /* empty */
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator cast_expression
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

cast_expression
    : unary_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression
    | multiplicative_expression '/' cast_expression
    | multiplicative_expression '%' cast_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression
    | relational_expression '>' shift_expression
    | relational_expression LE_OP shift_expression
    | relational_expression GE_OP shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression
    | equality_expression NE_OP relational_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LEFT_ASSIGN
    | RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

constant_expression
    : conditional_expression
    ;

/* ========================
   2. DECLARATIONS
   ======================== */

declaration
    : declaration_specifiers init_declarator_list_opt ';'
    ;

declaration_specifiers
    : storage_class_specifier declaration_specifiers_opt
    | type_specifier declaration_specifiers_opt
    ;

declaration_specifiers_opt
    : declaration_specifiers
    | /* empty */
    ;

init_declarator_list_opt
    : init_declarator_list
    | /* empty */
    ;

init_declarator_list
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator
    | declarator '=' initializer
    ;

storage_class_specifier
    : STATIC
    ;

type_specifier
    : VOID
    | CHAR_KW
    | SHORT
    | INT
    | LONG
    | FLOAT_KW
    | DOUBLE
    | SIGNED
    | UNSIGNED
    | BOOL
    ;

declarator
    : direct_declarator
    | pointer direct_declarator
    ;

pointer
    : '*'
    | '*' pointer
    ;

direct_declarator
    : IDENTIFIER
    | '(' declarator ')'
    | direct_declarator '[' assignment_expression_opt ']'
    | direct_declarator '(' parameter_type_list ')'
    | direct_declarator '(' identifier_list_opt ')'
    ;

assignment_expression_opt
    : assignment_expression
    | /* empty */
    ;

identifier_list_opt
    : identifier_list
    | /* empty */
    ;

parameter_type_list
    : parameter_list
    | parameter_list ',' ELLIPSIS
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

initializer
    : assignment_expression
    | '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    ;

initializer_list
    : designation_opt initializer
    | initializer_list ',' designation_opt initializer
    ;

designation_opt
    : designation
    | /* empty */
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    ;

/* ========================
   3. STATEMENTS
   ======================== */

statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' block_item_list_opt '}'
    ;

block_item_list_opt
    : block_item_list
    | /* empty */
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

expression_statement
    : expression_opt ';'
    ;

expression_opt
    : expression
    | /* empty */
    ;

selection_statement
    : IF '(' expression ')' statement %prec LOWER_THAN_ELSE
    | IF '(' expression ')' statement ELSE statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' expression_opt ';' expression_opt ';' expression_opt ')' statement
    | FOR '(' declaration expression_opt ';' expression_opt ')' statement
    ;

jump_statement
    : CONTINUE ';'
    | BREAK ';'
    | RETURN expression_opt ';'
    ;

/* ========================
   4. TOP-LEVEL (translation unit)
   ======================== */

translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    ;

function_definition
    : declaration_specifiers declarator compound_statement
    ;

%%

int main(void) {
    if (yyparse() == 0)
        printf("Parsing successful!\n");
    else
        printf("Parsing failed.\n");
    return 0;
}
