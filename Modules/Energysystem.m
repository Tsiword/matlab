classdef Energysystem < handle
    %Energysystem 复合微能源系统
    
    properties
        
        sensor;
        supercaPs_acitor;
        battery;
        s_harvester;
        v_harvester;
        
        management; % Energy management strategy: 1-SC_first, 2-Ps_arallel, 3-Improved, 4-Rule-based
        Ps_a; %The average power of sensor
        P4; % Energy management Ps_arameters
        P5;
        
        DC_Eff_Sensor = 0.9; % Efficiency of DC/DC for charge
        DC_Eff_Solar = 0.9; % Efficiency of DC/DC for solar cell
        DC_Eff_Vibra = 0.85; % Efficiency of DC/DC for piezo generator
        
        dt = 0.1;
        Sys_t = 0;
        
        state = 1; % State of the system: -1 - out of life; 0 - out of charge; 1 - normal
    end
    
    methods
        function obj = Energysystem(dt, sensor, SC, battery, s_harvester, v_harvester, Ps_a, management, k)
            % sensor, SC, battery, s_harvester,v_harvester, management
            obj.dt = dt;
            obj.sensor = sensor;
            obj.supercaPs_acitor = SC;
            obj.battery = battery;
            obj.supercaPs_acitor.Voc = obj.battery.Voc;
            obj.s_harvester = s_harvester;
            obj.v_harvester = v_harvester;
            obj.management = management;
            obj.Ps_a = Ps_a;
            if management>=4
                obj.P4 = [Ps_a*k(1), k(2)*SC.Vm, Ps_a*k(3)];
                if management == 5
                    obj.P5 = [k(4) k(5)];
                end
            end
        end
        
        function P = update(obj, event, env)
            % update the energy system at the time Sys_t
            if obj.state==1
                obj.Sys_t = obj.Sys_t+obj.dt;
                obj.sensor.computepower(event, obj.Sys_t);
                obj.s_harvester.computepower(env(1));
                obj.v_harvester.computepower(env(2));
                Psensor = obj.sensor.P;
                Psolar = obj.s_harvester.P;
                Pvibra = obj.v_harvester.P;
                Pdemand = Psensor/obj.DC_Eff_Sensor-Psolar*obj.DC_Eff_Solar-Pvibra*obj.DC_Eff_Vibra; %大于0消耗能量，小于0收集能量
                [P_SC,P_Bat] = energy_manager(obj, Pdemand);
                obj.supercaPs_acitor.update(P_SC,obj.dt);
                obj.battery.update(P_Bat,obj.dt);
                obj.judgestate();
                P = [Psensor,Psolar,Pvibra,P_SC,P_Bat];
            end
        end
        
        function [P_SC,P_Bat] = energy_manager(obj, Pdemand)
            P_Bat = 0;
            P_SC = 0;
            switch obj.management
                case 0 % Strategy: Only Battery
                    P_Bat = Pdemand;
                
                case 1 % Strategy: Super CaPs_acitor First
                    if ( (Pdemand>0) && (obj.supercaPs_acitor.state~=0) ) || ( (Pdemand<0) && (obj.supercaPs_acitor.state~=2) )
                        P_SC = Pdemand;
                    else
                        P_Bat = Pdemand;
                    end
                    
                case 2 % Strategy: Voltage Controlled
                    if ((Pdemand>0) && (obj.supercaPs_acitor.Voc>obj.battery.Voc)) || ...
                            ((Pdemand<0) && (obj.supercaPs_acitor.Voc<obj.battery.Voc))
                        P_SC = Pdemand;
                    else
                        P_Bat = Pdemand;
                    end
                    
                case 3 % Strategy: Improved Ps_arallel strategy
                    if Pdemand>0
                        if obj.s_harvester.P>0.5*obj.Ps_a
                            if obj.supercaPs_acitor.Voc-obj.battery.Voc<=-0.9  && obj.supercaPs_acitor.state~=0
                                P_Bat = Pdemand;
                            else
                                P_SC = 0.5*obj.supercaPs_acitor.C*(obj.supercaPs_acitor.Voc-obj.battery.Voc+0.9)^2/obj.dt;
                                if P_SC>Pdemand
                                    P_SC = Pdemand;
                                else
                                    P_Bat = Pdemand-P_SC;
                                end
                            end
                        else
                            if obj.supercaPs_acitor.Voc>obj.battery.Voc
                                P_SC = 0.5*obj.supercaPs_acitor.C*(obj.supercaPs_acitor.Voc-obj.battery.Voc)^2/obj.dt;
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
                        if obj.supercaPs_acitor.Voc-obj.battery.Voc>=0.3
                            P_Bat = Pdemand;
                        else
                            P_SC = -0.5*obj.supercaPs_acitor.C*(obj.supercaPs_acitor.Voc-obj.battery.Voc-0.3)^2/obj.dt;
                            if P_SC<Pdemand
                                P_SC = Pdemand;
                            else
                                P_Bat = Pdemand-P_SC;
                            end
                        end
                    end
                    
                case 4 % Strategy: Improved Rule-based strategy
                    if obj.s_harvester.P<obj.P4(1) && obj.supercaPs_acitor.Voc<obj.P4(2)
                        P_Bat = obj.P4(3);
                        P_SC = -P_Bat;
                    end
                    if Pdemand>0
                        if obj.supercaPs_acitor.state ~= 0
                            P_SC = P_SC+Pdemand;
                        else
                            P_Bat = P_Bat+Pdemand;
                        end
                    else
                        if obj.supercaPs_acitor.state~=2
                            P_SC = P_SC+Pdemand;
                        else
                            P_Bat = P_Bat+Pdemand;
                        end
                    end
                    
                case 5 % Strategy: Improved Rule-based strategy
                    if obj.s_harvester.P<obj.P4(1)
                        if obj.supercaPs_acitor.Voc<obj.P4
                            P_Bat = obj.P4(3);
                            P_SC = -P_Bat;                            
                        end
                    end
                    if Pdemand>0
                        if obj.supercaPs_acitor.state ~= 0
                            P_SC = P_SC+Pdemand;
                        else
                            P_Bat = P_Bat+Pdemand;
                        end
                    else
                        if obj.supercaPs_acitor.state~=2
                            P_SC = P_SC+Pdemand;
                        else
                            if obj.s_harvester.P>obj.Ps_a
                                Pdemand = min((1-obj.P5(1)*obj.P5(2)-(1-obj.P5(2))*obj.battery.Soc)/(1-obj.P5(1)),1)*Pdemand;
                            end
                            P_Bat = P_Bat+Pdemand;
                        end
                    end
            end
        end
        
        function judgestate(obj)
            if obj.battery.state==-1
                obj.state = -1; % Battery is out of life
            elseif obj.battery.state==0 && obj.supercaPs_acitor.state==0
                obj.state = 0; % System is out of charge
            end
        end
        
    end
end
