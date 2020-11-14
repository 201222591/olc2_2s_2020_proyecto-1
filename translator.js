var Symbol = function(t, ret, id, val, len, scope, pos, scope2, nDim, oPos, arrLen)
{
    this.model = 'Symbol';
    this.type = t; //function or variable 
    this.returnType = ret; // variable/function type
    this.id = id; // name
    this.value = val;
    this.length = len; // 1 if var, else val.length
    this.scope = scope; // let / const
    this.position = pos; // position in stack relative to P
    this.scope2 = scope2; // local / global
    this.nDim = nDim; // number of array dimensions
    this.oPos = oPos; // stack position for types
    this.arrLen = arrLen; // array's length
};

var SymbolTable = function()
{
    this.model = 'SymbolTable';
    this.symbols = [];
};

var Error = function(message, row, col)
{
    this.model = 'Error';
    this.message = message;
    this.row = row;
    this.column = col;
};

//Error lists
var lexicalErrors = [];
var syntaxErrors = [];
var semanticErrors = [];
var finalSymbolTable = [];
// continue and break stack
var continueStack = [];
var breakStack = [];

var tsStack = []; // symbol table stack
var pStack = []; //  stores last position used in ts
var p = []; //stores de beginning of environment
var resultCode = '';
var resultTemp = null;
var resultPeek = null;
var resultType = null;
var resultLabel = null;
var tmpArray = [];
//var s_counter = 0; // stack  counter
var t_counter = 0;
var l_counter = 0;

// AST node counter
var nodeCounter = 1;
var dotData = '';
var astAddress = 'https://dreampuf.github.io/GraphvizOnline/#digraph{';
//astAddress += 'rankdir=LR;';

//array type
var arrayType = '';
var currentArrayLength;
var currentArrayID;
var returnedArrayLength;

var header = `
#include <stdio.h> 
#include <math.h>
//Importar para el uso de Printf
float heap[16384]; //Estructura para heap
float stack[16394]; //Estructura para stack
float P; //Puntero P
float H; //Puntero H;
`;

var mainFunction1 = `
void main() {

`;
var mainFunction2 = `
return;
}
`;

function create_t()
{
    t_counter++;
    let tmp = 't'+t_counter;
    tmpArray.push(tmp);
    return tmp;
}

function create_l()
{
    l_counter++;
    return 'L'+l_counter;
}

function clearResultCode()
{
    resultCode = '';
    t_counter = 0;
    l_counter = 0;
    tsStack = [];
    header = `
#include <stdio.h> 
#include <math.h>
//Importar para el uso de Printf
float heap[16384]; //Estructura para heap
float stack[16394]; //Estructura para stack
float P; //Puntero P
float H; //Puntero H;
`;
}

function addTmpToHeader()
{
    header += 'float ';
    for(let i=0; i<=tmpArray.length-1; i++)
    {
        if(i == tmpArray.length-1)
        {
            header += tmpArray[i] + ';\n';
        }
        else
        {
            header += tmpArray[i] + ', ';
        }
    }
}


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

function saveGlobal(ast)
{
    tsStack = [];
    p = [];
    pStack = [];
    lexicalErrors = [];
    syntaxErrors = []
    semanticErrors = [];
    tmpArray = [];
    finalSymbolTable = [];
    dotData = '';


    let globalTS = new SymbolTable();

    if(ast != null)
    {
        ast.forEach(stm => {
            if(stm.model == 'Function')
            {
                let f = new Symbol('Function', stm.returnType, stm.id, stm.statements, stm.parameters, 'var', -1, 'Global', -1, -1, -1);
                globalTS.symbols.push(f);
                finalSymbolTable.push(f);
            }
            else if(stm.model == 'ObjectDeclaration')
            {
                let f = new Symbol('Type', stm.id , stm.id, stm.attributes, null, 'var', -1, 'Global', -1, -1, -1);
                globalTS.symbols.push(f);
                finalSymbolTable.push(f);
            }
        });
    }
    tsStack.push(globalTS);
    pStack.push(0);
    p.push(0);
}

function translate(ast)
{
    if(ast != null)
    {
        for(let i=0; i<=ast.length-1; i++){
            let v = ast[i].model;
            if(ast[i].model == 'Function')
            {
            }
            else if(ast[i].model == 'Declaration')
            {
                translateDeclaration(ast[i]);
            }
            else if(ast[i].model == 'Object')
            {
                translateObject(ast[i]);
            }
            else if(ast[i].model == 'Expression')
            {
                var res = translateExpression(ast[i]);
            }
            else if(ast[i].model == 'If')
            {
                let ts = new SymbolTable();
                tsStack.push(ts); // save new symbol tabla
                pStack.push(0); // save new offset
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                let value = translateIf(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
                //return value;
            }
            else if(ast[i].model == 'IfElse')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                let value = translateIfElse(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
                //if(value != null) return value;
            }
            else if(ast[i].model == 'While')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                translateWhile(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'DoWhile')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                translateDowhile(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'For')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value

                translateFor(ast[i]);
                
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'ForOf')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                translateForOf(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'ForIn')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                translateForIn(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'Switch')
            {
                let ts = new SymbolTable();
                tsStack.push(ts);
                pStack.push(0);
                let previousIndex = pStack.length-2;
                p.push(pStack[previousIndex] + p[previousIndex]); // save new P value
                translateSwitch(ast[i]);
                tsStack.pop();
                pStack.pop();
                p.pop();
            }
            else if(ast[i].model == 'ConsoleLog')
            {
                translateConsolelog(ast[i]);
            }
            else if(ast[i].model == 'Break')
            {
                if(breakStack.length > 0)
                {
                    resultCode += '//BREAK\n';
                    resultCode += 'goto '+breakStack[breakStack.length-1]+';\n';
                    resultCode += '//BREAK\n';
                }
                else
                {
                    // invalid break
                    semanticErrors.push(new Error('Sentencia BREAK en un ámbito no válido', 0, 0));
                }
            }
            else if(ast[i].model == 'Continue')
            {
                if(continueStack.length > 0)
                {
                    resultCode += '//CONTINUE\n';
                    resultCode += 'goto '+continueStack[continueStack.length-1]+';\n';
                    resultCode += '//CONTINUE\n';
                }
                else
                {
                    // invalid break
                    semanticErrors.push(new Error('Sentencia CONTINUE en un ámbito no válido', 0, 0));
                }
            }
            else if(ast[i].model == 'Return')
            {
                // same as continue and break stacks
            }
        }
    }
}

function translateDeclaration(stm)
{
    stm.idList.forEach(d => {
        if(!isSymbolInTable(tsStack[tsStack.length-1], d.id))
        {
            //comprobar tipos. Tipo1 = d.type, Tipo2 = typeof(d.value);
            sPointer = pStack[pStack.length-1];
            let scope2 = tsStack.length == 1 ? 'Global' : 'Local';
            let typesMatch = false;
            if(d.array == null)
            {
                if(d.value != null)
                {
                    let value = translateExpression(d.value);
                    
                    resultCode += 'stack[(int)(P + '+sPointer+')] = ' + resultTemp + ';\n';
                    // guardar en la tabla de simbolos
                    let sym = new Symbol('Declaration', d.type, d.id, executeExpression(d.value), d.array, stm.scope, sPointer, scope2, 0, -1, 0);
                    tsStack[tsStack.length-1].symbols.push(sym);
                    finalSymbolTable.push(sym);
                    //console.log(d.id + '\t' + sPointer + '\t' + d.type + '\t' + sym.value);
                    //sPointer++;
                    pStack[pStack.length-1]++;
                }
                else
                {
                    //let value = translateExpression(d.value);
                    let defaultValue = null;
                    let temp = create_t();
                    if(d.type == 'number') 
                    {
                        let n = {
                            model: 'Number',
                            value: 0
                        };
                        translateExpression(n);
                    }
                    else if(d.type == 'string')
                    {
                        let s = {
                            model: 'String',
                            value: ''
                        };
                        translateExpression(s);
                    }
                    else if(d.type == 'boolean')
                    {
                        let s = {
                            model: 'Boolean',
                            value: false
                        };
                        translateExpression(s);
                    }
                    if(d.value == null && stm.scope.toLowerCase() == 'const')
                    {
                        semanticErrors.push(new Error('La variable '+d.id+' es constante. Debe declararse el valor.', 0, 0));

                    }
                    else
                    {
                        resultCode += 'stack[(int)(P + '+sPointer+')] = ' + resultTemp + ';\n';
                        // guardar en la tabla de simbolos
                        let value = d.value != null ? executeExpression(d.value) : null;
                        let sym = new Symbol('Declaration', d.type, d.id, value, d.array, stm.scope, sPointer, scope2, 0, -1, -1);
                        tsStack[tsStack.length-1].symbols.push(sym);
                        finalSymbolTable.push(sym);
                        //console.log(d.id + '\t' + sPointer + '\t' + d.type + '\t' + sym.value);
                        //sPointer++;
                        pStack[pStack.length-1]++;
                    }
                } 
            }
            else
            {
                /*console.log('Declarando arreglo');
                console.log(stm);*/
                //stm: idList: array, id, type, value() b
                arrayType = d.type;
                stm.idList.forEach(dec => {
                    if(dec.value == null)
                    {
                        // save empty array
                        /*resultCode += 'heap[(int)H] = ';
                        resultCode += 'stack[(int)P+'+sPointer+'] = ' + resultTemp + ';\n';*/
                        let nDim = dec.array.match(/\[/g);
                        let decValue = dec.value != null ? dec.value.value : null
                        let decValueLength = decValue == null ? -1 : decValue.length;
                        let sym = new Symbol('Declaration', dec.type, dec.id, decValue, dec.array, stm.scope, sPointer, scope2, nDim.length, -1, decValueLength);
                        tsStack[tsStack.length-1].symbols.push(sym);
                        pStack[pStack.length-1]++;
                        finalSymbolTable.push(sym);
                        // AGREGAR A STACK
                    }
                    else
                    {
                        // evaluate VALUE
                        //console.log(dec.value);
                        if(dec.value.model == 'ArrayAssignment') //        [expr]  expr-> expr,expr...
                        {
                            let nDim = dec.array.match(/\[/g);
                            currentArrayLength = nDim.length;
                            currentArrayID = dec.id;
                            let value = translateExpression(dec.value);
                            let tr = resultTemp;
                            if(true)
                            {
                                
                                let decValue = dec.value != null ? dec.value.value : null
                                let decValueLength = decValue == null ? -1 : decValue.length;
                                let sym = new Symbol('Declaration', dec.type, dec.id, decValue, dec.array, stm.scope, sPointer, scope2, nDim.length, -1, decValueLength);
                                tsStack[tsStack.length-1].symbols.push(sym);
                                pStack[pStack.length-1]++;
                                finalSymbolTable.push(sym);
                            }
                            else
                            {
                                // translateExpression should return the 
                            }
                        }
                        else if(dec.value.model == 'NewArray') // new array(expr)  expr-> expr,expr...
                        {
                            let newValue = {
                                model : 'ArrayAssignment',
                                value : dec.value.expression
                            };
                            let newStm = stm;
                            newStm.idList[0].value = newValue;
                            translateDeclaration(newStm);
                        }
                    }
                });
            }
        }
        else
        {
            // variable already declared locally
            semanticErrors.push(new Error('La variable '+d.id+' ya ha sido declarada localmente.', 0, 0));
        }
    });    
}

function translateObject(stm)
{
    // translating instance of TYPE
    // stm.type
    // stm.attributes
    let size = tsStack[0].symbols.length;
    for(let k=0; k<size; k++)
    {
        if(tsStack[0].symbols[k].id == stm.type)
        {
            //type exist
            let typeID = tsStack[0].symbols[k].id;
            let typeAttributes = Array.isArray(tsStack[0].symbols[k].value) ? tsStack[0].symbols[k].value : [tsStack[0].symbols[k].value];
            // check if id is used
            let index = tsStack.length-1;
            for(let j=0; j<tsStack[index].symbols.length; j++)
            {
                if(tsStack[index].symbols[j].id == stm.id)
                {
                    semanticErrors.push(new Error('Ya se ha declarado la variable '+stm.id, 0, 0));
                    return;
                }
                else
                {
                    // save??
                    // stm.attributes.id/value
                    let attributes = Array.isArray(stm.attributes) ? stm.attributes : [stm.attributes];
                    let attributeIndex = 0;
                    sPointer = pStack[pStack.length-1]; // next available space in stack
                    let ts = create_t(); // ts will store the first position in the heap (as strings)
                    resultCode += ts+' = H;\n'; // save H in stack
                    resultCode += 'H = H + 1;\n';
                    resultCode += 'stack[(int)(P + '+sPointer+')] = '+ts+';\n';
                    attributes.forEach(atr => {
                        /*console.log(atr.id);
                        console.log(typeAttributes[attributeIndex].id);*/
                        let sym;
                        if(atr.id == typeAttributes[attributeIndex].id)
                        {
                            // names match
                            // assume attribute type matches
                            
                        }
                        else
                        {
                            semanticErrors.push(new Error('No coinciden el nombre del atributo '+stm.id+' con el de TYPE '+typeAttributes[attributeIndex].id, 0, 0));
                            return;
                        }

                        attributeIndex += 1;
                    });
                    // create sym here
                    return;
                }
            }
            
        }        
        else if(stm.type == 'null')
        {
            console.log('TIPO ANONIMO ' + stm.id);
            return;
        }
    }
    semanticErrors.push(new Error('No existe el type '+stm.type, 0, 0));
}

function translateExpression(stm)
{
    if(stm.model == 'Number')
    {
        let t = create_t();
        resultCode += '//EMPIEZA NUMERO\n';
        resultCode += t + ' = ' + stm.value + ';\n';
        resultCode += '//TERMINA NUMERO\n';
        resultTemp = t;
        resultType = 'number';

        return Number(stm.value);
    }
    else if(stm.model == 'String')
    {
        resultCode += '//EMPIEZA CADENA\n';
        if(stm.value != '')
        {       
            let t = create_t();
            resultCode += t + ' = H;\n';     
            for(let i=0; i<stm.value.length; i++)
            {
                if(i==0) resultTemp = t;

                if(stm.value.charAt(i) == '\\')
                {
                    let tmpChar;
                    if(stm.value.charAt(i+1) == 'n') tmpChar = 10;
                    else if (stm.value.charAt(i+1) == '\"') tmpChar = 34;
                    else if (stm.value.charAt(i+1) == '\\') tmpChar = 92;
                    else if (stm.value.charAt(i+1) == 'r') tmpChar = 13;
                    else if (stm.value.charAt(i+1) == 't') tmpChar = 9;

                    resultCode += 'heap[(int)H] = ' + tmpChar + ';\n';
                    resultCode += 'H = H + 1;\n';

                    i++;
                }
                else
                {
                    resultCode += 'heap[(int)H] = ' + stm.value.charCodeAt(i) + ';\n';
                    resultCode += 'H = H + 1;\n';
                }                
            }
            resultCode += 'heap[(int)H] = -1;\n';
            resultCode += 'H = H + 1;\n';
        }
        else
        {
            //apuntador a -1 directamente P -> H -> -1
            let t = create_t();

            resultCode += t + ' = H;\n';
            resultCode += 'heap[(int)H] = -1;\n';
            resultCode += 'H = H + 1;\n';
            resultTemp = t;
        }
        resultCode += '//TERMINA CADENA\n';

        resultType = 'string';

        return String(stm.value);
    }
    else if(stm.model == 'Boolean')
    {
        let t = create_t();
        resultCode += '//EMPIEZA BOOLEANO\n';
        if(stm.value == 'true') resultCode += t + ' = 1;\n';
        else resultCode += t + ' = 0;\n';
        resultCode += '//TERMINA BOOLEANO\n';
        resultTemp = t;
        resultType = 'boolean';

        return Boolean(stm.value);
    }
    else if(stm.model == 'StringLength')
    {
        //stm.value = 'string' o variable
        if(stm.type == 'String')
        {
            // guardar en temporal la longitud de la cadena
            resultCode += '//EMPIEZA STRING LENGTH\n';
            let len = stm.value.length;
            let t = create_t();
            resultCode += t+' = (int)'+len+';\n';
            resultTemp = t;
            resultType = 'number'
            resultCode += '//TERMINA STRING LENGTH\n';
            return Number(len);
        }
        else if(stm.type == 'Variable')
        {
            // recover variable
            let index = tsStack.length-1;
            for(let i=index; i>=0; i--)
            {
                for(let j=0; j<tsStack[i].symbols.length; j++)
                {
                    let sym = tsStack[i].symbols[j];
                    if(sym.id == stm.value)
                    {

                        if(sym.nDim == 0)
                        {
                            let position = /*p[i]  +*/ sym.position;
                            let t = create_t();
                            let t0 = create_t();
                            let t1 = create_t();
                            let t2 = create_t();
                            let l0 = create_l();
                            let l1 = create_l();
                            let l2 = create_l();

                            resultCode += '//EMPIEZA VARIABLE LENGTH\n'; // 'hola'.length => 4
                            resultCode += t0+' = '+position+';//pos='+position+'\n';
                            resultCode += t1+' = (int)0;\n';
                            resultCode += t+' = stack[(int)(P + '+t0+')];\n';
                            resultCode += l0+':\n';
                            resultCode += t2+' = heap[(int)'+t+'];\n';
                            resultCode += 'if('+t2+' == -1) goto '+l2+';\n';
                            resultCode += 'goto '+l1+';\n';
                            resultCode += l1+':\n';
                            resultCode += t+' = '+t+'+1;\n';
                            resultCode += t1+' = '+t1+'+1;\n';
                            resultCode += 'goto '+l0+';\n';
                            resultCode += l2+':\n';
                            resultCode += '//TERMINA VARIABLE LENGTH\n';

                            resultTemp = t1;
                            resultType = 'number';
                            return 100;
                        }
                        else
                        {
                            resultCode += '//EMPIEZA ARRAY LENGTH\n';
                            let tr = create_t();
                            resultCode += tr+' = '+sym.value.length+';\n';
                            resultCode += '//TERMINA ARRAY LENGTH\n';
                            resultTemp = tr;
                            resultType = 'number';
                            return 100;
                        }
                        // symbol found
                        
                    }
                    continue;
                }
                continue;
            }
            semanticErrors.push(new Error('La variable '+stm.id+' no existe.', 0, 0));
        }
    }
    else if(stm.model == 'StringCharAt')
    {
        //value type index
        resultCode += '//EMPIEZA CHAR AT\n';
        translateExpression(stm.index);
        let index = resultTemp;
        if(stm.type == 'String')
        {
            let s = {
                model: 'String',
                value: stm.value
            };
            translateExpression(s);
            let t0 = resultTemp;
            let t1 = create_t();
            let t2 = create_t();
            let t3 = create_t();
            // for desde t hasta index
            let l0 = create_l();
            let l1 = create_l();
            let l2 = create_l();
            resultCode += t1+' = '+t0+'+'+index+';\n';
            resultCode += t2+' = (int)heap[(int)'+t1+'];\n';
            resultCode += t3+' = H;\n';
            resultCode += 'heap[(int)H] = '+t2+';\n';
            resultCode += 'H = H + 1;\n';
            resultCode += 'heap[(int)H] = -1;\n';
            resultCode += 'H = H + 1;\n';
            resultCode += '//TERMINA CHAR AT\n';
            resultTemp = t3;
            resultType = 'string';
            return 'string';
        }
        else if(stm.type == 'Variable')
        {
            let index = tsStack.length-1;
            for(let i=index; i>=0; i--)
            {
                for(let j=0; j<tsStack[i].symbols.length; j++)
                {
                    let sym = tsStack[i].symbols[j];
                    if(sym.id == stm.value)
                    {
                        // symbol found
                        let position = /*p[i] + */sym.position;
                        /*
                        t0 = stack[pos]
                        t1 = heap[t0+index]
                        heap[H] = t1
                        H = H+1
                        heap[H] = -1
                        H = H+1
                        */
                       resultCode += '//EMPIEZA CHAR AT\n';
                       let t0 = create_t();
                       let t1 = create_t();
                       let t2 = create_t();
                       translateExpression(stm.index);
                       let index = resultTemp;
                       resultCode += t0+' = stack[(int)(P + '+position+')];\n';
                       resultCode += t1+' = (int)heap[(int)('+t0+'+'+index+')];\n';
                       resultCode += t2+' = H;\n'; 
                       resultCode += 'heap[(int)H] = '+t1+';\n';
                       resultCode += 'H = H + 1;\n';
                       resultCode += 'heap[(int)H] = -1;\n';
                       resultCode += 'H = H + 1;\n';
                       resultCode += '//TERMINA CHAR AT\n';
                       resultTemp = t2;
                       resultType = 'string';
                       return 'string';
                    }                       
                    continue;
                }
                continue;
            }
            semanticErrors.push(new Error('La variable '+stm.id+' no existe.', 0, 0));
        }
        
    }
    else if(stm.model == 'StringToLower')
    {
        let value;
        if(stm.type == 'String')
        {
            let s = {
                model: 'String',
                value: stm.value
            };
            translateExpression(s);
        }
        else if(stm.type == 'Variable')
        {
            let v = {
                model: 'Variable',
                id: stm.value
            };
            translateExpression(v);
        }
        
        resultCode += '//EMPIEZA LOWER CASE\n';
        let t0 = resultTemp;
        let t00 = create_t();
        let t1 = create_t();
        let t2 = create_t();
        let t3 = create_t();
        let l0 = create_l();
        let l1 = create_l();
        let l2 = create_l();
        let l3 = create_l();
        let l4 = create_l();
        let l5 = create_l();
        let lsalida = create_l();

        resultCode += t00+' = '+t0+';\n';
        resultCode += l0+':\n';
        resultCode += t1+' = heap[(int)'+t0+'];\n';
        resultCode += 'if('+t1+' == -1) goto '+lsalida+';\n';
        resultCode += 'goto '+l1+';\n';
        resultCode += l1+':\n';
        resultCode += 'if('+t1+' >= 65) goto '+l2+';\n';
        resultCode += 'goto '+l3+';\n';
        resultCode += l2+':\n';
        resultCode += 'if('+t1+' <= 90) goto '+l4+';\n';
        resultCode += 'goto '+l3+';\n';
        resultCode += l4+':\n';
        resultCode += t3+' = '+t1+'+32;\n';
        resultCode += 'heap[(int)'+t0+'] = '+t3+';\n';
        resultCode += l3+':\n';
        resultCode += t0+' = '+t0+'+1;\n';
        resultCode += 'goto '+l0+';\n';
        resultCode += lsalida+':\n';
        resultCode += '//TERMINA LOWER CASE\n';

        resultTemp = t00;
        resultType = 'string';
        return 'string';
    }
    else if(stm.model == 'StringToUpper')
    {
        let value;
        if(stm.type == 'String')
        {
            let s = {
                model: 'String',
                value: stm.value
            };
            translateExpression(s);
        }
        else if(stm.type == 'Variable')
        {
            let v = {
                model: 'Variable',
                id: stm.value
            };
            translateExpression(v);
        }
        
        resultCode += '//EMPIEZA UPPER CASE\n';
        let t0 = resultTemp;
        let t00 = create_t();
        let t1 = create_t();
        let t2 = create_t();
        let t3 = create_t();
        let l0 = create_l();
        let l1 = create_l();
        let l2 = create_l();
        let l3 = create_l();
        let l4 = create_l();
        let l5 = create_l();
        let lsalida = create_l();

        resultCode += t00+' = '+t0+';\n';
        resultCode += l0+':\n';
        resultCode += t1+' = heap[(int)'+t0+'];\n';
        resultCode += 'if('+t1+' == -1) goto '+lsalida+';\n';
        resultCode += 'goto '+l1+';\n';
        resultCode += l1+':\n';
        resultCode += 'if('+t1+' >= 97) goto '+l2+';\n';
        resultCode += 'goto '+l3+';\n';
        resultCode += l2+':\n';
        resultCode += 'if('+t1+' <= 122) goto '+l4+';\n';
        resultCode += 'goto '+l3+';\n';
        resultCode += l4+':\n';
        resultCode += t3+' = '+t1+'-32;\n';
        resultCode += 'heap[(int)'+t0+'] = '+t3+';\n';
        resultCode += l3+':\n';
        resultCode += t0+' = '+t0+'+1;\n';
        resultCode += 'goto '+l0+';\n';
        resultCode += lsalida+':\n';
        resultCode += '//TERMINA UPPER CASE\n';

        resultTemp = t00;
        resultType = 'string';
        return 'string';
    }
    else if(stm.model == 'StringConcat')
    {
        resultCode += '//EMPIEZA CONCAT\n';
        if(stm.type == 'String')
        {
            let s = {
                model: 'String',
                value: stm.value1
            };
            translateExpression(s);
        }
        else if(stm.type == 'Variable')
        {
            let v = {
                model: 'Variable',
                id: stm.value1
            };
            
            translateExpression(v);
        }
        let t0 = resultTemp;
        translateExpression(stm.value2);
        let t1 = resultTemp;
        let t00 = create_t();
        let t2 = create_t();
        let t3 = create_t();
        let l1 = create_l();
        let l2 = create_l();
        let l3 = create_l();
        let l4 = create_l();
        let l5 = create_l();
        let l6 = create_l();
        let lsalida = create_l();
        resultCode += t00+' = H;\n';
        resultCode += l3+':\n';
        resultCode += 'heap[(int)H] = -1;\n';
        resultCode += t2+' = heap[(int)'+t0+'];\n';
        resultCode += 'if('+t2+' == -1) goto '+l1+';\n';
        resultCode += 'goto '+l2+';\n';
        resultCode += l1+':\n';
        resultCode += t3+' = heap[(int)'+t1+'];\n';
        resultCode += 'if('+t3+' == -1) goto '+l5+';\n';
        resultCode += 'goto '+l4+';\n';
        resultCode += l2+':\n';
        resultCode += 'heap[(int)H] = '+t2+';\n';
        resultCode += 'H = H + 1;';
        resultCode += t0+' = '+t0+'+1;\n';
        resultCode += 'goto '+l3+';\n';
        resultCode += l5+':\n';
        resultCode += 'heap[(int)H] = -1;\n';
        resultCode += 'H = H + 1;';
        resultCode += 'goto '+lsalida+';\n';
        resultCode += l4+':\n';
        resultCode += 'heap[(int)H] = '+t3+';\n';
        resultCode += 'H = H + 1;';
        resultCode += t1+' = '+t1+'+1;\n';
        resultCode += 'goto '+l1+';\n';
        resultCode += lsalida+':\n';
        resultCode += '//TERMINA CONCAT\n';

        resultTemp = t00;
        resultType = 'string';
        return 'string';
    }
    else if(stm.model == 'Variable')
    {
        // search for variable.id in all ts (top to bottom), return position
        let index = tsStack.length-1;
        for(let i=index; i>=0; i--)
        {
            for(let j=0; j<=tsStack[i].symbols.length-1; j++)
            {
                if(tsStack[i].symbols[j].id == stm.id)
                {
                    let sym = tsStack[i].symbols[j];
                    // variable is in stack[p[i] + sym.position]
                    // resultCode += 'P = '+p[i];
                    let t = create_t();
                    let position = p[i] + sym.position;
                    resultCode += '//EMPIEZA RECUPERACION DE VARIABLE '+stm.id+';\n';
                    resultCode += t + ' = ' + position + ';\n';
                    let t1 = create_t();
                    resultTemp = t1;
                    resultCode += t1 + ' = stack[(int)'+t+'];\n';
                    resultCode += '//TERMINA RECUPERACION DE VARIABLE '+stm.id+';\n';

                    if(sym.returnType == 'number')
                    {
                        resultType = 'number';
                        return 100.5;
                    }
                    else if(sym.returnType == 'string')
                    {
                        resultType = 'string';
                        return 'string';
                    }
                    else if(sym.returnType == 'boolean')
                    {
                        resultType = 'boolean';
                        return true;
                    }
                }
                // not current symbol
                continue;
            }
            //not current table
            continue;
        }
        // variable does not exist
        semanticErrors.push(new Error('La variable '+stm.id+' no existe.', 0, 0));
        return null;
    }
    else
    {
        if(stm.model == 'Call')
        {
            // llamada a funcion
        }        
        else if(stm.model == 'Length')
        {
            // obtener longitud de arreglo desde la tabla de simbolos
            //sym.value.length
            let tsIndex = tsStack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                for(let j=0; j<tsStack[i].symbols.length; j++)
                {
                    if(sym.id ==  null)
                    {

                    }
                    resultCode += '//INICIA ARRAY LENGTH\n';
                    let t0 = create_t();
                    let sym = tsStack[i].symbols[j];
                    let arraySize = Array.isArray(sym.value) ? sym.value.length : 0;
                    resultCode += t0+' = '+arraySize+';\n';
                    resultCode += '//TERMINA ARRAY LENGTH\n';
                    resultTemp = t0;
                    resultType = 'number';
                    return 100.5;
                }
            }
        }
        else if(stm.model == 'ArrayAssignment')
        {
            //       X = [expr]  expr-> expr,expr...
            //console.log(stm.value.expression.model);
            // let b:number[] = [2]
            sPointer = pStack[pStack.length-1];
            //console.log(arrayType);
            let value = Array.isArray(stm.value) ? stm.value : [stm.value];
            //console.log(value);
            if(stm.value == null)//ESTO
            {
                return null;
            }
            else
            {
                let arrayLength = currentArrayLength == null ? value.length : currentArrayLength;
                let arrayID = currentArrayID;
                let currentType = value[0].expression.model;
                currentArrayID = null;
                currentArrayLength = null;

                if(arrayLength == 1 || arrayID == null) // arrayID null significa que es un arreglo "anonimo" y debe ser de una dimension
                {
                    resultCode += '//INICIA GUARDAR ARREGLO\n';
                    let temps = []; // si es un arreglo tipo "number", contendra los temporales que guardan los numeros/booleanos, si es "string" contendra los apuntadores al heap de los inicios de cadena
                    let tr = create_t();               
                    
                    value.forEach(v => {
                        translateExpression(v);
                        let currentTemp = resultTemp;
                        temps.push(currentTemp);
                    });

                    resultCode += tr+' = H;\n';

                    temps.forEach(t => {
                        resultCode += 'heap[(int)H] = '+t+';\n';
                        resultCode += 'H = H + 1;\n';
                    });
                    
                    resultCode += 'stack[(int)(P + '+sPointer+')] = '+tr+';\n';
                    resultCode += '//TERMNINA GUARDAR ARREGLO\n';
                    resultTemp = tr;
                
                    pStack[pStack.length-1]++;
                    returnedArrayLength = value.length;
                    return [currentType, arrayLength];
                }
                else
                {
                    // nDim > 1
                    // linealizar arreglo
                    if(arrayLength == 2)
                    {
                        console.log('LINEALIZAR ARREGLOS 2');
                        let elements = []
                        for(let i=0; i<arrayLength; i++)
                        {
                            // each element is model = ArrayAssignment
                            //console.log(stm.value[i].expression.value);
                            elements.push(stm.value[i].expression.value);
                            // create Declaration
                        }
                        let newArrayAssignment = {
                            model : 'ArrayAssignment',
                            value : elements
                        };

                        let newVarElement = {
                            model : 'VarElement',
                            id : arrayID,
                            type : arrayType,
                            array : '[]', 
                            value : newArrayAssignment
                        };

                        let newDeclaration = {
                            model : 'Declaration',
                            scope : 'let',
                            idList : [newVarElement]
                        };

                        //console.log(newDeclaration);
                        translate([newDeclaration]);
                        
                    }
                    else if(arrayLength == 3)
                    {

                    }
                }
                
            }
        }
        else if(stm.model == 'ArrayAccess')
        {
            console.log(stm);

            //verificar stm.id
            if(stm.id.model == 'Variable')
            {
                let id = stm.id.id;
                let tsIndex = tsStack.length-1;
                for(let i=tsIndex; i>=0; i--)
                {
                    for(let j=0; j<tsStack[i].symbols.length; j++)
                    {
                        if(tsStack[i].symbols[j].id == id){
                            resultCode += '//EMPIEZA TRADUCIR INDICE\n';
                            translateExpression(stm.index);
                            let index = resultTemp;
                            resultCode += '//TERMINA TRADUCIR INDICE\n';
                            
                            let sym = tsStack[i].symbols[j];
                            let t0 = create_t();
                            let t1 = create_t();
                            resultCode += '//EMPIEZA ACCESO A ARREGLO\n';
                            resultCode += t0+' = stack[(int)(P + '+sym.position+')];\n';
                            resultCode += t1+' = heap[(int)('+t0+' + '+index+')];\n';
                            if(sym.returnType == 'number')
                            {
                                resultCode += '//TERMINA ACCESO A ARREGLO\n';
                                resultTemp = t1;
                                resultType = 'number';
                                return 100.5;
                            }
                            else if(sym.returnType == 'boolean')
                            {
                                resultCode += '//TERMINA ACCESO A ARREGLO\n';
                                resultTemp = t1;
                                resultType = 'boolean';
                                return false;
                            }
                            else
                            {
                                resultCode += '//TERMINA ACCESO A ARREGLO\n';
                                resultTemp = t1;
                                resultType = sym.resultType;
                                return 'string';
                            }
                            
                            
                        }
                    }
                }
                semanticErrors.push(new Error('La variable '+id+' no existe.', 0, 0));
            }
            else
            {
                // ERROR
            }
        }
        else if(stm.model == 'UnaryOperation')
        {
            let op = stm.operator;
            if(op == '!')
            {
                let value = translateExpression(stm.value);
                if(resultType == 'boolean')
                {
                    let t =  create_t();
                    let l1 = create_l();
                    let l2 = create_l();
                    let l3 = create_l();
                    resultCode += '//EMPIEZA NEGACION LOGICA\n';
                    resultCode += 'if('+resultTemp+' == 0) goto '+l1+';\n';
                    resultCode += 'goto '+l2+';\n';
                    resultCode += l1+':\n';
                    resultCode += t+' = '+1+';\n'
                    resultCode += 'goto '+l3+';\n';
                    resultCode += l2+':\n';
                    resultCode += t+' = '+0+';\n'
                    resultCode += 'goto '+l3+';\n';
                    resultCode += l3+':\n';
                    resultCode += '//TERMINA NEGACION LOGICA\n';
                    resultTemp = t;
                }
                else
                {
                    semanticErrors.push(new Error('El operando'+stm.value+' no es del tipo booleano.', 0, 0));
                    return null;
                }
            }
            else if(op == '++')
            {
                //let value = translateExpression(stm.value);
                // stm.value must be a variable
                if(stm.value.model == 'Variable')
                {
                    let index = tsStack.length-1;
                    for(let i=index; i>=0; i--)
                    {
                        for(let j=0; j<=tsStack[i].symbols.length-1; j++)
                        {
                            if(tsStack[i].symbols[j].id == stm.value.id)
                            {
                                let sym = tsStack[i].symbols[j];
                                tsStack[i].symbols[j].value++;
                                // variable is in stack[p[i] + sym.position]
                                let t = create_t();
                                let position = /*p[i] +*/ sym.position;
                                resultCode += '//EMPIEZA OPERACION ++\n';
                                resultCode += t + ' = ' + position + ';\n';
                                let t1 = create_t();
                                resultTemp = t1;
                                resultCode += t1 + ' = stack[(int)(P + '+t+')]+1;\n';
                                resultCode += 'stack[(int)(P + '+t+')] = '+t1+';\n';

                                resultCode += '//TERMINA OPERACION ++\n';
                                
                                return 100;
                            }
                            // not current symbol
                            continue;
                        }
                        //not current table
                        continue;
                    }
                    // variable does not exist
                    semanticErrors.push(new Error('La variable '+stm.value.id+' no existe.', 0, 0));
                    return null;
                }
                else
                {
                    semanticErrors.push(new Error('El operando '+stm.value.id+' no es una variable', 0, 0));
                    return null;
                }
            }
            else if(op == '--')
            {
                let value = translateExpression(stm.value);
                // stm.value must be a variable
                if(stm.value.model == 'Variable')
                {
                    let index = tsStack.length-1;
                    for(let i=index; i>=0; i--)
                    {
                        for(let j=0; j<=tsStack[i].symbols.length-1; j++)
                        {
                            if(tsStack[i].symbols[j].id == stm.value.id)
                            {
                                let sym = tsStack[i].symbols[j];
                                // variable is in stack[p[i] + sym.position]
                                let t = create_t();
                                let position = /*p[i] + */sym.position;
                                resultCode += '//EMPIEZA OPERACION --\n';
                                resultCode += t + ' = ' + position + ';\n';
                                let t1 = create_t();
                                resultTemp = t1;
                                resultCode += t1 + ' = stack[(int)(P + '+t+')]-1;\n';
                                resultCode += 'stack[(int)(P + '+t+')] = '+t1+';\n';

                                resultCode += '//TERMINA OPERACION --\n';
                                
                                return 100;
                            }
                            // not current symbol
                            continue;
                        }
                        //not current table
                        continue;
                    }
                    // variable does not exist
                    semanticErrors.push(new Error('La variable '+stm.value.id+' no existe.', 0, 0));
                    return null;
                }
                else
                {
                    semanticErrors.push(new Error('El operando '+stm.value.id+' no es una variable', 0, 0));
                    return null;
                }
            }
            else if(op == '-')
            {
                let value = translateExpression(stm.value);
                if(resultType == 'number')
                {
                    let t = create_t();
                    resultCode += t + ' = -' + resultTemp + ';\n';
                    resultTemp = t;
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('El operando no es un número.', 0, 0));
                    return null;
                }
            }
            else if(op == '**')
            {
                let exp = translateExpression(stm.value.value2); // exponent
                let b = resultTemp;
                let base = translateExpression(stm.value.value1); // exponent
                let a = resultTemp;
                let l1 = create_l();
                let l2 = create_l();
                let l3 = create_l();
                let t1 = create_t();
                let t2 = create_t();
                
                resultCode += '//EMPIEZA POTENCIACION\n';
                resultCode += t1+' = 1;\n'
                resultCode += t2+' = 1;\n'
                resultCode += l1+':\n';
                resultCode += 'if('+t1+' <= '+b+') goto '+l2+';\n';
                resultCode += 'goto '+l3+';\n';
                resultCode += l2+':\n';
                resultCode += t2+' = '+t2+' * '+a+';\n';
                resultCode += t1+' = '+t1+' + 1;\n'
                resultCode += 'goto '+l1+';\n';
                resultCode += l3+':\n';
                resultType = 'number';
                resultTemp = t2;
                resultCode += '//TERMINA POTENCIACION\n';
                return 100;
            }
        }
        else if(stm.model == 'ArithmeticOperation')
        {
            if(stm.operator == '+') // for number-number / number-boolean / boolean-number is the same code
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;

                if(aType == 'number' && bType == 'number' || aType == 'number' && bType == 'boolean' || aType == 'boolean' && bType == 'number')
                {
                    resultCode += '//EMPIEZA SUMA NUMEROS\n';
                    resultCode += t1+' = '+a+' + '+b+';\n';
                    resultTemp = t1;
                    resultType = 'number';
                    resultCode += '//TERMINA SUMA NUMEROS\n';
                    return 100.5;
                }
                else if(aType == 'string' && bType == 'number')
                {

                   let l0 = create_l();
                   let l1 = create_l();
                   let l2 = create_l();
                   let t2 = create_t();

                   resultCode += '//EMPIEZA SUMA CADENA Y NUMERO\n';
                   resultCode += t1+' = H;\n';
                   resultCode += l0+':\n';
                   resultCode += t2+' = heap[(int)'+a+'];\n';
                   resultCode += 'if('+t2+' != -1) goto '+l1+';\n';
                   resultCode += 'goto '+l2+';\n';
                   resultCode += l1+':\n';
                   resultCode += 'heap[(int)H] = '+t2+';\n';
                   resultCode += 'H = H + 1;\n';
                   resultCode += a+' = '+a+'+1;\n';
                   resultCode += 'goto '+l0+';\n';
                   resultCode += l2+':\n';

                   /////
                   let num = create_t();
                   let temp = create_t();
                   let factor = create_t();
                   let dig = create_t();
                   let l00 = create_l();
                   let l10 = create_l();
                   let l20 = create_l();
                   let l30 = create_l();
                   let l40 = create_l();

                   /*
                   
                    float num, temp, factor, dig;
                    factor=1;
                    num=4;
                    temp=num;
                    L0:
                    if(temp > 1) goto L1;
                    goto L2;
                    L1:
                    temp = (int)(temp/10);
                    factor=factor*10;
                    goto L0;
                    L2:
                    if(factor >1 ) goto L3;
                    goto L4;
                    L3:
                    factor=factor/10;
                    dig=num/factor;
                    printf("%d\n",(int)dig);
                    num=(int)num % (int)factor;
                    goto L2;
                    L4:
                   */

                   resultCode += factor+' = 1;//factor = 1\n';
                   resultCode += num+' = '+b+';\n';
                   resultCode += temp+' = '+num+';\n';
                   resultCode += l00+':\n';
                   resultCode += 'if('+temp+' > 1) goto '+l10+';\n';
                   resultCode += 'goto '+l20+';\n';
                   resultCode += l10+':\n';
                   resultCode += temp+' = (int)('+temp+' / 10);\n';
                   resultCode += factor+' = '+factor+' * 10;\n';
                   resultCode += 'goto '+l00+';\n';
                   resultCode += l20+':\n';
                   resultCode += 'if('+factor+' > 1) goto '+l30+';\n';
                   resultCode += 'goto '+l40+';\n';
                   resultCode += l30+':\n';
                   resultCode += factor+' = '+factor+' / 10;\n';
                   resultCode += dig+' = '+num+' / '+factor+';\n';
                   resultCode += 'heap[(int)H] = (int)('+dig+' + 48);//CONVERT TO ASCII\n'
                   resultCode += 'H = H + 1;\n';
                   
                   resultCode += num+' = (int)'+num+' % (int)'+factor+';\n';
                   resultCode += 'goto '+l20+';\n';
                   resultCode += l40+':\n';
                   resultCode += 'heap[(int)H] = -1;\n';
                   resultCode += 'H = H + 1;\n';
                   /////
                   resultCode += '//TERMINA SUMA CADENA Y NUMERO\n';
                   resultTemp = t1;
                   resultType = 'string';
                   return 'string';

                }
                else if(aType == 'number' && bType == 'string')
                {
                    let l0 = create_l();
                    let l1 = create_l();
                    let l2 = create_l();
                    let t2 = create_t();
                    let numberToString = String(executeExpression(stm.value1));
                    resultCode += '//EMPIEZA SUMA NUMERO CADENA\n';
                    resultCode += t1+' = H;\n';

                    /////
                   let num = create_t();
                   let temp = create_t();
                   let factor = create_t();
                   let dig = create_t();
                   let l00 = create_l();
                   let l10 = create_l();
                   let l20 = create_l();
                   let l30 = create_l();
                   let l40 = create_l();

                   resultCode += factor+' = 1;\n';
                   resultCode += num+' = '+a+';\n';
                   resultCode += temp+' = '+num+';\n';
                   resultCode += l00+':\n';
                   resultCode += 'if('+temp+' >= 1) goto '+l10+';\n';
                   resultCode += 'goto '+l20+';\n';
                   resultCode += l10+':\n';
                   resultCode += temp+' = (int)('+temp+' / 10);\n';
                   resultCode += factor+' = '+factor+' * 10;\n';
                   resultCode += 'goto '+l00+';\n';
                   resultCode += l20+':\n';
                   resultCode += 'if('+factor+' > 1) goto '+l30+';\n';
                   resultCode += 'goto '+l40+';\n';
                   resultCode += l30+':\n';
                   resultCode += factor+' = '+factor+' / 10;\n';
                   resultCode += dig+' = '+num+' / '+factor+';\n';
                   resultCode += 'heap[(int)H] = (int)'+dig+' + 48;//CONVERT TO ASCII\n'
                   resultCode += 'H = H + 1;\n';
                   
                   resultCode += num+' = (int)'+num+' % (int)'+factor+';\n';
                   resultCode += 'goto '+l20+';\n';
                   resultCode += l40+':\n';
                   /////

                    resultCode += l0+':\n';
                    resultCode += t2+' = heap[(int)'+b+'];\n';
                    resultCode += 'if('+t2+' != -1) goto '+l1+';\n';
                    resultCode += 'goto '+l2+';\n';
                    resultCode += l1+':\n';
                    resultCode += 'heap[(int)H] = '+t2+';\n';
                    resultCode += 'H = H + 1;\n';
                    resultCode += b+' = '+b+'+1;\n';
                    resultCode += 'goto '+l0+';\n';
                    resultCode += l2+':\n';
 
                    
                    resultCode += 'heap[(int)H] = -1;\n';
                    resultCode += 'H = H + 1;\n';
 
                    resultCode += '';
                    resultCode += '//TERMINA SUMA NUMERO CADENA\n';
                    resultTemp = t1;
                    resultType = 'string';
                    return 'string';
                }
                else if(aType == 'boolean' && bType == 'string')
                {
                    let lfalse = create_l();
                    let ltrue = create_l();
                    let lsalida = create_l();
                    let t1 = create_t();
                    let t2 = create_t();


                    // true -> 116 114 117 101 
                    // false-> 102 97  108 115 101

                    resultCode += '//EMPIEZA SUMA BOOLEAN Y CADENA\n';
                    resultCode += t1+' = H;\n';
                    resultCode += 'if('+a+' == 0) goto '+lfalse+';\n';
                    resultCode += 'goto '+ltrue+';\n';
                    resultCode += lfalse+':\n//agregar a heap "false"\n';
                    resultCode += 'heap[(int)H] = 102;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 97;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 108;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 115;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 101;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += ltrue+'://agregar a heap "true"\n';
                    resultCode += 'heap[(int)H] = 116;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 114;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 117;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 101;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += lsalida+'://lsalida\n';

                    let l3 = create_l();
                    let l4 = create_l();
                    let l5 = create_l();
                    
                    resultCode += l3+':\n';
                    resultCode += t2+' = heap[(int)'+b+'];\n';
                    resultCode += 'if('+t2+' != -1) goto '+l4+';\n';
                    resultCode += 'goto '+l5+';\n';
                    resultCode += l4+':\n';
                    resultCode += 'heap[(int)H] = '+t2+';\n';
                    resultCode += 'H = H + 1;\n';
                    resultCode += b+' = '+b+'+1;\n';
                    resultCode += 'goto '+l3+';\n';
                    resultCode += l5+':\n';
                    resultCode += 'heap[(int)H] = -1;\n';
                    resultCode += 'H = H + 1;\n'; 
                    resultCode += '//EMPIEZA SUMA BOOLEAN Y CADENA\n';

                    resultTemp = t1;
                    resultType = 'string';
                    return 'string';

                }
                else if(aType == 'string' && bType == 'boolean')
                {
                    let lfalse = create_l();
                    let ltrue = create_l();
                    let lsalida = create_l();
                    let t1 = create_t();
                    let t2 = create_t();


                    // true -> 116 114 117 101 
                    // false-> 102 97  108 115 101

                    resultCode += '//EMPIEZA SUMA CADENA Y BOOLEAN\n';
                    resultCode += t1+' = H;\n';
                    

                    let l3 = create_l();
                    let l4 = create_l();
                    let l5 = create_l();
                    
                    resultCode += l3+':\n';
                    resultCode += t2+' = heap[(int)'+a+'];\n';
                    resultCode += 'if('+t2+' != -1) goto '+l4+';\n';
                    resultCode += 'goto '+l5+';\n';
                    resultCode += l4+':\n';
                    resultCode += 'heap[(int)H] = '+t2+';\n';
                    resultCode += 'H = H + 1;\n';
                    resultCode += a+' = '+a+'+1;\n';
                    resultCode += 'goto '+l3+';\n';
                    resultCode += l5+':\n';
                    //resultCode += 'heap[(int)H] = -1;\n';
                    //resultCode += 'H = H + 1;\n'; 

                    resultCode += 'if('+b+' == 0) goto '+lfalse+';\n';
                    resultCode += 'goto '+ltrue+';\n';
                    resultCode += lfalse+':\n//agregar a heap "false"\n';
                    resultCode += 'heap[(int)H] = 102;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 97;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 108;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 115;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 101;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = -1;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += ltrue+'://agregar a heap "true"\n';
                    resultCode += 'heap[(int)H] = 116;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 114;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 117;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = 101;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += 'heap[(int)H] = -1;\n';
                    resultCode += 'H = H + 1;\n'
                    resultCode += lsalida+'://lsalida\n';

                    resultCode += '//EMPIEZA SUMA CADENA Y BOOLEAN\n';

                    resultTemp = t1;
                    resultType = 'string';
                    return 'string';
                }
                else if(aType == 'string' && bType == 'string')
                {
                    let l0 = create_l();
                    let l1 = create_l();
                    let l2 = create_l();
                    let t2 = create_t();

                    resultCode += '//EMPIEZA SUMA CADENA Y CADENA\n';
                    resultCode += t1+' = H;\n';
                    resultCode += l0+':\n';
                    resultCode += t2+' = heap[(int)'+a+'];\n';
                    resultCode += 'if('+t2+' != -1) goto '+l1+';\n';
                    resultCode += 'goto '+l2+';\n';
                    resultCode += l1+':\n';
                    resultCode += 'heap[(int)H] = '+t2+';\n';
                    resultCode += 'H = H + 1;\n';
                    resultCode += a+' = '+a+'+1;\n';
                    resultCode += 'goto '+l0+';\n';
                    resultCode += l2+':\n';

                    let l3 = create_l();
                    let l4 = create_l();
                    let l5 = create_l();
                    
                    resultCode += l3+':\n';
                    resultCode += t2+' = heap[(int)'+b+'];\n';
                    resultCode += 'if('+t2+' != -1) goto '+l4+';\n';
                    resultCode += 'goto '+l5+';\n';
                    resultCode += l4+':\n';
                    resultCode += 'heap[(int)H] = '+t2+';\n';
                    resultCode += 'H = H + 1;\n';
                    resultCode += b+' = '+b+'+1;\n';
                    resultCode += 'goto '+l3+';\n';
                    resultCode += l5+':\n';
                    resultCode += 'heap[(int)H] = -1;\n';
                    resultCode += 'H = H + 1;\n'; 

                    resultCode += '//TERMINA SUMA CADENA Y CADENA\n';
                    resultTemp = t1;
                    resultType = 'string';
                    return 'string';
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para suma', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '-')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA RESTA NUMEROS\n';
                    resultCode += t1+' = '+a+' - '+b+';\n';
                    resultTemp = t1;
                    resultType = 'number';
                    resultCode += '//TERMINA RESTA NUMEROS\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para resta', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '*')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA MULTIPLICACION NUMEROS\n';
                    resultCode += t1+' = '+a+' * '+b+';\n';
                    resultTemp = t1;
                    resultType = 'number';
                    resultCode += '//TERMINA MULTIPLICACION NUMEROS\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para multiplicacion', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '/')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA DIVISION NUMEROS\n';
                    resultCode += t1+' = '+a+' / '+b+';\n';
                    resultTemp = t1;
                    resultType = 'number';
                    resultCode += '//TERMINA DIVISION NUMEROS\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para division', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '%')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA RESTA NUMEROS\n';
                    resultCode += t1+' = fmod('+a+', '+b+');\n';
                    resultTemp = t1;
                    resultType = 'number';
                    resultCode += '//TERMINA RESTA NUMEROS\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para resta', 0, 0));
                    return null;
                }
            }
        }
        else if(stm.model == 'ShiftOperation')
        {
            if(stm.operator == '>>')
            {}
            else if(stm.operator == '<<')
            {}
        }
        else if(stm.model == 'RelationalOperation')
        {
            if(stm.operator == '<')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA MENOR QUE\n';
                    resultCode += t1+' = '+a+' < '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA MENOR QUE\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para menor que', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '>')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA MAYOR QUE\n';
                    resultCode += t1+' = '+a+' > '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA MAYOR QUE\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para mayor que', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '>=')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA MAYOR IGUAL QUE\n';
                    resultCode += t1+' = '+a+' >= '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA MAYOR IGUAL QUE\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para mayor igual que', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '<=')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'number' && bType == 'number')
                {
                    resultCode += '//EMPIEZA MENOR IGUAL QUE\n';
                    resultCode += t1+' = '+a+' <= '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA MENOR IGUAL QUE\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para menor igual que', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '==')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if((aType == 'number') && bType == 'number')
                {
                    resultCode += '//EMPIEZA IGUAL QUE NUMEROS\n';
                    resultCode += t1+' = '+a+' == '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA IGUAL QUE NUMEROS\n';
                    return true;
                }
                else if(aType == 'boolean' && bType == 'boolean')
                {
                    resultCode += '//EMPIEZA IGUAL QUE BOOLEAN\n';
                    resultCode += t1+' = '+a+' == '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA IGUAL QUE BOOLEAN\n';
                    return true;
                }
                else if(aType == 'string' && bType == 'string')
                {
                    resultCode += '//EMPIEZA IGUAL QUE STRING\n';
                    l0 = create_l();
                    l1 = create_l();
                    l2 = create_l();
                    l3 = create_l();
                    l4 = create_l();
                    l5 = create_l();
                    l6 = create_l();
                    l7 = create_l();
                    l8 = create_l();
                    lsalida = create_l();
                    tr = create_t();
                    t0 = create_t();
                    t1_2 = create_t();
                    t2 = create_t();
                    t3 = create_t();
                    t4 = create_t();
                    resultCode += l0+':\n';
                    resultCode += t0+' = heap[(int)'+a+'];\n';
                    resultCode += t1_2+' = heap[(int)'+b+'];\n';
                    resultCode += 'if('+t0+' == -1) goto '+l1+';\n';
                    resultCode += 'goto '+l2+';\n';
                    resultCode += l1+':\n';
                    resultCode += 'if('+t1_2+' == -1) goto '+l3+';\n';
                    resultCode += 'goto '+l4+';\n';
                    resultCode += l2+':\n';
                    resultCode += 'if('+t1_2+' == -1) goto '+l5+';\n';
                    resultCode += 'goto '+l6+';\n';
                    resultCode += l3+':\n';
                    resultCode += tr+' = 1;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += l4+':\n'+l5+':\n';
                    resultCode += tr+' = 0;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += l6+':\n';
                    resultCode += 'if('+t0+' == '+t1_2+') goto '+l7+'; \n';
                    resultCode += 'goto '+l8+';\n';
                    resultCode += l7+':\n';
                    resultCode += a+' = '+a+'+1;\n';
                    resultCode += b+' = '+b+'+1;\n';
                    resultCode += 'goto '+l0+';\n';
                    resultCode += l8+':\n';
                    resultCode += tr+' = 0;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += lsalida+':\n';

                    resultTemp = tr;
                    resultType = 'boolean';
                    resultCode += '//TERMINA IGUAL QUE STRING\n';
                    return true;
                }
                else if(aType == 'type' && bType == 'type')
                {

                }
                else if(aType == 'array' && bType == 'array')
                {

                }
                else if(aType == 'type' && bType == 'null')
                {

                }
                else if(aType == 'array' && bType == 'null')
                {

                }
                else if(aType == 'string' && bType == 'null')
                {

                }
                else if(aType == 'null' && bType == 'null')
                {

                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para igual que', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '!=')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if((aType == 'number') && bType == 'number')
                {
                    resultCode += '//EMPIEZA DIFERENTE QUE NUMEROS\n';
                    resultCode += t1+' = '+a+' != '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA DIFERENTE QUE NUMEROS\n';
                    return true;
                }
                else if(aType == 'boolean' && bType == 'boolean')
                {
                    resultCode += '//EMPIEZA DIFERENTE QUE BOOLEAN\n';
                    resultCode += t1+' = '+a+' != '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA DIFERENTE QUE BOOLEAN\n';
                    return true;
                }
                else if(aType == 'string' && bType == 'string')
                {
                    resultCode += '//EMPIEZA DIFERENTE QUE STRING\n';
                    l0 = create_l();
                    l1 = create_l();
                    l2 = create_l();
                    l3 = create_l();
                    l4 = create_l();
                    l5 = create_l();
                    l6 = create_l();
                    l7 = create_l();
                    l8 = create_l();
                    lsalida = create_l();
                    tr = create_t();
                    t0 = create_t();
                    t1_2 = create_t();
                    t2 = create_t();
                    t3 = create_t();
                    t4 = create_t();
                    resultCode += l0+':\n';
                    resultCode += t0+' = heap[(int)'+a+'];\n';
                    resultCode += t1_2+' = heap[(int)'+b+'];\n';
                    resultCode += 'if('+t0+' == -1) goto '+l1+';\n';
                    resultCode += 'goto '+l2+';\n';
                    resultCode += l1+':\n';
                    resultCode += 'if('+t1_2+' == -1) goto '+l3+';\n';
                    resultCode += 'goto '+l4+';\n';
                    resultCode += l2+':\n';
                    resultCode += 'if('+t1_2+' == -1) goto '+l5+';\n';
                    resultCode += 'goto '+l6+';\n';
                    resultCode += l3+':\n';
                    resultCode += tr+' = 0;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += l4+':\n'+l5+':\n';
                    resultCode += tr+' = 1;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += l6+':\n';
                    resultCode += 'if('+t0+' == '+t1_2+') goto '+l7+'; \n';
                    resultCode += 'goto '+l8+';\n';
                    resultCode += l7+':\n';
                    resultCode += a+' = '+a+'+1;\n';
                    resultCode += b+' = '+b+'+1;\n';
                    resultCode += 'goto '+l0+';\n';
                    resultCode += l8+':\n';
                    resultCode += tr+' = 1;\n';
                    resultCode += 'goto '+lsalida+';\n';
                    resultCode += lsalida+':\n';

                    resultTemp = tr;
                    resultType = 'boolean';
                    resultCode += '//TERMINA DIFERENTE QUE STRING\n';
                    return true;
                }
                else if(aType == 'type' && bType == 'type')
                {

                }
                else if(aType == 'array' && bType == 'array')
                {

                }
                else if(aType == 'type' && bType == 'null')
                {

                }
                else if(aType == 'array' && bType == 'null')
                {

                }
                else if(aType == 'string' && bType == 'null')
                {

                }
                else if(aType == 'null' && bType == 'null')
                {

                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para igual que', 0, 0));
                    return null;
                }
            }
        }
        else if(stm.model == 'BitwiseOperation')
        {
            if(stm.operator == '|'){}
            else if(stm.operator == '&'){}
            else if(stm.operator == '^'){}
        }
        else if(stm.model == 'LogicalOperation')
        {
            if(stm.operator == '||')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'boolean' && bType == 'boolean')
                {
                    resultCode += '//EMPIEZA OR\n';
                    resultCode += t1+' = '+a+' || '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA OR\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para or', 0, 0));
                    return null;
                }
            }
            else if(stm.operator == '&&')
            {
                let t1 = create_t();
                let val1 = translateExpression(stm.value1);
                let a = resultTemp;
                let aType = resultType;
                let val2 = translateExpression(stm.value2);
                let b = resultTemp;
                let bType = resultType;
                if(aType == 'boolean' && bType == 'boolean')
                {
                    resultCode += '//EMPIEZA AND\n';
                    resultCode += t1+' = '+a+' && '+b+';\n';
                    resultTemp = t1;
                    resultType = 'boolean';
                    resultCode += '//TERMINA AND\n';
                    return 100.5;
                }
                else
                {
                    semanticErrors.push(new Error('Los tipos de operandos '+aType+' y '+bType+' no son compatibles para and', 0, 0));
                    return null;
                }
            }
        }
        else if(stm.model == 'TernaryOperation')
        {
            let t1 = create_t();
            let val1 = translateExpression(stm.value1);
            let a = resultTemp;
            let aType = resultType;
            let val2 = translateExpression(stm.value2);
            let b = resultTemp;
            let bType = resultType;
            let val3 = translateExpression(stm.value3);
            let c = resultTemp;

            let l1 = create_l();
            let l2 = create_l();
            let l3 = create_l();
            if(aType == 'boolean')
            {
                resultCode += '//EMPIEZA TERNARIO\n';
                resultCode += 'if('+a+' == 1) goto '+l1+';\n';
                resultCode += 'goto '+l2+';\n';
                resultCode += l1+':\n';
                // true ->  value2. Verify types?
                resultCode += t1+' = '+b+';\n';
                resultCode += 'goto '+l3+';\n';
                resultCode += l2+':\n';
                // false ->value3
                resultCode += t1+' = '+c+';\n';
                resultCode += 'goto '+l3+';\n';
                resultCode += l3+':\n';
                resultCode += '//TERMINA TERNARIO\n';
                resultTemp = t1;
                resultType = bType;
                let retValue;
                if(resultType == 'number') return 100.5;
                else if(resultType == 'boolean') return true;
                else if(resultType == 'string') return 'string';
            }
            else
            {
                semanticErrors.push(new Error('El tipo de  '+aType+' no es booleano para operador ternario', 0, 0));
                return null;
            }
        }
        else if(stm.model == 'AssignOperation')
        {
            // a = X or b[i] = X
            if(stm.value1.model == 'ArrayAccess')
            {
                resultCode += '//EMPIEZA ASIGNACION A ARREGLO\n';
                resultCode += '//EN PROGRESO\n';
                resultCode += '//TERMINA ASIGNACION A ARREGLO\n';
            }
            else if(stm.value1.model == 'Variable')
            {
                resultCode += '//EMPIEZA ASIGNACION A VARIABLE\n';
                // get variable
                let index = tsStack.length-1;
                for(let i=index; i>=0; i--)
                {
                    for(let j=0; j<tsStack[i].symbols.length; j++)
                    {
                        let sym = tsStack[i].symbols[j];
                        let pos = p[i] + sym.position;
                        if(sym.scope != 'const')
                        {
                            if(sym.id == stm.value1.id)
                            {
                                //update value
                                let newValue = translateExpression(stm.value2);
                                if(resultType == sym.returnType)
                                {
                                    if(sym.returnType == 'number' || sym.returnType == 'boolean')
                                    {
                                        // save new value in the stack
                                        resultCode += 'stack[(int)'+pos+'] = '+resultTemp+';\n';
                                        return true;
                                    }
                                    else if(sym.returnType == 'string')
                                    {
                                        // save new value
                                        resultCode += 'stack[(int)'+pos+'] = '+resultTemp+';\n';
                                        return true;
                                    }
                                }
                                else
                                {
                                    // types do not match
                                    semanticErrors.push(new Error('Los tipos de variable('+sym.returnType+') y expresion('+resultType+') no coinciden', 0, 0));
                                }
                            }
                        }
                        else
                        {
                            semanticErrors.push(new Error('No se puede reasignar el valor de '+sym.id+'. Es CONST.', 0, 0));
                        }

                    }
                }
                resultCode += '//TERMINA ASIGNACION A VARIABLE';
            }
            else
            {
                semanticErrors.push(new Error('El lado izquierdo de la expresion es invalido', 0, 0));
                return null;
            }
        }
        else if(stm.model == 'Expression')
        {
            return translateExpression(stm.expression);
        }
    }
}

function translateIf(stm)
{
    console.log(p);
    resultCode += '//INICIA IF\n';
    let cond = translateExpression(stm.condition.expression);
    let trueLabel = create_l();
    let falseLabel = create_l();
    let t = create_t(); // t = P
    resultCode += t + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';
    resultCode += 'if('+ resultTemp  +' == 1) goto ' + trueLabel + ';\n';
    resultCode += 'goto ' + falseLabel + ';\n';
    resultCode += trueLabel + ':\n'
    translate(stm.statements);
    resultCode += falseLabel + ':\n'
    resultCode += 'P = ' + t +';\n';
    resultCode += '//TERMINA IF\n';
}

function translateIfElse(stm)
{
    resultCode += '//INICIA IF ELSE\n';
    let cond = translateExpression(stm.condition.expression);
    let trueLabel = create_l();
    let falseLabel = create_l();
    let exitLabel = create_l();
    let t = create_t(); // t = P
    resultCode += t + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';
    resultCode += 'if('+ resultTemp  +' == 1) goto ' + trueLabel + ';\n';
    resultCode += 'goto ' + falseLabel + ';\n';
    resultCode += trueLabel + ':\n'
    if(Array.isArray(stm.statementsTrue)) translate(stm.statementsTrue);
    else translate([stm.statementsTrue]);
    resultCode += 'goto ' + exitLabel +';\n';
    resultCode += falseLabel + ':\n';
    if(Array.isArray(stm.statementsFalse)) translate(stm.statementsFalse);
    else translate([stm.statementsFalse]);
    resultCode += exitLabel +':\n'
    resultCode += 'P = ' + t +';\n';
    resultCode += '//TERMINA IF ELSE\n';
}

function translateWhile(stm)
{
    resultCode += '//INICIA WHILE\n';
    let returnLabel = create_l();
    let trueLabel = create_l();
    let exitLabel = create_l();

    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';

    breakStack.push(exitLabel);
    continueStack.push(returnLabel);

    resultCode += returnLabel+'://etiqueta de retorno WHILE\n';
    let cond = translateExpression(stm.condition.expression);
    let t0 = resultTemp;
    resultCode += 'if('+t0+' == 1) goto '+trueLabel+';//if para verificar\n';
    resultCode += 'goto '+exitLabel+';\n';
    resultCode += trueLabel+':\n';
    
    let stms = translate(stm.statements);

    breakStack.pop();
    continueStack.pop();

    resultCode += 'goto '+returnLabel+';\n';
    resultCode += exitLabel+':\n';
    resultCode += 'P = ' + tp +';\n';
    resultCode += '//TERMINA WHILE\n';
}

function translateDowhile(stm)
{
    resultCode += '//INICIA DO WHILE\n';
    let returnLabel = create_l();
    let trueLabel = create_l();
    let exitLabel = create_l();

    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';

    breakStack.push(exitLabel);
    continueStack.push(returnLabel);

    

    resultCode += returnLabel+':\n';
    let cond = translateExpression(stm.condition.expression);
    let t0 = resultTemp;
    let stms = translate(stm.statements);
    resultCode += 'if('+t0+' == 1) goto '+trueLabel+';\n';
    resultCode += 'goto '+exitLabel+';\n';
    resultCode += trueLabel+':\n';


    breakStack.pop();
    continueStack.pop();

    resultCode += 'goto '+returnLabel+';\n';
    resultCode += exitLabel+':\n';

    resultCode += 'P = ' + tp +';\n';

    resultCode += '//TERMINA DO WHILE\n'; 
}

function translateFor(stm)
{
    resultCode += '//EMPIEZA FOR\n'; 

    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';

    let a = translate([stm.arg1]);
    let arg1 = resultTemp;
    let returnLabel = create_l();
    let exitLabel = create_l();
    let trueLabel = create_l();
    let arg3Label = create_l();

    breakStack.push(exitLabel);
    continueStack.push(arg3Label);


    resultCode += returnLabel+':\n';
    let b = translateExpression(stm.arg2);
    let arg2 = resultTemp;
    resultCode += 'if('+arg2+' == 1) goto '+trueLabel+';//IF DE FOR\n'; 
    resultCode += 'goto '+exitLabel+';\n';
    resultCode += trueLabel+':\n';

    breakStack.push(exitLabel);
    continueStack.push(returnLabel);

    let block = translate(stm.statements);

    resultCode += arg3Label+':\n';
    let arg3 = translateExpression(stm.arg3);

    resultCode += 'goto '+returnLabel+';\n';
    resultCode += exitLabel+':\n';

    resultCode += 'P = ' + tp +';\n';

    resultCode += '//TERMINA FOR\n'; 
}

function translateForOf(stm) // elements of array (any)
{
    let decType;
    let arrayLength;
    try
    {
        decType = stm.list.expression.value[0].expression.model;
        arrayLength = stm.list.expression.value.length
    }
    catch(error)
    {

        decType = null; // decType = returntype de la variable
        let stopFor = false;
        for(let i=tsStack.length-1; i>=0; i--)
        {
            for(let j=0; j<tsStack[i].symbols.length; j++)
            {
                if(stm.list.expression.id == tsStack[i].symbols[j].id)
                {
                    decType = tsStack[i].symbols[j].returnType;
                    arrayLength = tsStack[i].symbols[j].arrLen;
                    stopFor = true;
                    break;
                }
            }
            if(stopFor) break;
        }
    }

    decType = decType.toLowerCase();
    
    //let listType = stm.list.expression.model == 'Variable' ? 
    // stm: id, list, statements
    resultCode += '//EMPIEZA FOR OF\n'; 
    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';
    // declarar variable stm.id
    sPointer = pStack[pStack.length-1];
    let a = translateExpression(stm.list);
    let sym = new Symbol('Declaration', decType, stm.id, null, null, 'let', sPointer, 'Local', 0, -1, -1);
    tsStack[tsStack.length-1].symbols.push(sym);
    finalSymbolTable.push(sym);
    pStack[pStack.length-1]++;
    
    let t0 = create_t(); 
    let ti = create_t(); 
    let tcounter = create_t();
    let tindex = create_t();
    let tarr = create_t(); 
    let lr = create_l();
    let lfor = create_l();
    let lsalida = create_l();

    t0 = resultTemp; // will contain the first position for list
    
    resultCode += ti+' = stack[(int)(P + '+sPointer+')];// variable i para recorrer\n';

    resultCode += lr+':\n';
    // if(index >= arrSize) goto Lfor
    resultCode += 'if('+tindex+' < '+arrayLength+') goto '+lfor+';// if(index < arr.length)\n';
    // goto Lsalida;
    resultCode += 'goto '+lsalida+';\n';
    // Lfor
    resultCode += lfor+':\n';
    resultCode += tarr+' = heap[(int)('+t0+' + '+tindex+')];\n';
    resultCode += 'stack[(int)(P'+' + '+sPointer+')] = '+tarr+';// asignacion de la posicion array[index] a la variable i\n';
    //traducir bloque
    translate(stm.statements);
    resultCode += ti+' = '+ti+' + 1;\n';
    resultCode += tindex+' = '+tindex+' + 1;\n';
    resultCode += 'goto '+lr+';\n';
    // Lsalida:
    resultCode += lsalida+':\n';
    resultCode += '//TERMINA FOR OF\n'; 
}

function translateForIn(stm) // index of elements of array (string)
{
    let decType;
    let arrayLength;
    try
    {
        decType = stm.list.expression.value[0].expression.model;
        arrayLength = stm.list.expression.value.length
    }
    catch(error)
    {

        decType = null; // decType = returntype de la variable
        let stopFor = false;
        for(let i=tsStack.length-1; i>=0; i--)
        {
            for(let j=0; j<tsStack[i].symbols.length; j++)
            {
                if(stm.list.expression.id == tsStack[i].symbols[j].id)
                {
                    decType = tsStack[i].symbols[j].returnType;
                    arrayLength = tsStack[i].symbols[j].arrLen;
                    stopFor = true;
                    break;
                }
            }
            if(stopFor) break;
        }
    }

    decType = decType.toLowerCase();
    
    //let listType = stm.list.expression.model == 'Variable' ? 
    // stm: id, list, statements
    resultCode += '//EMPIEZA FOR IN\n'; 
    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';
    // declarar variable stm.id
    sPointer = pStack[pStack.length-1];
    let a = translateExpression(stm.list);
    let sym = new Symbol('Declaration', 'number', stm.id, null, null, 'let', sPointer, 'Local', 0, -1, -1);
    tsStack[tsStack.length-1].symbols.push(sym);
    finalSymbolTable.push(sym);
    pStack[pStack.length-1]++;
    
    let t0 = create_t(); 
    let ti = create_t(); 
    let tcounter = create_t();
    let tindex = create_t();
    let tarr = create_t(); 
    let lr = create_l();
    let lfor = create_l();
    let lsalida = create_l();

    t0 = resultTemp; // will contain the first position for list
    
    resultCode += ti+' = stack[(int)(P + '+sPointer+')];// variable i para recorrer\n';

    resultCode += lr+':\n';
    // if(index >= arrSize) goto Lfor
    resultCode += 'if('+tindex+' < '+arrayLength+') goto '+lfor+';// if(index < arr.length)\n';
    // goto Lsalida;
    resultCode += 'goto '+lsalida+';\n';
    // Lfor
    resultCode += lfor+':\n';
    resultCode += tarr+' = '+tindex+';\n';
    resultCode += 'stack[(int)(P'+' + '+sPointer+')] = '+tarr+';// asignacion de la posicion array[index] a la variable i\n';
    //traducir bloque
    translate(stm.statements);
    resultCode += ti+' = '+ti+' + 1;\n';
    resultCode += tindex+' = '+tindex+' + 1;\n';
    resultCode += 'goto '+lr+';\n';
    // Lsalida:
    resultCode += lsalida+':\n';
    resultCode += '//TERMINA FOR IN\n'
}

function translateSwitch(stm)
{
    resultCode += '//EMPIEZA SWITCH\n';

    let tp = create_t(); // t = P
    resultCode += tp + ' = P;\n';
    resultCode += 'P = '+p[p.length-1]+';\n';

    translateExpression(stm.condition);
    switchId = resultTemp;
    let exitLabel = create_l();
    breakStack.push(exitLabel);
    if(stm.cases != null)
    {
        let caseCounter = 0;
        stm.cases.forEach(c => {
            let def = executeExpression(c.value);
            if(def == 'default')
            {
                resultCode += '//EMPIEZA CASE DEFAULT\n';
                resultCode += nextCaseLabel+':\n';
                translate(c.statements);
                
                nextCaseLabel = create_l();
                resultCode += '//TERMINA CASE DEFAULT\n';
            }
            else
            {
                if(caseCounter == 0)
                {
                    resultCode += '//EMPIEZA CASE\n';
                    translateExpression(c.value);
                    caseValue = resultTemp;
                    trueLabel = create_l();
                    falseLabel = create_l();
                    nextCaseLabel = create_l();
                    resultCode += 'if('+switchId+' == '+caseValue+') goto '+trueLabel+';\n';
                    resultCode += 'goto '+falseLabel+';\n';
                    resultCode += trueLabel+':\n';
                    translate(c.statements);
                    //goto next case
                    resultCode += 'goto '+nextCaseLabel+';\n';
                    resultCode += falseLabel+':\n';
                    resultCode += '//TERMINA CASE\n';
                }
                else
                {
                    resultCode += '//EMPIEZA CASE\n';
                    translateExpression(c.value);
                    caseValue = resultTemp;
                    trueLabel = create_l();
                    falseLabel = create_l();
                    resultCode += 'if('+switchId+' == '+caseValue+') goto '+nextCaseLabel+';\n';
                    resultCode += 'goto '+falseLabel+';\n';
                    resultCode += nextCaseLabel+':\n';
                    resultLabel =  create_l();
                    translate(c.statements);
                    //goto next case
                    nextCaseLabel = create_l();
                    resultCode += 'goto '+nextCaseLabel+';\n';
                    resultCode += falseLabel+':\n';
                    resultCode += '//TERMINA CASE\n';
                }
            }
            caseCounter++;
        });
        resultCode += nextCaseLabel+':\n';
    }
    breakStack.pop();
    resultCode += exitLabel+':\n';

    resultCode += 'P = ' + tp +';\n';

    resultCode += '//TERMINA SWITCH\n';
}

function translateConsolelog(stm)
{
    //stm.param -> expression 
    //evaluate expression and determine the type
    let params = Array.isArray(stm.param) ? stm.param : [stm.param];
    resultCode += '//EMPIEZA IMPRIMIR\n';
    params.forEach(param => {
        let value = translateExpression(param);
        if(typeof value == 'number')
        {
            if(Number.isInteger(value))
            {
                // print %d
                resultCode += '//EMPIEZA IMPRIMIR ENTERO\n';
                resultCode += 'printf("%d", (int)' + resultTemp + ');\n';
                resultCode += '//EMPIEZA IMPRIMIR ENTERO\n';
            }
            else
            {
                // print %f
                resultCode += '//EMPIEZA IMPRIMIR DECIMAL\n';
                resultCode += 'printf("%f", (float)' + resultTemp + ');\n';
                resultCode += '//EMPIEZA IMPRIMIR DECIMAL\n';
            }
        }
        else if(typeof value == 'string')
        {
            // print %s
            //resultTemp has the beggining of the string
            let t = create_t();
            let beginLabel = create_l();
            let endLabel = create_l();
            resultCode += '//EMPIEZA IMPRIMIR CADENA\n';
            /*resultCode += t + ' = (int)' + resultTemp + ';\n';
            resultCode += beginLabel +':\n';
            resultCode += 'printf("%c", (int)heap[(int)'+t+']);\n'
            resultCode += t + ' = '+t+'+1;\n';
            resultCode += 'if(heap[(int)'+t+'] != -1) goto ' + beginLabel + ';\n';
            resultCode += 'goto ' + endLabel + ';\n'
            resultCode += endLabel + ':\n';
            resultCode += 'printf("\\n");\n'*/
            let tr = create_t();
            let t1 = create_t();
            let l0 = create_l();
            let l1 = create_l();
            let ls = create_l();
            let lsalida = create_l();
            resultCode += tr+' = '+resultTemp+';\n';
            resultCode += l0+':\n';
            resultCode += t1+' = heap[(int)'+tr+'];\n';
            resultCode += 'if('+t1+' == -1) goto '+lsalida+';\n';
            resultCode += 'goto '+l1+';\n';
            resultCode += lsalida+':\n';
            resultCode += 'goto '+ls+';\n';
            resultCode += l1+':\n';
            resultCode += 'printf("%c", (int)'+t1+');\n';
            resultCode += tr+' = '+tr+' + 1;\n';
            resultCode += 'goto '+l0+';\n';
            resultCode += ls+':\n';
            //resultCode += 'printf("\\n");\n'
            resultCode += '//TERMINA IMPRIMIR CADENA\n';
        }
        else if(typeof value == 'boolean')
        {
            // if 0 print false else print 1
            let trueLabel = create_l();
            let falseLabel = create_l();
            let exitLabel = create_l();
            resultCode += '//EMPIEZA IMPRIMIR BOOLEAN\n';
            resultCode += 'if('+resultTemp+' == 1) goto '+trueLabel+';\n';
            resultCode += 'goto '+falseLabel+';\n';
            resultCode += trueLabel+':\n';
            resultCode += 'printf("true");\n';
            resultCode += 'goto '+exitLabel+';\n';
            resultCode += falseLabel+':\n';
            resultCode += 'printf("false");\n';
            resultCode += 'goto '+exitLabel+';\n';
            resultCode += exitLabel+':\n';
            resultCode += '//TERMINA IMPRIMIR BOOLEAN\n';
        }
    });
    resultCode += 'printf("\\n");\n'
    resultCode += '//TERMINA IMPRIMIR\n';
    
    //resultCode += 'printf(\"'+ typeof value +'\");\n'
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
        let index = tsStack.length-1;
        for(let i = index; i >= 0; i--)
        {
            for(let j=0; j<tsStack[i].symbols.length; j++)
            {
                if(tsStack[i].symbols[j].id == stm.id)
                {
                    let sym = tsStack[i].symbols[j];
                    return sym.value;
                }
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
            let tsIndex = tsStack[0].symbols.length-1
            // SAVE
            for(let j=tsStack.length-1; j>=0; j--)
            {
                for(let i=0; i<=tsIndex; i++)
                {
                    let f = tsStack[j].symbols[i];
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
                                    let sym = new Symbol('Declaration', paramType, paramName, paramValue, null, 'let', 'Local', 0, -1, -1);
                                    //ts.symbols.push(sym);
                                }
                                else
                                {
                                    //param type does not match
                                    semanticErrors.push(new Error('No existe el parámetro', 0, 0));
                                    return null
                                }
                            }
                            tsStack.push(ts);
                            insideFunction = true;
                            returnStack.push(f.returnType);
                            var res = execute(f.value);
                            returnStack.pop();
                            tsStack.pop();
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
            let tsIndex = tsStack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = tsStack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(tsStack[i].symbols[j].id == stm.value1)
                    {
                        if(tsStack[i].symbols[j].length == '[]')
                        {
                            let value2 = executeExpression(stm.value2);
                            tsStack[i].symbols[j].value.push(value2);
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
            semanticErrors.push(new Error('No se encontro el simbolo '+stm.id, 0, 0));
            return null;
        }
        else if(stm.model == 'Pop')
        {
            let tsIndex = tsStack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = tsStack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(tsStack[i].symbols[j].id == stm.value)
                    {
                        if(tsStack[i].symbols[j].length == '[]')
                        {
                            let popped = tsStack[i].symbols[j].value.pop();
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
            semanticErrors.push(new Error('No se encontro el simbolo '+stm.id, 0, 0));
            return null;
        }
        else if(stm.model == 'Length')
        {
            let tsIndex = tsStack.length-1;
            for(let i=tsIndex; i>=0; i--)
            {
                let symIndex = tsStack[i].symbols.length-1;
                for(let j=0; j<=symIndex; j++)
                {
                    if(tsStack[i].symbols[j].id == stm.value)
                    {
                        if(tsStack[i].symbols[j].length == '[]')
                        {
                            let l = tsStack[i].symbols[j].value.length;
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
            semanticErrors.push(new Error('No se encontro el simbolo '+stm.id, 0, 0));
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
                let index = tsStack.length-1;
                for(let i = index; i >= 0; i--)
                {
                    if(isSymbolInTable(tsStack[i], stm.id.id))
                    {
                        /*let sym = getSymbol(tsStack[i], stm.id.id, arrayIndex);
                        if(arrayIndex != null) return sym.value[arrayIndex];
                        else return sym.value;*/
                    }
                    else continue;
                }
                //semanticErrors.push(new Error('No existe el simbolo', 0, 0));
                return null;
            }
            else
            {
                semanticErrors.push(new Error('Valor de indice invalido: '+arrayIndex,0, 0));
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