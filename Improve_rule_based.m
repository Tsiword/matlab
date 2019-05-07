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
Msc = 1;
disp(['The SC capacity is:' num2str(Msc*C) 'F']);
% ��ز���
Vbat = 3.7;
Q = 0.014;
% Q = Ps_a*24/DC_Eff_ch/Vbat;% ﮵������
disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
% ̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
suntime = 1/10;
S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% ̫���ܵ�����
disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
% ϵͳ����
dt = 0.2; % Sample interval [s]
day = 4000;
P5 = [2 0.98 2];% ����������Բ���
P6 = [0 0.2];
k = [P5 P6];
% ��������
load('E:\qnj\EnergySystem\matlab\Datas\En&event\event_10_1.mat');
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En_shaded.mat');
% ��ʼ��
Qloss = zeros(day*24*60,6);
Soc = zeros(day*24*60,6);
figure,hold on;
for m = 5:6
    sensor = Sensor(Ts,Te,Ps,Pa,Ph);
    SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
    battery = LiBattery(Q); % Q�������
    s_harvester = SolarHarvester(S_s); % Area
    energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,m,k);
    j = 0; % ��ļ���
    for d = 0:(day-1)
        jj = 0; % ����
        ii = 0; % ����
%         event = event_generate(dt,lambda,miu);% �¼�����
        for hour = 0:23
            for min = 0:59
                jj = jj+1;
                for ss = 0:(60/dt-1)
                    ii = ii+1;
                    energysystem.update(event(ii),En(jj));% ����ϵͳ״̬
                end
                j = j+1;
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
% legend('Without Supercapacitor','SC First','Vlotage Based','Improved Parallel','Rule Based','Improved Rule Based','Location','SouthEast');
legend('Rule Based','Improved Rule Based','Location','SouthEast');