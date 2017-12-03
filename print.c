#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "DFA.h"
#include "print.h"
#include "timer.c"

FILE *cfg;
FILE *live;

// String Hashing
Map stringMap;

// Queue for Worklist
Queue queue;

// Total time spent for DFA
double total_time = 0;

char *className;
char *methodName;
char *blockName;
int blockNameLen;
int blockNum;
struct Block *blockArr;
struct BlockInfo *blockInfoArr;
int bitVecSize;

struct RefVarExpr *assignTarget;
bool isBlockEmpty = true;
bool endWithRet = false;

int main() {
    cfg = fopen("CFG.out", "w");
    live = fopen("liveness.out", "w");

    blockNameLen = 0;  // Initialize block
    blockNum = 0;
    blockName = (char *)calloc(10, sizeof(char));
    blockArr = (struct Block *)calloc(100, sizeof(struct Block));
    blockInfoArr = (struct BlockInfo *)calloc(100, sizeof(struct BlockInfo));

    if (!yyparse()) {
	fprintf(cfg, "# Control Flow Graph\n");
	fprintf(live, "# The Result of Liveness Analysis");
	printf("DFA running time for Each Block\n");
	s_program();
    }

    printf("Total DFA running time: %fs\n", total_time);
    
    fclose(cfg);
    fclose(live);

    return 0;
}

void s_program() {
    if (head == NULL) {
	fprintf(stderr, "Program does not exist.\n");
	return;
    }
    
    if (head->_class != NULL)
	s_class(head->_class);

    if (head->classMethodDef != NULL)
	s_classMethodDef(head->classMethodDef);

    if (head->mainFunc == NULL) {
	fprintf(stderr, "Main function does not exist.\n");
	return;
    }

    s_mainFunc(head->mainFunc);	
}

void s_class(struct Class *class_) {
    className = class_->id;

    if (class_->prev != NULL) {
	s_class(class_->prev);
    }

    if (class_->priMember != NULL) {
	s_member(class_->priMember);
    }

    if (class_->pubMember != NULL) {
	s_member(class_->pubMember);
    }
}

void s_member(struct Member *member) {
    if (member->methodDef != NULL) {
	s_methodDef(member->methodDef);
    }
}

void s_varDecl(struct VarDecl *vardecl) {
    if (vardecl->prev != NULL)
	s_varDecl(vardecl->prev);

    if (vardecl->assignType != eNon) {
	addContext("\t");

	addDef(vardecl->ident->id);
	s_ident(vardecl->ident);

	addContext(" = ");
	
	if (vardecl->assignType == eAsFloat)
	    addContextFloat(vardecl->assigner.floatnum);
	else
	    addContextInt(vardecl->assigner.intnum);
	addContext("\n");
	
	isBlockEmpty = false;
    }
}

void s_methodDef(struct MethodDef *methoddef) {
    if (methoddef->prev != NULL)
	s_methodDef(methoddef->prev);

    nextBlockName();
    methodName = methoddef->id;
    clearBlockArr();

    s_compoundStmt(methoddef->compoundStmt);

    if (!isBlockEmpty) {
	addSucc(-1, blockNum);
	nextBlock();
    }
    else if (!endWithRet && blockNum != 0) {
	int predNum = blockInfoArr[blockNum].predNum;
	for (int i = 0; i < predNum; ++i) {
	    int predBlockNum = blockArr[blockNum].pred[i];
	    blockInfoArr[predBlockNum].succNum--;
	    addSucc(-1, predBlockNum);
	}
    }
    else if (blockNum == 0) {
	addSucc(-1, blockNum);
	blockNum++;
    }

    workList();
    print_live();
    print_cfg(methoddef->param);
}

void s_classMethodDef(struct ClassMethodDef *classmethoddef) {
    if (classmethoddef->prev != NULL)
	s_classMethodDef(classmethoddef->prev);

    nextBlockName();
    className = classmethoddef->className;
    methodName = classmethoddef->methodName;
    clearBlockArr();

    s_compoundStmt(classmethoddef->compoundStmt);

    if (!isBlockEmpty) {
	addSucc(-1, blockNum);
	nextBlock();
    }
    else if (!endWithRet && blockNum != 0) {
	int predNum = blockInfoArr[blockNum].predNum;
	for (int i = 0; i < predNum; ++i) {
	    int predBlockNum = blockArr[blockNum].pred[i];
	    blockInfoArr[predBlockNum].succNum--;
	    addSucc(-1, predBlockNum);
	}
    }
    else if (blockNum == 0) {
	addSucc(-1, blockNum);
	blockNum++;
    }

    workList();
    print_live();
    print_cfg(classmethoddef->param);
}

void s_mainFunc(struct MainFunc *mainfunc) {
    nextBlockName();
    className = NULL;
    methodName = "main";
    clearBlockArr();

    s_compoundStmt(mainfunc->compoundStmt);

    if (!isBlockEmpty) {
	addSucc(-1, blockNum);
	nextBlock();
    }
    else if (!endWithRet && blockNum != 0) {
	int predNum = blockInfoArr[blockNum].predNum;
	for (int i = 0; i < predNum; ++i) {
	    int predBlockNum = blockArr[blockNum].pred[i];
	    blockInfoArr[predBlockNum].succNum--;
	    addSucc(-1, predBlockNum);
	}
    }
    else if (blockNum == 0) {
	addSucc(-1, blockNum);
	blockNum++;
    }

    workList();
    print_live();
    print_cfg(NULL);
}

void s_param(struct Param *param) {
    if (param->prev != NULL) {
	s_param(param->prev);
	fprintf(cfg, ", ");
    }

    s_type(param->type);
    fprintf(cfg, "%s", param->ident->id);
    if (param->ident->len != 0) {
	fprintf(cfg, "[%d]", param->ident->len);
    }
}

void s_ident(struct Ident *ident) {
    addContext(ident->id);
    if (ident->len != 0) {
	addContext("[");
	addContextInt(ident->len);
	addContext("]");
    }
}

void s_type(struct Type *type) {
    if (type->e == eInt) {
	fprintf(cfg, "int ");
    }
    else if (type->e == eFloat) {
	fprintf(cfg, "float ");
    }
    else {
	fprintf(cfg, "%s ", type->id);
    }
}

void s_compoundStmt(struct CompoundStmt *compoundstmt) {
    if (compoundstmt->varDecl != NULL) {
	s_varDecl(compoundstmt->varDecl);
    }

    if (compoundstmt->stmt != NULL) {
	s_stmt(compoundstmt->stmt);
    }
}

void s_stmt(struct Stmt *stmt) {
    if (stmt->prev != NULL)
	s_stmt(stmt->prev);

    if (stmt->e == eExpr)
	s_exprStmt(stmt->type.exprStmt);
    else if (stmt->e == eAssign)
	s_assignStmt(stmt->type.assignStmt);
    else if (stmt->e == eRet)
	s_retStmt(stmt->type.retStmt);
    else if (stmt->e == eWhile)
	s_whileStmt(stmt->type.whileStmt);
    else if (stmt->e == eDo)
	s_doStmt(stmt->type.doStmt);
    else if (stmt->e == eFor)
	s_forStmt(stmt->type.forStmt);
    else if (stmt->e == eIf)
	s_ifStmt(stmt->type.ifStmt);
    else if (stmt->e == eCompound)
	s_compoundStmt(stmt->type.compoundStmt);
}

void s_exprStmt(struct ExprStmt *exprstmt) {
    addContext("\t");
    s_expr(exprstmt->expr);
    addContext("\n"); 
    endWithRet = false;
}

void s_assignStmt(struct AssignStmt *assignstmt) {
    addContext("\t");

    assignTarget = assignstmt->refVarExpr;
    s_refVarExpr(assignstmt->refVarExpr);
    assignTarget = NULL;

    addContext(" = ");

    s_expr(assignstmt->expr);

    addContext("\n");

    endWithRet = false;
}

void s_retStmt(struct RetStmt *retstmt) {
    addContext("\treturn ");

    if (retstmt->expr != NULL)
	s_expr(retstmt->expr);

    addContext("\n");

    addSucc(-1, blockNum);
    nextBlock();
    isBlockEmpty = true;
    endWithRet = true;
}

void s_whileStmt(struct WhileStmt *whilestmt) {
    int startBlockNum = blockNum;
    int condBlockNum;
    int bodyBlockNum;

    // Conditional Block
    if (!isBlockEmpty) {
	nextBlock();
	addSucc(blockNum, startBlockNum);
    }
    condBlockNum = blockNum;
    addContext("\t");
    s_expr(whilestmt->cond);
    addContext("\n");

    // Body Block
    nextBlock();
    bodyBlockNum = blockNum;
    addSucc(bodyBlockNum, condBlockNum);
    isBlockEmpty = true;
    endWithRet = false;
    s_stmt(whilestmt->body);

    if (bodyBlockNum == blockNum || !isBlockEmpty) {
	addSucc(condBlockNum, blockNum);
	nextBlock();
	endWithRet = false;
    }
    else if (isBlockEmpty) {
	if (!endWithRet) {
	    int predNum = blockInfoArr[blockNum].predNum;
	    for (int i = 0; i < predNum; ++i) {
		int predBlockNum = blockArr[blockNum].pred[i];
		blockInfoArr[predBlockNum].succNum = 0;
		addSucc(condBlockNum, predBlockNum);
	    }
	    blockInfoArr[blockNum].predNum = 0;
	}
    }

    // Next Block
    addSucc(blockNum, condBlockNum);
    isBlockEmpty = true;
}

void s_doStmt(struct DoStmt *dostmt) {
    int startBlockNum = blockNum;
    int bodyBlockNum;
    int condBlockNum;

    // Body Block
    if (!isBlockEmpty) {
	nextBlock();
	addSucc(blockNum, startBlockNum);
    }
    bodyBlockNum = blockNum;
    isBlockEmpty = true;
    endWithRet = false;
    s_stmt(dostmt->body);

    // Cond Block
    if (!isBlockEmpty) {
	int lastBodyBlockNum = blockNum;
	nextBlock();
	addSucc(blockNum, lastBodyBlockNum);
    }
    addContext("\t");
    s_expr(dostmt->cond);
    addContext("\n");
    condBlockNum = blockNum;
    addSucc(bodyBlockNum, condBlockNum);

    // Next Block
    nextBlock();
    addSucc(blockNum, condBlockNum);
    isBlockEmpty = true;
    endWithRet = false;
}

void s_forStmt(struct ForStmt *forstmt) {
    int startBlockNum = blockNum;
    int bodyBlockNum;
    int lastBodyBlockNum;
    int condBlockNum;
    int incrBlockNum;

    addContext("\t");
    s_expr(forstmt->init);
    addContext("\n");

    // Cond Block
    nextBlock();
    condBlockNum = blockNum;
    addSucc(condBlockNum, startBlockNum);
    addContext("\t");
    s_expr(forstmt->cond);
    addContext("\n");

    // Body Block
    nextBlock();
    bodyBlockNum = blockNum;
    addSucc(bodyBlockNum, condBlockNum);
    isBlockEmpty = true;
    endWithRet = false;
    s_stmt(forstmt->body);
    lastBodyBlockNum = blockNum;

    // Incr Block
    if (!endWithRet) {
	addSucc(condBlockNum, lastBodyBlockNum);
    }
    if (!isBlockEmpty) {
	nextBlock();
	addSucc(blockNum, lastBodyBlockNum);
    }
    incrBlockNum = blockNum;
    addContext("\t");
    s_expr(forstmt->incr);
    addContext("\n");
    addSucc(condBlockNum, incrBlockNum);

    // Next Block
    nextBlock();
    addSucc(blockNum, condBlockNum);
    isBlockEmpty = true;
    endWithRet = false;
}

void s_ifStmt(struct IfStmt *ifstmt) {
    int condBlockNum;
    int bodyBlockNum;
    int lastBodyBlockNum;
    int elseBlockNum;
    bool bodyEndWithRet;

    if (!isBlockEmpty) {
	int startBlockNum = blockNum;
	nextBlock();
	addSucc(blockNum, startBlockNum);
    }

    // Cond Block
    addContext("\t");
    s_expr(ifstmt->cond);
    addContext("\n");
    condBlockNum = blockNum;

    // Body Block
    nextBlock();
    bodyBlockNum = blockNum;
    addSucc(bodyBlockNum, condBlockNum);
    isBlockEmpty = true;
    endWithRet = false;
    s_stmt(ifstmt->ifBody);
    lastBodyBlockNum = blockNum;
    if (isBlockEmpty && blockNum != bodyBlockNum) {
	lastBodyBlockNum -= 1;
    }
    else {
	nextBlock();
    }
    bodyEndWithRet = endWithRet;

    if (ifstmt->elseBody != NULL) {
	elseBlockNum = blockNum;
	addSucc(elseBlockNum, condBlockNum);
	isBlockEmpty = true;
	endWithRet = false;
	s_stmt(ifstmt->elseBody);

	if (!isBlockEmpty) {
	    int lastElseBlockNum = blockNum;
	    nextBlock();
	    addSucc(blockNum, lastElseBlockNum);
	    endWithRet = false;
	}
	else if (blockNum == elseBlockNum) {
	    nextBlock();
	    addSucc(blockNum, elseBlockNum);
	}
    }
    else {
	addSucc(blockNum, condBlockNum);
    }

    if (!bodyEndWithRet) {
	addSucc(blockNum, lastBodyBlockNum);
    }
    isBlockEmpty = true;
}

void s_expr(struct Expr *expr) {
    if (expr->e == eOper)
	s_operExpr(expr->type.operExpr);
    else if (expr->e == eRef) {
	s_refExpr(expr->type.refExpr);
    }
    else if (expr->e == eIntnum) {
	addContextInt(expr->type.intnum);
    }
    else if (expr->e == eFloatnum) {
	addContextFloat(expr->type.floatnum);
    }

    isBlockEmpty = false;
}

void s_operExpr(struct OperExpr *operexpr) {
    if (operexpr->e == eUn)
	s_unOp(operexpr->type.un);
    else if (operexpr->e == eAddi)
	s_addiOp(operexpr->type.addi);
    else if (operexpr->e == eMult)
	s_multOp(operexpr->type.mult);
    else if (operexpr->e == eRela)
	s_relaOp(operexpr->type.rela);
    else if (operexpr->e == eEqlt)
	s_eqltOp(operexpr->type.eqlt);
    else if (operexpr->e == eBracket) {
	addContext("(");
	s_expr(operexpr->type.bracket);
	addContext(")");
    }
}

void s_refExpr(struct RefExpr *refexpr) {
    if (refexpr->e == eVar)
	s_refVarExpr(refexpr->type.refVarExpr);
    else if (refexpr->e == eCall)
	s_refCallExpr(refexpr->type.refCallExpr);
}

void s_refVarExpr(struct RefVarExpr *refvarexpr) {
    if (refvarexpr->refExpr != NULL) {
	s_refExpr(refvarexpr->refExpr);
	addContext(".");
    }

    if (refvarexpr->refExpr == NULL) {
	if (refvarexpr == assignTarget)
	    addDef(refvarexpr->identExpr->id);
	else
	    addUse(refvarexpr->identExpr->id);
    }

    s_identExpr(refvarexpr->identExpr);
}

void s_refCallExpr(struct RefCallExpr *refcallexpr) {
    if (refcallexpr->refExpr != NULL) {
	s_refExpr(refcallexpr->refExpr);
	addContext(".");
    }

    s_callExpr(refcallexpr->callExpr);
}

void s_identExpr(struct IdentExpr *identexpr) {
    addContext(identexpr->id);
    if (identexpr->expr != NULL) {
	addContext("[");
	s_expr(identexpr->expr);
	addContext("]");
    }
}

void s_callExpr(struct CallExpr *callexpr) {
    addContext(callexpr->id);
    addContext("(");
    if (callexpr->arg != NULL)
	s_arg(callexpr->arg);
    addContext(")");
}

void s_arg(struct Arg *arg) {
    if (arg->prev != NULL) {
	s_arg(arg->prev);
	addContext(", ");
    }

    s_expr(arg->expr);
}

void s_unOp(struct UnOp *unop) {
    addContext("-");
    s_expr(unop->expr);
}

void s_addiOp(struct AddiOp *addiop) {
    s_expr(addiop->lhs);

    if (addiop->e == ePlus) {
	addContext(" + ");
    }
    else if (addiop->e == eMinus) {
	addContext(" - ");
    }

    s_expr(addiop->rhs);
}

void s_multOp(struct MultOp *multop) {
    s_expr(multop->lhs);

    if (multop->e == eMul) {
	addContext(" * ");
    }
    else if (multop->e == eDiv) {
	addContext(" / ");
    }

    s_expr(multop->rhs);
}

void s_relaOp(struct RelaOp *relaop) {
    s_expr(relaop->lhs);

    if (relaop->e == eLT) {
	addContext(" < ");
    }
    else if (relaop->e == eGT) {
	addContext(" > ");
    }
    else if (relaop->e == eLE) {
	addContext(" <= ");
    }
    else if (relaop->e == eGE) {
	addContext(" >= ");
    }

    s_expr(relaop->rhs);
}

void s_eqltOp(struct EqltOp *eqltop) {
    s_expr(eqltop->lhs);

    if (eqltop->e == eEQ) {
	addContext(" == ");
    }
    else if (eqltop->e == eNE) {
	addContext(" != ");
    }

    s_expr(eqltop->rhs);
}

// ----------------------------------------------
//               Block Management
// ----------------------------------------------

void nextBlockName() {
    int i = blockNameLen - 1;
    while (1) {
	if (i < 0) {
	    if (sizeof(blockName) <= blockNameLen) {
		blockName = (char *)realloc(blockName, (blockNameLen + 1) * 2);
	    }
	    blockName[blockNameLen] = 'A';
	    blockNameLen++;
	    return;
	}
	else if (blockName[i] < 'Z') {
	    blockName[i]++;
	    return;
	}
	else {
	    blockName[i] = 'A';
	    i--;
	}
    }
}

void nextBlock() {
    blockNum++;
    if (blockNum >= sizeof(blockArr)/sizeof(struct Block)) {
	blockArr = (struct Block *)realloc(blockArr, sizeof(struct Block) * blockNum * 2);
	blockInfoArr = (struct BlockInfo *)realloc(blockInfoArr, sizeof(struct BlockInfo) * blockNum * 2);
	memset(blockArr + blockNum, 0, sizeof(struct Block) * blockNum);
	memset(blockInfoArr + blockNum, 0, sizeof(struct BlockInfo) * blockNum);
    }
}

void clearBlockArr() {
    memset(blockInfoArr, 0, sizeof(blockInfoArr));
    memset(stringMap.key, 0, HASHSIZE * sizeof(int));
    memset(stringMap.string, 0, HASHSIZE * sizeof(char *));
	for (int i = 0; i < blockNum; ++i) {
		memset(blockArr[i].def, 0, stringMap.count);
		memset(blockArr[i].use, 0, stringMap.count);
	}
    blockNum = 0;
    stringMap.count = 0;
    isBlockEmpty = true;
    endWithRet = false;
}

// ----------------------------------------------
//               DFI Management
// ----------------------------------------------

void addDef(char *id) {
    int key = getKeyFromStr(id);
    struct Block *curBlock = &blockArr[blockNum];

    if (curBlock->def == NULL)
		curBlock->def = (unsigned long *)calloc(10, sizeof(unsigned long));
    if (sizeof(curBlock->def) <= key) {
		curBlock->def = (unsigned long *)realloc(curBlock->def, key * 2);
		memset(curBlock->def + key, 0, key);
	}

	curBlock->def[key / sizeof(unsigned long)] |= (unsigned long) 1 << (key % sizeof(unsigned long));
}

void addUse(char *id) {
    int key = getKeyFromStr(id);
    struct Block *curBlock = &blockArr[blockNum];

    if (curBlock->use == NULL)
		curBlock->use = (unsigned long *)calloc(10, sizeof(unsigned long));
    if (sizeof(curBlock->use) <= key) {
		curBlock->use = (unsigned long *)realloc(curBlock->use, key * 2);
		memset(curBlock->use + key, 0, key);
	}

	curBlock->use[key / sizeof(unsigned long)] |= (unsigned long) 1 << (key % sizeof(unsigned long));
}

// addSucc function also adds predecessor
void addSucc(int sNum, int pNum) {
    int *succNum = &blockInfoArr[pNum].succNum;
    int *predNum = &blockInfoArr[sNum].predNum;
    struct Block *succBlock;
    
    blockArr[pNum].succ[*succNum] = sNum;
    *succNum += 1;
    if (*succNum > 2)
	*succNum = 2;

    if (sNum == -1)
	return;

    succBlock = &blockArr[sNum];
    if (succBlock->pred == NULL) {
	succBlock->pred = (int *)calloc(10, sizeof(int));
    }
    else if ((sizeof(succBlock->pred) / sizeof(int)) <= *predNum) {
	succBlock->pred = (int *)realloc(succBlock->pred, sizeof(int) * (*predNum) * 2);
    }
    succBlock->pred[*predNum] = pNum;
    *predNum += 1;
}

// ----------------------------------------------
//               Hash Function
// ----------------------------------------------

int getKeyFromStr(char *str) {
    int hash = string_hash(str);

    for (int i = 0; i < HASHSIZE; ++i) {
	if (stringMap.string[hash] == NULL) {
	    stringMap.string[hash] = str;
	    stringMap.key[hash] = stringMap.count;
	    stringMap.hashValue[stringMap.count] = hash;
	    return stringMap.count++;
	}
	else if (!strcmp(stringMap.string[hash], str)) {
	    return stringMap.key[hash];
	}
	else {
	    hash++;
	}
    }

    fprintf(stderr, "Hash table overflowed.");
    return 0;
}

char* getStrFromKey(int key) {
    return stringMap.string[stringMap.hashValue[key]];
}

int string_hash(unsigned char *str) {
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
	hash = ((hash << 5) + hash) + c;

    return hash % HASHSIZE;
}

// ----------------------------------------------
//               Queue Function
// ----------------------------------------------

void queue_init(Queue *q, int size) {
    int maxSize = size * 4;
    if (q->arr == NULL) {
	q->arr = (int *)calloc(maxSize, sizeof(int));
	q->check = (int *)calloc(size, sizeof(int));
    }
    else if (sizeof(q->arr) / sizeof(int) < maxSize) {
	q->arr = (int *)realloc(q->arr, maxSize * sizeof(int));
    }

    if (sizeof(q->check) / sizeof(int) < size) {
	q->check = (int *)realloc(q->check, size * sizeof(int));
    }
    memset(q->check, 0, size * sizeof(int));
    q->queueSize = maxSize;
    q->head = 0;
    q->tail = 0;
    q->count = 0;
}

void queue_push_back(Queue *q, int v) {
    if (q->count >= q->queueSize)
	return;

    if (q->check[v] == 0) {
	q->arr[q->head] = v;
	q->check[v] = 1;
	q->head = (q->head + 1) % q->queueSize;
	q->count++;
    }
}

int queue_pop(Queue *q) {
    int result;
    if (q->count <= 0)
	return -1;

    result = q->arr[q->tail];
    q->check[result] = 0;
    q->tail =(q->tail + 1) % q->queueSize;
    q->count--;

    return result;
}

// ----------------------------------------------
//               Liveness Analysis
// ----------------------------------------------

// Iterative worklist algorithm
void workList() {
    // Setting timer
    reset_timer();

    // Initialize (IN = USE)
    bitVecSize = (stringMap.count / sizeof(unsigned long)) + 1;
    queue_init(&queue, blockNum);
    for (int i = blockNum - 1; i >= 0; --i) {
	if (blockArr[i].in == NULL) {
	    blockArr[i].in = (unsigned long *)calloc(bitVecSize, sizeof(unsigned long));
	}
	else if (sizeof(blockArr[i].in) <= stringMap.count) {
	    blockArr[i].in = (unsigned long *)realloc(blockArr[i].in, sizeof(unsigned long) - (stringMap.count % sizeof(unsigned long)) + stringMap.count);
	    memset(blockArr[i].in, 0, stringMap.count);
	}
	else {
	    memset(blockArr[i].in, 0, stringMap.count);
	}

	if (blockArr[i].out == NULL) {
	    blockArr[i].out = (unsigned long *)calloc(bitVecSize, sizeof(unsigned long));
	}
	else if (sizeof(blockArr[i].out) <= stringMap.count) {
	    blockArr[i].out = (unsigned long *)realloc(blockArr[i].out, sizeof(unsigned long) - (stringMap.count % sizeof(unsigned long)) + stringMap.count);
	    memset(blockArr[i].out, 0, stringMap.count);
	}
	else {
	    memset(blockArr[i].out, 0, stringMap.count);
	}

	int curSize;

	if (blockArr[i].use == NULL) {
	    blockArr[i].use = (unsigned long *)calloc(bitVecSize, sizeof(unsigned long));
	}
	else if ((curSize = sizeof(blockArr[i].use) / sizeof(unsigned long)) < bitVecSize) {
	    blockArr[i].use = (unsigned long *)realloc(blockArr[i].use, bitVecSize * sizeof(unsigned long));
	    memset(blockArr[i].use + curSize, 0, (bitVecSize - curSize) * sizeof(unsigned long));
	}

	if (blockArr[i].def == NULL) {
	    blockArr[i].def = (unsigned long *)calloc(bitVecSize, sizeof(unsigned long));
	}
	else if ((curSize = sizeof(blockArr[i].def) / sizeof(unsigned long)) < bitVecSize) {
	    blockArr[i].def = (unsigned long *)realloc(blockArr[i].def, bitVecSize * sizeof(unsigned long));
	    memset(blockArr[i].def + curSize, 0, (bitVecSize - curSize) * sizeof(unsigned long));
	}


	for (int j = 0; j < bitVecSize; ++j) {
	    blockArr[i].in[j] = blockArr[i].use[j];
	}

	queue_push_back(&queue, i);
    }

    while (queue.count > 0) {
	int block = queue_pop(&queue);
	int succNum = blockInfoArr[block].succNum;
	int predNum = blockInfoArr[block].predNum;
	unsigned long *curOut = blockArr[block].out;
	unsigned long *curIn = blockArr[block].in;
	unsigned long *curUse = blockArr[block].use;
	unsigned long *curDef = blockArr[block].def;
	bool changed = false;

	// OUT = succersors' IN
	memset(curOut, 0, stringMap.count);
	for (int i = 0; i < succNum; ++i) {
	    if (blockArr[block].succ[i] == -1)
		continue;

	    unsigned long *succIn = blockArr[blockArr[block].succ[i]].in;

	    for (int j = 0; j < bitVecSize; ++j) {
		curOut[j] = curOut[j] | succIn[j];
	    }
	}

	// IN = USE + ( OUT - DEF)
	for (int i = 0; i < bitVecSize; ++i) {
	    unsigned long bits = curUse[i] | (curOut[i] & ~curDef[i]);
	    if (bits != curIn[i]) {
		curIn[i] = bits;
		changed = true;
	    }
	}

	if (changed) {
	    int *pred = blockArr[block].pred;
	    for (int i = 0; i < predNum; ++i) {
		queue_push_back(&queue, pred[i]);
	    }
	}
    }

    double time = lab_timer();
    total_time += time;
    printf("Block %s: %fs\n", blockName, time);
}

void print_live() {
    if (className != NULL)
	fprintf(live, "\n%s::%s\n", className, methodName);
    else
	fprintf(live, "\n%s\n", methodName);
    fprintf(live, "\t\tIN\t\tOUT\n");

    for (int i = 0; i < blockNum; ++i) {
	unsigned long *in = blockArr[i].in;
	unsigned long *out = blockArr[i].out;
	char *comma = "";
	fprintf(live, "%s%d : ", blockName, i);

	fprintf(live, "{");
	for (int j = 0; j < bitVecSize; ++j) {
	    unsigned long bits = in[j];
	    int key = j * sizeof(unsigned long);
	    while (bits != 0) {
		if (bits % 2) {
		    fprintf(live, "%s%s", comma, getStrFromKey(key));
		    comma = ", ";
		}
		++key;
		bits = bits >> 1;
	    }
	}
	fprintf(live, "}");
	
	comma = "";
	fprintf(live, "\t{");
	for (int j = 0; j < bitVecSize; ++j) {
	    unsigned long bits = out[j];
	    int key = j * sizeof(unsigned long);
	    while (bits != 0) {
		if (bits % 2) {
		    fprintf(live, "%s%s", comma, getStrFromKey(key));
		    comma = ", ";
		}
		++key;
		bits = bits >> 1;
	    }
	}
	fprintf(live, "}\n");
    }
}

// ----------------------------------------------
//                 CFG Printing
// ----------------------------------------------

void addContext(char *id) {
    int idLen = strlen(id);

    if (blockArr[blockNum].context == NULL) {
	blockArr[blockNum].context = (char *)calloc(20, sizeof(char));
    }

    if (blockInfoArr[blockNum].contextLen + idLen >= sizeof(blockArr[blockNum].context)) {
	blockArr[blockNum].context = (char *)realloc(blockArr[blockNum].context, sizeof(char) * (blockInfoArr[blockNum].contextLen + idLen) * 2);
    }

    strcat(blockArr[blockNum].context, id);
    blockInfoArr[blockNum].contextLen += idLen;
}

void addContextInt(int intnum) {
    char buffer[15];
    int strLen;

    sprintf(buffer, "%d", intnum);
    addContext(buffer);
}

void addContextFloat(float floatnum) {
    char buffer[100];
    int strLen;

    strLen = snprintf(buffer, 100, "%f", floatnum);
    if (strLen > 100) {
	char *long_buffer = (char *)malloc(strLen + 1);
	sprintf(long_buffer, "%f", floatnum);
	addContext(long_buffer);
	free(long_buffer);
    }
    else
	addContext(buffer);
}

void print_cfg(struct Param *param) {
    char *comma;

    if (className != NULL) {
	fprintf(cfg, "\n%s::%s(", className, methodName);
	if (param != NULL) {
	    s_param(param);
	}
	fprintf(cfg, ")");
    }
    else
	fprintf(cfg, "\nmain()");

    fprintf(cfg, "\t\t[%s0-%d]\n", blockName, blockNum - 1);

    for (int i = 0; i < blockNum; ++i) {
	fprintf(cfg, "\n%s%d\n{\n%s}\n", blockName, i, blockArr[i].context);

	comma = "";
	fprintf(cfg, "Predecessor: ");
	if (i == 0) {
	    fprintf(cfg, "start");
	    comma = ", ";
	}
	
	int predNum = blockInfoArr[i].predNum;
	for (int j = 0; j < predNum; ++j) {
	    fprintf(cfg, "%s%s%d", comma, blockName, blockArr[i].pred[j]);
	    comma = ", ";
	}

	comma = "";
	fprintf(cfg, "\nSuccessor: ");
	int succNum = blockInfoArr[i].succNum;
	for (int j = 0; j < succNum; ++j) {
	    if (blockArr[i].succ[j] == -1) {
		fprintf(cfg, "%send", comma);
	    }
	    else
		fprintf(cfg, "%s%s%d", comma, blockName, blockArr[i].succ[j]);
	    comma = ", ";
	}
	fprintf(cfg, "\n");
    }
}
