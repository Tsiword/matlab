num=xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\容量测试3.csv');
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
% save('E:\qnj\科研\03复合能量收集\建模与仿真\仿真程序\我的模型\EnergySystem\Datas\voc_bat.mat');