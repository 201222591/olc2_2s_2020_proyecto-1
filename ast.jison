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

		dotData += nodeCounter+'[label=\"func_decl\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter++;
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"func_decl\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
;

params
	: param COMMA params
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
	| param
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

param
	: NAME return_type
	{
        $$ = nodeCounter;

		dotData += nodeCounter+'[label=\"param\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	| NAME
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"param\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

return_type
	: COLON type
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"return_type\"];'
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
;

type
	: NUMBER
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"type\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}	
	| STRING
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"type\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}	
	| BOOLEAN
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"type\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}	
	| VOID
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"type\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

block_decl
	: L_CURLY stm_list R_CURLY
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"block_decl\"];'
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
;

stm_list
	: stm stm_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm_list\"];'
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

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| var_decl SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| IF L_PAR expr	R_PAR stm ELSE stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter++;
	}
	| IF L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
	| WHILE L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter++;
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter++;
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter++;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

then_stm
	: IF L_PAR expr	R_PAR then_stm ELSE then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter++;
	}
	| IF L_PAR expr	R_PAR then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter++;
	}
	| WHILE L_PAR expr R_PAR then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter++;
	}
	| FOR L_PAR VAR NAME OF NAME R_PAR then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter++;
	}
	| FOR L_PAR VAR NAME IN NAME R_PAR then_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter++;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"then_stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

normal_stm
	: DO stm WHILE L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
	| SWITCH L_PAR expr R_PAR L_CURLY case_stm R_CURLY
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter++;
	}
	| block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| expr SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| BREAK SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| CONTINUE SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| RETURN expr SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| SEMICOLON
	{
		// does nothing
	}
	| func_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| CONSOLE_LOG L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->consoleLog;';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter++;
	}
	| GRAFICAR_TS L_PAR R_PAR SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

var_decl
	: scope var_element var_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_decl\"];'
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

		dotData += nodeCounter+'[label=\"scope\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| LET
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"scope\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| CONST
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"scope\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
;

var_element
	: NAME dec_type dec_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_element\"];'
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

		dotData += nodeCounter+'[label=\"var_list\"];'
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

		dotData += nodeCounter+'[label=\"dec_type\"];'
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

		dotData += nodeCounter+'[label=\"array\"];'
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter++;
	}
	| L_SQUARE 		R_SQUARE
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"array\"];'		

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

		dotData += nodeCounter+'[label=\"dec_assign\"];'
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

		dotData += nodeCounter+'[label=\"arg\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	| var_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"arg\"];'
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter++;
	}
	|
;

case_stm
	: CASE value COLON L_CURLY stm_list R_CURLY case_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter++;
	}
	| CASE value COLON stm_list case_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter++;
	}
	| DEFAULT COLON L_CURLY stm_list R_CURLY
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$4+';';
		
		nodeCounter++;
	}
	| DEFAULT COLON stm_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
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

		dotData += nodeCounter+'[label=\"expr\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"expr\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_assign
	: op_if ASSIGN op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_if
	: op_or QUESTION op_if COLON op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_ternary\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		
		nodeCounter++;
	}
	| op_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_if\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_or
	: op_or OR op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		nodeCounter++;
	}
;

op_and
	: op_and AND op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_and\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_or
	: op_bin_or BIN_OR op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_xor
	: op_bin_xor BIN_XOR op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_xor\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_bin_and
	: op_bin_and BIN_AND op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_and\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_equate
	: op_equate EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_equate NOT_EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_compare
	: op_compare LESS op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare GREATER op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare LESS_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_compare GREATER_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_shift
	: op_shift L_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_shift R_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_add
	: op_add PLUS op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_add MINUS	op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_mult
	: op_mult MULTIPLY op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult DIVIDE op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_mult REMAINDER op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

op_unary
	: NOT op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];'
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter++;
	}
	| BIN_NOT op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];'
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter++;
	}
	| op_unary INCREMENT
	{
		// RANDOM COMMENT
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| op_unary DECREMENT
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| MINUS	op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];'
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter++;
	}
	| op_pointer
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
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

		dotData += nodeCounter+'[label=\"op_pointer\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| value
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_pointer\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
;

value
	: NUMBER
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| DECIMAL
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| STRING
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| NAME
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| NAME L_PAR expr R_PAR
	{
		//function call
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| NAME L_PAR      R_PAR	
	{
		//function call
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter++;
	}
	| L_SQUARE expr R_SQUARE
	{
		//array assignment [elements]
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter++;
	}
	| L_SQUARE		R_SQUARE
	{
		//array assignment []
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		
		nodeCounter++;
	}
	| L_PAR expr R_PAR
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter++;
	}
	| NAME DOT PUSH L_PAR expr R_PAR
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		
		nodeCounter++;
	}
	| NAME DOT POP L_PAR	   R_PAR
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
	| NAME DOT LENGTH
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];'
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter++;
	}
;