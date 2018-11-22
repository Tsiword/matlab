Q = xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\广州\70度.xlsx');
Q = Q(:,2);
dQloss = (Q(2:end-1)-Q(3:end))/Q(1);
Qloss = 1-Q(2:end)/Q(1);
para0 = [0.824,0.0032,-1516,15162];
para = lsqcurvefit(@compute,para0,Qloss(1:end-1),dQloss);
Qloss_s = Qloss;
for i=1:length(Qloss)-1
    dQloss_s = compute(para,Qloss_s(i));
    Qloss_s(i+1) = Qloss_s(i)+dQloss_s;
end
figure,plot(Qloss),hold on
plot(Qloss_s)

function dQloss = compute(para,Qloss)
% charge and discharge parameter
I_c = 0.06;
I_d = 0.12;
Q0 = 61.72/1000;
C_c = I_c/Q0;
C_d = I_d/Q0;
% baterry parameter
R  = 8.314; % Gas constant (J/(mol K));
T  = 273.15+70; % Absolute temperature (K);
% Ea = 15162; % Activation energy (J);
z = para(1);
A0 = para(2);
B = para(3);
Ea = para(4);
dQloss = Q0*(1-Qloss)*z*A0.^(1/z)*exp(-(Ea+B*C_c)/(z*R*T)).*Qloss.^((z-1)/z);
Qloss = Qloss+dQloss;
dQloss = dQloss+Q0*(1-Qloss)*z*A0.^(1/z)*exp(-(Ea+B*C_d)/(z*R*T)).*Qloss.^((z-1)/z);
end
