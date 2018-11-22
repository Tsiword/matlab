% close all;
% num = xlsread('E:\qnj\����\03���������ռ�\ʵ��\�������\�������.csv');
% t = num(:,1);
% v = num(:,2);
load('Datas/voc_SC.mat');
v_discharge = v((imax+1):end);
t = [t_charge;t_discharge+t_charge(end)];
v = [v_charge;v_discharge];
figure(1),plot(t,v,':'),hold on
% [Vmax,imax]=max(v);
% v_charge = v(1:imax);
% v_discharge = v((imax+1):end);
% t_charge = t(1:imax);
% t_discharge = t((imax+1):end)-t(imax);
% plot(t_charge,v_charge,t_discharge,v_discharge)
% save('E:\qnj\����\03���������ռ�\��ģ�����\�������\�ҵ�ģ��\EnergySystem\Datas\voc_SC.mat');

i1 = 0.020;
i2 = 0.015;
R = (v_charge(end)-v_discharge(1))/(i1+i2);
U1 = v_charge(end)-v_charge(1);
t1 = t_charge(end)-t_charge(1);
U2 = v_discharge(1)-v_discharge(end);
t2 = t_discharge(end)-t_discharge(1);
C = (i1*t1+i2*t2)/(U1+U2);

v_charge_s = i1*R+i1*t_charge/C;
v_discharge_s = v_charge_s(end)-(i1+i2)*R-i2*t_discharge/C;
v_s = [v_charge_s;v_discharge_s];
plot(t,v_s);
legend('ʵ������','��������');
xlabel('ʱ��(s)'),ylabel('��ѹ(V)'),title('�������ݺ�����ŵ�����');


