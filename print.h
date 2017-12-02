#ifndef PRINT_H
#define PRINT_H
#define HASHSIZE 1334

#include "AST.h"

struct Program *head;

struct Map {
    char *string[HASHSIZE];
    int hashValue[HASHSIZE];
    int key[HASHSIZE];
    int count;
};

typedef struct Queue_ {
    int *arr;
    int queueSize;
    int head;
    int tail;
    int count;
} Queue;

struct Block {
    unsigned long *in;
    unsigned long *out;
    unsigned long *def;
    unsigned long *use;
    int *pred;
    int succ[2];
};

struct BlockInfo {
    int predNum;
    int succNum;
};

void s_program(void);
void s_class(struct Class *);
void s_member(struct Member *);
void s_varDecl(struct VarDecl *);
void s_methodDecl(struct MethodDecl *);
void s_methodDef(struct MethodDef *);
void s_classMethodDef(struct ClassMethodDef *);
void s_mainFunc(struct MainFunc *);
void s_param(struct Param *);
void s_ident(struct Ident *);
void s_type(struct Type *);
void s_compoundStmt(struct CompoundStmt *);
void s_stmt(struct Stmt *);
void s_exprStmt(struct ExprStmt *);
void s_assignStmt(struct AssignStmt *);
void s_retStmt(struct RetStmt *);
void s_whileStmt(struct WhileStmt *);
void s_doStmt(struct DoStmt *);
void s_forStmt(struct ForStmt *);
void s_ifStmt(struct IfStmt *);
void s_expr(struct Expr *);
void s_operExpr(struct OperExpr *);
void s_refExpr(struct RefExpr *);
void s_refVarExpr(struct RefVarExpr *);
void s_refCallExpr(struct RefCallExpr *);
void s_identExpr(struct IdentExpr *);
void s_callExpr(struct CallExpr *);
void s_arg(struct Arg *);
void s_unOp(struct UnOp *);
void s_addiOp(struct AddiOp *);
void s_multOp(struct MultOp *);
void s_relaOp(struct RelaOp *);
void s_eqltOp(struct EqltOp *);

void nextBlockName();
void nextBlock();
void clearBlockArr();
void addDef(char *);
void addUse(char *);
void addSucc(int, int);
int getKeyFromStr(char *);
char* getStrFromKey(int);
int string_hash(unsigned char *);
void queue_init(Queue *, int);
void queue_push_back(Queue *, int);
int queue_pop(Queue *);
void workList();
void print_live();

#endif
