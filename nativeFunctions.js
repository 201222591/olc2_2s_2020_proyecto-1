function consoleLogString(start, type)
{
    let f;
    if(type == 1)
    {
        f = `
        void printString(){
            int aux;
            int i=${start};
            do{
                aux = (int)heap[i];
                if(aux == -1) break;
                else printf("%c", (int)aux);
                i = i+1;
            }while(1);
            goto l1;
            l1:
            return;
        }
        `;
    }
    else if(type == 2)
    {

    }
    else if(type == 3)
    {

    }
    return f;
}

function consoleLogInteger(start)
{
    let f = `
    void printNumber(){
        int aux;
        int i=${start};
        printf("%d\n", (int)stack[i]);
        goto l1;
        l1:
        return;
    }
    `;
    return f;
}

function consoleLogFloat(start)
{
    let f = `
    void printNumber(){
        int aux;
        int i=${start};
        printf("%f\n", (float)stack[i]);
        goto l1;
        l1:
        return;
    }
    `;
    return f;
}

function consoleLogInteger(start)
{
    let f = `
    void printNumber(){
        int aux;
        int i=${start};
        printf("%f\n", (float)stack[i]);
        goto l1;
        l1:
        return;
    }
    `;
    return f;
}