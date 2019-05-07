classdef Energysystem < handle
    %Energysystem 复合微能源系统
    
    properties
        
        sensor;
        supercapacitor;
        battery;
        s_harvester;
        
        management; % Energy management strategy: 1-SC_first, 2-Ps_arallel, 3-Improved, 4-Rule-based
        Ps_a; %The average power of sensor
        k; % Energy management Parameters
        k_adaptive; % Adaptive Energy management Parameters
        
        DC_Eff_Sensor = 0.9; % Efficiency of DC/DC for charge
        DC_Eff_Solar = 0.9; % Efficiency of DC/DC for solar cell
        
        dt = 0.1;
        Sys_t = 0;
        
        state = 1; % State of the system: -1 - out of life; 0 - out of charge; 1 - normal
    end
    
    methods
        function obj = Energysystem(dt, sensor, SC, battery, s_harvester, Ps_a, management, k)
            % sensor, SC, battery, s_harvester,v_harvester, management
            obj.dt = dt;
            obj.sensor = sensor;
            obj.supercapacitor = SC;
            obj.battery = battery;
            obj.supercapacitor.Voc = obj.battery.Voc;
            obj.s_harvester = s_harvester;
            obj.management = management;
            obj.Ps_a = Ps_a;
            obj.k = k;
            obj.k_adaptive = [k(1)*Ps_a,k(2)*SC.Vm,k(3)*Ps_a,k(4),k(5)];
        end
        
        function P = update(obj, event, env)
            % update the energy system at the time Sys_t
            if obj.state>=0
                obj.Sys_t = obj.Sys_t+obj.dt;
                obj.sensor.computepower(event, obj.Sys_t);
                obj.s_harvester.computepower(env);
                Psensor = obj.sensor.P;
                Psolar = obj.s_harvester.P;
                Pdemand = Psensor/obj.DC_Eff_Sensor-Psolar*obj.DC_Eff_Solar; %大于0消耗能量，小于0收集能量
                [P_SC,P_Bat] = energy_manager(obj, Pdemand);
                obj.supercapacitor.update(P_SC,obj.dt);
                obj.battery.update(P_Bat,obj.dt);
                obj.judgestate();
                P = [Pdemand,Psensor,Psolar,P_SC,P_Bat];
            end
        end
        
        function [P_SC,P_Bat] = energy_manager(obj, Pdemand)
            P_Bat = 0;
            P_SC = 0;
            switch obj.management
                case 1 % Strategy: Only Battery
                    P_Bat = Pdemand;
                
                case 2 % Strategy: Super Capacitor First
                    if ( (Pdemand>0) && (obj.supercapacitor.state~=0) ) || ( (Pdemand<0) && (obj.supercapacitor.state~=2) )
                        P_SC = Pdemand;
                    else
                        P_Bat = Pdemand;
                    end
                    
                case 3 % Strategy: Voltage Controlled
                    if ((Pdemand>0) && (obj.supercapacitor.Voc>obj.battery.Voc)) || ...
                            ((Pdemand<0) && (obj.supercapacitor.Voc<obj.battery.Voc))
                        P_SC = Pdemand;
                    else
                        P_Bat = Pdemand;
                    end
                    
                case 4 % Strategy: Improved Parallel strategy
                    if Pdemand>0
                        if obj.s_harvester.P>0.5*obj.Ps_a
                            if obj.supercapacitor.Voc-obj.battery.Voc<=-0.9  && obj.supercapacitor.state~=0
                                P_Bat = Pdemand;
                            else
                                P_SC = 0.5*obj.supercapacitor.C*(obj.supercapacitor.Voc-obj.battery.Voc+0.9)^2/obj.dt;
                                if P_SC>Pdemand
                                    P_SC = Pdemand;
                                else
                                    P_Bat = Pdemand-P_SC;
                                end
                            end
                        else
                            if obj.supercapacitor.Voc>obj.battery.Voc
                                P_SC = 0.5*obj.supercapacitor.C*(obj.supercapacitor.Voc-obj.battery.Voc)^2/obj.dt;
                                if P_SC>Pdemand
                                    P_SC = Pdemand;
                                else
                                    P_Bat = Pdemand-P_SC;
                                end
                            else
                                P_SC = -0.2*obj.Ps_a;
                                P_Bat = Pdemand-P_SC;
                            end
                        end
                    else
                        if obj.supercapacitor.Voc-obj.battery.Voc>=0.3
                            P_Bat = Pdemand;
                        else
                            P_SC = -0.5*obj.supercapacitor.C*(obj.supercapacitor.Voc-obj.battery.Voc-0.3)^2/obj.dt;
                            if P_SC<Pdemand
                                P_SC = Pdemand;
                            else
                                P_Bat = Pdemand-P_SC;
                            end
                        end
                    end
                    
                case 5 % Strategy: Rule-based strategy
                    if obj.s_harvester.P<obj.k(1)
                        if obj.supercapacitor.Voc<obj.k(2)
                            P_Bat = obj.k(3);
                            P_SC = -P_Bat;                            
                        end
                    end
                    if Pdemand>0
                        if obj.supercapacitor.state ~= 0
                            P_SC = P_SC+Pdemand;
                        else
                            P_Bat = P_Bat+Pdemand;
                        end
                    else
                        if obj.supercapacitor.state~=2
                            P_SC = P_SC+Pdemand;
                        else
                            if Pdemand<-5*obj.Ps_a
                                Pdemand = min((1-obj.k(4)*obj.k(5)-(1-obj.k(5))*obj.battery.Soc)/(1-obj.k(4)),1)*Pdemand;
                            end
                            P_Bat = P_Bat+Pdemand;
                        end
                    end
                    
                case 6 % Strategy: Adaptive Rule-based strategy
                    if obj.s_harvester.P<obj.k_adaptive(1)
                        if obj.supercapacitor.Voc<obj.k_adaptive(2)
                            P_Bat = obj.k_adaptive(3);
                            P_SC = -P_Bat;                            
                        end
                    end
                    if Pdemand>0
                        if obj.supercapacitor.state ~= 0
                            P_SC = P_SC+Pdemand;
                        else
                            P_Bat = P_Bat+Pdemand;
                        end
                    else
                        if obj.supercapacitor.state~=2
                            P_SC = P_SC+Pdemand;
                        else
                            if Pdemand<-5*obj.Ps_a
                                Pdemand = min((1-obj.k_adaptive(4)*obj.k_adaptive(5)-(1-obj.k_adaptive(5))*obj.battery.Soc)/(1-obj.k_adaptive(4)),1)*Pdemand;
                            end
                            P_Bat = P_Bat+Pdemand;
                        end
                    end
            end
        end
        
        function judgestate(obj)
            if obj.battery.state==-1
                obj.state = -1; % Battery is out of life
            elseif obj.battery.state==0 && obj.supercapacitor.state==0
                obj.state = 0; % System is out of charge
            end
        end
        
    end
end
