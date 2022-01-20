tic
Guai_Li = struct();
mq_volumn = table2timetable(readtable('拥挤度数据.xlsx','Sheet','成交量'));
mq_amount = table2timetable(readtable('拥挤度数据.xlsx','Sheet','成交额'));
mq_turn = table2timetable(readtable('拥挤度数据.xlsx','Sheet','换手率'));
shift_1 = circshift(mq_volumn,1);
shift_2 = circshift(mq_volumn,2);
mean =(shift_1+shift_2)/2;
Guai_Li.('vol_dv') = (mq_volumn-mean)./mean

shift_1 = circshift(mq_amount,1);
shift_2 = circshift(mq_amount,2);
mean =(shift_1+shift_2)/2;
Guai_Li.('amt_dv') = (mq_amount-mean)./mean

shift_1 = circshift(mq_turn,1);
shift_2 = circshift(mq_turn,2);
mean =(shift_1+shift_2)/2;
Guai_Li.('turn_dv') = (mq_turn-mean)./mean

% CrowdData = struct('vol',mq_volumn,'amt',mq_amount,'turn',mq_turn);
% guai_li_index = {'vol_dv','amt_dv','turn_dv'};
% original_index = {'vol','amt','turn'};
% Guai_Li = struct();
% for k=1:3
%     1
%     original_indexer = original_index{k};
%     original_data = CrowdData.(original_indexer); %取数据
%     temp_table = table();
%     temp_table.Date = original_data.Date;
%     temp_table = table2timetable(temp_table);
% %     time_table = varfun(GuaiLiCal,original_data);
%     for i=1:length(original_data.Properties.VariableNames)
%         temp_table.(original_data.Properties.VariableNames{i}) = GuaiLiCal(original_data{:,i});
%     end
%     Guai_Li.(guai_li_index{k}) = temp_table;
% end
% Guai_Li;
toc