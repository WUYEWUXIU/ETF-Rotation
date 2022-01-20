function llt = GetLLT( close ,D)
%计算资产LLT均线

    num=length(close(1,:));
    Tlength=length(close(:,1));
    a=2/(D+1);
    llt=zeros(Tlength,num);
    for i=1:1:num
        for j=1:1:Tlength
            if j<=2
                llt(j,i)=close(j,i);
            else
                llt(j,i)=(a-a^2/4)*close(j,i)+(a^2/2)*close(j-1,i)-(a-3*a^2/4)*close(j-2,i)+2*(1-a)*llt(j-1,i)-(1-a)^2*llt(j-2,i);
                if ~isnan(llt(j,i))
                    disp(llt(j,i))
                end
            end     
        end
    end

end

