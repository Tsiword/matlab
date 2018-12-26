classdef Sensor < handle
    %Sensor 传感器类
    
    properties
        Ts; % Period of the sensor[s]
        te; % Time interval of emission[s]
        Ps; % Power of sleeping mode [mW]
        Pa; % Power of active mode [mW]
        Ph; % Power of high workload mode [mW]
        P; % Real power of sensor [W]
    end
    
    methods
        function obj = Sensor(Ts, te, Ps, Pa, Ph)
            %Sensor 构造此类的实例
            %为Sensor对象赋予属性值
            obj.Ts = Ts;
            obj.te = te;
            obj.Ps = Ps;
            obj.Pa = Pa;
            obj.Ph = Ph;
        end
        
        function computepower(obj, event, Sys_t)
            %computepower 获取Sensor对象的功率要求
            sensor_t = rem(Sys_t,obj.Ts);
            if event==0
                if (sensor_t>=obj.Ts/2 && sensor_t<obj.Ts/2+obj.te)
                    obj.P = obj.Pa;% active mode
                else
                    obj.P = obj.Ps;% sleeping mode
                end
            else
                obj.P = obj.Ph;
            end
            obj.P = obj.P/1000;
        end
        
    end
end

