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
.                       {
							lexicalErrors.push(new Error('Error léxico en el token '+ yytext+'.', yylloc.first_line, yylloc.first_column));
							console.error('Error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column);
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
%}


%start S

%% /* Definición de la gramática */

S
	: decls EOF
	{
		return $1;
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext + '.', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext + '.', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
	}
;

func_decl
	: FUNCTION NAME L_PAR params R_PAR return_type block_decl
	{
		$$ =  create_function($6, $2, $4, $7);
	}
	| FUNCTION NAME L_PAR params R_PAR             block_decl
	{
		$$ = create_function(null, $2, $4, $6);
	}
	| FUNCTION NAME L_PAR        R_PAR return_type block_decl
	{
		$$ = create_function($5, $2, null, $6);
	}
	| FUNCTION NAME L_PAR        R_PAR             block_decl
	{
		$$ = create_function(null, $2, null, $5);
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
	}
	
;

param
	: NAME return_type
	{
		let param1 = {
			model: 'Parameter',
			id: $1,
			type: $2
		};
		$$ = param1;
	}
	| NAME
	{
		let param2 = {
			model: 'Parameter',
			id: $1,
			type: null
		}; 
		$$ = param2;
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
	}
;

return_type
	: COLON type
	{
		$$ = $2;
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
	}
;

block_decl
	: L_CURLY stm_list R_CURLY
	{
		$$ = $2;
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ' + yytext, this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| GRAFICAR_TS L_PAR R_PAR SEMICOLON
	{
		$$ = create_graficarTS();
	}
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
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
	| error
	{
		syntaxErrors.push(new Error('Token no esperado: ', this._$.first_line, this._$.first_column));
	}
;