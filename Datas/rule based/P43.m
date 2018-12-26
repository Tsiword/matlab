!load('F:\EnergySystem\Datas\kc_l.mat');
load('F:\EnergySystem\Datas\kv_l.mat');
b = lsqcurvefit(@P43compute,2,kc_l,kv_l);
figure(1),plot(kc_l,kv_l,':*',1:100,P43compute(b,1:100));
xlabel('Relative Supercapacitor Capacity M'),ylabel('{Paremeter k_2}');
legend('Optimization results','Fitting curve')