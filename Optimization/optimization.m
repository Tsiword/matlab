lambda = 10;
dt = 0.2;
miu = 1;
Ph = 200;
Cr = 2.584;
% 事件参数
event = event_generate(dt,lambda,miu);
load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat']);
% 环境参数
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En_shaded.mat');
k1 = 2;
k2 = k2_cr(b,Cr);
k3 = 2;
i = 0;
k = zeros(11,1);
Qloss = zeros(11,1);
% for Cr = [0.5 1 2 5 10 20 50 100 200 500 1000]
    i = i+1;
    options = optimset('Display','iter');
    k = fminbnd(@(k2)rboptimization(k1,k2,k3,event,En,lambda,Ph,Cr),0.5,1.0,options);
%     [k(i), Qloss(i)]= fminbnd(@(k2)rboptimization(k1,k2,k3,event,En,lambda,Ph,Cr),0.5,1.0,options);
% end