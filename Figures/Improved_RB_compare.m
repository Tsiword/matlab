close all;
figure(1);% 生成新的图形窗口
load('F:\EnergySystem\Datas\Qloss4.mat');
Qloss4 = Qloss;
load('F:\EnergySystem\Datas\Qloss5n.mat');
Qloss5 = Qloss;
plot((1:length(Qloss4))/60/24,Qloss4,(1:length(Qloss5))/60/24,Qloss5);
xlabel('Time(Day)'),ylabel('Baterry Capacity Loss');
xlim([0,2400]),ylim([0,0.155]);
legend('Rule Based','Improved Rule Based','Location','NorthWest');                                                                                          
axes('Position',[0.5,0.2,0.4,0.3]); % 生成子图 
day = 1;
t1 = day+(1:24*60)/60/24;
Qloss4_1 = Qloss4(24*60*day+(1:24*60));
Qloss5_1 = Qloss5(24*60*day+(1:24*60));
plot(t1,Qloss4_1,t1,Qloss5_1); % 绘制局部曲线图
ylim([2e-4,4.2e-4]);