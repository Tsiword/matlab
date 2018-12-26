% data = xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D\数据整理3.xlsx');
% dQloss = data(:,4);
% Qloss = data(:,1:3);
% Ah = data(:,5);
% C_Rate = Qloss(:,1);
% Qloss1 = Qloss(C_Rate==1,:);
% Qloss2 = Qloss(C_Rate==2,:);
% Qloss3 = Qloss(C_Rate==3,:);
% dQloss1 = dQloss(C_Rate==1);
% dQloss2 = dQloss(C_Rate==2);
% dQloss3 = dQloss(C_Rate==3);
% para0 = [0.4,-4 -4 -2];
% para = lsqcurvefit(@compute,para0,Qloss,dQloss);

% data = xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D\数据整理4.xlsx');
% dQloss_m = compute(para,data);
close all;

data = xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D\数据整理5.xlsx','Sheet2');
C_Rate = data(:,1);
Qloss = data(:,2:4);
figure,plot(Qloss(:,1),Qloss(:,2),':*',Qloss(:,1),Qloss(:,3),'-o','LineWidth',1)
xlabel('Ah throughput(Ah)'),ylabel('Baterry Capacity Loss');
legend('measured','modeled','Location','NorthWest');

Qloss1 = data(C_Rate==1,2:4);
Qloss2 = data(C_Rate==2,2:4);
Qloss3 = data(C_Rate==3,2:4);
figure,plot(Qloss1(:,1),Qloss1(:,2),':*',Qloss1(:,1),Qloss1(:,3),'-o','LineWidth',1)
xlabel('Ah throughput(Ah)'),ylabel('Baterry Capacity Loss');
legend('measured','modeled','Location','NorthWest');
figure,plot(Qloss2(:,1),Qloss2(:,2),':*',Qloss2(:,1),Qloss2(:,3),'-o','LineWidth',1)
xlabel('Ah throughput(Ah)'),ylabel('Baterry Capacity Loss');
legend('measured','modeled','Location','NorthWest');
figure,plot(Qloss3(:,1),Qloss3(:,2),':*',Qloss3(:,1),Qloss3(:,3),'-o','LineWidth',1)
xlabel('Ah throughput(Ah)'),ylabel('Baterry Capacity Loss');
legend('measured','modeled','Location','NorthWest');
% function dQloss = compute(para,Qloss)
% z = para(1);
% b = para(2:4)';
% dQloss = z*exp(b(Qloss(:,1))/z).*Qloss(:,2).^(1-1/z).*Qloss(:,3);
% end
