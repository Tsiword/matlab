classdef SuperCapacitor_a < handle
    % SuperCapacitor 超级电容模型
    
    properties
        % ----- Properties of SuperCapacitor -----
        Vm = 5/2; % Maxium Voltage[V] (Minmum voltage is half of it)
        
        % ----- RC model parameters-----
        Rr = 1.0857/2; % Ri(Ohm)
        C = 0.1225*2; % Capicitance(F)
        
        % ----- Parallel/Series numbers-----
        Nsc = 2;
        Msc = 1;
        
        % ----- Initial state parameters ----
        Voc = 0; % Open circut voltage of SC
        Soc = 0;
        state = 0; % 0 - out of charge; 1 - normal; 2 - full of charge
    end
    
    methods
        function obj = SuperCapacitor_a(Nsc,Msc)
            if  nargin==2
                obj.Nsc = Nsc;
                obj.Msc = Msc;
            end
            obj.Vm = obj.Vm*obj.Nsc;
            obj.Rr = obj.Rr*obj.Nsc/obj.Msc;
            obj.C = obj.C*obj.Msc/obj.Nsc;
        end
        
        function update(obj,Psys,dt)
             % Psys>0为电容对外放电，Psys<0为外界对电容充电(W)
            % dt为充放电仿真时间步长(s)
            if Psys>0 && obj.state==0
                disp('The SC is out of charge!');
            elseif Psys<0 && obj.state==2
                disp('The SC is full of charge!');
            else
                Vocn = sqrt(obj.Voc^2-2*Psys*dt/obj.C); % Estimated voltage after charge/discharge
                Q1 = obj.C*abs(Vocn-obj.Voc); % Estimated electric quantity change after charge/discharge
                Er = Q1^2*obj.Rr/dt;
                Ec = Er+Psys*dt;
                obj.Voc = sqrt(obj.Voc^2-2*Ec/obj.C);
                obj.Soc = obj.Voc/obj.Vm;
                % Judge the capacitor state
                if obj.Voc>=obj.Vm
                    obj.state = 2;
                elseif obj.Voc<=obj.Vm/2
                    obj.state = 0;
                else
                    obj.state = 1;
                end
            end
        end
    end
end

