var text = '';
function translate(ast)
{
    if(ast != null)
    {
        ast.forEach(stm => {
            if(stm.model == 'Function')
            {
                translateFunction(stm);
            }
            else
            {
                translateBlock(stm);
            }
        });
    }
}

function translateFunction(stm)
{
    console.log('Translating function');
}

function  translateBlock(stms)
{
    if(stms != null)
    {
        stms.forEach(stm => {
            if(stm.model == 'Declaration')
            {

            }
            else if(stm.model == 'If')
            {

            }
            else if(stm.model == 'IfElse')
            {

            }
            else if(stm.model == 'While')
            {

            }
            else if(stm.model == 'DoWhile')
            {

            }
            else if(stm.model == 'For')
            {

            }
            else if(stm.model == 'ForOf')
            {

            }
            else if(stm.model == 'ForIn')
            {

            }
            else if(stm.model == 'Switch')
            {

            }
            else if(stm.model == 'GraficarTS')
            {

            }
            else if(stm.model == 'ConsoleLog')
            {

            }
        });
    }
}

function translateDeclaration(stm)
{

}

function translateIf(stm)
{
}

function translateIfelse(stm)
{
}

function translateWhile(stm)
{
}

function translateDowhile(stm)
{
}

function translateFor(stm)
{
}

function translateIn(stm)
{
}

function translateOf(stm)
{
}

function translateSwitch(stm)
{
}

function translateGraficarts(stm)
{
}

function translateConsolelog(stm)
{
}