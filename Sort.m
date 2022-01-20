function A=Sort(A,low,high)

if low<high
    [A,key]=get(A,low,high);
    A=Sort(A,low,key-1);
    A=Sort(A,key+1,high);
end

end

function [A,index]=get(A,i,j)
key=A(i);
while i<j
    while i<j&&A(j)>=key
        j=j-1;
    end
    
    if i<j
        A(i)=A(j);
    end
    
    while i<j&&A(i)<=key
        i=i+1;
    end
    
    if i<j
        A(j)=A(i);
    end
end
A(i)=key;
index=i;
end
