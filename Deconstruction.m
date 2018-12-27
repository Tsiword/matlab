% 负载参数
lambda = 10;
miu = 1;
Ts = 2;
Te = 0.2;
Ps = 0.05;
Pa = 10;
Ph = 200;
DC_Eff_ch = 0.9;
Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
% 超电参数
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
Msc = ceil(Msc);
disp(['The SC capacity is:' num2str(Msc*C) 'F']);
% 电池参数
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat;% 锂电池容量
% Q = ceil(Q/0.01)*0.01;
disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
% 太阳能电池参数
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a;% 太阳能电池面积
% S_s = ceil(S_s/10)*10;
disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
% 系统参数
dt = 0.2; % Sample interval [s]
day = 1;
P5 = [2 0.98 2];% 能量管理策略参数
P6 = [-0.2 0.6];
k = [P5 P6];
% 事件参数
% event = event_generate(dt,lambda,miu);
load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
% 环境参数
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En.mat');
% 初始化
Qloss = zeros(day*24*60,5);
Sys_P = zeros(day*24*3600/dt,5,5);
SC_V = zeros(day*24*3600/dt,5);
Bat_Soc = zeros(day*24*3600/dt,5);
Bat_I = zeros(day*24*3600/dt,5);
for m = 1:5
    sensor = Sensor(Ts,Te,Ps,Pa,Ph);
    SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(串并联数量)（超电单体容量为0.245F）
    battery = LiBattery(Q); % Q电池容量
    s_harvester = SolarHarvester(S_s); % Area
    energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,m,k);
    jj = 0; % 分钟
    ii = 0; % 次数
    for hour = 0:23
        for min = 0:59
            jj = jj+1;
            for ss = 0:(60/dt-1)
                ii = ii+1;
                Sys_P(ii,:,m) = energysystem.update(event(ii),En(jj));% 更新系统状态
                SC_V(ii,m) = energysystem.supercapacitor.Voc;
                Bat_Soc(ii,m) = energysystem.battery.Soc;
                Bat_I(ii,m) = energysystem.battery.I;
            end
            Qloss(jj,m) = energysystem.battery.Qloss-0.01;
        end
    end
    figure(1),hold on,plot((1:ii)*dt/3600/24,SC_V(1:ii,m));
    figure(2),hold on,plot((1:ii)*dt/3600/24,Bat_Soc(1:ii,m));
    figure(3),hold on,plot((1:ii)*dt/3600/24,Bat_I(1:ii,m));
end
save('E:\qnj\EnergySystem\matlab\Datas\System\SC_V.mat','SC_V');
save('E:\qnj\EnergySystem\matlab\Datas\System\Bat_Soc.mat','Bat_Soc');
save('E:\qnj\EnergySystem\matlab\Datas\System\Bat_I.mat','Bat_I');
figure(1),xlabel('Time(h)'),ylabel('Supercapacitor voltage(V)');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','SouthEast');
figure(2),xlabel('Time(h)'),ylabel('Baterry SOC');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','SouthEast');
figure(3),xlabel('Time(h)'),ylabel('Baterry current(A)');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','SouthEast');
