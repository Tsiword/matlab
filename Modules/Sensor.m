classdef Sensor < handle
    %Sensor 传感器类
    
    properties
        Ts; % Period of the sensor[s]
        te; % Time interval of emission[s]
        Ps; % Power of sleeping mode [mW]
        Pe; % Power of emission mode [mW]
        %         Pa; % Power of active mode [mW]
        
        P; % Real power of sensor [W]
    end
    
    methods
        %         function obj = Sensor(Ts, te, Ps, Pe, Pa)
        function obj = Sensor(Ts, te, Ps, Pe)
            %Sensor 构造此类的实例
            %为Sensor对象赋予属性值
            obj.Ts = Ts;
            obj.te = te;
            obj.Ps = Ps;
            obj.Pe = Pe;
            %             obj.Pa = Pa;
        end
        
        function computepower(obj, event, Sys_t)
            %computepower 获取Sensor对象的功率要求
            sensor_t = rem(Sys_t,obj.Ts);
            if (sensor_t>=obj.Ts/2 && sensor_t<obj.Ts/2+obj.te) || event==1
                obj.P = obj.Pe;% Emission mode
            else
                obj.P = obj.Ps;% sleeping mode
            end
            %             obj.P = obj.P+obj.Pa*event;
            obj.P = obj.P/1000;
        end
        
    end
end

