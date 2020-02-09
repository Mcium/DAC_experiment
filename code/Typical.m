Power_harvest1=xlsread('E:\Piezo.xlsx');% power trace read 
% TV-RF Piezo Thermal WiFi-home WiFi-office
Power_harvest=Power_harvest1(:,1);

Solution=xlsread('E:\pv.xlsx');%
% lenet fr pv hg

Power_search=Solution(:,3);
Solution_1=Solution(1,:);
[m_ph,n_ph]=size(Power_harvest);
Energy_efficiency=zeros(m_ph,1); %能效
Throughput_efficiency=zeros(m_ph,1); %吞吐率
Energy_utilization=zeros(m_ph,1); %能量利用率
Out=zeros(m_ph,4);
cyc_time=0.1; % 采样周期
% 1e8/20=5e8

%----- test data -----%
% Psl=7.58e-5/0.78; %min
% Pll=0.002220577/0.65; %max
Psl=0.00012234; %min
Pll=0.002248542; %max
Energy=0;

E_use_sum=0;
E_collect_sum=0;


%Pll=2.96e-20/(1e-9*0.1)
%-------------------test section---------------------%
%m_ph=10;

for i=1:m_ph
    
    Pload=Power_harvest(i,1)*1e-6; % 当前cycle的Pload 单位W
    
    test_cnt=1;
    Cycle_cnt=0;
    Operand_sum=0;
    Energy_use=0;
    Energy_collect=0;
    %--------------------- case 1 -----------------------%
    if Pload >= Pll % case 1
        
        Operand_sum=150*16*4*5e6/4;
        Energy_use=Pll*cyc_time;
        Energy_collect=Pload*cyc_time;
        
        %E_loadstore=1; %存取能耗
        %E_sum=E_loadstore+Pload*0.1; %注意单位
        %Operand=(5e6/(Solution(trans_m,1)/4))*150*16*4; % 操作数
        
        %------------------- case 1 end --------------------%
        
        %--------------------- case 2 -----------------------%
    else if Pload >= Psl % 充放（间断）模型
            % ----test----%
            %Operand_sum=25*6*11*5e6;
            %Energy_use=7.8e-4*0.1;
            %Energy_collect=Pload*0.1;
            
            P=find(Power_search<=Pload);
            Pmax=max(Power_search(P));
            [m_case2,n_case2]=find(Power_search==Pmax);
            m_case3=m_case2(1,1);
            
            Comp_cnt=5e6/(Solution(m_case3,1)/4);
            Operand_sum=Solution(m_case3,4)*Solution(m_case3,5)*Solution(m_case3,6)*Comp_cnt;
            Energy_use=Solution(m_case3,3)*cyc_time;
            Energy_collect=Pload*0.1;
           
            %------------------- case 2 end --------------------%
            
            %--------------------- case 3 -----------------------%
        else if Pload > 0 %
                % --- 批处理 ---- %
                Energy_efficiency(i,1)= 0;
                Throughput_efficiency(i,1)=0;
                Energy_utilization(i,1)=0;
            end
        end
        %------------------- case 2 end --------------------%
    end
    
    if Pload < Psl
        Energy_efficiency(i,1)= 0;
        Throughput_efficiency(i,1)=0;
        Energy_utilization(i,1)=0;
    else
        Energy_efficiency(i,1)= Operand_sum/Energy_use;
        Throughput_efficiency(i,1)=Operand_sum/cyc_time;
        Energy_utilization(i,1)=Energy_use/Energy_collect;
        
        E_use_sum=E_use_sum+Energy_use;
        E_collect_sum=E_collect_sum+Energy_collect;
    end
    
end

Esum_uti=E_use_sum/E_collect_sum;

Out(:,1)=Power_harvest(:,1);
Out(:,2)=Energy_efficiency;
Out(:,3)=Throughput_efficiency;
Out(:,4)=Energy_utilization;

csvwrite('Typ_pv_Piezo.csv',Out);
% xlswrite('result_lenet.xls',Power_harvest(:,1),sheet1,'A2');
% xlswrite('result_lenet.xls',Energy_efficiency,sheet1,'B2');
% xlswrite('result_lenet.xls',Throughput_efficiency,sheet1,'C2');
% xlswrite('result_lenet.xls',Energy_utilization,sheet1,'D2');