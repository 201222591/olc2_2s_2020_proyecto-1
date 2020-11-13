var optimizationLog = [];

function optimize(code)
{
    optimizationLog = [];
    let optimized = true;
    let optimized1 = false;
    let optimized2 = false;
    let optimized3 = false;
    let optimized4 = false;
    let optimized5 = false;
    let optimized6 = false;
    let optimized7 = false;
    let optimized8 = false;
    let optimized9 = false;
    let optimized10 = false;
    let optimized11 = false;
    let optimized12 = false;
    let optimized13 = false;
    let optimized14 = false;
    let optimized15 = false;
    let optimized16 = false;
    let finalCode = code;
    
    while(optimized)
    {
        optimized1 = optimizeRule1(finalCode);
        optimized2 = optimizeRule2(optimized1.code);
        optimized3 = optimizeRule3(optimized2.code);
        optimized4 = optimizeRule4(optimized3.code);
        optimized5 = optimizeRule5(optimized4.code);
        optimized6 = optimizeRule6(optimized5.code);
        optimized7 = optimizeRule7(optimized6.code);
        optimized8 = optimizeRule8(optimized7.code);
        optimized9 = optimizeRule9(optimized8.code);
        optimized10 = optimizeRule10(optimized9.code);
        optimized11 = optimizeRule11(optimized10.code);
        optimized12 = optimizeRule12(optimized11.code);
        optimized13 = optimizeRule13(optimized12.code);
        optimized14 = optimizeRule14(optimized13.code);
        optimized15 = optimizeRule15(optimized14.code);
        optimized16 = optimizeRule16(optimized15.code);

        let aux1 = optimized1.optimized || optimized2.optimized || optimized3.optimized || optimized4.optimized || optimized5.optimized;
        let aux2 = optimized6.optimized || optimized7.optimized || optimized8.optimized || optimized9.optimized || optimized10.optimized;
        let aux3 = optimized11.optimized || optimized12.optimized || optimized13.optimized || optimized14.optimized || optimized15.optimized || optimized16.optimized;
        optimized = aux1 || aux2 || aux3;

        finalCode = optimized16.code;
    }
    return finalCode;
}

function optimizeRule1(code)
{
    let lineNumber = 0;
    let start = -1;
    let end = 0;
    let gotoPattern = /^goto L[0-9]+;/;
    let labelPattern = /L[0-9]+/;
    let labelPattern2 = /^L[0-9]+/;
    let resultCode = [];
    let stopFor = false;
    let eofReached = false;
    let labelFound = false;
    for(let i=0; i<code.length; i++)
    {
        // get block of code goto Lx->Lx:
        let ins = code[i].match(gotoPattern);
        
        if(ins != null)
        {
            start = i;
            let gotoInstruction = ins[0];
            resultCode.push(gotoInstruction);
            let label = gotoInstruction.match(labelPattern)[0];
            lineNumber = i;
            while(lineNumber < code.length)
            {                
                let currentInstruction = code[lineNumber];
                let currentLabel = currentInstruction.match(labelPattern2)!=null ? currentInstruction.match(labelPattern2)[0] : null;
                // search for a label until -label- is found
                // main label is always found
                if(currentLabel != null)
                {
                    if(currentLabel == label)
                    {
                        end = lineNumber;
                        stopFor = true;
                        break;
                    }

                    else
                    {
                        labelFound = true;
                    }
                }
                lineNumber++;
                end = code.length;
                labelFound = false;
            }
        }
        else
        {
            resultCode.push(code[i]);
        }
        if(stopFor) break;
    }
    // check if is there any label in [start, end]
    let isLabelInCode = false;
    for(let i=start+1; i<end; i++)
    {
        if(isLabel(code[i]))
        {
            isLabelInCode = true;
            break;
        }
    }
    // add code or not depending on if is there a label in code

    let didOptimize = !labelFound && end != start+1;

    if(start == -1 && end == 0) // did not found anything
    {
        let result = {
            optimized: false,
            code: resultCode
        };
        return result;
    }

    if(isLabelInCode)
    {
        // add all the instructions
        for(let i=start+1; i<code.length; i++)
        {
            resultCode.push(code[i]);
        }
        let result = {
            optimized: false,
            code: resultCode
        };
        return result;
    }
    else
    {
        // add from end to code.length
        for(let i=end; i<code.length; i++)
        {
            resultCode.push(code[i]);
        }
        
        let result = {
            optimized: didOptimize,
            code: resultCode
        };
        if(didOptimize) optimizationLog.push('Se aplico la regla 1 en la linea '+start);
        return result;
    }
}

function optimizeRule2(code)
{
    let lineNumber = 0;
    let ifPattern = /^if\((\-)?(t[0-9]+|[0-9]+) \=\= (\-)?(t[0-9]+|[0-9]+)\)/;
    //let ifPattern = /^if/;
    let operand = /(\-)?(t[0-9]+|(\-)?[0-9]+)/g;
    let labelPattern = /L[0-9]+/;
    let resultCode = [];
    let didOptimize = false;

    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(ifPattern);
        lineNumber = i;
        if(ins != null)
        {
            let ifInstruction = code[i];
            let gotoInstruction = code[i+1];
            let op1 = ifInstruction.match(operand)[0];
            let op2 = ifInstruction.match(operand)[1];
            let l1 = ifInstruction.match(labelPattern)[0];
            let l2 = gotoInstruction.match(labelPattern)[0];

            let newIfInstruction = 'if('+op1+' != '+op2+') goto '+l2+';';
            resultCode.push(newIfInstruction);
            let ins1 = lineNumber+2;
            for(let j=ins1; j<code.length; j++)
            {
                resultCode.push(code[j]);
            }
            didOptimize = true;
            optimizationLog.push('Se aplico la regla 2 en la linea '+(lineNumber+1));
            break;
        }
        else
        {
            resultCode.push(code[i]);
            didOptimize = false;
        }
    }

    let result = {
        optimized: didOptimize,
        code: resultCode
    };
    return result;
}

function optimizeRule3(code)
{
    let ifPattern = /^if\((\-)?[0-9]+ (\=|\!)\= (\-)?[0-9]+\)/;
    let valuePattern = /(\-)?[0-9]+/g;
    let operatorPattern = /(\=|\!)\=/;
    resultCode = [];
    let lineNumber = 0;
    let stopFor = false;
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(ifPattern);
        if(ins != null)
        {
            let op1 = code[i].match(valuePattern)[0];
            let op2 = code[i].match(valuePattern)[1];
            let op  = code[i].match(operatorPattern)[0];
            resultCode.push(code[i])
            lineNumber = i+2;
            let isTrue = false;
            if(op == '==')
            {
                if(op1 == op2) isTrue = true;
            }
            else if(op == '!=')
            {
                if(op1 != op2) isTrue = true;
            }
            if(isTrue)
            {
                // remove next instruction
                stopFor = true;
                didOptimize = true;
                for(let j=lineNumber; j<code.length; j++)
                {
                    resultCode.push(code[j]);
                }
            }
            else
            {

            }
            if(stopFor) break;
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode
    };
    if(didOptimize) optimizationLog.push('Se aplico la regla 3 en la linea '+(lineNumber+1));
    return result;
}

function optimizeRule4(code)
{
    let ifPattern = /^if\((\-)?[0-9]+ (\=|\!)\= (\-)?[0-9]+\)/;
    let valuePattern = /(\-)?[0-9]+/g;
    let operatorPattern = /(\=|\!)\=/;
    resultCode = [];
    let lineNumber = 0;
    let stopFor = false;
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(ifPattern);
        if(ins != null)
        {
            let op1 = code[i].match(valuePattern)[0];
            let op2 = code[i].match(valuePattern)[1];
            let op  = code[i].match(operatorPattern)[0];
            //resultCode.push(code[i])
            lineNumber = i+1;
            let isFalse = true;
            if(op == '==')
            {
                if(op1 == op2) isFalse = false;
            }
            else if(op == '!=')
            {
                if(op1 != op2) isFalse = false;
            }
            if(isFalse)
            {
                // remove if
                stopFor = true;
                didOptimize = true;
                for(let j=lineNumber; j<code.length; j++)
                {
                    resultCode.push(code[j]);
                }
            }
            else
            {

            }
            if(stopFor) break;
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode
    };
    if(didOptimize) optimizationLog.push('Se aplico la regla 4 en la linea '+lineNumber);
    return result;
}

function optimizeRule5(code)
{
    let assignPattern = /t[0-9]+ \= t[0-9]+;/;
    let valuePattern = /t[0-9]+/g;
    let labelPattern = /^L[0-9]+/;
    let start = 0;
    let end = -1;
    resultCode = [];
    let op1;
    let op2;
    stopFor = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        if(ins != null)
        {
            resultCode.push(code[i]);
            // assignation found t0 = t1
            op1 = code[i].match(valuePattern)[0];
            op2 = code[i].match(valuePattern)[1];
            start = i+1; // search from next instruction
            for(let j=start; j<code.length; j++)
            {
                let ins2 = code[j].match(assignPattern);
                if(ins2 != null)
                {
                    // found A = B
                    // B = A
                    let op1_2 = code[j].match(valuePattern)[0];
                    let op2_2 = code[j].match(valuePattern)[1];
                    if(op1 == op2_2 && op2 == op1_2)
                    {
                        end = j-1;
                        stopFor = true;
                        break;
                    }
                }
            }
            if(stopFor) break;
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    
    if(end == -1)
    {
        // found nothing, all instruction have been added
        let r1 = {
            optimized: false,
            code: resultCode  
        };
        return r1;
    }
    else if(end < start)
    {
        // no instruction between t0 = t1; t1= t0
        // add instructions from start+1 -> code.length
        for(let i=start+1; i<code.length; i++)
        {
            resultCode.push(code[i]);
        }
        let r2 = {
            optimized: true,
            code: resultCode  
        };
        optimizationLog.push('Se aplico la regla 5 en la linea '+(end+1));
        return r2;
    }
    else
    {
        // search for an assignation op1 = X or a label
        let instructionFound = false;
        for(let k=start; k<=end; k++)
        {
            let isAssign = false;
            let isALabel = false;
            let op1_2 = code[k].match(valuePattern) != null ? code[k].match(valuePattern)[0] : null;
            let lbl_2 = code[k].match(labelPattern) != null ? code[k].match(labelPattern)[0] : null;
            if(op1_2 != null || lbl_2 != null)
            {
                instructionFound = true;
                break;
            }
            continue
        }
        // if no instruction found, delete
        // else add all instructions
        if(!instructionFound)
        {
            for(let i=start; i<code.length; i++)
            {
                if(i != end+1) resultCode.push(code[i]);
            }
            let r4 = {
                optimized: true,
                code: resultCode  
            };
            optimizationLog.push('Se aplico la regla 5 en la linea '+(end+1));
            return r4;
        }
        else
        {
            for(let i=start+1; i<code.length; i++)
            {
                resultCode.push(code[i]);
            }
            let r3 = {
                optimized: false,
                code: resultCode  
            };
            return r3;
        }
    }
}

function optimizeRule6(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \+ (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];

            if(v == op1 || v == op2) // t0 = t0 + 0, t0 = 0 + t0
            {
                if(op1 == '0')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 6 en la linea '+(i+1));
                }
                else if(op2 == '0')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 6 en la linea '+(i+1));
                }
                else
                {
                    resultCode.push(code[i]);
                    didOptimize = false;
                }
            }
            else
            {
                resultCode.push(code[i]);
            }
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule7(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \- (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];

            if(v == op1 || v == op2) // t0 = t0 + 0, t0 = 0 + t0
            {
                if(op1 == '0')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 7 en la linea '+(i+1));
                }
                else if(op2 == '0')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 7 en la linea '+(i+1));
                }
                else
                {
                    resultCode.push(code[i]);
                    didOptimize = false;
                }
            }
            else
            {
                resultCode.push(code[i]);
            }
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule8(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \* (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];

            if(v == op1 || v == op2) // t0 = t0 + 0, t0 = 0 + t0
            {
                if(op1 == '1')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 8 en la linea '+(i+1));
                }
                else if(op2 == '1')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 8 en la linea '+(i+1));
                }
                else
                {
                    resultCode.push(code[i]);
                    didOptimize = false;
                }
            }
            else
            {
                resultCode.push(code[i]);
            }
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule9(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \/ (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];

            if(v == op1 || v == op2) // t0 = t0 + 0, t0 = 0 + t0
            {
                if(op1 == '1')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 9 en la linea '+(i+1));
                }
                else if(op2 == '1')
                {
                    didOptimize =true;
                    optimizationLog.push('Se aplico la regla 9 en la linea '+(i+1));
                }
                else
                {
                    resultCode.push(code[i]);
                    didOptimize = false;
                }
            }
            else
            {
                resultCode.push(code[i]);
            }
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule10(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \+ (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op1 == '0')
            {
                let newInstruction = v+' = '+op2+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 10 en la linea '+(i+1));
            }
            else if(op2 == '0')
            {
                let newInstruction = v+' = '+op1+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 10 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule11(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \- (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op1 == '0')
            {
                let newInstruction = v+' = '+op2+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 11 en la linea '+(i+1));
            }
            else if(op2 == '0')
            {
                let newInstruction = v+' = '+op1+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 11 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule12(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \* (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op1 == '1')
            {
                let newInstruction = v+' = '+op2+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 12 en la linea '+(i+1));
            }
            else if(op2 == '1')
            {
                let newInstruction = v+' = '+op1+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 12 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule13(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \/ (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op2 == '1')
            {
                let newInstruction = v+' = '+op1+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 13 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule14(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \* (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op1 == '2')
            {
                let newInstruction = v+' = '+op2+' + '+op2+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 14 en la linea '+(i+1));
            }
            else if(op2 == '2')
            {
                let newInstruction = v+' = '+op1+' + '+op1+';';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 14 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule15(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \* (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op1 == '0')
            {
                let newInstruction = v+' = 0;';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 15 en la linea '+(i+1));
            }
            else if(op2 == '0')
            {
                let newInstruction = v+' = 0;';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 15 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function optimizeRule16(code)
{
    let assignPattern = /^t[0-9]+ \= (t[0-9]+|[0-9]+) \/ (t[0-9]+|[0-9]+)/;
    let valuePattern = /(t[0-9]+|[0-9]+)/g;
    let resultCode = [];
    let didOptimize = false;
    for(let i=0; i<code.length; i++)
    {
        let ins = code[i].match(assignPattern);
        // assign var = (var|num) op (var|num)
        if(ins != null)
        {
            let v = code[i].match(valuePattern)[0];
            let op1 = code[i].match(valuePattern)[1];
            let op2 = code[i].match(valuePattern)[2];
            if(op2 == '0')
            {
                let newInstruction = v+' = 0;';
                didOptimize =true;
                resultCode.push(newInstruction);
                optimizationLog.push('Se aplico la regla 16 en la linea '+(i+1));
            }
            else
            {
                resultCode.push(code[i]);
                didOptimize = false;
            }            
        }
        else
        {
            resultCode.push(code[i]);
        }
    }
    let result = {
        optimized: didOptimize,
        code: resultCode  
    };
    return result;
}

function codeToArray(codetxt)
{
    let codeArray = codetxt.split("\n");
    return codeArray;
}

function isLabel(instruction)
{
    let labelPattern = /^L[0-9]+:/;
    let result = instruction.match(labelPattern);
    if(result != null) return true;
    else return false;
}