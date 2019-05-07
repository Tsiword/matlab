% ���ز���
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
% �������
C = 0.1225;
Vsc = 5;
Nsc = 2;
Msc0 = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
Msc = 2;
Cr = Msc/Msc0;
disp(['The SC capacity is:' num2str(Cr) '*' num2str(Msc0*C) 'F']);
% ��ز���
Vbat = 3.7;
Q = Ps_a*24/DC_Eff_ch/Vbat;% ﮵������
% Q = ceil(Q/0.01)*0.01;
disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
% ̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
suntime = 1/10;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% ̫���ܵ�����
disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
% ϵͳ����
dt = 0.2; % Sample interval [s]
day = 2;
b = 0.8955;
P5 = [2*Ps_a k2_cr(b,Cr)*Vsc 2.5*Ps_a];% ����������Բ���
P6 = [-0.1 0.1];
k = [P5 P6];
% �¼�����
load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
% ��������
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En_shaded.mat');
% ��ʼ��
Qloss = zeros(day*24*60,5);
figure,hold on;
for m = 1:5
    sensor = Sensor(Ts,Te,Ps,Pa,Ph);
    SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
    battery = LiBattery(Q); % Q�������
    s_harvester = SolarHarvester(S_s); % Area
    energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,m,k);
    j = 0; % �������
    for d = 0:(day-1)
        jj = 0; % ����
        ii = 0; % ����
%         event = event_generate(dt,lambda,miu);
        for hour = 0:23
            for min = 0:59
                jj = jj+1;
                j = j+1;
                for ss = 0:(60/dt-1)
                    ii = ii+1;
                    energysystem.update(event(ii),En(jj));% ����ϵͳ״̬
                end
                Qloss(j,m) = energysystem.battery.Qloss-0.01;
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
