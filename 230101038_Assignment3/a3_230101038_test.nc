/* ============================================================
   a3_230101038_test.nc
   Test file for the nanoC Lexer (CS348 Assignment 3)
   Roll: 230101038
   Covers: all keywords, identifiers, integer/float/char/string
           constants, all punctuators, comments, escape sequences,
           and deliberate lexical error.
   ============================================================ */

// ── 1. All Keywords
int main_func(void) {
    break;
    continue;
    return;
    do {} while (0);
    for (;;) {}
    if (1) {} else {}
    while (1) {}
    case 1: default:
    static int x;
    signed int si;
    unsigned long ul;
    short s;
    char c;
    float f;
    double d;
    _Bool flag;
}

// ── 2. Identifiers 
int alpha;
int _under_score;
int camelCase;
int MixED123;
int a;
int z9;
int _leadingUnderscore;

// ── 3. Integer constants 
int i1 = 1;
int i2 = 42;
int i3 = 9999;
int i4 = 0;

// ── 4. Floating-point constants
double fp1 = 3.14;
double fp2 = .5;
double fp3 = 100.;
double fp4 = 0.001;

// ── 5. Character constants with all escape sequences 
char ch1 = 'A';
char ch2 = 'z';
char ch3 = '0';
char ch4 = '\n';
char ch5 = '\t';
char ch6 = '\\';
char ch7 = '\'';
char ch8 = '\a';
char ch9 = '\b';
char ch10 = '\f';
char ch11 = '\r';
char ch12 = '\v';
char ch13 = '\?';
char ch14 = '\"';

// ── 6. String literals 
char *s1 = "hello world";
char *s2 = "";
char *s3 = "escape \n test \t done";
char *s4 = "backslash \\ and quote \"";

// ── 7. All Punctuators 

/* compound assignment */
int punc_test;
punc_test = 5;
punc_test *= 2;
punc_test /= 2;
punc_test %= 3;
punc_test += 1;
punc_test -= 1;
punc_test <<= 1;
punc_test >>= 1;
punc_test &= 255;
punc_test ^= 1;
punc_test |= 16;

/* comparison */
int cmp;
cmp = (punc_test == 0);
cmp = (punc_test != 0);
cmp = (punc_test < 10);
cmp = (punc_test > 10);
cmp = (punc_test <= 10);
cmp = (punc_test >= 10);

/* logical */
cmp = (cmp && 1);
cmp = (cmp || 0);
cmp = !cmp;

/* bitwise */
punc_test = punc_test & 255;
punc_test = punc_test | 1;
punc_test = punc_test ^ 16;
punc_test = ~punc_test;
punc_test = punc_test << 2;
punc_test = punc_test >> 2;

/* arithmetic */
punc_test = punc_test + 1;
punc_test = punc_test - 1;
punc_test = punc_test * 2;
punc_test = punc_test / 2;
punc_test = punc_test % 3;

/* increment / decrement */
punc_test++;
punc_test--;

/* unary */
int *ptr = &punc_test;
int val  = *ptr;
int neg  = -val;

/* arrow and dot */
/* struct S { int m; } obj, *p; */
/* obj.m = 1; p->m = 2; */

/* ternary, colon, semicolon */
int t = (cmp ? 1 : 0);

/* array brackets */
int arr[10];
arr[0] = 1;

/* ellipsis */
/* void varfunc(int n, ...); */

/* comma */
int p = 1, q = 2;

/* ── 8. Multi-line comment*/
/*
   This comment
   spans multiple
   lines and should
   be silently ignored.
*/

// ── 9. Single-line comment
// Everything on this line is ignored: int bad = 999;

// ── 10. Deliberate lexical error 
int bad = @;
