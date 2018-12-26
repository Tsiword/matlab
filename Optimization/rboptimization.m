function Qloss = rboptimization(k1,k2,k3,event,En,Ps_a)
%���ز���
Ts = 2;
Te = 0.1;
Ps = 0.05;
Pa = 100;
sensor = Sensor(Ts,Te,Ps,Pa); % Ts,Te,Ps,Pe,Pa
%�������
C = 0.1225;
Nsc = 2;
Msc = 0.2/C;
SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
%��ز���
Q = 0.16;
battery = LiBattery(Q); % Q�������
%̫���ܵ�ز���
S_s = 100;
s_harvester = SolarHarvester(S_s); % Area
%ѹ�緢�������
S_v = 2.4*2.4;%ѹ�緢������
v_harvester = VibraHarvester(S_v); % Area
%ϵͳ����
dt = 0.2; % Sample interval [s]
management = 4;
k = [k1 k2 k3];
energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,v_harvester,Ps_a,management,k);
%��ʼ��
Qloss = 0;
j = 0; %�������
ii = 0; %�������
for hour = 0:23
    for min = 0:59
        j = j+1;
        for kk = 0:(60/dt-1)
            ii = ii+1;
            energysystem.update(event(ii),En(j,:));% ����ϵͳ״̬
        end
        Qloss = energysystem.battery.Qloss;
    end
end
end