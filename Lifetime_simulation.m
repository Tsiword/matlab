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
day = 8000;
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
Soc = zeros(day*24*60,5);
Qloss_end = zeros(5,5);
figure,hold on;
for m = 1:5
    sensor = Sensor(Ts,Te,Ps,Pa,Ph);
    SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(串并联数量)（超电单体容量为0.245F）
    battery = LiBattery(Q); % Q电池容量
    s_harvester = SolarHarvester(S_s); % Area
    energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,m,k);
    j = 0; % 仿真分钟
    for d = 0:(day-1)
        jj = 0; % 分钟
        ii = 0; % 次数
        for hour = 0:23
            for min = 0:59
                jj = jj+1;
                j = j+1;
                for ss = 0:(60/dt-1)
                    ii = ii+1;
                    energysystem.update(event(ii),En(jj));% 更新系统状态
                end
                Qloss(j,m) = energysystem.battery.Qloss-0.01;
                Soc(j,m) = energysystem.battery.Soc;
            end
        end
        if Qloss(j,m)>0.2
            break;
        end
    end
    plot((1:j)/60/24,Qloss(1:j,m));
end
xlabel('Time(day)'),ylabel('Baterry Capacity Loss');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','SouthEast');
