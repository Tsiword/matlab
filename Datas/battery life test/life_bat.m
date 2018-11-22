Q0 = 0.063765;
I_c = 0.06;
I_d = 0.12;
k = 2;
Q_c = zeros(10*k,1);
Q_d = zeros(10*k,1);
Q_ck = zeros(10,k);
Q_dk = zeros(10,k);
Qloss_ck = zeros(10,k);
Qloss_dk = zeros(10,k);
dQloss = zeros(1,k);
for j=1:k
    num_j = xlsread(['E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\寿命测试' num2str(j) '.csv']);
    if j==1
        num = num_j;
    else
        num_j(:,1) = num_j(:,1)+num(end,1);
        num = [num;num_j];
    end
end
t = num(:,1);
v = num(:,2);
plot(t,v)
[vmax,imax] = findpeaks(v,'MinPeakProminence',0.6);
[vmin,imin] = findpeaks(-v,'MinPeakProminence',1);
index = [1;imax;imin;length(v)];
index = sort(index);
n = floor(length(index)/2);
for i=1:n
    Q_d(i) = I_d*(index(2*i)-index(2*i-1))/3600;
    Q_c(i) = I_c*(index(2*i+1)-index(2*i))/3600;
end
for j=1:k
    Q_ck(:,j) = Q_c((-9:0)+10*j);
    Qloss_ck(:,j) = (Q_c(1)-Q_ck(:,j))/Q_c(1);
    Q_dk(:,j) = Q_d((-9:0)+10*j);
    Qloss_dk(:,j) = (Q_d(1)-Q_dk(:,j))/Q_d(1);
    Qdata = [Q_ck; Qloss_ck; Q_dk; Qloss_dk];
    if  j~=1
        dQloss(j) = (Q_d((j-1)*10)-Q_d(j*10))/Q_d(1);
    else
        dQloss(j) = (Q_d(1)-Q_d(10))/Q_d(1);
    end
end

para0 = [0.824,0.0032,-1516];
para = lsqcurvefit(@compute,para0,Qdata,dQloss);

function dQloss = compute(para,Qdata)
I_c = 0.06;
I_d = 0.12;
% input parameter
Q_c = Qdata(1:10,:);
Qloss_c = Qdata(11:20,:);
Q_d = Qdata(21:30,:);
Qloss_d = Qdata(31:40,:);
% baterry parameter
Q0_c = Q_c(1,1);
Q0_d = Q_d(1,1);
R  = 8.314; % Gas constant (J/(mol K));
T  = 273.15+40; % Absolute temperature (K);
Ea = 15162; % Activation energy (J);
dQloss = 0;
z = para(1);
A0 = para(2);
B = para(3);
for i=1:10
    dQloss = dQloss+Q_d(i,:)*z*A0.^(1/z)*exp(-(Ea+B*I_d/Q0_d)/(z*R*T)).*Qloss_d(i,:)^((z-1)/z);
    dQloss = dQloss+Q_c(i,:)*z*A0.^(1/z)*exp(-(Ea+B*I_c/Q0_c)/(z*R*T)).*Qloss_c(i,:)^((z-1)/z);
end
end
