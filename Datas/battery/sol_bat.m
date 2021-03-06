% clear all;
% close all;
load('E:\qnj\科研\03复合能量收集\建模与仿真\仿真程序\我的模型\EnergySystem\Datas\voc_bat.mat');
l_c = length(v_chargen);
s_c = (1:l_c)/l_c;
s_c = s_c';
l_d = length(v_dischargen);
s_d = (1:l_d)/l_d;
s_d = 1-s_d';
t1 = rand(1,8);
t2 = rand(1,8);
% t1 = [-108.026723096581,-886.888641135583,-6.59399296815221,905.092847787891,-238.922690790547,-273.751859046532];
% t2 = [-93.1287230457192,-877.532323153703,-9.37757142052118,887.038314110720,82.3063652400426,-357.009158235111];
% t1 = [-136.897211517320,-838.347023155036,-8.04676389240152,854.560042115681,-171.359093966936,-411.034429570154];
% t2 = [-87.1812815849213,-877.834667850712,-9.97215544242043,886.735969590458,109.592359640647,-351.461105774092];
t_c = lsqcurvefit(@sv,t1,s_c,v_chargen);
t_d = lsqcurvefit(@sv,t2,s_d,v_dischargen);
figure(1),plot(s_c,v_chargen,':',s_c,sv(t_c,s_c));
legend('实测曲线','仿真曲线','Location','SouthEast');
xlabel('SOC'),ylabel('开路电压(V)'),title('锂电池恒流充电曲线');
figure(2),plot(s_d,v_dischargen,':',s_d,sv(t_d,s_d));
set(gca,'XDir','reverse');  
legend('实测曲线','仿真曲线');
xlabel('SOC'),ylabel('开路电压(V)'),title('锂电池恒流放电曲线');