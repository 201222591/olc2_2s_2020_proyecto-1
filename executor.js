var Symbol = function(t, ret, id, val, len, scope)
{
    this.model = 'Symbol';
    this.type = t; //function variable 
    this.returnType = ret;
    this.id = id;
    this.value = val;
    this.length = len;
    this.scope = scope;
};

var SymbolTable = function()
{
    this.model = 'SymbolTable';
    this.symbols = [];
};

function isSymbolInTable(ts, id)
{
    let exist = false;
    ts.symbols.forEach(sym => {
        if(sym.id == id) 
        {
            exist = true;
        }
    });
    return exist;
}

function getSymbol(ts, id, index)
{
    if(index != null)
    {
        let s = null;
        ts.symbols.forEach(sym => {
            if(sym.id == id) s = sym;
        });
        return s;
    }
    else
    {
        let s = null;
        ts.symbols.forEach(sym => {
            if(sym.id == id) s = sym;
        });
        return s;
    }
    
}

function updateSymbol(id, arrayIndex, value)
{
    let index = globalStack.stack.length-1;
    let updated = false;
    let typesMatch = false;
    let voidAssigned = false;
    let isConst = false;
    for(let j = index; j>=0; j--) // symbol tables
    {
        for (let i = 0; i < globalStack.stack[j].symbols.length; i++) // symbols
        {
            if(globalStack.stack[j].symbols[i].id == id)
            {
                let type = globalStack.stack[j].symbols[i].returnType;
                let isNumber = type == 'number' && typeof value == 'number';
                let isString = type == 'string' && typeof value == 'string';
                let isBoolean = type == 'boolean' && typeof value == 'boolean';
                let isNull = type == null;
                isConst = globalStack.stack[j].symbols[i].scope == 'const';
                if(!isConst)
                {
                    if(type != 'void')
                    {
                        if(isNumber || isString || isBoolean || isNull)
                        {
                            //globalStack.stack[j].symbols[i].value = value;
                            if(arrayIndex != null) globalStack.stack[j].symbols[i].value[arrayIndex] = value;
                            else globalStack.stack[j].symbols[i].value = value;

                            if(isNull) globalStack.stack[j].symbols[i].returnType = typeof value;
                            updated = true;
                            typesMatch = true
                            voidAssigned = false;
                            break;
                        }
                        else
                        {
                            // TYPES DO NOT MATCH
                            updated = false;
                            typesMatch = false;
                            voidAssigned = false;
                        }
                    }
                    else
                    {
                        // TRYING TO ASSIGN TO VOID
                        updated = false;
                        typesMatch = false;
                        voidAssigned = true;
                    }
                }
                else
                {
                    updated = false;
                }
            }
            else continue;
        }
    }
    if(!typesMatch) semanticErrors.push(new Error('Los tipos de '+ id + ' y ' + value + ' no coinciden', 0, 0));
    if(voidAssigned) semanticErrors.push(new Error('No es posible asignar ' + value + ' a variable VOID '+ id));
    if(isConst) semanticErrors.push(new Error('La variable '+ id + ' es CONST y no puede modificarse'));
    return updated;
}

var TsStack = function()
{
    this.model = 'TS Stack';
    this.stack = [];
};
var Error = function(message, row, col)
{
    this.model = 'Error';
    this.message = message;
    this.row = row;
    this.column = col;
};

//var globalTS = new SymbolTable();
var globalStack = new TsStack();
var continueStack = [];
var breakStack = [];
var returnStack = [];

//Error lists
var lexicalErrors = [];
var syntaxErrors = [];
var semanticErrors = [];
//Console output
var consoleOutput='>>';
// AST URL
var astAddress = 'https://dreampuf.github.io/GraphvizOnline/#digraph{';
var dotData = '';
var nodeCounter = 0;
// flag declaration inside a function
var insideFunction = false;
// flag to check if called function is a child function
var isChildFunction = false;

function saveGlobal(ast)
{
    // save global variables and outer functions on TS
    globalStack.stack = [];
    /*lexicalErrors = [];
    syntaxErrors = [];
    semanticErrors = [];*/

    let globalTS = new SymbolTable();

    if(ast != null)
    {
        ast.forEach(stm => {
            if(stm.model == 'Function')
            {
                let f = new Symbol('Function', stm.returnType, stm.id, stm.statements, stm.parameters, 'var');
                globalTS.symbols.push(f);
            }
        });
    }
    // push TS to stack
    globalStack.stack.push(globalTS);
}

function execute(ast)
{
    if(ast != null)
    {
        for(let i=0; i<=ast.length-1; i++){
            let v = ast[i].model;
            if(ast[i].model == 'Function')
            {
                // add a flag to check if the saveglobal procedure already saved global functions
                // every other function that enters here, is a child function
                if(insideFunction)
                {
                    //console.log('DECLARING CHILD FUNCTION '+ast[i].id);
                    let f = new Symbol('Function', ast[i].returnType, ast[i].id, ast[i].statements, ast[i].parameters, 'var');
                    globalStack.stack[globalStack.stack.length-1].symbols.push(f);
                }


            }
            else if(ast[i].model == 'Declaration')
            {
                executeDeclaration(ast[i]);
            }
            else if(ast[i].model == 'Expression')
            {
                var res = executeExpression(ast[i]);
                //return res;
            }
            else if(ast[i].model == 'If')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                let value = executeIf(ast[i]);
                globalStack.stack.pop();
                //return value;
            }
            else if(ast[i].model == 'IfElse')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                let value = executeIfelse(ast[i]);
                globalStack.stack.pop();
                if(value != null) return value;
            }
            else if(ast[i].model == 'While')
            {
                let ts = new SymbolTable();
                //globalStack.stack.push(ts);
                breakStack.push(0);
                continueStack.push(0);
                executeWhile(ast[i]);
                //globalStack.stack.pop();
                breakStack.pop();
                continueStack.pop();
            }
            else if(ast[i].model == 'DoWhile')
            {
                let ts = new SymbolTable();
                //globalStack.stack.push(ts);
                breakStack.push(0);
                continueStack.push(0);
                executeDowhile(ast[i]);
                //globalStack.stack.pop();
                breakStack.pop();
                continueStack.pop();
            }
            else if(ast[i].model == 'For')
            {
                let ts = new SymbolTable();
                //globalStack.stack.push(ts);
                executeFor(ast[i]);
                //globalStack.stack.pop();
                breakStack.pop();
                continueStack.pop();
            }
            else if(ast[i].model == 'ForOf')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                breakStack.push(0);
                continueStack.push(0);
                executeForOf(ast[i]);
                globalStack.stack.pop();
                breakStack.pop();
                continueStack.pop();
            }
            else if(ast[i].model == 'ForIn')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                breakStack.push(0);
                continueStack.push(0);
                executeForIn(ast[i]);
                globalStack.stack.pop();
                breakStack.pop();
                continueStack.pop();
            }
            else if(ast[i].model == 'Switch')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                breakStack.push(0);
                executeSwitch(ast[i]);
                globalStack.stack.pop();
                breakStack.pop();
            }
            else if(ast[i].model == 'GraficarTS')
            {
                executeGraficarts(ast[i]);
            }
            else if(ast[i].model == 'ConsoleLog')
            {
                executeConsolelog(ast[i]);
            }
            else if(ast[i].model == 'Break')
            {
                i=ast.length;
            }
            else if(ast[i].model == 'Continue')
            {
                continue;
            }
            else if(ast[i].model == 'Return')
            {
                if(returnStack.length > 0)
                {
                    if(ast[i].value != null)
                    {
                        var res = executeExpression(ast[i].value);
                        return res;
                    }
                    else return null;
                }
                else
                {
                    semanticErrors.push(new Error('Sentencia return en un entorno no válido', 0, 0));
                }
                /*let returnValue = ast[i].value ? executeExpression(ast[i].value) : null;
                let functionType = returnStack[returnStack.length-1];
                let expectedType = null;
                let givenType = typeof returnValue;
                if(functionType == 'void') expectedType = null;
                else expectedType = functionType;
                if(expectedType == givenType) console.log('too bien');
                else console.log('too mal');*/
            }
        }
    }
}

function executeExpression(stm)
{
    if(stm.model == 'Number')
    {
        return Number(stm.value);
    }
    else if(stm.model == 'String')
    {
        return String(stm.value);
    }
    else if(stm.model == 'Boolean')
    {
        if(stm.value == 'true') return true;
        else if(stm.value == 'false') return false;
    }
    else if(stm.model == 'Variable')
    {
        // search for variable.id in all ts (top to bottom), return value
        let index = globalStack.stack.length-1;
        for(let i = index; i >= 0; i--)
        {
            if(isSymbolInTable(globalStack.stack[i], stm.id))
            {
                let sym = getSymbol(globalStack.stack[i], stm.id, null);
                return sym.value;
            }
        }
        let e = new Error('Símbolo \''+stm.id+'\' no existe', 0, 0);
        semanticErrors.push(e);
        return null;
    }
    else
    {
        if(stm.model == 'Call')
        {
            let tsIndex = globalStack.stack[0].symbols.length-1
            // SAVE
            for(let j=globalStack.stack.length-1; j>=0; j--)
            {
                for(let i=0; i<=tsIndex; i++)
                {
                    let f = globalStack.stack[j].symbols[i];
                    if(f!=null && f.id == stm.id && f.type == 'Function')
                    {
                        //verify number of parameters
                        let p_number1 = f.length == null ? 0 : f.length.length;
                        let singleParameter = stm.parameters != null && !Array.isArray(stm.parameters);
                        let p_number2;
                        if(singleParameter) p_number2 = 1;
                        else p_number2 = stm.parameters == null ? 0 : stm.parameters.length;
                        if(p_number1 == p_number2)
                        {
                            // new ts for the function
                            let ts = new SymbolTable();
                            for(let i=0; i<=p_number1-1; i++)
                            {
                                ////////////
                                let paramName = f.length[i].id;
                                let paramValue;
                                if(singleParameter) paramValue = executeExpression(stm.parameters);
                                else paramValue = executeExpression(stm.parameters[i]);
                                ////////////
                                let paramType = f.length[i].type;
                                let typesMatch = (paramType == null || paramType == typeof paramValue)? true: false;
                                if(typesMatch)
                                {
                                    // add each parameter = value to ts
                                    let sym = new Symbol('Declaration', paramType, paramName, paramValue, null, 'let');
                                    ts.symbols.push(sym);
                                }
                                else
                                {
                                    //param type does not match
                                    semanticErrors.push(new Error('No existe el parámetro', 0, 0));
                                    return null
                                }
                            }
                            globalStack.stack.push(ts);
                            insideFunction = true;
                            returnStack.push(f.returnType);
                            var res = execute(f.value);
                            returnStack.pop();
                            globalStack.stack.pop();
                            insideFunction = false;
                            /*if(res != null)*/ return res;
                            
                        }
                        else
                        {
                            //number of params does not match
                            semanticErrors.push(new Error('No coincide el número de parámetros', 0, 0));
                            return null;
                        }
                    }
                }
            }
            return null;
        }
        else if(stm.model == 'Push')
        {
            let tsIndex = globalStack.stack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = globalStack.stack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(globalStack.stack[i].symbols[j].id == stm.value1)
                    {
                        if(globalStack.stack[i].symbols[j].length == '[]')
                        {
                            let value2 = executeExpression(stm.value2);
                            globalStack.stack[i].symbols[j].value.push(value2);
                            return true;
                        }
                        else
                        {
                            semanticErrors.push(new Error('No se puede hacer PUSH. La variable no es un arreglo', 0, 0));
                            return null;
                        }
                    }
                    else continue;
                }
            }
            semanticErrors.push(new Error('No se encontró el símbolo '+stm.id, 0, 0));
            return null;
        }
        else if(stm.model == 'Pop')
        {
            let tsIndex = globalStack.stack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = globalStack.stack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(globalStack.stack[i].symbols[j].id == stm.value)
                    {
                        if(globalStack.stack[i].symbols[j].length == '[]')
                        {
                            let popped = globalStack.stack[i].symbols[j].value.pop();
                            return popped;
                        }
                        else
                        {
                            semanticErrors.push(new Error('No se puede hacer POP. La variable no es un arreglo', 0, 0));
                            return null;
                        }
                    }
                    else continue;
                }
            }
            semanticErrors.push(new Error('No se encontró el símbolo '+stm.id, 0, 0));
            return null;
        }
        else if(stm.model == 'Length')
        {
            let tsIndex = globalStack.stack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = globalStack.stack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(globalStack.stack[i].symbols[j].id == stm.value)
                    {
                        if(globalStack.stack[i].symbols[j].length == '[]')
                        {
                            let l = globalStack.stack[i].symbols[j].value.length;
                            return l;
                        }
                        else
                        {
                            semanticErrors.push(new Error('No se puede hacer LENGTH. La variable no es un arreglo', 0, 0));
                            return null;
                        }
                    }
                    else continue;
                }
            }
            semanticErrors.push(new Error('No se encontró el símbolo '+stm.id, 0, 0));
            return null;
        }
        else if(stm.model == 'ArrayAssignment')
        {
            let elements = [];
            if(stm.value != null)
            {
                if(Array.isArray(stm.value))
                {
                    stm.value.forEach(v => {
                        elements.push(executeExpression(v));
                    });
                }
                else elements.push(executeExpression(stm.value));
            }
            return elements;
        }
        else if(stm.model == 'ArrayAccess')
        {
            let arrayIndex = executeExpression(stm.index);
            let validIndex = arrayIndex >= 0 && Number.isInteger(arrayIndex);
            if(validIndex)
            {
                // get value
                let index = globalStack.stack.length-1;
                for(let i = index; i >= 0; i--)
                {
                    if(isSymbolInTable(globalStack.stack[i], stm.id.id))
                    {
                        let sym = getSymbol(globalStack.stack[i], stm.id.id, arrayIndex);
                        if(arrayIndex != null) return sym.value[arrayIndex];
                        else return sym.value;
                    }
                    else continue;
                }
                semanticErrors.push(new Error('No existe el símbolo', 0, 0));
                return null;
            }
            else
            {
                semanticErrors.push(new Error('Valor de índice inválido: '+arrayIndex,0, 0));
                return null;
            }
        }
        else if(stm.model == 'UnaryOperation')
        {
            let op = stm.operator;
            if(op == '!')
            {
                return !executeExpression(stm.value);
            }
            else if(op == '~')
            {
                return ~executeExpression(stm.value);
            }
            else if(op == '++')
            {
                // update symbol stm.value in TS
                let val = executeExpression(stm.value);
                let updated = false;
                if(typeof val == 'number') updated = updateSymbol(stm.value.id, null, val+1);
                if(!updated)
                {
                    semanticErrors.push(new Error('No se pudo realizar la operación ++',0, 0));
                    return null;
                }
                return true;
            }
            else if(op == '--')
            {
                // update symbol stm.value in TS
                let val = executeExpression(stm.value);
                let updated = false;
                if(typeof val == 'number') updated = updateSymbol(stm.value.id, null, val-1);
                if(!updated)
                {
                    semanticErrors.push(new Error('No se pudo realizar la operación --',0, 0));
                    return null;
                }
                return true;
            }
            else if(op == '-')
            {
                return -executeExpression(stm.value);
            }
            else if(op == '**')
            {
                // stm.value = Power(val1, val2)
                let base = executeExpression(stm.value.value1);
                let exp = executeExpression(stm.value.value2);
                return base ** exp;
            }
        }
        else if(stm.model == 'ArithmeticOperation')
        {
            if(stm.operator == '+')      return executeExpression(stm.value1) + executeExpression(stm.value2);
            else if(stm.operator == '-') return executeExpression(stm.value1) - executeExpression(stm.value2);
            else if(stm.operator == '*') return executeExpression(stm.value1) * executeExpression(stm.value2);
            else if(stm.operator == '/') return executeExpression(stm.value1) / executeExpression(stm.value2);
            else if(stm.operator == '%') return executeExpression(stm.value1) % executeExpression(stm.value2);
        }
        else if(stm.model == 'ShiftOperation')
        {
            if(stm.operator == '>>')      return executeExpression(stm.value1) >> executeExpression(stm.value2);
            else if(stm.operator == '<<') return executeExpression(stm.value1) << executeExpression(stm.value2);
        }
        else if(stm.model == 'RelationalOperation')
        {
            if(stm.operator == '<')       return executeExpression(stm.value1) < executeExpression(stm.value2);
            else if(stm.operator == '>')  return executeExpression(stm.value1) > executeExpression(stm.value2);
            else if(stm.operator == '>=') return executeExpression(stm.value1) >= executeExpression(stm.value2);
            else if(stm.operator == '<=') return executeExpression(stm.value1) <= executeExpression(stm.value2);
            else if(stm.operator == '==') return executeExpression(stm.value1) == executeExpression(stm.value2);
            else if(stm.operator == '!=') return executeExpression(stm.value1) != executeExpression(stm.value2);
        }
        else if(stm.model == 'BitwiseOperation')
        {
            if(stm.operator == '|')      return executeExpression(stm.value1) | executeExpression(stm.value2);
            else if(stm.operator == '&') return executeExpression(stm.value1) & executeExpression(stm.value2);
            else if(stm.operator == '^') return executeExpression(stm.value1) ^ executeExpression(stm.value2);
        }
        else if(stm.model == 'LogicalOperation')
        {
            if(stm.operator == '||')      return executeExpression(stm.value1) || executeExpression(stm.value2);
            else if(stm.operator == '&&') return executeExpression(stm.value1) && executeExpression(stm.value2);
        }
        else if(stm.model == 'TernaryOperation')
        {
            if(executeExpression(stm.value1) == true)
            {
                return executeExpression(stm.value2);
            }
            else
            {
                return executeExpression(stm.value3);
            }
        }
        else if(stm.model == 'AssignOperation')
        {
            // value1 = variable / variable [index]
            // value2 = variable / variable [index]
            //console.log(stm);
            let newValue = executeExpression(stm.value2);
            // verificar si es una variable o un acceso a arreglo
            let updated = false;
            if(stm.value1.model == 'ArrayAccess'){
                let arrayIndex = executeExpression(stm.value1.index);
                updated = updateSymbol(stm.value1.id.id, arrayIndex, newValue);
            }
            else if(stm.value1.model == 'Variable'){
                updated = updateSymbol(stm.value1.id, null, newValue);
            }
            
            if(!updated) semanticErrors.push(new Error('No se pudo actualizar la variable '+stm.value1.id+ ' = '+newValue, 0, 0));
        }
        else if(stm.model == 'Expression')
        {
            return executeExpression(stm.expression);
        }
    }
}

function executeFunction(stm)
{
}

function executeDeclaration(stm)
{
    // var Symbol = function(t, ret, id, val, len){}

    //let currentTS = globalStack.stack.pop();
    stm.idList.forEach(dec => {
        // get ts from top of stack and try to save there
        if(isSymbolInTable(/*currentTS*/globalStack.stack[globalStack.stack.length-1], dec.id) == false)
        {
            let val = null;
            let varType = null;
            let elementsMatchType = false;
            if(dec.value != null) val = executeExpression(dec.value);
            if(dec.type == null)
            {
                if(dec.value == null)
                {
                    varType = null;
                }
                else
                {
                    varType = typeof val;
                }
            }
            else
            {
                varType = dec.type;
            }
            if(dec.array != null)
            {
                val.forEach(element => {
                    if(typeof element == varType) elementsMatchType = true
                });
            }
            else {}
            //verify if types match
            if(typeof val == varType || val == null || (Array.isArray(val) && val.length == 0) || elementsMatchType)
            {
                let d = new Symbol('Declaration', varType, dec.id, val, dec.array, stm.scope);
                //decide where to store the variable
                if(stm.scope == 'var')
                {
                    if(insideFunction) globalStack.stack[globalStack.stack.length-1].symbols.push(d);
                    else globalStack.stack[0].symbols.push(d);
                }
                else
                {
                    globalStack.stack[globalStack.stack.length-1].symbols.push(d);
                }
            }
            else
            {
                semanticErrors.push(new Error('No coinciden el tipo de variable y el valor asignado', 0, 0));
            }

            
            
        }
        else
        {
            //error, id already in ts
            let e = new Error('Símbolo \''+dec.id+'\' ya existe en el ámbito actual');
            semanticErrors.push(e);
        }
    });
    //globalStack.stack.push(currentTS);
}

function executeIf(stm)
{
    let cond = stm.condition.expression;
    let stms = stm.statements;
    if(executeExpression(cond)) return execute(stms);
    else return null;
}

function executeIfelse(stm)
{
    let cond = stm.condition.expression;
    let stmsTrue = stm.statementsTrue;
    let stmsFalse = stm.statementsFalse;
    if(executeExpression(cond)) return execute(stmsTrue);
    else return execute(stmsFalse);
}

function executeWhile(stm)
{
    let cond = stm.condition.expression;
    let stms = stm.statements;
    while(executeExpression(cond))
    {
        globalStack.stack.push(new SymbolTable());
        execute(stms);
        globalStack.stack.pop();
    }
}

function executeDowhile(stm)
{
    let cond = stm.condition.expression;
    let stms = stm.statements;
    do
    {
        globalStack.stack.push(new SymbolTable());
        execute(stms); 
        globalStack.stack.pop();
    }
    while(executeExpression(cond));
}

function executeFor(stm)
{
    let arg1 = stm.arg1;
    let arg2 = stm.arg2;
    let arg3 = stm.arg3;
    let assignation = execute([arg1]);
    while(executeExpression(arg2))
    {
        globalStack.stack.push(new SymbolTable());
        execute(stm.statements);
        executeExpression(arg3);
        globalStack.stack.pop();
    }
}

function executeForIn(stm)
{
    //get array
    let index = globalStack.stack.length-1;
    let sym = null;
    for(let i = index; i >= 0; i--)
    {
        if(isSymbolInTable(globalStack.stack[i], stm.list))
        {
            sym = getSymbol(globalStack.stack[i], stm.list, null);
        }
    }
    // list exist
    if(sym != null)
    {
        sym.value.forEach(e => {
            //var element
            let element = {
                model: 'VarElement',
                id: stm.id,
                type: sym.returnType,
                array: null,
                value: e
            };
            let dec = {
                model: "Declaration",
                scope: 'let',
                idList: [element],
            };
            globalStack.stack[globalStack.stack.length-1].symbols.push(new Symbol('Declaration', sym.returnType, stm.id, e, null, 'let'));
            execute(stm.statements);
        });
    }
    else
    {
        semanticErrors.push(new Error('No existe el arreglo '+ stm.id, 0, 0));
    }
}

function executeForOf(stm)
{
    //get array
    let index = globalStack.stack.length-1;
    let sym = null;
    for(let i = index; i >= 0; i--)
    {
        if(isSymbolInTable(globalStack.stack[i], stm.list))
        {
            sym = getSymbol(globalStack.stack[i], stm.list, null);
        }
    }
    // list exist
    if(sym != null)
    {
        sym.value.forEach(e => {
            //var element
            let element = {
                model: 'VarElement',
                id: stm.id,
                type: sym.returnType,
                array: null,
                value: e
            };
            let dec = {
                model: "Declaration",
                scope: 'let',
                idList: [element],
            };
            globalStack.stack[globalStack.stack.length-1].symbols.push(new Symbol('Declaration', sym.returnType, stm.id, e, null, 'let'));
            execute(stm.statements);
        });
    }
    else
    {
        semanticErrors.push(new Error('No existe el arreglo '+ stm.id, 0, 0));
    }
}

function executeSwitch(stm)
{
    let cond = executeExpression(stm.condition);
    let cases = stm.cases;
    let caseMatch = false;
    let defCase = null;
    cases.forEach(c => {
        let v2 = executeExpression(c.value);
        defCase = v2 == 'default'? c : null;
        let compare =  cond == v2;
        if(compare) 
        {
            execute(c.statements);
            caseMatch = true;
        }
    });
    if(!caseMatch && defCase != null) execute(defCase.statements);
}

function executeGraficarts(stm)
{
    console.log(globalStack.stack[globalStack.stack.length-1]);
    consoleOutput += '\nID \t\t\t VALUE\n';
    globalStack.stack[globalStack.stack.length-1].symbols.forEach(sym =>{
        consoleOutput += sym.id + '\t\t\t' + sym.value + '\n';
    });
    consoleOutput += '>>';
}

function executeConsolelog(stm)
{
    console.log(executeExpression(stm.param));
    consoleOutput += executeExpression(stm.param) + '\n>>';
}