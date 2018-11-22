function Qloss = rboptimization(lambda,k,event,En)
%�¼�����
miu = 2;
%���ز���
Ts = 2;
Te = 0.1;
Ps = 0.05;
Pa = 100;
DC_Eff_ch = 0.9;
Ps_a = ((Ps*(Ts-Te)+Pa*Te*(1-lambda*miu/60))/Ts+lambda*miu/60*Pa)/1000; %ƽ������
% disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
%�������
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc = Pa/1000*miu*1.6/0.9*2/(0.75*Vsc^2)/C;
Msc = ceil(Msc*C/0.01)*0.01/C;
% disp(['The SC capacity is:' num2str(Msc*C) 'F']);
%��ز���
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat/0.05*0.05;%﮵������
Q = ceil(Q/0.01)*0.01;
% disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
%̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a;%̫���ܵ�����
S_s = ceil(S_s/10)*10;
% disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
%ѹ�緢�������
S_v = 2.4*2.4;%ѹ�緢������
%ϵͳ����
dt = 0.1; % Sample interval [s]
day = 1;
management = 4;
%��ʼ��
Qloss = 0;
sensor = Sensor(Ts,Te,Ps,Pa); % Ts,Te,Ps,Pe,Pa
SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
battery = LiBattery(Q); % Q�������
s_harvester = SolarHarvester(S_s); % Area
v_harvester = VibraHarvester(S_v); % Area
energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,v_harvester,Ps_a,management,k);
j = 0; %�������
for d = 0:(day-1)
    jj = 0; %����
    ii = 0; %����
    for hour = 0:23
        for min = 0:59
            jj = jj+1;
            j = j+1;
            for kk = 0:(60/dt-1)
                ii = ii+1;
                energysystem.update(event(ii),En(jj,:));% ����ϵͳ״̬
            end
            Qloss = energysystem.battery.Qloss;
        end
    end
end
end