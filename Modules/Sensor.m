classdef Sensor < handle
    %Sensor ��������
    
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
            %Sensor ��������ʵ��
            %ΪSensor����������ֵ
            obj.Ts = Ts;
            obj.te = te;
            obj.Ps = Ps;
            obj.Pe = Pe;
            %             obj.Pa = Pa;
        end
        
        function computepower(obj, event, Sys_t)
            %computepower ��ȡSensor����Ĺ���Ҫ��
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

