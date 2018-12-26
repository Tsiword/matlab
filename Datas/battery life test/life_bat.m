fileFolder=fullfile('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1');
dirOutput=dir(fullfile(fileFolder,'*.csv'));
fileNames={dirOutput.name}';
fileNums = length(fileNames);

tv = [];
Qd1 = [];
Qd2 = [];
Ah1 = [0];
Ah2 = [0];
I_c1 = 0.01;

for j=1:fileNums
    csvname = fileNames{j};
    c_rate = str2double(csvname(1));
    tv_j = xlsread(['E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\' csvname]);
    v = tv_j(:,2);
    [~,imax] = findpeaks(v,'MinPeakProminence',0.6);
    [~,imin] = findpeaks(-v,'MinPeakProminence',1);
    index = [1;imax;imin;length(v)];
    index = sort(index);
    N = floor(length(index)/2);
    if c_rate == 2
        Qd_i = I_c1*c_rate*(index(2*N)-index(2*N-1))/3600/10;
        Qd1 = [Qd1;Qd_i];
        Ah_i = 0;
        for i=1:N
            Ah_i = Ah_i+2*I_c1*c_rate*(index(2*i)-index(2*i-1))/3600/10;
        end
        Ah1 = [Ah1;Ah_i];
    else
        for i=1:N
            Qd_i = I_c1*c_rate*(index(2*i)-index(2*i-1))/3600/10;
            Qd2 = [Qd2;Qd_i];
            Ah_i = Qd_i*2;
            Ah2 = [Ah2;Ah_i];
        end
    end
end
Qloss1 = (Qd1(1)-Qd1)/Qd1(1);
Qloss2 = (Qd2(1)-Qd2)/Qd2(1);
Ah1 = cumsum(Ah1);
Ah2 = cumsum(Ah2);
x1 = log(Ah1(2:end-1));
y1 = log(Qloss1(2:end));
x2 = log(Ah2(2:end-1));
y2 = log(Qloss2(2:end));
p1 = polyfit(x1,y1,1);
p2 = polyfit(x2,y2,1);
figure,plot(x1,y1,'o',x1,polyval(p1,x1))
hold on,plot(x2,y2,'*',x2,polyval(p2,x2))
