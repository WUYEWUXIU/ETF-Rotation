% guai_li_cal
tic
CrowdData;
Guai_Li;
percent_index = ["vol_percent","amt_percent","turn_percent","vol_dv_percent","amt_dv_percent","turn_dv_percent"];
percent_values = cell(1,6);
for k=1:3
    1
    original_indexer = original_index{k};
    original_data = CrowdData.(original_indexer); 
    temp_table = table();
    temp_table.Date = original_data.Date;
    temp_table = table2timetable(temp_table);
    for i=1:length(original_data.Properties.VariableNames)%按行业
        percent_list = Sort(original_data{1:12,i},1,12)';
        for j=13:length(original_data.Date)%按日期
            data = original_data{j,i};
            for n=1:length(percent_list)
                if percent_list(n)<data
                    percent_list = [percent_list(1:n) data percent_list(n+1:end)];
                    temp_table.(original_data.Properties.VariableNames{i})(j) = (n+1)/length(percent_list);
                end
            end
        end
    end
    percent_values{k} = temp_table;
end

for k=1:3
    1
    original_indexer = guai_li_index{k};
    original_data = Guai_Li.(original_indexer); 
    temp_table = table();
    temp_table.Date = original_data.Date;
    temp_table = table2timetable(temp_table);
    for i=1:length(original_data.Properties.VariableNames)%按行业
        percent_list = Sort(original_data{1:12,i},1,12)';
        for j=13:length(original_data.Date)%按日期
            data = original_data{j,i};
            for n=1:length(percent_list)
                if percent_list(n)<data
                    percent_list = [percent_list(1:n),data,percent_list(n+1:end)];
                    temp_table.(original_data.Properties.VariableNames{i})(j) = (n+1)/length(percent_list);
                end
            end
        end
    end
    percent_values{k+3} = temp_table; 
end

percent = struct();
for i=1:6
    percent.(percent_index(i)) = percent_values{i};
end
percent;
toc
    
                    
    