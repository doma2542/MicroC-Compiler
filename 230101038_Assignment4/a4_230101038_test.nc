/* a4_230101038_test.nc
   Test file for nanoC Parser - Assignment 4
   Roll: 230101038
   Covers all grammar rules in the nanoC specification.
*/

/* -------------------------------------------------------
   1. Global declarations: type-specifiers, storage-class
------------------------------------------------------- */
static int global_static;
unsigned long counter;
double pi;
float rate;
char ch;
short s;
signed long sl;
_Bool flag;
void *ptr;

/* -------------------------------------------------------
   2. Declarations with initializers
------------------------------------------------------- */
int x = 10;
float y = 3.14;
char letter = 'A';

/* Array declarations */
int arr[10];
int arr2[5] = {1, 2, 3, 4, 5};

/* Designated initializers */
int arr3[5] = {[0] = 1, [2] = 3};

/* Multiple declarators */
int a, b, c;
int p = 1, q = 2, r = 3;

/* -------------------------------------------------------
   3. Function definitions - various parameter forms
------------------------------------------------------- */

/* No parameters */
void no_params(void) {
    return;
}

/* With parameters */
int add(int x, int y) {
    return x + y;
}

/* Variadic (parameter_type_list with ...) */
int variadic_func(int n, ...) {
    return n;
}

/* With identifier-list style (identifier_list_opt path) */
int old_style(void) {
    return 0;
}

/* -------------------------------------------------------
   4. Expressions - all operators
------------------------------------------------------- */
int expressions_test(void) {
    int i, j, k;
    float f;

    /* Primary expressions */
    i = 42;
    f = 3.14;
    i = (i + 1);

    /* Postfix: array subscript */
    int arr[5];
    arr[0] = 1;
    arr[i] = i + 1;

    /* Postfix: function calls */
    k = add(2, 3);
    no_params();

    /* Postfix: increment/decrement */
    i++;
    j--;

    /* Prefix increment/decrement */
    ++i;
    --j;

    /* Unary operators */
    k = -i;
    k = +i;
    k = ~i;
    k = !i;
    int *p2 = &i;
    k = *p2;

    /* Multiplicative */
    k = i * j;
    k = i / j;
    k = i % j;

    /* Additive */
    k = i + j;
    k = i - j;

    /* Shift */
    k = i << 2;
    k = i >> 1;

    /* Relational */
    k = i < j;
    k = i > j;
    k = i <= j;
    k = i >= j;

    /* Equality */
    k = i == j;
    k = i != j;

    /* Bitwise AND */
    k = i & j;

    /* Bitwise XOR */
    k = i ^ j;

    /* Bitwise OR */
    k = i | j;

    /* Logical AND / OR */
    k = i && j;
    k = i || j;

    /* Conditional (ternary) */
    k = (i > 0) ? i : -i;

    /* Assignment operators */
    i = 5;
    i += 2;
    i -= 1;
    i *= 3;
    i /= 2;
    i %= 3;
    i <<= 1;
    i >>= 1;
    i &= 255;
    i ^= 15;
    i |= 1;

    /* Comma expression */
    k = (i = 1, j = 2, i + j);

    return k;
}

/* -------------------------------------------------------
   5. Statements
------------------------------------------------------- */
void statements_test(void) {
    int i, sum;

    /* Expression statement */
    sum = 0;

    /* Empty expression statement */
    ;

    /* Compound statement */
    {
        int local = 10;
        sum += local;
    }

    /* ---- Selection statements ---- */

    /* if without else */
    if (i > 0)
        sum = i;

    /* if-else */
    if (i > 0)
        sum = i;
    else
        sum = -i;

    /* Nested if-else (dangling else resolved) */
    if (i > 0)
        if (i > 10)
            sum = 100;
        else
            sum = 10;
    else
        sum = 0;

    /* ---- Iteration statements ---- */

    /* while */
    while (i < 10) {
        sum += i;
        i++;
    }

    /* do-while */
    do {
        sum += i;
        i--;
    } while (i > 0);

    /* for - all three parts */
    for (i = 0; i < 10; i++) {
        sum += i;
    }

    /* for - empty parts */
    for (;;) {
        break;
    }

    /* for - with declaration */
    for (int j = 0; j < 5; j++) {
        sum += j;
    }

    /* ---- Jump statements ---- */

    /* continue */
    for (i = 0; i < 10; i++) {
        if (i == 5)
            continue;
        sum += i;
    }

    /* break */
    while (1) {
        if (sum > 100)
            break;
        sum++;
    }

    /* return with and without value */
    if (sum < 0)
        return;
}

/* -------------------------------------------------------
   6. Labeled statements
------------------------------------------------------- */
int labeled_test(int x) {
    /* Goto-target label */
    start:
        x++;

    /* switch-like: case and default */
    switch_labels:
    case 1:
        x = 1;
        break;
    case 2:
        x = 2;
        break;
    default:
        x = 0;
        break;

    return x;
}

/* -------------------------------------------------------
   7. Nested / complex function
------------------------------------------------------- */
int factorial(int n) {
    if (n <= 1)
        return 1;
    return n * factorial(n - 1);
}

int fibonacci(int n) {
    int a = 0, b = 1, tmp;
    for (int i = 0; i < n; i++) {
        tmp = a + b;
        a = b;
        b = tmp;
    }
    return a;
}

/* Array parameter */
int sum_array(int arr[], int len) {
    int total = 0;
    for (int i = 0; i < len; i++) {
        total += arr[i];
    }
    return total;
}

/* String literal usage */
void string_test(void) {
    char *msg = "Hello, nanoC!";
    char c = msg[0];
}

/* -------------------------------------------------------
   8. Initializer lists (nested)
------------------------------------------------------- */
int matrix[3][3] = {
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9}
};

/* -------------------------------------------------------
   9. Pointer declarations
------------------------------------------------------- */
int *int_ptr;
int **double_ptr;
void *void_ptr;

int pointer_test(void) {
    int val = 42;
    int *p = &val;
    int result = *p;
    return result;
}
