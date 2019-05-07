% 负载参数
miu = 1;
Ts = 2;
Te = 0.2;
Ps = 0.05;
Pa = 10;
DC_Eff_ch = 0.9;
% 超电参数
C = 0.1225;
Vsc = 5;
Nsc = 2;
% 电池参数
Vbat = 3.7;
% Q = 25/1000;
% 太阳能电池参数
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
% S_s = 20;
% 系统参数
dt = 0.2; % Sample interval [s]
% 环境参数
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En_shaded.mat');
% 事件参数
load('E:\qnj\EnergySystem\matlab\Datas\En&event\event_10_1.mat');
% 初始化
Qloss_end = zeros(13,5);
i = 0;
% for lambda = [0.1 0.2 0.5 1 2 5 10 20 50 100]
% for Ph = [10 20 50 100 120 150 200]
 for C_sc = [0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200]
    i = i+1;
    % 负载参数
    lambda = 10;
    load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
    Ph = 200;
    Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
    disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
    % 超电参数
    C0 = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2);
    Cr = C_sc/C0;
    Msc = C_sc/C;
%     Mscr = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
%     Msc = ceil(Mscr);
%     Cr = Msc/Mscr;
    disp(['The SC capacity is:' num2str(Msc*C) 'F']);
    % 电池参数
    Q = Ps_a*24/DC_Eff_ch/Vbat;% 锂电池容量
    disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
    % 太阳能电池参数
    suntime = 1/10;
    S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% 太阳能电池面积
    disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
    % 能量管理策略参数
    b = 0.8955;
    P5 = [2*Ps_a k2_cr(b,Cr)*Vsc 2.5*Ps_a];
    P6 = [-0.1 0.1];
    k = [P5 P6];
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
                    energysystem.update(event(ii),En(jj));% 更新系统状态
                end
            end
        end
        Qloss_end(i,m) = energysystem.battery.Qloss-0.01;
    end
end
plot(log10([0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200]),Qloss_end','o:');
% plot(log10([10 20 50 100 120 150 200]),Qloss_end','o:');
% plot(log10([0.1 0.2 0.5 1 2 5 10 20 50 100]),Qloss_end','o:');
%  xlabel('Event Frequency lg(Lambda)'),ylabel('Baterry Capacity Loss');
% xlabel('High Load Power lg(Ph)'),ylabel('Baterry Capacity Loss');
xlabel('Capacity of SC (lg(F))'),ylabel('Baterry Capacity Loss');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','NorthEast');
