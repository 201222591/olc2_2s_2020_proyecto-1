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
((\").*?(\"))|((\').*?(\'))				return 'STRINGVAL';
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
	};

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
	};

	var StringCharAt = function(str, type, index)
	{
		this.model = 'StringCharAt',
		this.value = str;
		this.type = type;
		this.index = index;
	};

	var StringToLower = function(str, type)
	{
		this.model = 'StringToLower',
		this.value = str;
		this.type = type;
	};

	var StringToUpper = function(str, type)
	{
		this.model = 'StringToUpper',
		this.value = str;
		this.type = type;
	};

	var StringConcat = function(str1, str2, type)
	{
		this.model = 'StringConcat',
		this.value1 = str1;
		this.value2 = str2;
		this.type = type;
	};

	var AccessList = function(arr)
	{
		this.model = 'AccessList';
		this.list = arr;
	}

	var ObjectDeclaration = function(id, atr)
	{
		this.model = 'ObjectDeclaration';
		this.id = id;
		this.attributes = atr;
	};

	var Objectt = function(id, typ, atr)
	{
		this.model = 'Object';
		this.id = id;
		this.type = typ;
		this.attributes = atr;
	};

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

	function create_object(id, tp, atrs)
	{
		let o = new Objectt(id, tp, atrs);
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
		let decls1 = [$1];
		if($2 != null)
		{
			if(Array.isArray($2))
			{
				$2.forEach(element => decls1.push(element));
			}
			else
			{
				decls1.push($2);
			}
			
		}
		$$ = decls1;
	}
	|
	{
		$$ = null;
	}
	| error SEMICOLON
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext + '. Recuperando con ;', this._$.first_line, this._$.first_column));
		//console.log('Token no esperado: ' + yytext + '. Recuperando con ;', this._$.first_line, this._$.first_column);
	}
	| error L_CURLY
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext + '. Recuperando con }', this._$.first_line, this._$.first_column));
		//console.log('Token no esperado: ' + yytext + '. Recuperando con }', this._$.first_line, this._$.first_column);
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext + '.', this._$.first_line, this._$.first_column));
		//console.log('Token no esperado: ' + yytext + '.', this._$.first_line, this._$.first_column);
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
		let func_decl_name1 = $2.toLowerCase();
		$$ =  create_function($6, func_decl_name1, $4, $7);
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		let func_decl_name2 = $2.toLowerCase();
		$$ = create_function(null, func_decl_name2, $4, $6);
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		let func_decl_name3 = $2.toLowerCase();
		$$ = create_function($5, func_decl_name3, null, $6);
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		let func_decl_name4 = $2.toLowerCase();
		$$ = create_function(null, func_decl_name4, null, $5);
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
		let param1 = {
			model: 'Parameter',
			id: $1.toLowerCase(),
			type: $2
		};
		$$ = param1;
	}
	| NAME
	{
		let param2 = {
			model: 'Parameter',
			id: $1.toLowerCase(),
			type: null
		}; 
		$$ = param2;
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
	| FOR L_PAR scope NAME OF expr R_PAR stm
	{
		$$ =  create_forof($4.toLowerCase(), $6, $8);
	}
	| FOR L_PAR scope NAME IN expr R_PAR stm
	{
		$$ =  create_forin($4.toLowerCase(), $6, $8);
	}
	| object 
	{
		$$ = $1;
	}
	| object_decl 
	{
		$$ = $1;
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
	| FOR L_PAR scope NAME OF expr R_PAR then_stm
	{
		$$ =  create_forof($4.toLowerCase(), $6, $8);
	}
	| FOR L_PAR scope NAME IN expr R_PAR then_stm
	{
		$$ =  create_forin($4.toLowerCase(), $6, $8);
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
	| RETURN SEMICOLON
	{
		// return with no expression(2)
		$$ = create_return('null');
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
;

object_decl
	: TYPE NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
		$$ = create_objectdeclaration($2.toLowerCase(), $5);
	}
;

atr_list
	: atr COMMA atr_list
	{
		let atrlist1 = [];
		if($3 != null)
		{
			if(Array.isArray($3))
			{
				atrlist1.push($1);
				$3.forEach(e =>{
					atrlist1.push(e);
				});
				$$ = atrlist1;
			}
			else
			{
				$$ = [$1, $3];
			}
		}
		else
		{
			$$ = $1;
		}
	}
	| atr
	{
		$$ = $1;
	}
	| 
	{
		$$ = null;
	}
;

atr
	: NAME COLON NAME // id : variable
	{
		let atr1 = {
			id: $1.toLowerCase(),
			value: create_variable($3.toLowerCase())
		};
		$$ = atr1;
	}
	| NAME COLON type
	{
		let atr2 = {
			id: $1.toLowerCase(),
			value: $3.toLowerCase()
		};
		$$ = atr2;
	}
	| NAME COLON value
	{
		let atr3 = {
			id: $1.toLowerCase(),
			value: $3
		};
		$$ = atr3;
	}
;

object
	: scope NAME COLON NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
		$$ = create_object($2.toLowerCase(), $4.toLowerCase(), $7);
	}
	| scope NAME ASSIGN L_CURLY atr_list R_CURLY SEMICOLON
	{
		$$ = create_object($2.toLowerCase(), 'null', $5);
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
		let element = {
			model: 'VarElement',
			id: $1.toLowerCase(),
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
;

array // for declaration
	: L_SQUARE expr R_SQUARE
	{
		$$ = $2;
	}
	| L_SQUARE 		R_SQUARE
	{
		$$ = '[]';
	}
	| array L_SQUARE R_SQUARE
	{
		if($1 == null)
		{
			$$ = '[]';
		}
		else 
		{
			let sbList = $1;
			sbList += '[]';
			$$ = sbList;
		}
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
	: var_decl
	{
		$$ = $1;
	}
	| expr
	{
		$$ = $1;
	}
	|
	{
		$$ = null;
	}
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
		let defString1 = create_string('default');
		$$ = [create_case(defString1, $4)];
	}
	| DEFAULT COLON stm_list
	{
		let defString2 = create_string('default');
		$$ = [create_case(defString2, $3)];
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
	| op_unary POWER op_pointer
	{
		$$ = create_unaryoperation(create_power($1,$3), $2);
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

string_function
	: LENGTH
	{
		$$ = {
			type: 'StringLength',
		};
	}
	| CHARAT L_PAR expr R_PAR
	{
		$$ = {
			type: 'StringCharAt',
			index: $3,		
		};
	}
	| TOLOWERCASE L_PAR R_PAR
	{
		$$ = {
			type: 'StringToLower',
		};
	}
	| TOUPPERCASE L_PAR R_PAR
	{
		$$ = {
			type: 'StringToUpper',
		};
	}
	| CONCAT L_PAR expr R_PAR
	{
		$$ = {
			type: 'StringConcat',
			value: $3,
		};
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
	| STRINGVAL DOT string_function
	{
		let s3 = $1.replace(/\"/g, "");
		let s4 = s3.replace(/\'/g, "");

		if($3.type == 'StringLength')
		{
			$$ = create_stringlength(s4, 'String');
		}
		else if($3.type == 'StringCharAt')
		{
			$$ = create_stringcharat(s4, 'String', $3.index);
		}
		else if($3.type == 'StringToLower')
		{
			$$ = create_stringtolower(s4, 'String');
		}
		else if($3.type == 'StringToUpper')
		{
			$$ = create_stringtoupper(s4, 'String');
		}
		else if($3.type == 'StringConcat')
		{
			$$ = create_stringconcat(s4, $3.value, 'String');
		}
	}
	| STRINGVAL
	{
		/*let s = $1.replace(/\"/g, "");
		let s2 = s.replace(/\'/g, "");
		$$ = create_string(s2);*/
		let s2 = $1.slice(1, -1);
		$$ = create_string(s2);
	}
	| NAME DOT string_function
	{
		let nameDotFunction = $1.toLowerCase();
		if($3.type == 'StringLength')
		{
			$$ = create_stringlength(nameDotFunction, 'Variable');
		}
		else if($3.type == 'StringCharAt')
		{
			$$ = create_stringcharat(nameDotFunction, 'Variable', $3.index);
		}
		else if($3.type == 'StringToLower')
		{
			$$ = create_stringtolower(nameDotFunction, 'Variable');
		}
		else if($3.type == 'StringToUpper')
		{
			$$ = create_stringtoupper(nameDotFunction, 'Variable');
		}
		else if($3.type == 'StringConcat')
		{
			$$ = create_stringconcat(nameDotFunction, $3.value, 'Variable');
		}
	}
	| NAME
	{
		let name01 = $1.toLowerCase();
		if(name01 == 'true' || name01 == 'false')
		{
			$$ = create_boolean(name01);
		}
		else
		{
			$$ = create_variable(name01);
		}
	}
	| NAME L_PAR expr R_PAR
	{
		//function call
		
		$$ = create_call($1.toLowerCase(), $3);
	}
	| NAME L_PAR      R_PAR	
	{
		//function call
		$$ = create_call($1.toLowerCase(), null);
	}
	| L_SQUARE expr R_SQUARE
	{
		//array assignment [elements]
		$$ = create_arrayassignment($2); //left side array
	}
	| L_SQUARE		R_SQUARE
	{
		//array assignment []
		$$ = create_arrayassignment(null); //left side array
	}
	| L_PAR expr R_PAR
	{
		$$ = $2;
	}
	| NAME DOT access_list
	{
		let name_accesslist = [];
		name_accesslist.push($1.toLowerCase());
		$3.forEach(e => {
			name_accesslist.push(e);
		});
		$$ = create_accesslist(name_accesslist);
	}
	| NEW ARRAY L_PAR expr R_PAR
	{
		let newArray = {
			model : 'NewArray',
			expression : $4
		};
		$$ = newArray;
	}
;

access_list
	: NAME DOT access_list
	{
		let accesslist1 = [];
		if(Array.isArray($3))
		{
			$3.forEach(id =>{
				accesslist1.push(id);
			});
		}
		else
		{
			accesslist1.push($1.toLowerCase());
			accesslist1.push($3);
		}
		$$ = accesslist1;
	}
	| NAME
	{
		$$ = $1.toLowerCase();
	}
;