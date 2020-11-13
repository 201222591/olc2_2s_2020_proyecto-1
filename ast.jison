/* Definición Léxica */
%lex

%options case-insensitive

%%

/* Espacios en blanco */
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
//"graficar_ts"		return 'GRAFICAR_TS';


"?"                 return 'QUESTION';
"=="                return 'EQUAL';
"="                 return 'ASSIGN';


"number"            return 'NUMBER';
"string"            return 'STRING';
"boolean"           return 'BOOLEAN';
"void"              return 'VOID';
//"push"              return 'PUSH';
//"pop"               return 'POP';
"length"            return 'LENGTH';
"let"               return 'LET';
"const"             return 'CONST';
//"var"               return 'VAR';
"function"          return 'FUNCTION';

"charat"			return 'CHARAT';
"tolowercase"		return 'TOLOWERCASE';
"touppercase"		return 'TOUPPERCASE';
"concat"			return 'CONCAT';

"new"				return 'NEW';
"array"				return 'ARRAY';
"type"				return 'TYPE';





[0-9]+("."[0-9]+)?\b    				return 'DECIMAL';
[0-9]+\b                				return 'INTEGER';
((\").*?(\"))|((\').*?(\'))				return 'STRING';
[a-zA-Z_][a-aA-Z_0-9]*					return	'NAME';


<<EOF>>                 return 'EOF';
.                       {
							lexicalErrors.push(new Error('Error lexico en el token: '+ yytext+'.', yylloc.first_line, yylloc.first_column));
						}
/lex

/* Asociación de operadores y precedencia */

%left 'PLUS' 'MINUS'
%left 'MULTIPLY' 'DIVIDE'
%left UMINUS


%{
	//MODELS
	var Function = function(returnType, id, parameters, statements)
	{
		this.model = "Function";
		this.returnType = returnType;
		this.id = id;
		this.parameters = parameters;
		this.statements = statements;
	};

	var Declaration = function(scope, idList)
	{
		this.model = "Declaration";
		this.scope = scope;
		this.idList = idList;
	};

	var If = function(condition, statements)
	{
		this.model = "If";
		this.condition = condition;
		this.statements = statements;
	};

	var IfElse = function(condition, statementsTrue, statementsFalse)
	{
		this.model = "IfElse";
		this.condition = condition;
		this.statementsTrue = statementsTrue;
		this.statementsFalse = statementsFalse;
	};

	var While = function(condition, statements)
	{
		this.model = "While";
		this.condition = condition;
		this.statements = statements;
	};

	var DoWhile = function(condition, statements)
	{
		this.model = "DoWhile";
		this.condition = condition;
		this.statements = statements;
	};

	var For = function(arg1, arg2, arg3, statements)
	{
		this.model = "For";
		this.arg1 = arg1;
		this.arg2 = arg2;
		this.arg3 = arg3;
		this.statements = statements;
	};

	var ForOf = function(id, list, statements)
	{
		this.model = 'ForOf';
		this.id = id;
		this.list = list;
		this.statements = statements;
	};

	var ForIn = function(id, list, statements)
	{
		this.model = 'ForIn';
		this.id = id;
		this.list = list;
		this.statements = statements;
	};
 
	var Case = function(value, statements)
	{
		this.model = "Case";
		this.value = value;
		this.statements = statements;
	};

	var Switch = function(condition, cases)
	{
		this.model = "Switch";
		this.condition = condition;
		this.cases = cases;
	};

	var Return = function(value)
	{
		this.model = "Return";
		this.value = value;
	};

	var Break = function()
	{
		this.model = "Break"
	};

	var Continue = function()
	{
		this.model = "Continue"
	};

	var GraficarTS = function()
	{
		this.model = "GraficarTS";
	};

	var ConsoleLog = function(param)
	{
		this.model = "ConsoleLog";
		this.param = param;
	};

	var PreOperation = function(value, operator)
	{
		this.model = "PreOperation";
		this.operator = operator;
		this.value = value;
	};

	var Power = function(value1, value2)
	{
		this.model = "Power";
		this.value1 = value1;
		this.value2 = value2;
	};

	var  UnaryOperation = function(value, operator)
	{
		this.model = "UnaryOperation";
		this.value = value;
		this.operator = operator;
	};

	var ArithmeticOperation = function(value1, value2, operator)
	{
		this.model = "ArithmeticOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var ShiftOperation = function(value1, value2, operator)
	{
		this.model = "ShiftOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var RelationalOperation = function(value1, value2, operator)
	{
		this.model ="RelationalOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var LogicalOperation = function(value1, value2, operator)
	{
		this.model ="LogicalOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var BitwiseOperation = function(value1, value2, operator)
	{
		this.model ="BitwiseOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var TernaryOperation = function(value1, value2, value3)
	{
		this.model ="TernaryOperation";
		this.value1 = value1;
		this.value2 = value2;
		this.value3 = value3;
	};
	
	var AssignOperation = function(value1, value2, operator)
	{
		this.model ='AssignOperation';
		this.value1 = value1;
		this.value2 = value2;
		this.operator = operator;
	};

	var Expression = function(exp)
	{
		this.model = 'Expression';
		this.expression = exp;
	}

	var Variable = function(id)
	{
		this.model = 'Variable';
		this.id = id;
	};

	var Number = function(value)
	{
		this.model = 'Number';
		this.value = value;
	};

	var String = function(value)
	{
		this.model = 'String';
		this.value = value;
	};

	var Boolean = function(value)
	{
		this.model = 'Boolean';
		this.value = value;
	};

	var Call = function(id, parameters)
	{
		this.model = 'Call';
		this.id = id;
		this.parameters = parameters;
	};

	var Push = function(arr, expression)
	{
		this.model = 'Push';
		this.value1 = arr;
		this.value2 = expression;
	};

	var Pop = function(value)
	{
		this.model = 'Pop';
		this.value = value;
	};

	var Length = function(value)
	{
		this.model = 'Length';
		this.value = value;
	};

	var ArrayAssignment = function(expr)
	{
		this.model = 'ArrayAssignment';
		this.value = expr;
	};

	var StringLength = function(str, type)
	{
		this.model = 'StringLength',
		this.value = str;
		this.type = type;
	}

	var StringCharAt = function(str, type, index)
	{
		this.model = 'StringCharAt',
		this.value = str;
		this.type = type;
		this.index = index;
	}

	var StringToLower = function(str, type)
	{
		this.model = 'StringToLower',
		this.value = str;
		this.type = type;
	}

	var StringToUpper = function(str, type)
	{
		this.model = 'StringToUpper',
		this.value = str;
		this.type = type;
	}

	var StringConcat = function(str1, str2, type)
	{
		this.model = 'StringConcat',
		this.value1 = str1;
		this.value2 = str2;
		this.type = type;
	}

	var AccessList = function(arr)
	{
		this.model = 'AccessList';
		this.list = arr;
	}

	var ObjectDeclaration = function(id, atr)
	{
		this.model = 'ObjectDeclaration';
		this.attributes = atr;
	}

	// FUNCTIONS

	function create_function(returnType, id, params, stms)
	{
		let f = new Function(returnType, id, params, stms);
		return f;
	}
	
	function create_declaration(scp, idList)
	{
		let d = new Declaration(scp, idList);
		return d;
	}

	function create_if(cond, stms)
	{
		let i = new If(cond, stms);
		return i;
	}

	function create_ifelse(cond, stms_true, stms_false)
	{
		let ie = new IfElse(cond, stms_true, stms_false);
		return ie;
	}

	function create_while(cond, stms)
	{
		let w = new While(cond, stms);
		return w;
	}

	function create_dowhile(cond, stms)
	{
		let dw = new DoWhile(cond, stms);
		return dw;
	}

	function create_for(arg1, arg2, arg3, stms)
	{
		let f = new For(arg1, arg2, arg3, stms);
		return f;
	}

	function create_forof(id, list, stms)
	{
		let f = new ForOf(id, list, stms);
		return f;
	}

	function create_forin(id, list, stms)
	{
		let f = new ForIn(id, list, stms);
		return f;
	}

	function create_case(val, stms)
	{
		let c = new Case(val, stms);
		return c;
	}

	function create_switch(cond, css)
	{
		let s = new Switch(cond, css);
		return s;
	}

	function create_return(val)
	{
		let r = new Return(val);
		return r;
	}

	function create_break()
	{
		let b = new Break();
		return b;
	}

	function create_continue()
	{
		let c = new Continue();
		return c;
	}

	function create_graficarTS()
	{
		let g = new GraficarTS();
		return g;
	}

	function create_consolelog(p)
	{
		let c = new ConsoleLog(p);
		return c;
	}

	function create_push(arr, exp)
	{
		let p = new Push(arr, exp);
		return p;
	}

	function create_pop(arr)
	{
		let p = new Pop(arr);
		return p;
	}
	
	function create_length(arr)
	{
		let l = new Length(arr);
		return l;
	}

	function create_arrayassignment(arr)
	{
		let a = new ArrayAssignment(arr);
		return a;
	}

	function create_preoperation(val, op)
	{
		let a = new PreOperation(val, op);
		return a;
	}
	function create_power(val1, val2)
	{
		let p = new Power(val1, val2);
		return p;
	}
	function create_unaryoperation(val, op)
	{
		let u = new UnaryOperation(val, op);
		return u;
	}
	function create_arithmeticoperation(val1, val2, op)
	{
		let a = new ArithmeticOperation(val1, val2, op);
		return a;
	}
	function create_shiftoperation(val1, val2, op)
	{
		let s = new ShiftOperation(val1, val2, op);
		return s;
	}
	function create_relationaloperation(val1, val2, op)
	{
		let r = new RelationalOperation(val1, val2, op);
		return r;
	}
	function create_logicaloperation(val1, val2, op)
	{
		let l = new LogicalOperation(val1, val2, op);
		return l;
	}
	function create_bitwiseoperation(val1, val2, op)
	{
		let b = new BitwiseOperation(val1, val2, op);
		return b;
	}
	function create_ternaryoperation(val1, val2, val3)
	{
		let t = new TernaryOperation(val1, val2, val3);
		return t;
	}
	function create_assignoperation(val1, val2, op)
	{
		let a = new AssignOperation(val1, val2, op);
		return a;
	}

	function create_expression_element(exp)
	{
		let e = new Expression(exp);
		return e;
	}

	function create_number(value)
	{
		let n = new Number(value);
		return n;
	}

	function create_string(value)
	{
		let s = new String(value);
		return s;
	}

	function create_variable(id)
	{
		let v = new Variable(id);
		return v;
	}

	function create_call(id, params)
	{
		let c = new Call(id, params);
		return c;
	}

	function create_boolean(val)
	{
		let b = new Boolean(val);
		return b;
	}

	function create_stringlength(str, type)
	{
		let s = new StringLength(str, type);
		return s;
	}

	function create_stringcharat(str, type, index)
	{
		let s = new StringCharAt(str, type, index);
		return s;
	}

	function create_stringtolower(str, type)
	{
		let s = new StringToLower(str, type);
		return s;
	}

	function create_stringtoupper(str, type)
	{
		let s = new StringToUpper(str, type);
		return s;
	}

	function create_stringconcat(str1, str2, type)
	{
		let s = new StringConcat(str1, str2, type);
		return s;
	}

	function create_accesslist(arr)
	{
		let l = new AccessList(arr);
		return l;
	}

	function create_objectdeclaration(id, atrs)
	{
		let o = new ObjectDeclaration(id, atrs);
		return o;
	}
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
		$$ = nodeCounter;


		dotData += nodeCounter+'[label=\"decls\"];';

		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;

	}
	|
	{
		$$ = nodeCounter;
		let dcs1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"decls\"];';
		dotData += dcs1+'[label=\"null\"];';
		dotData += nodeCounter+'->'+dcs1+';';

		nodeCounter += 2;
	}
;

decl
	: func_decl DOT DOT DOT
	{
		$$ = $1;
	}
	| stm_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"decl\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

func_decl
	: FUNCTION NAME L_PAR params R_PAR return_type block_decl
	{
		$$ = nodeCounter;
		let fd1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += fd1+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+fd1+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter += 2;
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		$$ = nodeCounter;
		let fd2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += fd2+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+fd2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter += 2;
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		$$ = nodeCounter;
		let fd3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += fd3+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+fd3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter += 2;
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		$$ = nodeCounter;
		let fd4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"func_decl\"];';
		dotData += fd4+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+fd4+';';
		dotData += nodeCounter+'->'+$5+';';
		
		nodeCounter += 2;
	}
;

params
	: param COMMA params
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';
		
		nodeCounter += 1;
	}
	| param
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += nodeCounter+'->'+$1+';';
		
		nodeCounter += 1;
	}	
;

param
	: NAME return_type
	{
		$$ = nodeCounter;
		let prm1 = nodeCounter + 1

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += prm1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+prm1+';';
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter += 2;
	}
	| NAME
	{
		$$ = nodeCounter;
		let prm2 = nodeCounter + 1

		dotData += nodeCounter+'[label=\"params\"];';
		dotData += prm2+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+prm2+';';
		
		nodeCounter += 2;
	}
;

return_type
	: COLON type
	{
		$$ = nodeCounter;
		let rt1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"return_type\"];';
		dotData += rt1+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+rt1+';';

		nodeCounter += 2;
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
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"block_decl\"];';

		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;
	}
;

stm_list
	: stm stm_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm_list\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$2+';';
		
		nodeCounter += 1;
	}
	|
	{
		$$ = nodeCounter;
		let stms1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm_list\"];';
		dotData += stms1+'[label=\"null\"];';
		dotData += nodeCounter+'->'+stms1+';';

		nodeCounter += 2;
	}
;

stm
	: func_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| var_decl SEMICOLON
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| IF L_PAR expr	R_PAR stm ELSE stm
	{
		$$ = nodeCounter;
		let stm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm1+'[label=\"IF ELSE\"];';
		dotData += nodeCounter+'->'+stm1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter += 2;
	}
	| IF L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm2+'[label=\"IF\"];';
		dotData += nodeCounter+'->'+stm2+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 2;
	}
	| WHILE L_PAR expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm3+'[label=\"WHILE\"];';
		dotData += nodeCounter+'->'+stm3+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 2;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR stm
	{
		$$ = nodeCounter;
		let stm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm4+'[label=\"FOR\"];';
		dotData += nodeCounter+'->'+stm4+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter += 2;
	}
	| FOR L_PAR scope NAME OF expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm5 = nodeCounter+1;
		let stm6 = nodeCounter+2;
		let stm7 = nodeCounter+3;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm5+'[label=\"FOR OF\"];';
		dotData += stm6+'[label=\"'+$4+'\"];';
		dotData += stm7+'[label=\"'+$6+'\"];';
		dotData += nodeCounter+'->'+stm5+';';
		dotData += nodeCounter+'->'+stm6+';';
		dotData += nodeCounter+'->'+stm7+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter += 4;
	}
	| FOR L_PAR scope NAME IN expr R_PAR stm
	{
		$$ = nodeCounter;
		let stm8 = nodeCounter+1;
		let stm9 = nodeCounter+2;
		let stm10 = nodeCounter+3;

		dotData += nodeCounter+'[label=\"stm\"];';
		dotData += stm8+'[label=\"FOR IN\"];';
		dotData += stm9+'[label=\"'+$4+'\"];';
		dotData += stm10+'[label=\"'+$6+'\"];';
		dotData += nodeCounter+'->'+stm8+';';
		dotData += nodeCounter+'->'+stm9+';';
		dotData += nodeCounter+'->'+stm10+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter += 4;
	}
	| object 
	{

	}
	| object_decl 
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

then_stm
	: IF L_PAR expr	R_PAR then_stm ELSE then_stm
	{
		$$ = nodeCounter;
		let tstm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm1+'[label=\"IF ELSE\"];';
		dotData += nodeCounter+'->'+tstm1+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter += 2;
	}
	| IF L_PAR expr	R_PAR then_stm
	{
		$$ = nodeCounter;
		let tstm2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm2+'[label=\"IF\"];';
		dotData += nodeCounter+'->'+tstm2+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 2;
	}
	| WHILE L_PAR expr R_PAR then_stm
	{
		$$ = nodeCounter;
		let tstm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm3+'[label=\"WHILE\"];';
		dotData += nodeCounter+'->'+tstm3+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 2;
	}
	| FOR L_PAR arg SEMICOLON arg SEMICOLON arg R_PAR then_stm
	{
		$$ = nodeCounter;
		let tstm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm4+'[label=\"FOR\"];';
		dotData += nodeCounter+'->'+tstm4+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';
		dotData += nodeCounter+'->'+$9+';';

		nodeCounter += 2;
	}
	| FOR L_PAR scope NAME OF expr R_PAR then_stm
	{
		$$ = nodeCounter;
		let tstm5 = nodeCounter+1;
		let tstm6 = nodeCounter+2;
		let tstm7 = nodeCounter+3;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm5+'[label=\"FOR OF\"];';
		dotData += tstm6+'[label=\"'+$4+'\"];';
		dotData += tstm7+'[label=\"'+$6+'\"];';
		dotData += nodeCounter+'->'+tstm5+';';
		dotData += nodeCounter+'->'+tstm6+';';
		dotData += nodeCounter+'->'+tstm7+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter += 4;
	}
	| FOR L_PAR scope NAME IN expr R_PAR then_stm
	{
		$$ = nodeCounter;
		let tstm8 = nodeCounter+1;
		let tstm9 = nodeCounter+2;
		let tstm10 = nodeCounter+3;

		dotData += nodeCounter+'[label=\"then_stm\"];';
		dotData += tstm8+'[label=\"FOR IN\"];';
		dotData += tstm9+'[label=\"'+$4+'\"];';
		dotData += tstm10+'[label=\"'+$6+'\"];';
		dotData += nodeCounter+'->'+tstm8+';';
		dotData += nodeCounter+'->'+tstm9+';';
		dotData += nodeCounter+'->'+tstm10+';';
		dotData += nodeCounter+'->'+$8+';';

		nodeCounter += 4;
	}
	| normal_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

normal_stm
	: DO stm WHILE L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;
		let nstm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm1+'[label=\"DO WHILE\"];';
		dotData += nodeCounter+'->'+nstm1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 2;
	}
	| SWITCH L_PAR expr R_PAR L_CURLY case_stm R_CURLY
	{
		$$ = nodeCounter;
		let nstm3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm3+'[label=\"SWITCH\"];';
		dotData += nodeCounter+'->'+nstm3+';';
		dotData += nodeCounter+'->'+$3+';';
		dotData += nodeCounter+'->'+$6+';';

		nodeCounter += 2;
	}
	| block_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| expr SEMICOLON
	{
		// does nothing
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"normal_stm\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| BREAK SEMICOLON
	{
		$$ = nodeCounter;
		let nstm4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm4+'[label=\"BREAK\"];';
		dotData += nodeCounter+'->'+nstm4+';';

		nodeCounter += 2;
	}
	| CONTINUE SEMICOLON
	{
		$$ = nodeCounter;
		let nstm5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm5+'[label=\"CONTINUE\"];';
		dotData += nodeCounter+'->'+nstm5+';';

		nodeCounter += 2;
	}
	| RETURN expr SEMICOLON
	{
		$$ = nodeCounter;
		let nstm6 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm6+'[label=\"RETURN\"];';
		dotData += nodeCounter+'->'+nstm6+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 2;
	}
	| RETURN SEMICOLON
	{
		// return with no expression(2)
		$$ = nodeCounter;
		let nstm7 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm7+'[label=\"RETURN\"];';
		dotData += nodeCounter+'->'+nstm7+';';

		nodeCounter += 2;
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

		nodeCounter += 1;
	}
	| CONSOLE_LOG L_PAR expr R_PAR SEMICOLON
	{
		$$ = nodeCounter;
		let nstm8 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"normal_stm\"];';
		dotData += nstm8+'[label=\"CONSOLE_LOG\"];';
		dotData += nodeCounter+'->'+nstm8+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

object_decl
	: TYPE NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
		$$ = nodeCounter;
		let od1 = nodeCounter+1;
		let od2 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"object_decl\"];';
		dotData += od1+'[label=\"TYPE\"];';
		dotData += od2+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+od1+';';
		dotData += nodeCounter+'->'+od2+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 3;
	}
;

atr_list
	: atr COMMA atr_list
	{
		$$ = nodeCounter;
		dotData += nodeCounter+'[label=\"atr_list\"];';

		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

	}
	| atr
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"atr_list\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| 
	{
		$$ = nodeCounter;
		let atl1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"atr_list\"];';
		dotData += atl1+'[label=\"null\"];';
		dotData += nodeCounter+'->'+atl1+';';

		nodeCounter += 2;
	}
;

atr
	: NAME COLON NAME
	{
		$$ = nodeCounter;
		let atr1 = nodeCounter+1;
		let atr2 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"atr\"];';
		dotData += atr1+'[label=\"'+$1+'\"];';
		dotData += atr2+'[label=\"'+$3+'\"];';
		dotData += nodeCounter+'->'+atr1+';';
		dotData += nodeCounter+'->'+atr2+';';

		nodeCounter += 3;
	}
	| NAME COLON type
	{
		$$ = nodeCounter;
		let atr03 = nodeCounter+1;
		let atr4 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"atr\"];';
		dotData += atr03+'[label=\"'+$1+'\"];';
		dotData += atr4+'[label=\"'+$3+'\"];';
		dotData += nodeCounter+'->'+atr03+';';
		dotData += nodeCounter+'->'+atr4+';';

		nodeCounter += 3;
	}
	| NAME COLON value
	{
		
	}
;

object
	: scope NAME COLON NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
	}
	| scope NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
	}
;

var_decl
	: scope var_element var_list
	{
		$$ = nodeCounter;
		let atr3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"var_decl\"];';
		dotData += atr3+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+atr3+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

scope
	: LET
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
		$$ = nodeCounter;
		let ve1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"var_element\"];';
		dotData += ve1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+ve1+';';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

var_list
	: COMMA var_element var_list
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"var_list\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	|
	{
		$$ = nodeCounter;
		let ve2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"atr_list\"];';
		dotData += ve2+'[label=\"null\"];';
		dotData += nodeCounter+'->'+ve2+';';

		nodeCounter += 2;
	}
;

dec_type
	: COLON type array
	{
		$$ = nodeCounter;
		let dt1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"dec_type\"];';
		dotData += dt1+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+dt1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

array
	: L_SQUARE expr R_SQUARE
	{
		$$ = nodeCounter;
		let arr1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"array\"];';
		dotData += arr1+'[label=\"[]\"];';
		dotData += nodeCounter+'->'+arr1+';';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 2;
	}
	| L_SQUARE 		R_SQUARE
	{
		$$ = nodeCounter;
		let arr2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"array\"];';
		dotData += arr2+'[label=\"[]\"];';
		dotData += nodeCounter+'->'+arr2+';';

		nodeCounter += 2;
	}
	| array L_SQUARE R_SQUARE
	{
	}
	|
	{
		$$ = nodeCounter;
		let arr3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"array\"];';
		dotData += arr3+'[label=\"null\"];';
		dotData += nodeCounter+'->'+arr3+';';

		nodeCounter += 2;
	}
;

dec_assign
	: ASSIGN op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"dec_assign\"];';

		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;
	}
	|
	{
		$$ = nodeCounter;
		let da1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"dec_assign\"];';
		dotData += da1+'[label=\"null\"];';
		dotData += nodeCounter+'->'+da1+';';

		nodeCounter += 2;
	}
;

arg
	: var_decl
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"arg\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| expr
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"arg\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	|
	{
		$$ = nodeCounter;
		let ag1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"arg\"];';
		dotData += ag1+'[label=\"null\"];';
		dotData += nodeCounter+'->'+ag1+';';

		nodeCounter += 2;
	}
;

case_stm
	: CASE value COLON L_CURLY stm_list R_CURLY case_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$5+';';
		dotData += nodeCounter+'->'+$7+';';

		nodeCounter += 1;
	}
	| CASE value COLON stm_list case_stm
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += nodeCounter+'->'+$2+';';
		dotData += nodeCounter+'->'+$4+';';
		dotData += nodeCounter+'->'+$5+';';

		nodeCounter += 1;
	}
	| DEFAULT COLON L_CURLY stm_list R_CURLY
	{
		$$ = nodeCounter;
		let cstm1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += cstm1+'[label=\"DEFAULT\"];';
		dotData += nodeCounter+'->'+$cstm1+';';
		dotData += nodeCounter+'->'+$4+';';

		nodeCounter += 2;
	}
	| DEFAULT COLON stm_list
	{
		$$ = nodeCounter;
		let cstm2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"case_stm\"];';
		dotData += cstm2+'[label=\"DEFAULT\"];';
		dotData += nodeCounter+'->'+cstm2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

expr
	: expr COMMA op_assign
	{
		$$ = nodeCounter;
		let exp1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"expr\"];';
		dotData += nodeCounter+'->'+exp1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"expr\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_assign
	: op_if ASSIGN op_assign
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_assign\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_if
	: op_or QUESTION op_if COLON op_if
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_if\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_if\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_or
	: op_or OR op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_or\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_and
	: op_and AND op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_and\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_bin_or
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_and\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_bin_or
	: op_bin_or BIN_OR op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_or\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_bin_xor
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_or\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_bin_xor
	: op_bin_xor BIN_XOR op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_xor\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_bin_and
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_xor\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_bin_and
	: op_bin_and BIN_AND op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_and\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_equate
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_bin_and\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_equate
	: op_equate EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_equate NOT_EQUAL op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_compare
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_equate\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_compare
	: op_compare LESS op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_compare GREATER op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_compare LESS_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_compare GREATER_EQUAL op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_shift
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_compare\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_shift
	: op_shift L_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_shift R_SHIFT op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_add
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_shift\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_add
	: op_add PLUS op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_add MINUS	op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_mult
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_add\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_mult
	: op_mult MULTIPLY op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_mult DIVIDE op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_mult REMAINDER op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_mult\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_unary
	: NOT op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;
	}
	| BIN_NOT op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;
	}
	| op_unary INCREMENT
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| op_unary DECREMENT
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| MINUS	op_unary
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$2+';';

		nodeCounter += 1;
	}
	| op_unary POWER op_pointer
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 1;
	}
	| op_pointer
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_unary\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

op_pointer
	: op_pointer DOT value
	{
		// array . push ( op_pointer ) ;
		// array . pop ( ) ;
		// array . length ;
		// OP POINTER OK
		$$ = null;
	}
	| op_pointer L_SQUARE expr R_SQUARE
	{
		//array access
		$$ = nodeCounter;
		let opp1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"op_pointer\"];';
		dotData += opp1+'[label=\"op_pointer\"];';
		dotData += nodeCounter+'->'+$1+';';
		dotData += nodeCounter+'->'+opp1+';';

		nodeCounter += 2;
	}
	| value
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"op_pointer\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
;

string_function
	: LENGTH
	{
		$$ = nodeCounter;
		let sf1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"string_function\"];';
		dotData += sf1+'[label=\"LENGTH\"];';
		dotData += nodeCounter+'->'+sf1+';';

		nodeCounter += 2;
	}
	| CHARAT L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let sf2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"string_function\"];';
		dotData += sf2+'[label=\"CHAR AT\"];';
		dotData += nodeCounter+'->'+sf2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| TOLOWERCASE L_PAR R_PAR
	{
		$$ = nodeCounter;
		let sf3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"string_function\"];';
		dotData += sf3+'[label=\"TO LOWER CASE\"];';
		dotData += nodeCounter+'->'+sf3+';';

		nodeCounter += 2;
	}
	| TOUPPERCASE L_PAR R_PAR
	{
		$$ = nodeCounter;
		let sf4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"string_function\"];';
		dotData += sf4+'[label=\"TO UPPER CASE\"];';
		dotData += nodeCounter+'->'+sf4+';';

		nodeCounter += 2;
	}
	| CONCAT L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let sf5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"string_function\"];';
		dotData += sf5+'[label=\"CONCAT\"];';
		dotData += nodeCounter+'->'+sf5+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
;

value
	: NUMBER
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| DECIMAL
	{
		$$ = nodeCounter;

		dotData += nodeCounter+'[label=\"value\"];';

		dotData += nodeCounter+'->'+$1+';';

		nodeCounter += 1;
	}
	| STRING DOT string_function
	{
		$$ = nodeCounter;
		let vl1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl1+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+vl1+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| STRING
	{
		$$ = nodeCounter;
		let vl001 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl001+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+vl001+';';

		nodeCounter += 2;
	}
	| NAME DOT string_function
	{
		$$ = nodeCounter;
		let vl2 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl2+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+vl2+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| NAME
	{
		$$ = nodeCounter;
		let vl002 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl002+'[label=\"'+$1+'\"];';
		dotData += nodeCounter+'->'+vl002+';';

		nodeCounter += 2;
	}
	| NAME L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let vl02 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl02+'[label=\"'+$1+'()\"];';
		dotData += nodeCounter+'->'+vl02+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| NAME L_PAR      R_PAR	
	{
		$$ = nodeCounter;
		let vl3 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl3+'[label=\"'+$1+'()\"];';
		dotData += nodeCounter+'->'+vl3+';';

		nodeCounter += 2;
	}
	| L_SQUARE expr R_SQUARE
	{
		//array assignment [elements]
		$$ = nodeCounter;
		let vl4 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl4+'[label=\"['+$2+']\"];';
		dotData += nodeCounter+'->'+vl4+';';

		nodeCounter += 2;
	}
	| L_SQUARE		R_SQUARE
	{
		$$ = nodeCounter;
		let vl5 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl5+'[label=\"['+$2+']\"];';
		dotData += nodeCounter+'->'+vl5+';';

		nodeCounter += 2;
	}
	| L_PAR expr R_PAR
	{
		$$ = nodeCounter;
		let vl6 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl6+'[label=\"('+$2+')\"];';
		dotData += nodeCounter+'->'+vl6+';';

		nodeCounter += 2;
	}
	| NAME DOT access_list
	{
		$$ = nodeCounter;
		let vl7 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"value\"];';
		dotData += vl7+'[label=\"'+$2+'\"];';
		dotData += nodeCounter+'->'+vl7+';';
		dotData += nodeCounter+'->'+$3+';';

		nodeCounter += 2;
	}
	| NEW ARRAY L_PAR expr R_PAR
	{
		
	}
;

access_list
	: NAME DOT access_list
	{
		$$ = nodeCounter;
		let al2 = nodeCounter+1;
		let al3 = nodeCounter+2;

		dotData += nodeCounter+'[label=\"access_list\"];';
		dotData += al2+'[label=\"'+ $1 +'\"];';
		dotData += al3+'[label=\"'+ $3 +'\"];';
		dotData += nodeCounter+'->'+al2+';';
		dotData += nodeCounter+'->'+al3+';';

		nodeCounter += 3;
	}
	| NAME
	{
		$$ = nodeCounter;
		let al1 = nodeCounter+1;

		dotData += nodeCounter+'[label=\"access_list\"];';
		dotData += al1+'[label=\"'+ $1 +'\"];';
		dotData += nodeCounter+'->'+al1+';';

		nodeCounter += 2;
	}
;