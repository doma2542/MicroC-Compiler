#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 500
#define MAX_REFS 100
#define MEMORY_SIZE 65536

//OPCODE TABLE 

typedef struct {
    char mnemonic[10];
    char opcode[3];
} Opcode;

Opcode OPTAB[] = {
    {"LDA","00"},{"LDX","04"},{"LDL","08"},
    {"STA","0C"},{"STX","10"},{"STL","14"},
    {"ADD","18"},{"SUB","1C"},{"MUL","20"},
    {"DIV","24"},{"COMP","28"},
    {"J","3C"},{"JLT","38"},{"JEQ","30"},
    {"JGT","34"},{"JSUB","48"},{"RSUB","4C"},
    {"TD","E0"},{"RD","D8"},{"WD","DC"},
    {"LDCH","50"},{"STCH","54"},
    {"TIX","2C"}
};

int OPTAB_SIZE = sizeof(OPTAB)/sizeof(Opcode);

//SYMBOL TABLE 

typedef struct {
    char name[20];
    int address;
    int defined;
    int forwardRefs[MAX_REFS];
    int refCount;
} Symbol;

Symbol SYMTAB[MAX_SYMBOLS];
int symCount = 0;

//GLOBAL 

int LOCCTR = 0;
int STARTADDR = 0;
char PROGNAME[20];

unsigned char MEMORY[MEMORY_SIZE];
int USED[MEMORY_SIZE];
int OBJLEN[MEMORY_SIZE];

//UTILITY 

int searchOpcode(char *op) {
    for(int i=0;i<OPTAB_SIZE;i++)
        if(strcmp(OPTAB[i].mnemonic,op)==0)
            return i;
    return -1;
}

int searchSymbol(char *name) {
    for(int i=0;i<symCount;i++)
        if(strcmp(SYMTAB[i].name,name)==0)
            return i;
    return -1;
}

int addSymbol(char *name) {
    strcpy(SYMTAB[symCount].name,name);
    SYMTAB[symCount].defined = 0;
    SYMTAB[symCount].refCount = 0;
    return symCount++;
}

//BACKPATCH 

void backpatch(int index) {
    for(int i=0;i<SYMTAB[index].refCount;i++) {
        int loc = SYMTAB[index].forwardRefs[i];
        int addr = SYMTAB[index].address;

        MEMORY[loc+1] = (addr >> 8) & 0xFF;
        MEMORY[loc+2] = addr & 0xFF;
    }
}

//MAIN 

int main() {

    FILE *input = fopen("input.asm","r");
    FILE *output = fopen("output1.obj","w");

    if(!input) {
        printf("Cannot open input.asm\n");
        return 0;
    }

    memset(MEMORY,0,sizeof(MEMORY));
    memset(USED,0,sizeof(USED));
    memset(OBJLEN,0,sizeof(OBJLEN));

    char line[200];

    while(fgets(line,sizeof(line),input)) {

        if(line[0]=='.' || line[0]=='\n')
            continue;

        char label[20]="", opcode[20]="", operand[30]="";

        char tokens[3][30];
        int tcount=0;

        char *token = strtok(line," \t\n");

        while(token && tcount<3) {
            strcpy(tokens[tcount++],token);
            token = strtok(NULL," \t\n");
        }

        if(tcount == 0)
            continue;

        /* START */
        if(tcount>=2 && strcmp(tokens[1],"START")==0) {
            strcpy(PROGNAME,tokens[0]);
            STARTADDR = (int)strtol(tokens[2],NULL,16);
            LOCCTR = STARTADDR;
            continue;
        }

        /* END */
        if(strcmp(tokens[0],"END")==0)
            break;

        int opIndex = searchOpcode(tokens[0]);

        if(opIndex==-1 &&
           strcmp(tokens[0],"WORD")!=0 &&
           strcmp(tokens[0],"RESW")!=0 &&
           strcmp(tokens[0],"RESB")!=0 &&
           strcmp(tokens[0],"BYTE")!=0) {

            strcpy(label,tokens[0]);
            strcpy(opcode,tokens[1]);
            if(tcount>2) strcpy(operand,tokens[2]);
        }
        else {
            strcpy(opcode,tokens[0]);
            if(tcount>1) strcpy(operand,tokens[1]);
        }

        /* DEFINE SYMBOL */
        if(strlen(label)>0) {
            int s = searchSymbol(label);
            if(s==-1)
                s = addSymbol(label);

            SYMTAB[s].address = LOCCTR;
            SYMTAB[s].defined = 1;
            backpatch(s);
        }

        opIndex = searchOpcode(opcode);

        /* MACHINE INSTRUCTION */
        if(opIndex!=-1) {

            int indexed = 0;
            char temp[30];
            strcpy(temp,operand);

            char *comma = strstr(temp,",X");
            if(comma) {
                indexed = 1;
                *comma = '\0';
            }

            MEMORY[LOCCTR] = (unsigned char)strtol(OPTAB[opIndex].opcode,NULL,16);

            USED[LOCCTR] = USED[LOCCTR+1] = USED[LOCCTR+2] = 1;
            OBJLEN[LOCCTR] = 3;

            if(strlen(temp)>0) {

                int s = searchSymbol(temp);
                if(s==-1)
                    s = addSymbol(temp);

                if(SYMTAB[s].defined) {
                    int addr = SYMTAB[s].address;
                    if(indexed)
                        addr |= 0x8000;

                    MEMORY[LOCCTR+1] = (addr>>8)&0xFF;
                    MEMORY[LOCCTR+2] = addr&0xFF;
                }
                else {
                    SYMTAB[s].forwardRefs[SYMTAB[s].refCount++] = LOCCTR;
                }
            }
            else {
                MEMORY[LOCCTR+1] = 0x00;
                MEMORY[LOCCTR+2] = 0x00;
            }

            LOCCTR += 3;
        }

        /* WORD */
        else if(strcmp(opcode,"WORD")==0) {

            int val = atoi(operand);

            MEMORY[LOCCTR]   = (val>>16)&0xFF;
            MEMORY[LOCCTR+1] = (val>>8)&0xFF;
            MEMORY[LOCCTR+2] = val&0xFF;

            USED[LOCCTR] = USED[LOCCTR+1] = USED[LOCCTR+2] = 1;
            OBJLEN[LOCCTR] = 3;

            LOCCTR += 3;
        }

        /* RESW */
        else if(strcmp(opcode,"RESW")==0) {
            LOCCTR += 3 * atoi(operand);
        }

        /* RESB */
        else if(strcmp(opcode,"RESB")==0) {
            LOCCTR += atoi(operand);
        }

        /* BYTE */
        else if(strcmp(opcode,"BYTE")==0) {

            if(operand[0]=='C') {

                int i=2;
                int start = LOCCTR;
                while(operand[i] != '\'') {
                    MEMORY[LOCCTR] = operand[i];
                    USED[LOCCTR] = 1;
                    LOCCTR++;
                    i++;
                }

                OBJLEN[start] = LOCCTR - start;
            }
            else if(operand[0]=='X') {

                char hex[10];
                strncpy(hex,operand+2,strlen(operand)-3);
                hex[strlen(operand)-3]='\0';

                MEMORY[LOCCTR] = (unsigned char)strtol(hex,NULL,16);
                USED[LOCCTR] = 1;
                OBJLEN[LOCCTR] = 1;

                LOCCTR++;
            }
        }
    }

    int PROGLEN = LOCCTR - STARTADDR;

    //WRITE OBJECT FILE 

    fprintf(output,"H%-6s%06X%06X\n",PROGNAME,STARTADDR,PROGLEN);

    int addr = STARTADDR;

    while(addr < STARTADDR + PROGLEN) {

        while(addr < STARTADDR + PROGLEN && USED[addr] == 0)
            addr++;

        if(addr >= STARTADDR + PROGLEN)
            break;

        int textStart = addr;
        char text[500] = "";
        int length = 0;

        while(addr < STARTADDR + PROGLEN &&
              USED[addr] == 1) {

            int chunk = OBJLEN[addr];

            if(chunk == 0) chunk = 1;

            if(length + chunk > 30)
                break;

            for(int i=0;i<chunk;i++) {
                char byteStr[3];
                sprintf(byteStr,"%02X",MEMORY[addr+i]);
                strcat(text,byteStr);
            }

            addr += chunk;
            length += chunk;
        }

        fprintf(output,"T%06X%02X%s\n",textStart,length,text);
    }

    fprintf(output,"E%06X\n",STARTADDR);

    fclose(input);
    fclose(output);

    return 0;
}
