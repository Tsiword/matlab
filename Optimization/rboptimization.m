function Qloss = rboptimization(k1,k2,k3,event,En,lambda,Ph,Cr)
% ���ز���
miu = 1;
Ts = 2;
Te = 0.2;
Ps = 0.05;
Pa = 10;
DC_Eff_ch = 0.9;
Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
% �������
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc = Cr*Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
% ��ز���
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat;% ﮵������
% ̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
suntime = 1/10;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% ̫���ܵ�����
% ϵͳ����
dt = 0.2; % Sample interval [s]
P5 = [k1*Ps_a k2*Vsc k3*Ps_a];% ����������Բ���
P6 = [-0.2 0.6];
k = [P5 P6];
% ��ʼ��
sensor = Sensor(Ts,Te,Ps,Pa,Ph);
SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
battery = LiBattery(Q); % Q�������
s_harvester = SolarHarvester(S_s); % Area
energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,5,k);
jj = 0; % ����
ii = 0; % ����
for hour = 0:23
    for min = 0:59
        jj = jj+1;
        for ss = 0:(60/dt-1)
            ii = ii+1;
            energysystem.update(event(ii),En(jj));% ����ϵͳ״̬
        end
    end
end
Qloss = energysystem.battery.Qloss-0.01;
end