%负载参数
Lambda = 1;
miu = 2;
Ts = 2;
Te = 0.1;
Ps = 0.05;
Pa = 100;
DC_Eff_ch = 0.9;
Ps_a = ((Ps*(Ts-Te)+Pa*Te*(1-Lambda*miu/60))/Ts+Lambda*miu/60*Pa)/1000; %平均功率
disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
%超电参数
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc = Pa/1000*miu*1.6/0.9*2/(0.75*Vsc^2)/C;
Msc = ceil(Msc*C/0.01)*0.01/C;
disp(['The SC capacity is:' num2str(Msc*C) 'F']);
%电池参数
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat/0.05*0.05;%锂电池容量
Q = ceil(Q/0.01)*0.01;
disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
%太阳能电池参数
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a;%太阳能电池面积
S_s = ceil(S_s/10)*10;
disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
%压电发电机参数
S_v = 2.4*2.4;%压电发电机面积
%系统参数
dt = 0.1; % Sample interval [s]
day = 1;
P4 = [0.6*Ps_a 1.2*Ps_a 0.99];%能量管理策略参数
P5 = [0.2 0.2];
P51 = 0.2:0.1:0.5;
P52 = 0.4:0.1:0.7;
%环境参数
load('F:\EnergySystem\Datas\En&event\En.mat');
load('F:\EnergySystem\Datas\En&event\event_1_2.mat');
%初始化
Qloss = zeros(day*24*60,1);
Soc = zeros(day*24*60,1);
Qloss_end = zeros(6,5);
% kc_l = [1 5 10 20 50 100];
% P43 = P43compute(2.3004,kc_l);
for i1 = 4
    P5(1) = P51(i1);
    figure,hold on;
    for i2 = 4
        P5(2) = P52(i2);
        sensor = Sensor(Ts,Te,Ps,Pa); % Ts,Te,Ps,Pe,Pa
        SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(串并联数量)（超电单体容量为0.245F）
        battery = LiBattery(Q); % Q电池容量
        s_harvester = SolarHarvester(S_s); % Area
        v_harvester = VibraHarvester(S_v); % Area
        energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,v_harvester,5,P4,P5);
        j = 0; %仿真分钟
        for d = 0:(day-1)
            jj = 0; %分钟
            ii = 0; %次数
            for hour = 0:23
                for min = 0:59
                    jj = jj+1;
                    j = j+1;
                    for k = 0:(60/dt-1)
                        ii = ii+1;
                        energysystem.update(event(ii),En(jj,:));% 更新系统状态
                    end
                    Qloss(j,1) = energysystem.battery.Qloss;
                    Soc(j,1) = energysystem.battery.Soc;
                end
            end
        end
        subplot(2,1,1),plot((1:j)/60/24,Qloss),hold on;
        subplot(2,1,2),plot((1:j)/60/24,Soc),hold on;
    end
%     subplot(2,1,1),legend('b=0.4','b=0.5','b=0.6','b=0.7');
%     subplot(2,1,2),legend('b=0.4','b=0.5','b=0.6','b=0.7');
%     Qloss_end(i,:) = Qloss(end,:);
%     xlabel('Time(h)'),ylabel('Baterry Capacity Loss');
%     legend('Without Supercapacitor','SC First','Vlotage Based','Improved Parallel','Rule Based','Location','SouthEast');
%     saveas(gcf, ['Figures/1107/' num2str(i)], 'png')
end

