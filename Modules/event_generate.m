function event = event_generate(dt,lambda,miu)
%系统参数
% dt = 0.1; % Sample interval [s]
% System parameters
eventime = 0;
flag = 0;
event = zeros(24*3600/dt,1);
ii = 0; %仿真次数
for hour = 0:23
    for min = 0:59
        for second = 0:59
            if rand(1)<lambda/3600
                eventime = miu; % 随机生成事件以及事件时长
                flag = 1;
            end
            for i = 1:(1/dt)
                % 判断事件状态
                if eventime>0
                    eventime = eventime-dt;
                else
                    eventime = 0;
                    flag = 0;
                end
                ii = ii+1;
                event(ii) = flag;
            end
        end
    end
end
end
