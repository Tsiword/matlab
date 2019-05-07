function Qloss = rboptimization(k1,k2,k3,event,En,lambda,Ph,Cr)
% 负载参数
miu = 1;
Ts = 2;
Te = 0.2;
Ps = 0.05;
Pa = 10;
DC_Eff_ch = 0.9;
Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
% 超电参数
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc = Cr*Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
% 电池参数
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat;% 锂电池容量
% 太阳能电池参数
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
suntime = 1/10;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% 太阳能电池面积
% 系统参数
dt = 0.2; % Sample interval [s]
P5 = [k1*Ps_a k2*Vsc k3*Ps_a];% 能量管理策略参数
P6 = [-0.2 0.6];
k = [P5 P6];
% 初始化
sensor = Sensor(Ts,Te,Ps,Pa,Ph);
SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(串并联数量)（超电单体容量为0.245F）
battery = LiBattery(Q); % Q电池容量
s_harvester = SolarHarvester(S_s); % Area
energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,5,k);
jj = 0; % 分钟
ii = 0; % 次数
for hour = 0:23
    for min = 0:59
        jj = jj+1;
        for ss = 0:(60/dt-1)
            ii = ii+1;
            energysystem.update(event(ii),En(jj));% 更新系统状态
        end
    end
end
Qloss = energysystem.battery.Qloss-0.01;
end