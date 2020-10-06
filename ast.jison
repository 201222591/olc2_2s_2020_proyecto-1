/* Definición Léxica */
%lex

%options case-insensitive

%%

\s+											// se ignoran espacios en blanco
"//".*										// comentario simple línea
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]			// comentario multiple líneas

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
"**"				return 'POWER';

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
        $$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
;

params
	: param COMMA params
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
	| param
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

param
	: NAME return_type
	{
        $$ = nodeCounter;

		dotData += nodeCounter+'[label=\"param\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	| NAME
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"param\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

return_type
	: COLON type
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"return_type\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
;

type
	: NUMBER
	{
		$$ = nodeCounter;
		let type4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"type\"];';
		dotData += type4+'[label=\"number\"];';
		dotData += nodeCounter+'->'+type4+';';

		nodeCounter+=2;
	}	
	| STRING
	{
		$$ = nodeCounter;
		let type3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"type\"];';
		dotData += type3+'[label=\"string\"];';
		dotData += nodeCounter+'->'+type3+';';

		nodeCounter+=2;
	}	
	| BOOLEAN
	{
		$$ = nodeCounter;
		let type2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"type\"];';
		dotData += type2+'[label=\"boolean\"];';
		dotData += nodeCounter+'->'+type2+';';

		nodeCounter+=2;
	}	
	| VOID
	{
		$$ = nodeCounter;
		let type1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"type\"];';
		dotData += type1+'[label=\"void\"];';
		dotData += nodeCounter+'->'+type1+';';

		nodeCounter+=2;
	}
;

block_decl
	: L_CURLY stm_list R_CURLY
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"block_decl\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
;

stm_list
	: stm stm_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm_list\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	|
	{
		$$ = nodeCounter;
		nodeCounter++;
	}
;

stm
	: func_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| var_decl SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| IF L_PAR expr	R_PAR stm ELSE stm
	{
		$$ = nodeCounter;
		let stm6 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm6+'[label=\"if else\"];';
		dotData += nodeCounter+'->'+stm6+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		
		nodeCounter+=2;
	}
	| IF L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm5+'[label=\"if\"];';
		dotData += nodeCounter+'->'+stm5+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| WHILE L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm4+'[label=\"while\"];';
		dotData += nodeCounter+'->'+stm4+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR stm
	{
		$$ = nodeCounter;
		let stm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm3+'[label=\"for\"];';
		dotData += nodeCounter+'->'+stm3+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter+=2;
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR stm
	{
		$$ = nodeCounter;
		let stm2 = nodeCounter+1;
		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm2+'[label=\"for of\"];';
		dotData += nodeCounter+'->'+stm2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter+=2;
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR stm
	{
		$$ = nodeCounter;
		let stm1 = nodeCounter+1;
		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm1+'[label=\"for in\"];';
		dotData += nodeCounter+'->'+stm1+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter+=2;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

then_stm
	: IF L_PAR expr	R_PAR then_stm ELSE then_stm
	{
		$$ = nodeCounter;
		let thenStm6 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += thenStm6+'[label=\"if else\"];';
		dotData += nodeCounter+'->'+thenStm6+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		
		nodeCounter+=2;
	}
	| IF L_PAR expr	R_PAR then_stm
	{
		$$ = nodeCounter;
		let thenStm5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += thenStm5+'[label=\"if\"];';
		dotData += nodeCounter+'->'+thenStm5+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| WHILE L_PAR expr R_PAR then_stm
	{
		$$ = nodeCounter;
		let thenStm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += nodeCounter+'[label=\"while\"];';
		dotData += nodeCounter+'->'+thenStm4+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR then_stm
	{
		$$ = nodeCounter;
		let thenStm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += thenStm3+'[label=\"for\"];';
		dotData += nodeCounter+'->'+thenStm3+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter+=2;
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR then_stm
	{
		$$ = nodeCounter;
		let thenStm2 = nodeCounter+1;
		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += thenStm2+'[label=\"for of\"];';
		dotData += nodeCounter+'->'+thenStm2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter+=2;
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR then_stm
	{
		$$ = nodeCounter;
		let thenStm1 = nodeCounter+1;
		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += thenStm1+'[label=\"for in\"];';
		dotData += nodeCounter+'->'+thenStm1+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter+=2;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

normal_stm
	: DO stm WHILE L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm11 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm11+'[label=\"do while\"];';
		dotData += nodeCounter+'->'+normalStm11+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| SWITCH L_PAR expr R_PAR L_CURLY case_stm R_CURLY
	{
		$$ = nodeCounter;
		let normalStm10 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm10+'[label=\"switch\"];';
		dotData += nodeCounter+'->'+normalStm10+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter+=2;
	}
	| block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| expr SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm9 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm9+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+normalStm9+';';
		
		nodeCounter+=2;
	}
	| BREAK SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm8 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm8+'[label=\"break\"];';
		dotData += nodeCounter+'->'+normalStm8+';';
		
		nodeCounter+=2;
	}
	| CONTINUE SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm7 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm7+'[label=\"continue\"];';
		dotData += nodeCounter+'->'+normalStm7+';';
		
		nodeCounter+=2;
	}
	| RETURN expr SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm5 = nodeCounter+1;
		let normalStm6 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm5+'[label=\"return\"];';
		dotData += normalStm6+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+normalStm5+';';
		dotData += nodeCounter+'->'+normalStm6+';';
		
		nodeCounter+=2;
	}
	| RETURN SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm4+'[label=\"return\"];';
		dotData += nodeCounter+'->'+normalStm4+';';
		
		nodeCounter+=2;
	}
	| SEMICOLON
	{
		// does nothing
	}
	| func_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| CONSOLE_LOG L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm2 = nodeCounter+1;
		let normalStm3 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm2+'[label=\"console.log\"];';
		dotData += normalStm3+'[label=\"console.log\"];';
		dotData += nodeCounter+'->'+normalStm2+';';
		dotData += nodeCounter+'->'+normalStm3+';';

		nodeCounter+=3;
	}
	| GRAFICAR_TS L_PAR R_PAR SEMICOLON
	{
		$$ = nodeCounter;
		let normalStm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += normalStm1+'[label=\"graficar_ts()\"];';
		dotData += nodeCounter+'->'+normalStm1+';';

		nodeCounter=+2;
	}
;

var_decl
	: scope var_element var_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_decl\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
;

scope
	: VAR
	{
		$$ = nodeCounter;
		let scope3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"scope\"];';
		dotData += scope3+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+scope3+';';

		nodeCounter+=2;
	}
	| LET
	{
		$$ = nodeCounter;
		let scope2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"scope\"];';
		dotData += scope2+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+scope2+';';

		nodeCounter+=2;
	}
	| CONST
	{
		$$ = nodeCounter;
		let scope1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"scope\"];';
		dotData += scope1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+scope1+';';

		nodeCounter+=2;
	}
;

var_element
	: NAME dec_type dec_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_element\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
;

var_list
	: COMMA var_element var_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_list\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
	|
	{
		$$ = nodeCounter;
		nodeCounter++;
	}
;

dec_type
	: COLON type array
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"dec_type\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
	|
	{
		$$ = nodeCounter;

		nodeCounter++;
	}
;

array
	: L_SQUARE expr R_SQUARE
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"array\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	| L_SQUARE 		R_SQUARE
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"array\"];';	

		nodeCounter++;
	}
	|
	{
		$$ = nodeCounter;

		nodeCounter++;
	}
;

dec_assign
	: ASSIGN op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"dec_assign =\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	|
	{
		$$ = nodeCounter;

		nodeCounter++;
	}
;

arg
	: expr
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"arg\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| var_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"arg\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	|{}
;

case_stm
	: CASE value COLON L_CURLY stm_list R_CURLY case_stm
	{
		$$ = nodeCounter;
		let caseStm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += caseStm4+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+caseStm4+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter+=2;
	}
	| CASE value COLON stm_list case_stm
	{
		$$ = nodeCounter;
		let caseStm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += caseStm3+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+caseStm3+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter+=2;
	}
	| DEFAULT COLON L_CURLY stm_list R_CURLY
	{
		$$ = nodeCounter;
		let caseStm2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += caseStm2+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+caseStm2+';';
		dotData += nodeCounter+'->'+$4+';';
		
		nodeCounter+=2;
	}
	| DEFAULT COLON stm_list
	{
		$$ = nodeCounter;
		let caseStm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += caseStm1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+caseStm1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter+=2;
	}
	|
	{
		$$ = nodeCounter;
		nodeCounter++;
	}
;

expr
	: expr COMMA op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"expr\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"expr\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_assign
	: op_if ASSIGN op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign =\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_if
	: op_or QUESTION op_if COLON op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_ternary\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		
		nodeCounter++;
	}
	| op_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_if\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_or
	: op_or OR op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or ||\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		nodeCounter++;
	}
;

op_and
	: op_and AND op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_and &\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_or
	: op_bin_or BIN_OR op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_or |\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_xor
	: op_bin_xor BIN_XOR op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_xor ^\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_and
	: op_bin_and BIN_AND op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_and &\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_equate
	: op_equate EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate ==\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_equate NOT_EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate !=\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_compare
	: op_compare LESS op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare <\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare GREATER op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare >\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare LESS_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare <=\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare GREATER_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare >=\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_shift
	: op_shift L_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift <<\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_shift R_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift >>\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_add
	: op_add PLUS op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add +\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_add MINUS	op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add -\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_mult
	: op_mult MULTIPLY op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult *\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult DIVIDE op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult /\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult REMAINDER op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult %\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_unary
	: NOT op_unary
	{
		$$ = nodeCounter;
		let opUnary12 = nodeCounter+1;
		let opUnary13 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary12+'[label=\"!\"];';
		dotData += opUnary13+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+opUnary12+';';
		dotData += nodeCounter+'->'+opUnary13+';';
		
		nodeCounter+=3;
	}
	| BIN_NOT op_unary
	{
		$$ = nodeCounter;
		let opUnary10 = nodeCounter+1;
		let opUnary11 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary10+'[label=\"~\"];';
		dotData += opUnary11+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+opUnary10+';';
		dotData += nodeCounter+'->'+opUnary11+';';
		
		nodeCounter+=3;
	}
	| op_unary INCREMENT
	{
		$$ = nodeCounter;
		let opUnary8 = nodeCounter+1;
		let opUnary9 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary8+'[label=\"++\"];';
		dotData += opUnary9+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+opUnary8+';';
		dotData += nodeCounter+'->'+opUnary9+';';
		
		nodeCounter+=3;
	}
	| op_unary DECREMENT
	{
		$$ = nodeCounter;
		let opUnary6 = nodeCounter+1;
		let opUnary7 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary6+'[label=\"--\"];';
		dotData += opUnary7+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+opUnary6+';';
		dotData += nodeCounter+'->'+opUnary7+';';
		
		nodeCounter+=3;
	}
	| MINUS	op_unary
	{
		$$ = nodeCounter;
		let opUnary4 = nodeCounter+1;
		let opUnary5 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary4+'[label=\"'-'\"];';
		dotData += opUnary5+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+opUnary4+';';
		dotData += nodeCounter+'->'+opUnary5+';';
		
		nodeCounter+=3;
	}
	| op_unary POWER op_pointer
	{
		$$ = nodeCounter;
		let opUnary2 = nodeCounter+1;
		let opUnary3 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"power\"];';
		dotData += opUnary2+'[label=\"'+$1+'\"];';
		dotData += opUnary3+'[label=\"'+$3+'\"];';
		dotData += nodeCounter+'->'+opUnary2+';';
		dotData += nodeCounter+'->'+opUnary3+';';
		
		nodeCounter+=3;
	}
	| op_pointer
	{
		$$ = nodeCounter;
		let opUnary1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += opUnary1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+opUnary1+';';
		
		nodeCounter+=2;
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
		$$ = nodeCounter;
		let opPointer1 = nodeCounter+1;
		let opPointer2 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"op_pointer\"];';
		dotData += opPointer1+'[label=\["'+$1+']\"];';
		dotData += opPointer2+'[label=\["'+$3+']\"];';
		dotData += nodeCounter+'->'+opPointer1+';';
		dotData += nodeCounter+'->'+opPointer2+';';
		
		nodeCounter+=3;
	}
	| value
	{
		$$ = nodeCounter;
		let name5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"op_pointer\"];';
		dotData += name5+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+name5+';';
		
		nodeCounter+=2;
	}
;

value
	: NUMBER
	{
		$$ = nodeCounter;
		let name4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += name4+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+name4+';';
		
		nodeCounter+=2;
	}
	| DECIMAL
	{
		$$ = nodeCounter;
		let name3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += name3+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+name3+';';
		
		nodeCounter+=2;
	}
	| STRING
	{
		$$ = nodeCounter;
		let name2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += name2+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+name2+';';
		
		nodeCounter+=2;
	}
	| NAME
	{
		$$ = nodeCounter;
		let name1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += name1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+name1+';';
		
		nodeCounter+=2;
	}
	| NAME L_PAR expr R_PAR
	{
		//function call
		$$ = nodeCounter;
		let functionCall3 = nodeCounter+1;
		let functionCall4 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += functionCall3+'[label=\"'+$1+'\"];';
		dotData += functionCall4+'[label=\"'+$3+'\"];';
		dotData += nodeCounter+'->'+functionCall3+';';
		dotData += nodeCounter+'->'+functionCall4+';';
		
		nodeCounter+=3;
	}
	| NAME L_PAR      R_PAR	
	{
		//function call
		$$ = nodeCounter;
		let functionCall1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += functionCall1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+functionCall1+';';
		
		nodeCounter+=2;
	}
	| L_SQUARE expr R_SQUARE
	{
		//array assignment [elements]
		$$ = nodeCounter;
		let notEmptyArray = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += notEmptyArray+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+notEmptyArray+';';
		
		nodeCounter+=2;
	}
	| L_SQUARE		R_SQUARE
	{
		//array assignment []
		$$ = nodeCounter;
		let emptyArray = nodeCounter+1

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += emptyArray+'[label=\"[]\"];';
		dotData += nodeCounter+'->'+emptyArray+';';
		
		nodeCounter+=2;
	}
	| L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let expr1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += expr1+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+expr1+';';
		
		nodeCounter+=2;
	}
	| NAME DOT PUSH L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let nameDotPush1 = nodeCounter+1;
		let nameDotPush2 = nodeCounter+2;
		let nameDotPush3 = nodeCounter+3;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += nameDotPush1+'[label=\"'+ $1 +'\"];';
		dotData += nameDotPush2+'[label=\"'+ $3 +'\"];';
		dotData += nameDotPush3+'[label=\"'+ $5 +'\"];';
		dotData += nodeCounter+'->'+nameDotPush1+';';
		dotData += nodeCounter+'->'+nameDotPush2+';';
		dotData += nodeCounter+'->'+nameDotPush3+';';
		
		nodeCounter+=4;
	}
	| NAME DOT POP L_PAR	   R_PAR
	{
		$$ = nodeCounter;
		let nameDotPop1 = nodeCounter+1;
		let nameDotPop2 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += nameDotPop1+'[label=\"'+ $1 +'\"];';
		dotData += nameDotPop2+'[label=\"'+ $3 +'\"];';
		dotData += nodeCounter+'->'+nameDotPop1+';';
		dotData += nodeCounter+'->'+nameDotPop2+';';
		
		nodeCounter+=3;
	}
	| NAME DOT LENGTH
	{
		$$ = nodeCounter;
		let nameDotLength1 = nodeCounter+1;
		let nameDotLength2 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += nameDotLength1+'[label=\"'+ $1 +'\"];';
		dotData += nameDotLength2+'[label=\"'+ $3 +'\"];';
		dotData += nodeCounter+'->'+nameDotLength1+';';
		dotData += nodeCounter+'->'+nameDotLength2+';';
		
		nodeCounter+=3;
	}
;