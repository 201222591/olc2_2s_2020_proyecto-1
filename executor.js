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

//Error lists
var lexicalErrors = [];
var syntaxErrors = [];
var semanticErrors = [];
//Console output
var consoleOutput='>>';

function saveGlobal(ast)
{
    // save global variables and outer functions on TS
    globalStack.stack = [];
    let globalTS = new SymbolTable();

    if(ast != null)
    {
        ast.forEach(stm => {
            if(stm.model == 'Function')
            {
                let f = new Symbol('Function', stm.returnType, stm.id, null, 0, 'VAR');
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
        ast.forEach(stm => {
            if(stm.model == 'Function')
            {
                //skip, already added to ts
            }
            else if(stm.model == 'Declaration')
            {
                executeDeclaration(stm);
            }
            else if(stm.model == 'Expression')
            {
                executeExpression(stm);
            }
            else if(stm.model == 'If')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeIf(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'IfElse')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeIfelse(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'While')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeWhile(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'DoWhile')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeDowhile(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'For')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeFor(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'ForOf')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeForOf(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'ForIn')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeForIn(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'Switch')
            {
                let ts = new SymbolTable();
                globalStack.stack.push(ts);
                executeSwitch(stm);
                globalStack.stack.pop();
            }
            else if(stm.model == 'GraficarTS')
            {
                executeGraficarts(stm);
            }
            else if(stm.model == 'ConsoleLog')
            {
                executeConsolelog(stm);
            }
        });
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
            
        }
        else if(stm.model == 'Push')
        {
            console.log('Pushing '+stm.value2+ ' into array '+stm.value1);
        }
        else if(stm.model == 'Pop')
        {
            console.log('Popping top value from '+stm.value);
        }
        else if(stm.model == 'Length')
        {
            console.log('Getting length for array '+stm.value);
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
                // this part is only reached if symbol is not found in any ts
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
    console.log('Translating function');
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
            let len = null;
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

            }
            let d = new Symbol('Declaration', varType, dec.id, val, dec.array, stm.scope);
            globalStack.stack[globalStack.stack.length-1].symbols.push(d);
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
    if(executeExpression(cond)) execute(stms);
}

function executeIfelse(stm)
{
    let cond = stm.condition.expression;
    let stmsTrue = stm.statementsTrue;
    let stmsFalse = stm.statementsFalse;
    if(executeExpression(cond)) execute(stmsTrue);
    else execute(stmsFalse);
}

function executeWhile(stm)
{
    let cond = stm.condition.expression;
    let stms = stm.statements;
    while(executeExpression(cond)) execute(stms);
}

function executeDowhile(stm)
{
    let cond = stm.condition.expression;
    let stms = stm.statements;
    do execute(stms); while(executeExpression(cond));
}

function executeFor(stm)
{
    let arg1 = stm.arg1;
    let arg2 = stm.arg2;
    let arg3 = stm.arg3;
    let assignation = execute([arg1]);
    while(executeExpression(arg2))
    {
        execute(stm.statements);
        executeExpression(arg3);
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
        //ERROR. ARRAY DOES NOT EXIST
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
        //ERROR. ARRAY DOES NOT EXIST
    }
}

function executeSwitch(stm)
{
    let cond = executeExpression(stm.condition);
    let cases = stm.cases;
    cases.forEach(c => {
        let v2 = executeExpression(c.value);
        let compare =  cond == v2;
        if(compare) execute(c.statements);
    });
    
}

function executeGraficarts(stm)
{
    console.log(globalStack.stack[globalStack.stack.length-1]);
}

function executeConsolelog(stm)
{
    console.log(executeExpression(stm.param));
    consoleOutput += executeExpression(stm.param) + '\n>>';
}