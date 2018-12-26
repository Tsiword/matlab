function Qloss = rboptimization(k1,k2,k3,event,En,Ps_a)
%负载参数
Ts = 2;
Te = 0.1;
Ps = 0.05;
Pa = 100;
sensor = Sensor(Ts,Te,Ps,Pa); % Ts,Te,Ps,Pe,Pa
%超电参数
C = 0.1225;
Nsc = 2;
Msc = 0.2/C;
SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(串并联数量)（超电单体容量为0.245F）
%电池参数
Q = 0.16;
battery = LiBattery(Q); % Q电池容量
%太阳能电池参数
S_s = 100;
s_harvester = SolarHarvester(S_s); % Area
%压电发电机参数
S_v = 2.4*2.4;%压电发电机面积
v_harvester = VibraHarvester(S_v); % Area
%系统参数
dt = 0.2; % Sample interval [s]
management = 4;
k = [k1 k2 k3];
energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,v_harvester,Ps_a,management,k);
%初始化
Qloss = 0;
j = 0; %仿真分钟
ii = 0; %仿真次数
for hour = 0:23
    for min = 0:59
        j = j+1;
        for kk = 0:(60/dt-1)
            ii = ii+1;
            energysystem.update(event(ii),En(j,:));% 更新系统状态
        end
        Qloss = energysystem.battery.Qloss;
    end
end
end