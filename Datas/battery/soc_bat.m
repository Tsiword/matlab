num=xlsread('E:\qnj\����\03���������ռ�\ʵ��\﮵�ز���\��������3.csv');
t = num(:,1);
v = num(:,2);
plot(t,v)
t = t(100000:end);
v = v(100000:end);
[Vmax,imax]=max(v);
[Vmin,imin]=min(v);
v_charge = v(imin:imax);
v_discharge = v(imax:end);
t_charge = t(imin:imax)-t(imin);
t_discharge = t(imax:end)-t(imax);
plot(t_charge,v_charge,t_discharge,v_discharge)
% save('E:\qnj\����\03���������ռ�\��ģ�����\�������\�ҵ�ģ��\EnergySystem\Datas\voc_bat.mat');