k = zeros(4,7);
Qloss = zeros(4,7);
i = 0;
j = 0;
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En.mat');
k1 = 0.69;
k2 = 0.988;
k3 = 1.566;
for lambda = [0.1, 0.2, 0.5, 1]
    i = i+1;
    j = 0;
    for miu = [0.1, 0.2, 0.5, 1, 2, 5, 10]
        j = j+1;
        Ts = 2;
        Te = 0.1;
        Ps = 0.05;
        Pa = 100;
        DC_Eff_ch = 0.9;
        Ps_a = ((Ps*(Ts-Te)+Pa*Te*(1-lambda*miu/60))/Ts+lambda*miu/60*Pa)/1000; %平均功率
        load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_' num2str(miu) '.mat']);
        options = optimset('Display','iter');
        [k(i,j), Qloss(i,j)]= fminbnd(@(k2)rboptimization(k1,k2,k3,event,En,Ps_a),0.5,1.0,options);
    end
end