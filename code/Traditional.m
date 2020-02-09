Power_harvest1=xlsread('E:\TV-RF.xlsx');% power trace read 
% TV-RF Piezo Thermal WiFi-home WiFi-office
Power_harvest=Power_harvest1(:,1);

Solution=xlsread('E:\lenet.xlsx');%
% lenet fr pv hg

Power_search=Solution(:,3);
Solution_1=Solution(1,:);
[m_ph,n_ph]=size(Power_harvest);
Energy_efficiency=zeros(m_ph,1); %��Ч
Throughput_efficiency=zeros(m_ph,1); %������
Energy_utilization=zeros(m_ph,1); %����������
Out=zeros(m_ph,4);
cyc_time=0.1; % ��������
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
    
    Pload=Power_harvest(i,1)*1e-6; % ��ǰcycle��Pload ��λW
    
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
        
        %E_loadstore=1; %��ȡ�ܺ�
        %E_sum=E_loadstore+Pload*0.1; %ע�ⵥλ
        %Operand=(5e6/(Solution(trans_m,1)/4))*150*16*4; % ������
        
        %------------------- case 1 end --------------------%
        
        %--------------------- case 2 -----------------------%
    else if Pload >= Psl % ��ţ���ϣ�ģ��
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
                flag=1;
                counter=0;
                V=0.2;
                while counter<2 % case 3 ��ţ���ϣ�ģ��
                    % ---------------------�ж��Ƿŵ绹�ǳ��һ��--------------------- %
                    if flag==0
                        Solution_1abs=abs(V-Solution_1);
                        [size_m,size_n]=find(Solution_1abs==min(Solution_1abs));
                        Solution_2=Solution(:,size_n);
                        Trans_Efficiency=max(Solution_2);
                        [trans_m,trans_n]=find(Solution_2==Trans_Efficiency);
                        
                        time=Solution(trans_m,1)/4*20e-9; % s
                        Energy_collect=Energy_collect+Solution(trans_m,3)/(0.01*Solution(trans_m,size_n))*time;
                        Energy_present=Solution(trans_m,3)*time;
                        Operand_sum=Operand_sum+Solution(trans_m,4)*Solution(trans_m,5)*Solution(trans_m,6);
                        Energy_use=Energy_use+Energy_present;
                        
                        V_up=sqrt(Energy_present/(1e-9));
                        V_down=Solution(trans_m,2)/(Trans_Efficiency*0.01*1e-9); % ��V
                        
                        Cycle_cnt=Cycle_cnt+Solution(trans_m,1)/4;
                    else
                        %Estore
                        Energy_collect=Energy_collect+Pload*20e-9;
                        V_up=sqrt(Pload*20e-9/(1e-9));
                        V_down=0;
                        
                        Cycle_cnt=Cycle_cnt+1;
                    end
                    % ---------------------     end     --------------------- %
                    V=V+V_up-V_down;
                    if V>=0.4 %�ŵ��ж�
                        flag=0;
                        counter=counter+1;
                    else if V<0.2 %����ж�
                            flag=1;
                            counter=counter+1;
                        end
                    end
                end
                % --- ������ ---- %
                period_cnt=floor(5e6/Cycle_cnt);
                Operand_sum=Operand_sum*period_cnt;
                Energy_use=Energy_use*period_cnt;
                Energy_collect= Energy_collect*period_cnt;
            end
        end
        %------------------- case 2 end --------------------%
    end
    
    if Pload == 0
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

csvwrite('Tradi_lenet_TV-RF.csv',Out);
% xlswrite('result_lenet.xls',Power_harvest(:,1),sheet1,'A2');
% xlswrite('result_lenet.xls',Energy_efficiency,sheet1,'B2');
% xlswrite('result_lenet.xls',Throughput_efficiency,sheet1,'C2');
% xlswrite('result_lenet.xls',Energy_utilization,sheet1,'D2');