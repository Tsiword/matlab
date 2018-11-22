for lambda = [0.25,0.5,1,2,4,8]
    for miu = [0.5 1 2 4 8]
        event = event_generate(lambda,miu);
        save(['E:\qnj\EnergySystem\matlab\Datas\En&event\event_' num2str(lambda) '_' num2str(miu) '.mat'],'event');
    end
end
