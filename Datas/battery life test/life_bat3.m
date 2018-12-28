fileFolder=fullfile('E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D');
dirOutput=dir(fullfile(fileFolder,'*.csv'));
fileNames={dirOutput.name}';
fileNums = length(fileNames);
I_c1 = 0.01;
Qd1 = [];
Qd2 = [];
Qd3 = [];
Ah1 = [0];
Ah2 = [0];
Ah3 = [0];
for j=1:fileNums
    csvname = fileNames{j};
    c_rate = str2double(csvname(1));
    tv_j = xlsread(['E:\qnj\科研\03复合能量收集\实验\锂电池测试\寿命测试\11mAh\bat1\20D\' csvname]);
    t= tv_j(:,1);
    v = tv_j(:,2);
    plot(t,v)
    [~,imax] = findpeaks(v,'MinPeakProminence',0.1);
    [~,imin] = findpeaks(-v,'MinPeakProminence',0.2);
    index = [1;imax;imin;length(v)];
    index = sort(index);
    N = floor(length(index)/2);
    if c_rate == 1
        for i=1:N
            if v(index(1))>v(index(2))
                Qd_i = I_c1*c_rate*(index(2*i)-index(2*i-1))/3600*(t(2)-t(1));
            else
                Qd_i = I_c1*c_rate*(index(2*i+1)-index(2*i))/3600*(t(2)-t(1));
            end
            Qd1 = [Qd1;Qd_i];
            Ah_i = Qd_i*2;
            Ah1 = [Ah1;Ah_i];
        end
    elseif c_rate == 2
        for i=1:N
            if v(index(1))>v(index(2))
                Qd_i = I_c1*c_rate*(index(2*i)-index(2*i-1))/3600*(t(2)-t(1));
            else
                Qd_i = I_c1*c_rate*(index(2*i+1)-index(2*i))/3600*(t(2)-t(1));
            end
            Qd2 = [Qd2;Qd_i];
            Ah_i = Qd_i*2;
            Ah2 = [Ah2;Ah_i];
        end
    elseif c_rate == 3
        for i=1:N
            if v(index(1))>v(index(2))
                Qd_i = I_c1*c_rate*(index(2*i)-index(2*i-1))/3600*(t(2)-t(1));
            else
                Qd_i = I_c1*c_rate*(index(2*i+1)-index(2*i))/3600*(t(2)-t(1));
            end
            Qd3 = [Qd3;Qd_i];
            Ah_i = Qd_i*2;
            Ah3 = [Ah3;Ah_i];
        end
    end
end
% Qloss1 = (Qd1n(1)-Qd1n)/Qd1n(1);
% Qloss2 = (Qd2n(1)-Qd2n)/Qd2n(1);
% Qloss3 = (Qd3n(1)-Qd3n)/Qd3n(1);
% x1 = log(Ah1n(2:end));
% y1 = log(Qloss1(2:end));
% x2 = log(Ah2n(2:end));
% y2 = log(Qloss2(2:end));
% x3 = log(Ah3n(2:end));
% y3 = log(Qloss3(2:end));
% p1 = polyfit(x1,y1,1);
% p2 = polyfit(x2,y2,1);
% p3 = polyfit(x3,y3,1);
% figure,plot(x1,y1,'o',x1,polyval(p1,x1),'--')
% figure,plot(x2,y2,'*',x2,polyval(p2,x2),'--')
% figure,plot(x3,y3,'*',x3,polyval(p3,x3),'--')