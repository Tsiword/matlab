classdef LiBattery < handle
    %LiBattery ﮵��ģ��
    
    properties
        % Cycle-life parameters
        z  = 0.430348812891015; 
        b_para  = [1.0519,-5.6896]; 
        Ar = 0.0088;
        
        % Initial electrical parameters
        A0;	% Original capacity of battery [A*h]
        Rr = 0.46; % Inner resistance of battery [Ohm]
        t_c = [0.832784949290123,0.00950742937440156,0.986933683934508,1.91017763008209,0.366569502392137,1.00215219026646,1.57676233212954];
        t_d = [0.476542280050523,0.0531424828486832,0.968130028634588,2.09592651158253,1.35223313396928,4.34427534146120,1.48772171109281];
        
        % State of Battery
        Soc = 0.75; % State of charge [100%]
        Voc; % Voltage of battery [V]
        I = 0; % Current of battery [A]
        Qloss = 0.01; % Capacity loss of battery [100%]
        state = 1; %  -1 - out of life; 0 - out of charge; 1 - normal; 2 - full of charge
    end
    
    methods
        function obj = LiBattery(A0,t_c,t_d)
            if nargin == 1
                obj.A0 = A0;
            else
                obj.A0 = A0;
                obj.t_c = t_c;
                obj.t_d = t_d;
            end
            obj.Voc = obj.t_d(1)*(1-(obj.t_d(2)*(1-obj.Soc)/(1-obj.t_d(3)*(1-obj.Soc))))+obj.t_d(4)*(1-(obj.t_d(5)*(1-obj.Soc)/(1+obj.t_d(6)*(1-obj.Soc))))+obj.t_d(7);
        end
        function update(obj,Pdemand,dt)
            % P_battery>0Ϊ��ض���ŵ磬P_battery<0Ϊ���Ե�س��(W)
            % dtΪ��ŵ����ʱ�䲽��(s)
            if Pdemand>0 && obj.state==0
                %                 disp('The battery is out of charge!');
            elseif Pdemand<0 && obj.state==2
                %                 disp('The battery is full of charge!');
            elseif Pdemand~=0 && obj.state~=-1
                % 1. Solve the battery model
                if Pdemand>0
                    obj.Voc = obj.t_d(1)*(1-(obj.t_d(2)*(1-obj.Soc)/(1-obj.t_d(3)*(1-obj.Soc))))+obj.t_d(4)*(1-(obj.t_d(5)*(1-obj.Soc)/(1+obj.t_d(6)*(1-obj.Soc))))+obj.t_d(7);
                else
                    obj.Voc = obj.t_c(1)*(1-(obj.t_c(2)*(1-obj.Soc)/(1-obj.t_c(3)*(1-obj.Soc))))+obj.t_c(4)*(1-(obj.t_c(5)*(1-obj.Soc)/(1+obj.t_c(6)*(1-obj.Soc))))+obj.t_c(7);
                end
                obj.I = -(obj.Voc-sqrt(obj.Voc^2-4*obj.Rr*Pdemand))/(2*obj.Rr);
                Ah = obj.I*dt/3600; % Ah-throughput in dt
                obj.Soc = Ah/((1-obj.Qloss)*obj.A0)+obj.Soc;
                C = abs(obj.I/obj.A0);
                b = obj.b_para(1)*C+obj.b_para(2);
                % 2. Solve the cycle-life model
                Ahr = Ah/obj.A0*obj.Ar;
                dQloss = abs(Ahr)*obj.z*exp(b/obj.z)*obj.Qloss^((obj.z-1)/obj.z);
                obj.Qloss = obj.Qloss+dQloss; % New capacity loss of battery [100%]
                % 3. Judge the battery state
                if obj.Qloss>=0.90
                    obj.state = -1;
                    disp('The battery is out of life!');
                elseif obj.Soc>=(1-obj.Qloss) || obj.Soc>=0.99
                    obj.state = 2;
                elseif obj.Soc<=0.10
                    obj.state = 0;
                    disp('The battery is out of charge!');
                else
                    obj.state = 1;
                end
            end
        end
    end
end

