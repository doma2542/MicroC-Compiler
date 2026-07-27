#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_SYMBOLS 500
#define MAX_LINE 256

// OPCODE TABLE

typedef struct {
    char mnemonic[10];
    int code;
} OpCode;

OpCode opTable[] = {
    {"LDA",0x00},{"LDX",0x04},{"LDL",0x08},
    {"STA",0x0C},{"STX",0x10},{"STL",0x14},
    {"ADD",0x18},{"SUB",0x1C},{"MUL",0x20},
    {"DIV",0x24},{"COMP",0x28},
    {"J",0x3C},{"JLT",0x38},{"JEQ",0x30},
    {"JGT",0x34},{"JSUB",0x48},{"RSUB",0x4C},
    {"TD",0xE0},{"RD",0xD8},{"WD",0xDC},
    {"LDCH",0x50},{"STCH",0x54},
    {"TIX",0x2C}
};

int opCount = sizeof(opTable)/sizeof(opTable[0]);

// SYMBOL TABLE

typedef struct {
    char name[30];
    int address;
} Symbol;

Symbol symtab[MAX_SYMBOLS];
int symCount = 0;

// GLOBAL

char programName[30];

// LOOKUP

int getOpcode(char *op) {
    for (int i = 0; i < opCount; i++)
        if (strcmp(opTable[i].mnemonic, op) == 0)
            return opTable[i].code;
    return -1;
}

int getSymbol(char *name) {
    for (int i = 0; i < symCount; i++)
        if (strcmp(symtab[i].name, name) == 0)
            return symtab[i].address;
    return -1;
}

void addSymbol(char *name, int addr) {
    if (getSymbol(name) == -1) {
        strcpy(symtab[symCount].name, name);
        symtab[symCount].address = addr;
        symCount++;
    }
}

// PARSE LINE

void parseLine(char *line, char *label,
               char *opcode, char *operand) {

    label[0] = opcode[0] = operand[0] = '\0';

    char *tok = strtok(line, " \t\n");

    if (!tok) return;

    char *t1 = tok;
    char *t2 = strtok(NULL, " \t\n");
    char *t3 = strtok(NULL, " \t\n");

    if (t3) {
        strcpy(label, t1);
        strcpy(opcode, t2);
        strcpy(operand, t3);
    }
    else if (t2) {
        strcpy(opcode, t1);
        strcpy(operand, t2);
    }
    else {
        strcpy(opcode, t1);
    }
}

// PASS 1

int pass1(int *startAddr) {

    FILE *input = fopen("input.asm", "r");
    FILE *inter = fopen("intermediate.txt", "w");

    if (!input) {
        printf("Cannot open input.asm\n");
        exit(1);
    }

    char line[MAX_LINE];
    char label[30], opcode[30], operand[50];
    int locctr = 0;

    while (fgets(line, sizeof(line), input)) {

        if (line[0] == '.' || line[0] == '\n') {
            fprintf(inter, "%s", line);
            continue;
        }

        char temp[MAX_LINE];
        strcpy(temp, line);
        parseLine(temp, label, opcode, operand);

        if (strcmp(opcode, "START") == 0) {
            strcpy(programName, label);
            sscanf(operand, "%x", startAddr);
            locctr = *startAddr;

            fprintf(inter, "%04X %s %s %s\n",
                    locctr, label, opcode, operand);
            continue;
        }

        fprintf(inter, "%04X %s %s %s\n",
                locctr, label, opcode, operand);

        if (strlen(label) > 0)
            addSymbol(label, locctr);

        if (getOpcode(opcode) != -1)
            locctr += 3;
        else if (strcmp(opcode, "WORD") == 0)
            locctr += 3;
        else if (strcmp(opcode, "RESW") == 0)
            locctr += 3 * atoi(operand);
        else if (strcmp(opcode, "RESB") == 0)
            locctr += atoi(operand);
        else if (strcmp(opcode, "BYTE") == 0) {
            if (operand[0] == 'C')
                locctr += strlen(operand) - 3;
            else if (operand[0] == 'X')
                locctr += (strlen(operand) - 3) / 2;
        }
        else if (strcmp(opcode, "END") == 0)
            break;
    }

    fclose(input);
    fclose(inter);

    return locctr - *startAddr;
}

// TEXT RECORD FLUSH

void flushText(FILE *obj, int start,
               char *buffer, int length) {

    if (length == 0) return;

    fprintf(obj, "T%06X%02X%s\n",
            start, length, buffer);

    buffer[0] = '\0';
}

// PASS 2

void pass2(int startAddr, int progLen) {

    FILE *inter = fopen("intermediate.txt", "r");
    FILE *obj = fopen("output.obj", "w");

    char line[MAX_LINE];
    char label[30], opcode[30], operand[50];
    int address;

    char textBuffer[1000] = "";
    int textLen = 0;
    int textStart = 0;

    /* HEADER */
    fprintf(obj, "H%-6s%06X%06X\n",
            programName, startAddr, progLen);

    while (fgets(line, sizeof(line), inter)) {

        if (line[0] == '.' || line[0] == '\n')
            continue;

        sscanf(line, "%x", &address);

        char rest[MAX_LINE];
        char *p = strchr(line, ' ');
        if (!p) continue;
        strcpy(rest, p + 1);

        parseLine(rest, label, opcode, operand);

        if (strcmp(opcode, "START") == 0)
            continue;
        if (strcmp(opcode, "END") == 0)
            break;

        char objcode[100] = "";
        int op = getOpcode(opcode);

        if (op != -1) {

            int target = 0;
            int indexed = 0;

            char *comma = strchr(operand, ',');
            if (comma) {
                indexed = 1;
                *comma = '\0';
            }

            if (strlen(operand) > 0)
                target = getSymbol(operand);

            if (indexed)
                target |= 0x8000;

            sprintf(objcode, "%02X%04X",
                    op, target);
        }
        else if (strcmp(opcode, "WORD") == 0) {
            sprintf(objcode, "%06X",
                    atoi(operand));
        }
        else if (strcmp(opcode, "BYTE") == 0) {

            if (operand[0] == 'C') {
                for (int i = 2; operand[i] != '\''; i++) {
                    char temp[10];
                    sprintf(temp, "%02X",
                            operand[i]);
                    strcat(objcode, temp);
                }
            }
            else if (operand[0] == 'X') {
                strncpy(objcode,
                        operand + 2,
                        strlen(operand) - 3);
                objcode[strlen(operand)-3] = '\0';
            }
        }
        else if (strcmp(opcode, "RESW") == 0 ||
                 strcmp(opcode, "RESB") == 0) {

            flushText(obj, textStart,
                      textBuffer, textLen);
            textLen = 0;
            continue;
        }

        if (strlen(objcode) > 0) {

            if (textLen == 0)
                textStart = address;

            int objBytes = strlen(objcode) / 2;

            if (textLen + objBytes > 30) {
                flushText(obj, textStart,
                          textBuffer, textLen);
                textLen = 0;
                textStart = address;
            }

            strcat(textBuffer, objcode);
            textLen += objBytes;
        }
    }

    flushText(obj, textStart, textBuffer, textLen);

    fprintf(obj, "E%06X\n", startAddr);

    fclose(inter);
    fclose(obj);
}

// MAIN

int main() {

    int startAddr = 0;
    int progLen = pass1(&startAddr);
    pass2(startAddr, progLen);

    printf("Two-pass SIC Assembler executed successfully.\n");
    printf("Generated:\n");
    printf(" - intermediate.txt\n");
    printf(" - output.obj\n");

    return 0;
}
