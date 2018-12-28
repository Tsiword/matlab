dt = 0.2;
for lambda = [0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 30, 40, 50]
    for miu = 1
        event = event_generate(dt,lambda,miu);
        save(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat'],'event');
    end
end
