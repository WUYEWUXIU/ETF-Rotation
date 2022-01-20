function A = first_cal_Guai_Li(n)
tic
A = cell(1,4);
Guai_Li = struct();
mq_volumn = table2array(table2timetable(readtable('拥挤度数据2.xlsx','Sheet','成交量')));
mq_volumn = mq_volumn(2:end,:);
mq_amount = table2array(table2timetable(readtable('拥挤度数据2.xlsx','Sheet','成交额')));
mq_amount = mq_amount(2:end,:);
mq_turn = table2array(table2timetable(readtable('拥挤度数据2.xlsx','Sheet','换手率')));
mq_turn = mq_turn(2:end,:);
A{1} = mq_volumn;
A{2} = mq_amount;
A{3} = mq_turn;

SUM = 0;
for i=1:n
    SUM = SUM + circshift(mq_volumn,i);
end
Mean = SUM/n;
Guai_Li.('vol_dv') = (mq_volumn-Mean)./Mean;
Guai_Li.('vol_dv')(1:n,:) = 0;
Guai_Li.('vol_dv')(isnan(Guai_Li.('vol_dv')))=0;

SUM = 0;
for i=1:n
    SUM = SUM + circshift(mq_amount,i);
end
Mean = SUM/n;
Guai_Li.('amt_dv') = (mq_amount-Mean)./Mean;
Guai_Li.('amt_dv')(1:n,:) = 0;
Guai_Li.('amt_dv')(isnan(Guai_Li.('amt_dv')))=0;

SUM = 0;
for i=1:n
    SUM = SUM + circshift(mq_turn,i);
end
Mean = SUM/n;
Guai_Li.('turn_dv') = (mq_turn-Mean)./Mean;
Guai_Li.('turn_dv')(1:n,:) = 0
Guai_Li.('turn_dv')(isnan(Guai_Li.('turn_dv')))=0;
A{4} = Guai_Li;
toc