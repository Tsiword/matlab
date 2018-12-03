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
dQloss1 = (Qd1(1)-Qd1)/Qd1(1);
dQloss2 = (Qd2(1)-Qd2)/Qd2(1);

