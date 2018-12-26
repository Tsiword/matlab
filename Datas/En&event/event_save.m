dt = 0.2;
for lambda = [1, 2, 5, 10, 20, 50, 100]
    for miu = 1
        event = event_generate(dt,lambda,miu);
        save(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_1.mat'],'event');
    end
end
