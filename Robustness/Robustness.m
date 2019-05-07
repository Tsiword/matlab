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
% Q = 25/1000;
% ̫���ܵ�ز���
Psolar_a = 0.000269654227794441;
DC_Eff_pv = 0.9;
% S_s = 20;
% ϵͳ����
dt = 0.2; % Sample interval [s]
% ��������
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En_shaded.mat');
% �¼�����
load('E:\qnj\EnergySystem\matlab\Datas\En&event\event_10_1.mat');
% ��ʼ��
Qloss_end = zeros(13,5);
i = 0;
% for lambda = [0.1 0.2 0.5 1 2 5 10 20 50 100]
% for Ph = [10 20 50 100 120 150 200]
 for C_sc = [0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200]
    i = i+1;
    % ���ز���
    lambda = 10;
    load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
    Ph = 200;
    Ps_a = (((Ps*(Ts-Te)+Pa*Te))/Ts*(1-lambda*miu/3600)+Ph*lambda*miu/3600)/1000/DC_Eff_ch;
    disp(['The average power of sensor is:' num2str(Ps_a) 'W']);
    % �������
    C0 = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2);
    Cr = C_sc/C0;
    Msc = C_sc/C;
%     Mscr = Ph/1000*miu*2/0.9*2/(0.75*Vsc^2)/C;
%     Msc = ceil(Mscr);
%     Cr = Msc/Mscr;
    disp(['The SC capacity is:' num2str(Msc*C) 'F']);
    % ��ز���
    Q = Ps_a*24/DC_Eff_ch/Vbat;% ﮵������
    disp(['The battery capacity is:' num2str(Q*1000) 'mAh']);
    % ̫���ܵ�ز���
    suntime = 1/10;
    S_s = Ps_a/DC_Eff_ch/DC_Eff_pv/Psolar_a/suntime;% ̫���ܵ�����
    disp(['The area of solor panel is:' num2str(S_s) 'cm^2']);
    % ����������Բ���
    b = 0.8955;
    P5 = [2*Ps_a k2_cr(b,Cr)*Vsc 2.5*Ps_a];
    P6 = [-0.1 0.1];
    k = [P5 P6];
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
plot(log10([0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200]),Qloss_end','o:');
% plot(log10([10 20 50 100 120 150 200]),Qloss_end','o:');
% plot(log10([0.1 0.2 0.5 1 2 5 10 20 50 100]),Qloss_end','o:');
%  xlabel('Event Frequency lg(Lambda)'),ylabel('Baterry Capacity Loss');
% xlabel('High Load Power lg(Ph)'),ylabel('Baterry Capacity Loss');
xlabel('Capacity of SC (lg(F))'),ylabel('Baterry Capacity Loss');
legend('Without Supercapacitor','SC First','Voltage Controlled','Improved Parallel','Rule Based', 'Location','NorthEast');
