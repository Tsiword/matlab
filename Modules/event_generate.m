function event = event_generate(dt,lambda,miu)
%ϵͳ����
% dt = 0.1; % Sample interval [s]
% System parameters
eventime = 0;
flag = 0;
event = zeros(24*3600/dt,1);
ii = 0; %�������
for hour = 0:23
    for min = 0:59
        for second = 0:59
            if rand(1)<lambda/3600
                eventime = miu; % ��������¼��Լ��¼�ʱ��
                flag = 1;
            end
            for i = 1:(1/dt)
                % �ж��¼�״̬
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
