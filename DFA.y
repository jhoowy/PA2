%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "DFA.h"
#include "print.h"
%}

%union {
	struct Program	*ptr_Program;
	struct Class	*ptr_Class;
	struct Member	*ptr_Member;
	struct VarDecl	*ptr_VarDecl;
	struct MethodDecl	*ptr_MethodDecl;
	struct MethodDef	*ptr_MethodDef;
	struct ClassMethodDef	*ptr_ClassMethodDef;
	struct MainFunc	*ptr_MainFunc;
	struct Param	*ptr_Param;
	struct Ident	*ptr_Ident;
	struct Type	*ptr_Type;
	struct CompoundStmt	*ptr_CompoundStmt;
	struct Stmt	*ptr_Stmt;
	struct ExprStmt	*ptr_ExprStmt;
	struct AssignStmt	*ptr_AssignStmt;
	struct RetStmt	*ptr_RetStmt;
	struct WhileStmt	*ptr_WhileStmt;
	struct DoStmt	*ptr_DoStmt;
	struct ForStmt	*ptr_ForStmt;
	struct IfStmt	*ptr_IfStmt;
	struct Expr	*ptr_Expr;
	struct OperExpr	*ptr_OperExpr;
	struct RefExpr	*ptr_RefExpr;
	struct RefVarExpr	*ptr_RefVarExpr;
	struct RefCallExpr	*ptr_RefCallExpr;
	struct IdentExpr	*ptr_IdentExpr;
	struct CallExpr	*ptr_CallExpr;
	struct Arg	*ptr_Arg;
	struct UnOp	*ptr_UnOp;
	struct AddiOp	*ptr_AddiOp;
	struct MultOp	*ptr_MultOp;
	struct RelaOp	*ptr_RelaOp;
	struct EqltOp	*ptr_EqltOp;
	int intnum;
	float floatnum;
	char* str;
}

%token <intnum>INTNUM <floatnum>FLOATNUM <str>ID
%token CLS PRIVATE PUBLIC INT FLOAT MAIN RETURN WHILE DO FOR IF SCOPE

%right '='
%left EQ NE
%left LT GT LE GE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%nonassoc IFX
%nonassoc ELSE

%type <ptr_Program> PROGRAM;
%type <ptr_Class> CLASS;
%type <ptr_Member> MEMBER;
%type <ptr_VarDecl> VARDECL;
%type <ptr_MethodDecl> METHODDECL;
%type <ptr_MethodDef> METHODDEF;
%type <ptr_ClassMethodDef> CLASSMETHODDEF;
%type <ptr_MainFunc> MAINFUNC;
%type <ptr_Param> PARAM;
%type <ptr_Ident> IDENT;
%type <ptr_Type> TYPE;
%type <ptr_CompoundStmt> COMPOUNDSTMT;
%type <ptr_Stmt> STMT;
%type <ptr_Stmt> SINGLESTMT;
%type <ptr_ExprStmt> EXPRSTMT;
%type <ptr_AssignStmt> ASSIGNSTMT;
%type <ptr_RetStmt> RETSTMT;
%type <ptr_WhileStmt> WHILESTMT;
%type <ptr_DoStmt> DOSTMT;
%type <ptr_ForStmt> FORSTMT;
%type <ptr_IfStmt> IFSTMT;
%type <ptr_Expr> EXPR;
%type <ptr_OperExpr> OPEREXPR;
%type <ptr_RefExpr> REFEXPR;
%type <ptr_RefVarExpr> REFVAREXPR;
%type <ptr_RefCallExpr> REFCALLEXPR;
%type <ptr_IdentExpr> IDENTEXPR;
%type <ptr_CallExpr> CALLEXPR;
%type <ptr_Arg> ARG;
%type <ptr_UnOp> UNOP;
%type <ptr_AddiOp> ADDIOP;
%type <ptr_MultOp> MULTOP;
%type <ptr_RelaOp> RELAOP;
%type <ptr_EqltOp> EQLTOP;

%%

PROGRAM :
    CLASS CLASSMETHODDEF MAINFUNC {
	struct Program *program = (struct Program*)malloc(sizeof(struct Program));
	program->_class = $1;
	program->classMethodDef = $2;
	program->mainFunc = $3;
	head = program;
	$$ = program;
    }

|   CLASS MAINFUNC {
	struct Program *program = (struct Program*)malloc(sizeof(struct Program));
	program->_class = $1;
	program->classMethodDef = NULL;
	program->mainFunc = $2;
	head = program;
	$$ = program;
    }
|   CLASSMETHODDEF MAINFUNC {
	struct Program *program = (struct Program*)malloc(sizeof(struct Program));
	program->_class = NULL;
	program->classMethodDef = $1;
	program->mainFunc = $2;
	head = program;
	$$ = program;
    }
|   MAINFUNC {
	struct Program *program = (struct Program*)malloc(sizeof(struct Program));
	program->_class = NULL;
	program->classMethodDef = NULL;
	program->mainFunc = $1;
	head = program;
	$$ = program;
    }
;

CLASS : 
    CLASS CLS ID '{' PRIVATE ':' MEMBER PUBLIC ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $3;
	class_->priMember = $7;
	class_->pubMember = $10;
	class_->prev = $1;
	$$ = class_;
    }
|   CLASS CLS ID '{' PRIVATE ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $3;
	class_->priMember = $7;
	class_->pubMember = NULL;
	class_->prev = $1;
	$$ = class_;
    }
|   CLASS CLS ID '{' PUBLIC ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $3;
	class_->priMember = NULL;
	class_->pubMember = $7;
	class_->prev = $1;
	$$ = class_;
    }
|   CLASS CLS ID '{' '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $3;
	class_->priMember = NULL;
	class_->pubMember = NULL;
	class_->prev = $1;
	$$ = class_;
    }
|   CLS ID '{' PRIVATE ':' MEMBER PUBLIC ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $2;
	class_->priMember = $6;
	class_->pubMember = $9;
	class_->prev = NULL;
	$$ = class_;
    }
|   CLS ID '{' PRIVATE ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $2;
	class_->priMember = $6;
	class_->pubMember = NULL;
	class_->prev = NULL;
	$$ = class_;
    }
|   CLS ID '{' PUBLIC ':' MEMBER '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $2;
	class_->priMember = NULL;
	class_->pubMember = $6;
	class_->prev = NULL;
	$$ = class_;
    }
|   CLS ID '{' '}' {
	struct Class *class_ = (struct Class*)malloc(sizeof(struct Class));
	class_->id = $2;
	class_->priMember = NULL;
	class_->pubMember = NULL;
	class_->prev = NULL;
	$$ = class_;
    }
;

MEMBER : 
    VARDECL METHODDECL METHODDEF {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = $1;
	member->methodDecl = $2;
	member->methodDef = $3;
	$$ = member;
    }
|   VARDECL METHODDECL {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = $1;
	member->methodDecl = $2;
	member->methodDef = NULL;
	$$ = member;
    }
|   VARDECL METHODDEF {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = $1;
	member->methodDecl = NULL;
	member->methodDef = $2;
	$$ = member;
    }
|   METHODDECL METHODDEF {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = NULL;
	member->methodDecl = $1;
	member->methodDef = $2;
	$$ = member;
    }
|   VARDECL {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = $1;
	member->methodDecl = NULL;
	member->methodDef = NULL;
	$$ = member;
    }
|   METHODDECL {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = NULL;
	member->methodDecl = $1;
	member->methodDef = NULL;
	$$ = member;
    }
|   METHODDEF {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = NULL;
	member->methodDecl = NULL;
	member->methodDef = $1;
	$$ = member;
    }
|   {
	struct Member *member = (struct Member*)malloc(sizeof(struct Member));
	member->varDecl = NULL;
	member->methodDecl = NULL;
	member->methodDef = NULL;
	$$ = member;
    }
;

VARDECL :
    VARDECL TYPE IDENT '=' INTNUM ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $2;
	vardecl->ident = $3;
	vardecl->assignType = eAsInt;
	vardecl->assigner.intnum = $5;
	vardecl->prev = $1;
	$$ = vardecl;
    }
|   VARDECL TYPE IDENT '=' FLOATNUM ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $2;
	vardecl->ident = $3;
	vardecl->assignType = eAsFloat;
	vardecl->assigner.floatnum = $5;
	vardecl->prev = $1;
	$$ = vardecl;
    }
|   VARDECL TYPE IDENT ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $2;
	vardecl->ident = $3;
	vardecl->assignType = eNon;
	vardecl->prev = $1;
	$$ = vardecl;
    }
|   TYPE IDENT '=' INTNUM ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $1;
	vardecl->ident = $2;
	vardecl->assignType = eAsInt;
	vardecl->assigner.intnum = $4;
	vardecl->prev = NULL;
	$$ = vardecl;
    }
|   TYPE IDENT '=' FLOATNUM ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $1;
	vardecl->ident = $2;
	vardecl->assignType = eAsFloat;
	vardecl->assigner.floatnum = $4;
	vardecl->prev = NULL;
	$$ = vardecl;
    }
|   TYPE IDENT ';' {
	struct VarDecl *vardecl = (struct VarDecl*)malloc(sizeof(struct VarDecl));
	vardecl->type = $1;
	vardecl->ident = $2;
	vardecl->assignType = eNon;
	vardecl->prev = NULL;
	$$ = vardecl;
    }
;

METHODDECL :
    METHODDECL TYPE ID '(' PARAM ')' ';' {
	struct MethodDecl *methoddecl = (struct MethodDecl*)malloc(sizeof(struct MethodDecl));
	methoddecl->id = $3;
	methoddecl->type = $2;
	methoddecl->param = $5;
	methoddecl->prev = $1;
	$$ = methoddecl;
    }
|   METHODDECL TYPE ID '(' ')' ';' {
	struct MethodDecl *methoddecl = (struct MethodDecl*)malloc(sizeof(struct MethodDecl));
	methoddecl->id = $3;
	methoddecl->type = $2;
	methoddecl->param = NULL;
	methoddecl->prev = $1;
	$$ = methoddecl;
    }
|   TYPE ID '(' PARAM ')' ';' {
	struct MethodDecl *methoddecl = (struct MethodDecl*)malloc(sizeof(struct MethodDecl));
	methoddecl->id = $2;
	methoddecl->type = $1;
	methoddecl->param = $4;
	methoddecl->prev = NULL;
	$$ = methoddecl;
    }
|   TYPE ID '(' ')' ';' {
	struct MethodDecl *methoddecl = (struct MethodDecl*)malloc(sizeof(struct MethodDecl));
	methoddecl->id = $2;
	methoddecl->type = $1;
	methoddecl->param = NULL;
	methoddecl->prev = NULL;
	$$ = methoddecl;
    }
;

METHODDEF :
    METHODDEF TYPE ID '(' PARAM ')' COMPOUNDSTMT {
	struct MethodDef *methoddef = (struct MethodDef*)malloc(sizeof(struct MethodDef));
	methoddef->id = $3;
	methoddef->type = $2;
	methoddef->param = $5;
	methoddef->compoundStmt = $7;
	methoddef->prev = $1;
	$$ = methoddef;
    }
|   METHODDEF TYPE ID '(' ')' COMPOUNDSTMT {
	struct MethodDef *methoddef = (struct MethodDef*)malloc(sizeof(struct MethodDef));
	methoddef->id = $3;
	methoddef->type = $2;
	methoddef->param = NULL;
	methoddef->compoundStmt = $6;
	methoddef->prev = $1;
	$$ = methoddef;
    }
|   TYPE ID '(' PARAM ')' COMPOUNDSTMT {
	struct MethodDef *methoddef = (struct MethodDef*)malloc(sizeof(struct MethodDef));
	methoddef->id = $2;
	methoddef->type = $1;
	methoddef->param = $4;
	methoddef->compoundStmt = $6;
	methoddef->prev = NULL;
	$$ = methoddef;
    }
|   TYPE ID '(' ')' COMPOUNDSTMT {
	struct MethodDef *methoddef = (struct MethodDef*)malloc(sizeof(struct MethodDef));
	methoddef->id = $2;
	methoddef->type = $1;
	methoddef->param = NULL;
	methoddef->compoundStmt = $5;
	methoddef->prev = NULL;
	$$ = methoddef;
    }
;

CLASSMETHODDEF :
    CLASSMETHODDEF TYPE ID SCOPE ID '(' PARAM ')' COMPOUNDSTMT {
	struct ClassMethodDef *classmethoddef = (struct ClassMethodDef*)malloc(sizeof(struct ClassMethodDef));
	classmethoddef->type = $2;
	classmethoddef->className = $3;
	classmethoddef->methodName = $5;
	classmethoddef->param = $7;
	classmethoddef->compoundStmt = $9;
	classmethoddef->prev = $1;
	$$ = classmethoddef;
    }
|   CLASSMETHODDEF TYPE ID SCOPE ID '(' ')' COMPOUNDSTMT {
	struct ClassMethodDef *classmethoddef = (struct ClassMethodDef*)malloc(sizeof(struct ClassMethodDef));
	classmethoddef->type = $2;
	classmethoddef->className = $3;
	classmethoddef->methodName = $5;
	classmethoddef->param = NULL;
	classmethoddef->compoundStmt = $8;
	classmethoddef->prev = $1;
	$$ = classmethoddef;
    }
|   TYPE ID SCOPE ID '(' PARAM ')' COMPOUNDSTMT {
	struct ClassMethodDef *classmethoddef = (struct ClassMethodDef*)malloc(sizeof(struct ClassMethodDef));
	classmethoddef->type = $1;
	classmethoddef->className = $2;
	classmethoddef->methodName = $4;
	classmethoddef->param = $6;
	classmethoddef->compoundStmt = $8;
	classmethoddef->prev = NULL;
	$$ = classmethoddef;
    }
|   TYPE ID SCOPE ID '(' ')' COMPOUNDSTMT {
	struct ClassMethodDef *classmethoddef = (struct ClassMethodDef*)malloc(sizeof(struct ClassMethodDef));
	classmethoddef->type = $1;
	classmethoddef->className = $2;
	classmethoddef->methodName = $4;
	classmethoddef->param = NULL;
	classmethoddef->compoundStmt = $7;
	classmethoddef->prev = NULL;
	$$ = classmethoddef;
    }
;

MAINFUNC :
    INT MAIN '(' ')' COMPOUNDSTMT {
	struct MainFunc *mainfunc = (struct MainFunc*)malloc(sizeof(struct MainFunc));
	mainfunc->compoundStmt = $5;
	$$ = mainfunc;
    }
;

PARAM :
    PARAM ',' TYPE IDENT {
	struct Param *param = (struct Param*)malloc(sizeof(struct Param));
	param->type = $3;
	param->ident = $4;
	param->prev = $1;
	$$ = param;
    }
|   TYPE IDENT {
	struct Param *param = (struct Param*)malloc(sizeof(struct Param));
	param->type = $1;
	param->ident = $2;
	param->prev = NULL;
	$$ = param;
    }
;

IDENT :
    ID {
	struct Ident *ident = (struct Ident*)malloc(sizeof(struct Ident));
	ident->id = $1;
	ident->len = 0;
	$$ = ident;
    }
|   ID '[' INTNUM ']' {
	struct Ident *ident = (struct Ident*)malloc(sizeof(struct Ident));
	ident->id = $1;
	ident->len = $3;
	$$ = ident;
    }
;

TYPE :
    INT {
	struct Type *type = (struct Type*)malloc(sizeof(struct Type));
	type->id = NULL;
	type->e = eInt;
	$$ = type;
    }
|   FLOAT {
	struct Type *type = (struct Type*)malloc(sizeof(struct Type));
	type->id = NULL;
	type->e = eFloat;
	$$ = type;
    }
|   ID {
	struct Type *type = (struct Type*)malloc(sizeof(struct Type));
	type->id = $1;
	type->e = eClass;
	$$ = type;
    }
;

COMPOUNDSTMT :
    '{' VARDECL STMT '}' {
	struct CompoundStmt *compoundstmt = (struct CompoundStmt*)malloc(sizeof(struct CompoundStmt));
	compoundstmt->varDecl = $2;
	compoundstmt->stmt = $3;
	$$ = compoundstmt;
    }
|   '{' VARDECL '}' {
	struct CompoundStmt *compoundstmt = (struct CompoundStmt*)malloc(sizeof(struct CompoundStmt));
	compoundstmt->varDecl = $2;
	compoundstmt->stmt = NULL;
	$$ = compoundstmt;
    }
|   '{' STMT '}' {
	struct CompoundStmt *compoundstmt = (struct CompoundStmt*)malloc(sizeof(struct CompoundStmt));
	compoundstmt->varDecl = NULL;
	compoundstmt->stmt = $2;
	$$ = compoundstmt;
    }
|   '{' '}' {
	struct CompoundStmt *compoundstmt = (struct CompoundStmt*)malloc(sizeof(struct CompoundStmt));
	compoundstmt->varDecl = NULL;
	compoundstmt->stmt = NULL;
	$$ = compoundstmt;
    }
;

STMT :
    STMT EXPRSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eExpr;
	stmt->type.exprStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT ASSIGNSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eAssign;
	stmt->type.assignStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT RETSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eRet;
	stmt->type.retStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT WHILESTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eWhile;
	stmt->type.whileStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT DOSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eDo;
	stmt->type.doStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT FORSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eFor;
	stmt->type.forStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT IFSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eIf;
	stmt->type.ifStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT COMPOUNDSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eCompound;
	stmt->type.compoundStmt = $2;
	stmt->prev = $1;
	$$ = stmt;
    }
|   STMT ';' {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eSemi;
	stmt->prev = $1;
	$$ = stmt;
    }
|   EXPRSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eExpr;
	stmt->type.exprStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   ASSIGNSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eAssign;
	stmt->type.assignStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   RETSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eRet;
	stmt->type.retStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   WHILESTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eWhile;
	stmt->type.whileStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   DOSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eDo;
	stmt->type.doStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   FORSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eFor;
	stmt->type.forStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   IFSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eIf;
	stmt->type.ifStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   COMPOUNDSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eCompound;
	stmt->type.compoundStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   ';' {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eSemi;
	stmt->prev = NULL;
	$$ = stmt;
    }
;

SINGLESTMT :
    EXPRSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eExpr;
	stmt->type.exprStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   ASSIGNSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eAssign;
	stmt->type.assignStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   RETSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eRet;
	stmt->type.retStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   WHILESTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eWhile;
	stmt->type.whileStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   DOSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eDo;
	stmt->type.doStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   FORSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eFor;
	stmt->type.forStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   IFSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eIf;
	stmt->type.ifStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   COMPOUNDSTMT {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eCompound;
	stmt->type.compoundStmt = $1;
	stmt->prev = NULL;
	$$ = stmt;
    }
|   ';' {
	struct Stmt *stmt = (struct Stmt*)malloc(sizeof(struct Stmt));
	stmt->e = eSemi;
	stmt->prev = NULL;
	$$ = stmt;
    }
;

EXPRSTMT :
    EXPR ';' {
	struct ExprStmt *exprstmt = (struct ExprStmt*)malloc(sizeof(struct ExprStmt));
	exprstmt->expr = $1;
	$$ = exprstmt;
    }
;

ASSIGNSTMT :
    REFVAREXPR '=' EXPR ';' {
	struct AssignStmt *assignstmt = (struct AssignStmt*)malloc(sizeof(struct AssignStmt));
	assignstmt->refVarExpr = $1;
	assignstmt->expr = $3;
	$$ = assignstmt;
    }
;

RETSTMT :
    RETURN EXPR ';' {
	struct RetStmt *retstmt = (struct RetStmt*)malloc(sizeof(struct RetStmt));
	retstmt->expr = $2;
	$$ = retstmt;
    }
;

WHILESTMT :
    WHILE '(' EXPR ')' SINGLESTMT {
	struct WhileStmt *whilestmt = (struct WhileStmt*)malloc(sizeof(struct WhileStmt));
	whilestmt->cond = $3;
	whilestmt->body = $5;
	$$ = whilestmt;
    }
;

DOSTMT :
    DO SINGLESTMT WHILE '(' EXPR ')' ';' {
	struct DoStmt *dostmt = (struct DoStmt*)malloc(sizeof(struct DoStmt));
	dostmt->cond = $5;
	dostmt->body = $2;
	$$ = dostmt;
    }
;

FORSTMT :
    FOR '(' EXPR ';' EXPR ';' EXPR ')' SINGLESTMT {
	struct ForStmt *forstmt = (struct ForStmt*)malloc(sizeof(struct ForStmt));
	forstmt->init = $3;
	forstmt->cond = $5;
	forstmt->incr = $7;
	forstmt->body = $9;
	$$ = forstmt;
    }
;

IFSTMT :
    IF '(' EXPR ')' SINGLESTMT %prec IFX {
	struct IfStmt *ifstmt = (struct IfStmt*)malloc(sizeof(struct IfStmt));
	ifstmt->cond = $3;
	ifstmt->ifBody = $5;
	ifstmt->elseBody = NULL;
	$$ = ifstmt;
    }
|   IF '(' EXPR ')' SINGLESTMT ELSE SINGLESTMT {
	struct IfStmt *ifstmt = (struct IfStmt*)malloc(sizeof(struct IfStmt));
	ifstmt->cond = $3;
	ifstmt->ifBody = $5;
	ifstmt->elseBody = $7;
	$$ = ifstmt;
    }

EXPR :
    OPEREXPR {
	struct Expr *expr = (struct Expr*)malloc(sizeof(struct Expr));
	expr->e = eOper;
	expr->type.operExpr = $1;
	$$ = expr;
    }
|   REFEXPR {
	struct Expr *expr = (struct Expr*)malloc(sizeof(struct Expr));
	expr->e = eRef;
	expr->type.refExpr = $1;
	$$ = expr;
    }
|   INTNUM {
	struct Expr *expr = (struct Expr*)malloc(sizeof(struct Expr));
	expr->e = eIntnum;
	expr->type.intnum = $1;
	$$ = expr;
    }
|   FLOATNUM {
	struct Expr *expr = (struct Expr*)malloc(sizeof(struct Expr));
	expr->e = eFloatnum;
	expr->type.floatnum = $1;
	$$ = expr;
    }
;

OPEREXPR :
    UNOP %prec UMINUS {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eUn;
	operexpr->type.un = $1;
	$$ = operexpr;
    }
|   ADDIOP {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eAddi;
	operexpr->type.addi = $1;
	$$ = operexpr;
    }
|   MULTOP {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eMult;
	operexpr->type.mult = $1;
	$$ = operexpr;
    }
|   RELAOP {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eRela;
	operexpr->type.rela = $1;
	$$ = operexpr;
    }
|   EQLTOP {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eEqlt;
	operexpr->type.eqlt = $1;
	$$ = operexpr;
    }
|   '(' EXPR ')' {
	struct OperExpr *operexpr = (struct OperExpr*)malloc(sizeof(struct OperExpr));
	operexpr->e = eBracket;
	operexpr->type.bracket = $2;
	$$ = operexpr;
    }
;

REFEXPR :
    REFVAREXPR {
	struct RefExpr *refexpr = (struct RefExpr*)malloc(sizeof(struct RefExpr));
	refexpr->e = eVar;
	refexpr->type.refVarExpr = $1;
	$$ = refexpr;
    }
|   REFCALLEXPR {
	struct RefExpr *refexpr = (struct RefExpr*)malloc(sizeof(struct RefExpr));
	refexpr->e = eCall;
	refexpr->type.refCallExpr = $1;
	$$ = refexpr;
    }
;

REFVAREXPR :
    REFEXPR '.' IDENTEXPR {
	struct RefVarExpr *refvarexpr = (struct RefVarExpr*)malloc(sizeof(struct RefVarExpr));
	refvarexpr->refExpr = $1;
	refvarexpr->identExpr = $3;
	$$ = refvarexpr;
    }
|   IDENTEXPR {
	struct RefVarExpr *refvarexpr = (struct RefVarExpr*)malloc(sizeof(struct RefVarExpr));
	refvarexpr->refExpr = NULL;
	refvarexpr->identExpr = $1;
	$$ = refvarexpr;
    }
;

REFCALLEXPR :
    REFEXPR '.' CALLEXPR {
	struct RefCallExpr *refcallexpr = (struct RefCallExpr*)malloc(sizeof(struct RefCallExpr));
	refcallexpr->refExpr = $1;
	refcallexpr->callExpr = $3;
	$$ = refcallexpr;
    }
|   CALLEXPR {
	struct RefCallExpr *refcallexpr = (struct RefCallExpr*)malloc(sizeof(struct RefCallExpr));
	refcallexpr->refExpr = NULL;
	refcallexpr->callExpr = $1;
	$$ = refcallexpr;
    }
;

IDENTEXPR :
    ID '[' EXPR ']' {
	struct IdentExpr *identexpr = (struct IdentExpr*)malloc(sizeof(struct IdentExpr));
	identexpr->id = $1;
	identexpr->expr = $3;
	$$ = identexpr;
    }
|   ID {
	struct IdentExpr *identexpr = (struct IdentExpr*)malloc(sizeof(struct IdentExpr));
	identexpr->id = $1;
	identexpr->expr = NULL;
	$$ = identexpr;
    }
;

CALLEXPR :
    ID '(' ARG ')' {
	struct CallExpr *callexpr = (struct CallExpr*)malloc(sizeof(struct CallExpr));
	callexpr->id = $1;
	callexpr->arg = $3;
	$$ = callexpr;
    }
|   ID '(' ')' {
	struct CallExpr *callexpr = (struct CallExpr*)malloc(sizeof(struct CallExpr));
	callexpr->id = $1;
	callexpr->arg = NULL;
	$$ = callexpr;
    }
;

ARG :
    ARG ',' EXPR {
	struct Arg *arg = (struct Arg*)malloc(sizeof(struct Arg));
	arg->expr = $3;
	arg->prev = $1;
	$$ = arg;
    }
|   EXPR {
	struct Arg *arg = (struct Arg*)malloc(sizeof(struct Arg));
	arg->expr = $1;
	arg->prev = NULL;
	$$ = arg;
    }
;

UNOP :
    '-' EXPR {
	struct UnOp *unop = (struct UnOp*)malloc(sizeof(struct UnOp));
	unop->e = eNegative;
	unop->expr = $2;
	$$ = unop;
    }
;

ADDIOP :
    EXPR '+' EXPR {
	struct AddiOp *addiop = (struct AddiOp*)malloc(sizeof(struct AddiOp));
	addiop->e = ePlus;
	addiop->lhs = $1;
	addiop->rhs = $3;
	$$ = addiop;
    }
|   EXPR '-' EXPR {
	struct AddiOp *addiop = (struct AddiOp*)malloc(sizeof(struct AddiOp));
	addiop->e = eMinus;
	addiop->lhs = $1;
	addiop->rhs = $3;
	$$ = addiop;
    }
;

MULTOP :
    EXPR '*' EXPR {
	struct MultOp *multop = (struct MultOp*)malloc(sizeof(struct MultOp));
	multop->e = eMul;
	multop->lhs = $1;
	multop->rhs = $3;
	$$ = multop;
    }
|   EXPR '/' EXPR {
	struct MultOp *multop = (struct MultOp*)malloc(sizeof(struct MultOp));
	multop->e = eDiv;
	multop->lhs = $1;
	multop->rhs = $3;
	$$ = multop;
    }
;

RELAOP :
    EXPR LT EXPR {
	struct RelaOp *relaop = (struct RelaOp*)malloc(sizeof(struct RelaOp));
	relaop->e = eLT;
	relaop->lhs = $1;
	relaop->rhs = $3;
	$$ = relaop;
    }
|   EXPR GT EXPR {
	struct RelaOp *relaop = (struct RelaOp*)malloc(sizeof(struct RelaOp));
	relaop->e = eGT;
	relaop->lhs = $1;
	relaop->rhs = $3;
	$$ = relaop;
    }
|   EXPR LE EXPR {
	struct RelaOp *relaop = (struct RelaOp*)malloc(sizeof(struct RelaOp));
	relaop->e = eLE;
	relaop->lhs = $1;
	relaop->rhs = $3;
	$$ = relaop;
    }
|   EXPR GE EXPR {
	struct RelaOp *relaop = (struct RelaOp*)malloc(sizeof(struct RelaOp));
	relaop->e = eGE;
	relaop->lhs = $1;
	relaop->rhs = $3;
	$$ = relaop;
    }
;

EQLTOP :
    EXPR EQ EXPR {
	struct EqltOp *eqltop = (struct EqltOp*)malloc(sizeof(struct EqltOp));
	eqltop->e = eEQ;
	eqltop->lhs = $1;
	eqltop->rhs = $3;
	$$ = eqltop;
    }
|   EXPR NE EXPR {
	struct EqltOp *eqltop = (struct EqltOp*)malloc(sizeof(struct EqltOp));
	eqltop->e = eNE;
	eqltop->lhs = $1;
	eqltop->rhs = $3;
	$$ = eqltop;
    }
;

%%

int yyerror (char *s) {
	return fprintf (stderr, "%s\n", s);
}
