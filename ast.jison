/* Definición Léxica */
%lex

%options case-insensitive

%%

";"                 return 'SEMICOLON';
","                 return 'COMMA';
":"                 return 'COLON';
"."                 return 'DOT';

"("                 return 'L_PAR';
")"                 return 'R_PAR';
"["                 return 'L_SQUARE';
"]"                 return 'R_SQUARE';
"{"                 return 'L_CURLY';
"}"                 return 'R_CURLY';

"++"                return 'INCREMENT';
"--"                return 'DECREMENT';

"+"                 return 'PLUS';
"-"                 return 'MINUS';
"*"                 return 'MULTIPLY';
"/"                 return 'DIVIDE';
"%"                 return 'REMAINDER';

">>"                return 'R_SHIFT';
"<<"                return 'L_SHIFT';
"<="                return 'LESS_EQUAL';
">="                return 'GREATER_EQUAL';
"<"                 return 'LESS';
">"                 return 'GREATER';
"!="                return 'NOT_EQUAL';
"&&"                return 'AND';
"||"                return 'OR';
"!"                 return 'NOT';

"&"                 return 'BIN_AND';
"|"                 return 'BIN_OR';
"~"                 return 'BIN_NOT';
"^"                 return 'BIN_XOR';

"if"                return 'IF';
"else"              return 'ELSE';
"switch"            return 'SWITCH';
"case"              return 'CASE';
"default"           return 'DEFAULT';
"break"             return 'BREAK';
"continue"          return 'CONTINUE';
"return"            return 'RETURN';
"while"             return 'WHILE';
"do"                return 'DO';
"for"               return 'FOR';
"in"                return 'IN';
"of"                return 'OF';
"console.log"		return 'CONSOLE_LOG';
"graficar_ts"		return 'GRAFICAR_TS';


"?"                 return 'QUESTION';
"=="                return 'EQUAL';
"="                 return 'ASSIGN';


"number"            return 'NUMBER';
"string"            return 'STRING';
"boolean"           return 'BOOLEAN';
"void"              return 'VOID';
"types"             return 'TYPES';
"push"              return 'PUSH';
"pop"               return 'POP';
"length"            return 'LENGTH';
"let"               return 'LET';
"const"             return 'CONST';
"var"               return 'VAR';
"function"          return 'FUNCTION';
/*"true"				return 'TRUE';
"false"				return 'FALSE';*/



/* Espacios en blanco */
[ \r\t]+            {}
\n                  {}

[0-9]+("."[0-9]+)?\b    				return 'DECIMAL';
[0-9]+\b                				return 'INTEGER';
((\").*?(\"))|((\').*?(\'))				return 'STRING';
[a-zA-Z_][a-aA-Z_0-9]*					return	'NAME';


<<EOF>>                 return 'EOF';
.                       { console.error('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column); }
/lex

/* Asociación de operadores y precedencia */

%left 'PLUS' 'MINUS'
%left 'MULTIPLY' 'DIVIDE'
%left UMINUS


%{
%}


%start S

%% /* Definición de la gramática */

S
	: decls EOF
	{
		return $1;
	}
;

decls
	: decl decls
	{
		let decls = [$1];
		if($2 != null)
		{
			$2.forEach(element => decls.push(element));
		}
		$$ = decls;
	}
	|
	{
		$$ = null;
	}
;

decl
	: func_decl DOT DOT DOT
	{
		$$ = $1;
	}
	| stm_list
	{
		$$ = $1;
	}
;

func_decl
	: FUNCTION NAME L_PAR params R_PAR return_type block_decl
	{
        let stringFuncDecl1 = 'func_decl'+nodeCounter;
		let func_decl1 =  stringFuncDecl1+'->'+$1+';';
        func_decl1 += stringFuncDecl1+'->'+$2+';';
        func_decl1 += stringFuncDecl1+'->'+$4+';';
        func_decl1 += stringFuncDecl1+'->'+$6+';';
        func_decl1 += stringFuncDecl1+'->'+$7+';';
        dotData += func_decl1;
        $$ = stringFuncDecl1;
        nodeCounter++;
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		let stringFuncDecl2 = 'func_decl'+nodeCounter;
		let func_decl2 =  stringFuncDecl2+'->'+$1+';';
        func_decl2 += stringFuncDecl2+'->'+$2+';';
        func_decl2 += stringFuncDecl2+'->'+$4+';';
        func_decl2 += stringFuncDecl2+'->'+$6+';';
		dotData += func_decl2;
        $$ = stringFuncDecl2;
        nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		let stringFuncDecl3 = 'func_decl'+nodeCounter;
		let func_decl3 =  stringFuncDecl3+'->'+$1+';';
        func_decl3 += stringFuncDecl3+'->'+$2+';';
        func_decl3 += stringFuncDecl3+'->'+$5+';';
        func_decl3 += stringFuncDecl3+'->'+$6+';';
		dotData += func_decl3;
        $$ = stringFuncDecl3;
        nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		let stringFuncDecl4 = 'func_decl'+nodeCounter;
		let func_decl4 =  stringFuncDecl4+'->'+$1+';';
        func_decl4 += stringFuncDecl4+'->'+$2+';';
        func_decl4 += stringFuncDecl4+'->'+$5+';';
		dotData += func_decl4;
        $$ = stringFuncDecl4;
        nodeCounter++;
	}
;

params
	: param COMMA params
	{
		let paramsList = [$1];
		if($3 != null)
		{
			$3.forEach(element => paramsList.push(element));
		}
		$$ = paramsList;
	}
	| param
	{
		$$ = [$1];
	}
;

param
	: NAME return_type
	{
        let stringParam1 = 'param'+nodeCounter;
        let param1 = stringParam1+'->'+$1;
        param1 += stringParam1+'->'+$2;
		$$ = stringParam1;
        nodeCounter++;
	}
	| NAME
	{
		let stringParam2 = 'param'+nodeCounter;
        let param2 = stringParam2+'->'+$1;
        param2 += stringParam2+'->'+$2;
		$$ = stringParam2;
        nodeCounter++;
	}
;

return_type
	: COLON type
	{
		$$ = $2;
	}
;

type
	: NUMBER
	{
		$$ = $1;
	}	
	| STRING
	{
		$$ = $1;
	}	
	| BOOLEAN
	{
		$$ = $1;
	}	
	| VOID
	{
		$$ = $1;
	}
;

block_decl
	: L_CURLY stm_list R_CURLY
	{
		$$ = $2;
	}
;

stm_list
	: stm stm_list
	{
		let stmList = [$1];
		if($2 != null)
		{
			$2.forEach(element => stmList.push(element));
		}
		$$ = stmList;
	}
	|
	{
		$$ = null;
	}
;

stm
	: func_decl
	{
		$$ = $1;
	}
	| var_decl SEMICOLON
	{
		$$ = $1;
	}
	| IF L_PAR expr	R_PAR stm ELSE stm
	{
		$$ = create_ifelse($3, $5, $7);
	}
	| IF L_PAR expr R_PAR stm
	{
		$$ =  create_if($3, $5);
	}
	| WHILE L_PAR expr R_PAR stm
	{
		$$ = create_while($3, $5);
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR stm
	{
		$$ = create_for($3, $5, $7, $9);
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR stm
	{
		$$ =  create_forof($4, $6, $8);
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR stm
	{
		$$ =  create_forin($4, $6, $8);
	}
	| normal_stm
	{
		$$ = $1;
	}
;

then_stm
	: IF L_PAR expr	R_PAR then_stm ELSE then_stm
	{
		$$ = create_ifelse($3, $5, $7);
	}
	| IF L_PAR expr	R_PAR then_stm
	{
		$$ = create_if($3, $5);
	}
	| WHILE L_PAR expr R_PAR then_stm
	{
		$$ = create_while($3, $5);
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR then_stm
	{
		$$ = create_for($3, $5, $7, $9);
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR then_stm
	{
		$$ =  create_forof($4, $6, $8);
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR then_stm
	{
		$$ =  create_forin($4, $6, $8);
	}
	| normal_stm
	{
		$$ = $1;
	}
;

normal_stm
	: DO stm WHILE L_PAR expr R_PAR SEMICOLON
	{
		$$ = create_dowhile($5, $2);
	}
	| SWITCH L_PAR expr R_PAR L_CURLY case_stm R_CURLY
	{
		$$ = create_switch($3, $6);
	}
	| block_decl
	{
		$$ = $1;
	}
	| expr SEMICOLON
	{
		// does nothing
		$$ = $1;
	}
	| BREAK SEMICOLON
	{
		$$ = create_break();
	}
	| CONTINUE SEMICOLON
	{
		$$ =  create_continue();
	}
	| RETURN expr SEMICOLON
	{
		$$ = create_return($2);
	}
	| SEMICOLON
	{
		// does nothing
	}
	| func_decl
	{
		$$ = $1;
	}
	| CONSOLE_LOG L_PAR expr R_PAR SEMICOLON
	{
		$$ = create_consolelog($3);
	}
	| GRAFICAR_TS L_PAR R_PAR SEMICOLON
	{
		$$ = create_graficarTS();
	}
;

var_decl
	: scope var_element var_list
	{
		let varList = [$2];
		if($3 != null)
		{
			$3.forEach(element => varList.push(element));
		}
		$$ = create_declaration($1, varList);
	}
;

scope
	: VAR
	{
		$$ = $1;
	}
	| LET
	{
		$$ = $1;
	}
	| CONST
	{
		$$ = $1;
	}
;

var_element
	: NAME dec_type dec_assign
	{
		let element = {
			model: 'VarElement',
			id: $1,
			type: $2 == null? null : $2.type,
			array: $2 == null? null : $2.array,
			value: $3
		};
		$$ = element;
	}
;

var_list
	: COMMA var_element var_list
	{
		let a = [$2];
		if($3 != null)
		{
			$3.forEach(element => a.push(element));
			$$ = a;
		}
		else
		{
			$$ = a;
		}
	}
	|
	{
		$$ = null;
	}
;

dec_type
	: COLON type array
	{
		let t = {
			type: $2,
			array: $3
		};
		$$ = t;
	}
	|
	{
		$$ = null;
	}
;

array
	: L_SQUARE expr R_SQUARE
	{
		$$ = $2;
	}
	| L_SQUARE 		R_SQUARE
	{
		$$ = '[]';
	}
	|
	{
		$$ = null;
	}
;

dec_assign
	: ASSIGN op_if
	{
		$$ = $2;
	}
	|
	{
		$$ = null;
	}
;

arg
	: expr
	{
		$$ = $1;
	}
	| var_decl
	{
		$$ = $1;
	}
	|
;

case_stm
	: CASE value COLON L_CURLY stm_list R_CURLY case_stm
	{
		let c1 = create_case($2, $5);
		let cases1 = [c1];
		if($7 != null)
		{
			$7.forEach(element => {
				cases1.push(element);
			});
		}
		$$ = cases1;
	}
	| CASE value COLON stm_list case_stm
	{
		let c2 = create_case($2, $4);
		let cases2 = [c2];
		if($5 != null)
		{
			$5.forEach(element => {
				cases2.push(element);
			});
		}
		$$ = cases2;
	}
	| DEFAULT COLON L_CURLY stm_list R_CURLY
	{
		$$ = [create_case('default', $4)];
	}
	| DEFAULT COLON stm_list
	{
		$$ = [create_case('default', $3)];
	}
	|
	{
		$$ = null;
	}
;

expr
	: expr COMMA op_assign
	{
		if($1.model == 'Expression')
		{
			//create array with [expr, op_assign]
			let e = create_expression_element($3);
			let arr = [$1, e];
			$$ = arr;
		}
		else
		{
			// add a new expression element to the list
			$$.push(create_expression_element($3));
		}
	}
	| op_assign
	{
		$$ = create_expression_element($1);
	}
;

op_assign
	: op_if ASSIGN op_assign
	{
		$$ = create_assignoperation($1, $3, $2);
	}
	| op_if
	{
		$$ = $1;
	}
;

op_if
	: op_or QUESTION op_if COLON op_if
	{
		$$ = create_ternaryoperation($1, $3, $5);
	}
	| op_or
	{
		$$ = $1;
	}
;

op_or
	: op_or OR op_and
	{
		$$ = create_logicaloperation($1, $3, $2);
	}
	| op_and
	{
		$$ = $1;
	}
;

op_and
	: op_and AND op_bin_or
	{
		$$ = create_logicaloperation($1, $3, $2);
	}
	| op_bin_or
	{
		$$ = $1;
	}
;

op_bin_or
	: op_bin_or BIN_OR op_bin_xor
	{
		$$ = create_bitwiseoperation($1, $3, $2);
	}
	| op_bin_xor
	{
		$$ = $1;
	}
;

op_bin_xor
	: op_bin_xor BIN_XOR op_bin_and
	{
		$$ = create_bitwiseoperation($1, $3, $2);
	}
	| op_bin_and
	{
		$$ = $1;
	}
;

op_bin_and
	: op_bin_and BIN_AND op_equate
	{
		$$ = create_bitwiseoperation($1, $3, $2);
	}
	| op_equate
	{
		$$ = $1;
	}
;

op_equate
	: op_equate EQUAL op_compare
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_equate NOT_EQUAL op_compare
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_compare
	{
		$$ = $1;
	}
;

op_compare
	: op_compare LESS op_shift
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_compare GREATER op_shift
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_compare LESS_EQUAL op_shift
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_compare GREATER_EQUAL op_shift
	{
		$$ = create_relationaloperation($1, $3, $2);
	}
	| op_shift
	{
		$$ = $1;
	}
;

op_shift
	: op_shift L_SHIFT op_add
	{
		$$ = create_shiftoperation($1, $3, $2);
	}
	| op_shift R_SHIFT op_add
	{
		$$ = create_shiftoperation($1, $3, $2);
	}
	| op_add
	{
		$$ = $1;
	}
;

op_add
	: op_add PLUS op_mult
	{
		$$ = create_arithmeticoperation($1, $3, $2);
	}
	| op_add MINUS	op_mult
	{
		$$ = create_arithmeticoperation($1, $3, $2);
	}
	| op_mult
	{
		$$ = $1;
	}
;

op_mult
	: op_mult MULTIPLY op_unary
	{
		$$ = create_arithmeticoperation($1, $3, $2);
	}
	| op_mult DIVIDE op_unary
	{
		$$ = create_arithmeticoperation($1, $3, $2);
	}
	| op_mult REMAINDER op_unary
	{
		$$ = create_arithmeticoperation($1, $3, $2);
	}
	| op_unary
	{
		$$ = $1;
	}
;

op_unary
	: NOT op_unary
	{
		$$ = create_unaryoperation($2, $1);
	}
	| BIN_NOT op_unary
	{
		$$ = create_unaryoperation($2, $1);
	}
	| op_unary INCREMENT
	{
		// RANDOM COMMENT
		$$ = create_unaryoperation($1, '++');
	}
	| op_unary DECREMENT
	{
		$$ = create_unaryoperation($1, '--');
	}
	| MINUS	op_unary
	{
		$$ = create_unaryoperation($2, $1);
	}
	| op_pointer
	{
		$$ = $1;
	}
;

op_pointer
	: op_pointer DOT value
	{
		// array . push ( op_pointer ) ;
		// array . pop ( ) ;
		// array . length ;
		$$ = null;
	}
	| op_pointer L_SQUARE expr R_SQUARE
	{
		//array access
		let arrayList = [];
		let ArrayAccess = 
		{
			model: 'ArrayAccess',
			id: $1,
			index: $3,
		};
		$$ = ArrayAccess;
	}
	| value
	{
		$$ = $1;
	}
;

value
	: NUMBER
	{
		$$ = create_number($1);
	}
	| DECIMAL
	{
		$$ = create_number($1);
	}
	| STRING
	{
		var s = $1.replace(/\"/g, "");
		var s2 = s.replace(/\'/g, "");
		$$ = create_string(s2);
	}
	| NAME
	{
		if($1 == 'true' || $1 == 'false')
		{
			$$ = create_boolean($1);
		}
		else
		{
			$$ = create_variable($1);
		}
	}
	| NAME L_PAR expr R_PAR
	{
		//function call
		$$ = create_call($1, $3);
	}
	| NAME L_PAR      R_PAR	
	{
		//function call
		$$ = create_call($1, null);
	}
	| L_SQUARE expr R_SQUARE
	{
		//array assignment [elements]
		$$ = create_arrayassignment($2);
	}
	| L_SQUARE		R_SQUARE
	{
		//array assignment []
		$$ = create_arrayassignment(null);
	}
	| L_PAR expr R_PAR
	{
		$$ = $2;
	}
	| NAME DOT PUSH L_PAR expr R_PAR
	{
		$$ = create_push($1, $5);
	}
	| NAME DOT POP L_PAR	   R_PAR
	{
		$$ = create_pop($1);
	}
	| NAME DOT LENGTH
	{
		$$ = create_length($1);
	}
;