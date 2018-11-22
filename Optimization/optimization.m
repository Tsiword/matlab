k = zeros(6,5,3);
Qloss = zeros(6,5,3);
i = 0;
j = 0;
load('E:\qnj\EnergySystem\matlab\Datas\En&event\En.mat');
k0 = [1 0.75 1];
A = [];
b = [];
Aeq = [];
beq = [];
lb = [0.6,0.5,0.8];
ub = [1.2,1,1.5];
for lambda=[0.25,0.5,1,2,4,8]
    i = i+1;
    for miu = [0.5 1 2 4 8]
        j = j+1;
        load(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_' num2str(miu) '.mat']);
        [k(i,j,:), Qloss(i,j)]= fmincon(@(k)rboptimization(lambda,k,event,En),k0,A,b,Aeq,beq,lb,ub);
    end
end