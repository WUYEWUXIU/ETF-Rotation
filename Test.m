tic

load ETFList %ETF列表
load ETFClose %ETF日频复权收盘价
load ETFVol %ETF日频成交额
ETFNum=length(ETFList(:,1));
ETFCloseLLT=GetLLT(ETFClose);

cell_list = first_cal_Guai_Li(3);
mq_volumn = cell_list{1};
mq_amount = cell_list{2};
mq_turn = cell_list{3};
Guai_Li = cell_list{4};

w=windmatlab;
tstart='2012/12/31';
tend='2021/6/30';
[~,~,~,TimesMonthly,~,~]=w.wsd('000906.SH','close',tstart,tend,'Period=M');
[~,~,~,TimesDaily,~,~]=w.wsd('000906.SH','close',tstart,tend,'Period=D');
TMonthly=length(TimesMonthly);
TimesMonthly=datestr(TimesMonthly,'yyyymmdd');
TimesMonthly1=str2num(TimesMonthly);
TDaily=length(TimesDaily);
TimesDaily=datestr(TimesDaily,'yyyymmdd');
TimesDaily1=str2num(TimesDaily);
TcpD=zeros(TMonthly,1);
for i=1:1:TMonthly
    for j=1:1:TDaily
        if strcmp(TimesMonthly(i,1:1:end),TimesDaily(j,1:1:end))==1
            TcpD(i)=j;
            break;
        end
    end
end

toc

Ts=13;

ETFstart = TcpD(Ts:1:end);
ETFend = TcpD(Ts+1:1:end);
if length(ETFstart) > length(ETFend)
    ETFstart(end) = [];
end
ETFMonthProfit = (ETFClose(ETFend,:)-ETFClose(ETFstart,:))./ETFClose(ETFstart,:);
ETFMonthProfit = ETFMonthProfit';
ETFMonthProfit(isnan(ETFMonthProfit))=0 ;
ETFMonthProfit = mean(ETFMonthProfit);

Stat=[]; %不同参数下的表现统计
NavAll=[]; %不同参数下的净值
PortNumAll=[]; %不同参数下的组合中ETF数量
SelectedFundAll=[]; %不同参数下的组合ETF明细
SelectedIdAll = [];
LDXAll=[]; %流动性，不同参数下的组合近一月日均成交额中位数
MonthlyProfitAll = []; 

ZeShi = [];
HuShen300 = readtable('沪深300.xlsx');
HuShen300_series = table2array(HuShen300(:,2));
llt = GetLLT(HuShen300_series,80);
diff_llt = diff(llt);
% empty = [];
% for j=Ts:1:TMonthly
%     if diff_llt(j-1) > 0
%         empty(j-Ts+1) = 1;
%     else
%         empty(j-Ts+1) = 0;
%     end
% end
emptyETFclose = 0;
diff_ETF_llt = diff(ETFCloseLLT);
for j=Ts:1:TMonthly
    judge = diff_ETF_llt(j-1) > 0
    empty = [empty;]

for combine=[1]%如果combine=1，使用复合策略；combine=0，使用纯动量策略
    for LLT=[0] %是否使用LLT，实际没有用到 
        for Adj=[0,1] %是否约束同类ETF的上限，1为约束
            for HYZTTh=[1,2]  %相同行业主题ETF数量上限

                if Adj==0 && HYZTTh>1
                    break;
                end 

                for TB=[1,3,6,12,-1,-3] %动量计算方法，参考word  


                    MonthlyProfit = [];
                    Pctchg=[];
                    PortNum=[];
                    LDX=[];
                    SelectedFund=cell(1,TMonthly);
                    SelectedIdSub=cell(1,TMonthly);
                    for j=Ts:1:TMonthly
                        ETFTemp=[];
                        for i=1:1:ETFNum
                            if ETFList{i,7}==1 %如为1，则仅考虑权益ETF；如果选择大于等于1，则考虑所有类型ETF
                                if TB<0
                                    if LLT==1
                                        CloseTemp=ETFCloseLLT(TcpD(j-12):1:TcpD(j),i);
                                        CloseTemp1=ETFCloseLLT(TcpD(j+TB):1:TcpD(j),i);
                                    else
                                        CloseTemp=ETFClose(TcpD(j-12):1:TcpD(j),i);
                                        CloseTemp1=ETFClose(TcpD(j+TB):1:TcpD(j),i);
                                    end
                                    if sum(isnan(CloseTemp))==0
                                        ETFTemp=[ETFTemp;[i,CloseTemp1(end)/CloseTemp1(1)-CloseTemp(end)/CloseTemp(1)]];
                                    end
                                else
                                    if LLT==1
                                        CloseTemp=ETFCloseLLT(TcpD(j-TB):1:TcpD(j),i);
                                    else
                                        CloseTemp=ETFClose(TcpD(j-TB):1:TcpD(j),i);
                                    end
                                    if sum(isnan(CloseTemp))==0
                                        ETFTemp=[ETFTemp;[i,CloseTemp(end)/CloseTemp(1)-1]];
                                    end
                                end
                            end
                        end
                        SortETFTemp=sortrows(ETFTemp,-2);
                        
%                         disp("SortETFTemp")
%                         disp(SortETFTemp)
                        
                        if Adj==1
                            SelectedId=[SortETFTemp(1,1)];
                            SelectedIdInfo=[ETFList(SortETFTemp(1,1),:)];
%                             disp("SelectedIdInfo")
%                             disp(SelectedIdInfo)
                            for ii=2:1:10

                                Flag=1;
                                TI=ETFList(SortETFTemp(ii,1),6);
                                if isempty(find(strcmp(TI,SelectedIdInfo(:,6))==1))==0
                                    Flag=0;
                                end

                                if ETFList{SortETFTemp(ii,1),3}==2
                                    HYZT=ETFList(SortETFTemp(ii,1),4);
                                    if Flag==1
                                        if length(find(strcmp(HYZT,SelectedIdInfo(:,4))==1))>=HYZTTh
                                            Flag=0;
                                        end
                                    end
                                end

                                if ETFList{SortETFTemp(ii,1),3}==3
                                    SB=ETFList(SortETFTemp(ii,1),5);
                                    if Flag==1
                                        if length(find(strcmp(SB,SelectedIdInfo(:,6))==1))>=1
                                            Flag=0;
                                        end
                                    end
                                end

                                if Flag==1
                                    SelectedId=[SelectedId;SortETFTemp(ii,1)];
                                    SelectedIdInfo=[SelectedIdInfo;ETFList(SortETFTemp(ii,1),:)];
                                end

                            end
                        else
                            SelectedId=SortETFTemp(1:1:10,1);
                        end
                        
                        if combine == 1
                            date = j;
                            crowdlist = [];
                            for  i=1:length(SelectedId)
                                PercentList = zeros(1,6);
                                NumOfSignal = zeros(1,6);
                                choice = SelectedId(i);
                                %计算六个量
                                SixDataList = cell(1,6);
%                                 SixDataList{1} = mq_volumn(date-12:date,choice);
%                                 SixDataList{2} = mq_amount(date-12:date,choice);
%                                 SixDataList{3} = mq_turn(date-12:date,choice);
%                                 SixDataList{4} = Guai_Li.vol_dv(date-12:date,choice);
%                                 SixDataList{5} = Guai_Li.amt_dv(date-12:date,choice);
%                                 SixDataList{6} = Guai_Li.turn_dv(date-12:date,choice);
                                SixDataList{1} = mq_volumn(1:date,choice);
                                SixDataList{2} = mq_amount(1:date,choice);
                                SixDataList{3} = mq_turn(1:date,choice);
                                SixDataList{4} = Guai_Li.vol_dv(1:date,choice);
                                SixDataList{5} = Guai_Li.amt_dv(1:date,choice);
                                SixDataList{6} = Guai_Li.turn_dv(1:date,choice);
%                                 disp("place1")
                                for m=1:6
                                    DataTobeCal = SixDataList{m};
%                                     disp("place2")
                                    Sorted = Sort(DataTobeCal,1,date);
                                    for n=1:date
%                                         disp("place3")
                                        if Sorted(n)==DataTobeCal(date)
                                            PercentList(m) = n/date;
                                            if PercentList(m) > 0.6
                                                NumOfSignal(m) = 1;
%                                                 disp("place4")
                                            end
                                        end
                                    end
                                end
                                if sum(NumOfSignal)<=3
                                    crowdlist(length(crowdlist)+1) = i;
                                end
                            end
                            SelectedId = SelectedId(crowdlist);
                            
                            if isempty(SelectedId)==1
                                SelectedFund{1,j}=[];
                            else
                                SelectedFund{1,j}=ETFList(SelectedId,2);

                            end
                        else
                            SelectedFund{1,j}=ETFList(SelectedId,2);                           
                        end
                        
                        
                        PortNumTemp=length(SelectedId);
                        PortNum=[PortNum;PortNumTemp];
                        LDXTemp=median(mean(ETFVol(TcpD(j-1):1:TcpD(j),SelectedId),1));
                        LDX=[LDX;LDXTemp];


                        if j<TMonthly
                            PfNavTemp=0;
                            if isempty(SelectedId) 
                                PfNavTemp=PfNavTemp+ones(1,length(TcpD(j):1:TcpD(j+1)))';
                            else
                                for i=1:1:length(SelectedId)
                                    PfNavTemp=PfNavTemp+ETFClose(TcpD(j):1:TcpD(j+1),SelectedId(i))/ETFClose(TcpD(j),SelectedId(i))/(length(SelectedId));
                                end
                            end
                            if empty(j-Ts+1) == 0
                                PctchgTemp = 1/2*[PfNavTemp(2:1:end)./PfNavTemp(1:1:end-1)-1];
                            else
                                PctchgTemp = 1*[PfNavTemp(2:1:end)./PfNavTemp(1:1:end-1)-1];
                            end
                            Pctchg=[Pctchg;PctchgTemp];
                            MonthNav=cumprod([ones(1,1);PctchgTemp+1]);
                            MonthlyProfit(j-12) = (MonthNav(end)-MonthNav(1))/MonthNav(1) - ETFMonthProfit(j-12);
                            if length(SelectedId)==0
                                MonthlyProfit(j-12) = 0;
                            end
                        end  
                        SelectedIdSub{1,j} = SelectedId;
                    end
                    SelectedIdAll = [SelectedIdAll;SelectedIdSub];
                    Nav=cumprod([ones(1,1);Pctchg+1]);
                    NavAll=[NavAll,Nav];
                    PortNumAll=[PortNumAll,PortNum];
                    LDXAll=[LDXAll,LDX];
                    SelectedFundAll=[SelectedFundAll;SelectedFund];
                    Stat=[Stat;[LLT,Adj,HYZTTh,TB,Nav(end)-1,maxdrawdown(Nav),mean(PortNum),mean(LDX)]];
                    MonthlyProfitAll = [MonthlyProfitAll,MonthlyProfit'];
                end
            end
        end
    end
end

ChiCangMingDan = cell(3,103);
for i=[3,9,15]
    for j=1:103
        ChiCangMingDan{i,j} = ETFList(SelectedIdAll{i,j});
    end
end

%计算策略表现
StrategyPerformanceAll = [(1+mean(MonthlyProfitAll)).^12-1;std(MonthlyProfitAll)*sqrt(12)];
%计算分年度表现
JingZhi = cumprod([ones(1,18);MonthlyProfitAll+1]);
JingZhi = JingZhi(:,[3,9,15])
Start = JingZhi(1:12:end,:);
End = JingZhi(13:12:end,:);
s1 = size(Start);
l1 = s1(1);
s2 = size(End);
l2 = s2(1);
if l2 < l1
    End(l1,:) = JingZhi(end,:);
end
FenNianDu = (End - Start)./Start;

%计算历史持仓数量
Size = size(SelectedFundAll);
NumofIndustry = Size(1); %18
NumofMonth = Size(2); %103
chi_cang_shu_liang = [];
for i=1:NumofIndustry
    for j=1:NumofMonth
        chi_cang_shu_liang(i,j) = length(SelectedFundAll{i,j});
    end
end
chi_cang_shu_liang = chi_cang_shu_liang';
average_chi_cang = mean(chi_cang_shu_liang(13:end,:));


% xlswrite('复合策略.xlsx',JingZhi,'累计净值')
% xlswrite('复合策略.xlsx',StrategyPerformanceAll(:,[3,9,15]),'策略表现');
% xlswrite('复合策略.xlsx',FenNianDu,'分年度表现');
% xlswrite('复合策略.xlsx',average_chi_cang([3,9,15]),'持仓数量及平均持仓');
% xlswrite('持仓数量.xlsx',chi_cang_shu_liang(13:end,[3,9,15]))

% xlswrite('动量策略.xlsx',JingZhi,'累计净值')
% xlswrite('动量策略.xlsx',StrategyPerformanceAll(:,[3,9,15]),'策略表现');
% xlswrite('动量策略.xlsx',FenNianDu,'分年度表现');
% xlswrite('动量策略.xlsx',average_chi_cang([3,9,15]),'持仓数量及平均持仓');
% xlswrite('持仓数量.xlsx',chi_cang_shu_liang(13:end,[3,9,15]))
StrategyPerformanceAll
toc