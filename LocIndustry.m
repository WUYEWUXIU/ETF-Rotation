function loc=LocIndustry(name)
logi = mq_amount.Properties.VariableNames==name;
for i=1:388
    if logi(i)==1
        loc=i;
    end
end
end

        