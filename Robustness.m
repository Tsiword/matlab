% ���ز���
miu = 1;
Ts = 2;
Te = 0.2;
Ps = 0.05;
Pa = 10;
DC_Eff_ch = 0.9;
% �������
C = 0.1225;
Vsc = 5;
Nsc = 2;
% ��ز���
Vbat = 3.7;
% ̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
% ϵͳ����
dt = 0.2; % Sample interval [s]
P5 = [2 0.98 2];% ����������Բ���
P6 = [-0.2 0.6];
k = [P5 P6];
% ��������
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En.mat');
% ��ʼ��
Qloss_end = zeros(7,5);
i = 0;
for lambda = [1 2 5 10 20 50 100]
% for Ph = [10 20 50 100 120 150 200]    
    % �¼�����
    load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
    i = i+1;
    % ���ز���
%     lambda = 10;
    Ph = 200;
    Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
    disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
    % �������
    Msc = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
    Msc = ceil(Msc);
    disp(['The SC capacity is:' num2str(Msc*C) 'F']);
    % ��ز���
    Q = Ps_a*24/DC_Eff_ch/Vbat;% ﮵������
    disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
    % ̫���ܵ�ز���
    S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a;% ̫���ܵ�����
    disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
    for m = 1:5
        sensor = Sensor(Ts,Te,Ps,Pa,Ph);
        SC = SuperCapacitor_a(Nsc,Msc); % Nsc,Msc(����������)�����絥������Ϊ0.245F��
        battery = LiBattery(Q); % Q�������
        s_harvester = SolarHarvester(S_s); % Area
        energysystem = Energysystem(dt,sensor,SC,battery,s_harvester,Ps_a,m,k);
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
        Qloss_end(i,m) = energysystem.battery.Qloss-0.01;
    end
end
plot([1 2 5 10 20 50 100],Qloss_end');
xlabel('Event frequency {/lambda}'),ylabel('Baterry Capacity Loss');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','NorthEast');
