function A=GuaiLiCal(series)

forward_1 = zeros(1,length(series));
forward_2 = zeros(1,length(series));
A = zeros(1,length(series));
for i=1:length(series)
    if i>1
        forward_1(i) = series(i-1);
    end
    if i>2
        forward_2(i) = series(i-2);
    end
end

mean = (forward_1+forward_2)/2;
mean = mean';
A = (series - mean)./mean;
A(isnan(A))=0;
A(1)=0;
A(2)=0;
end