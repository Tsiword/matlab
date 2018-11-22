classdef Capacitor < handle
    % Capacitor 理想无漏电无内阻电容模型
    
    properties
        % Capcitor parameters
        C; % Capacitance[F]
        Vm; % Maxium Voltage[V] (Minmum voltage is half of it)
        
        % Real time parameters
        Voc = 0; % Real time voltage[V]
        state = 0; % 0 - out of charge; 1 - normal; 2 - full of charge
    end
    
    methods
        function obj = Capacitor(Vm,C)
            obj.C = C;
            obj.Vm = Vm;
        end
        
        function update(obj,Psys,dt)
            % Psys>0为电容对外放电，Psys<0为外界对电容充电(W)
            % dt为充放电仿真时间步长(s)
            if Psys>0 && obj.state==0
%                 disp('The SC is out of charge!');
            elseif Psys<0 && obj.state==2
%                 disp('The SC is full of charge!');
            else
                obj.Voc = sqrt(obj.Voc^2-2*Psys*dt/obj.C);
                % Judge the capacitor state
                if obj.Voc>=obj.Vm
                    obj.state = 2;
                elseif obj.Voc<=obj.Vm/3
                    obj.state = 0;
                else
                    obj.state = 1;
                end
            end
        end
    end
end

