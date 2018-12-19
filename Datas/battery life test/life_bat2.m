data = xlsread('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D\数据整理3.xlsx');
dQloss = data(:,4);
Qloss = data(:,1:3);
Ah = data(:,5);
C_Rate = Qloss(:,1);
Qloss1 = Qloss(C_Rate==1,:);
Qloss2 = Qloss(C_Rate==2,:);
Qloss3 = Qloss(C_Rate==3,:);
dQloss1 = dQloss(C_Rate==1);
dQloss2 = dQloss(C_Rate==2);
dQloss3 = dQloss(C_Rate==3);
para0 = [0.45,1.4];
para1 = lsqcurvefit(@compute,para0,Qloss1,dQloss1);
para2 = lsqcurvefit(@compute,para0,Qloss2,dQloss2);
para3 = lsqcurvefit(@compute,para0,Qloss3,dQloss3);
Qloss1_s = Qloss1;
Qloss2_s = Qloss2;
Qloss3_s = Qloss3;
for i=1:length(Qloss1)-1
    dQloss1_s = compute(para1,Qloss1(i,:));
    Qloss1_s(i+1,2) = Qloss1_s(i,2)+dQloss1_s;
end
for i=1:length(Qloss2)-1
    dQloss2_s = compute(para2,Qloss2(i,:));
    Qloss2_s(i+1,2) = Qloss2_s(i,2)+dQloss1_s;
end
for i=1:length(Qloss3)-1
    dQloss3_s = compute(para3,Qloss3(i,:));
    Qloss3_s(i+1,2) = Qloss3_s(i,2)+dQloss3_s;
end
Qloss_s = [Qloss2_s;Qloss1_s;Qloss3_s];
figure,plot(Ah,Qloss(:,2),'*'),hold on
plot(Ah,Qloss_s(:,2),'o')
legend('measured','modeled')

function dQloss = compute(para,Qloss)
z = para(1);
b = para(2);
dQloss = z*exp(b/z)*Qloss(:,2).^(1-1/z).*Qloss(:,3);
end
