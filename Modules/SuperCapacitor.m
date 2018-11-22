classdef SuperCapacitor < handle
    % SuperCapacitor 超级电容模型
    
    properties
        % ----- Properties of SuperCapacitor -----
        Vm; % Maxium Voltage[V] (Minmum voltage is half of it)
        
        % ----- RC model parameters from constant charge and self discharge test-----
        ParaRC = [5.0, 0.025, 0.0012, 2430, 0.0031, 2.35*10^9]; % [Ri, Ci0, Ci1, Rd, Cd, Rl]
        
        % ----- Initial state parameters ----
        Voc;
        ParaInitial = [0 0 0 0 0]; % [Iout, Vout, Pout, Vi, Vd]
        state = 0; % 0 - out of charge; 1 - normal; 2 - full of charge
    end
    
    methods
        function obj = SuperCapacitor(Vm,Ri,Ci0,Ci1,Rd,Cd,Rl)
            if nargin==1
                obj.Vm = Vm;
            else
                obj.Vm = Vm;
                obj.ParaRC(1) = Ri; % Resistance of instant response branch [Ohm]
                obj.ParaRC(2) = Ci0; % Capacitance of instant response branch - constant term [F]
                obj.ParaRC(3) = Ci1; % Capacitance of instant response branch - linear term coefficient [F/V]
                obj.ParaRC(4) = Rd; % Resistance of delayed response branch [Ohm]
                obj.ParaRC(5) = Cd; % Capacitance of delayed response branch [F]
                obj.ParaRC(6) = Rl; % Leakage resistance [Ohm]
            end
        end
        
        function update(obj,Psys,dt)
            % Psys>0为电容对外放电，Psys<0为外界对电容充电(W)
            % dt为充放电仿真时间步长(s)
            if Psys>0 && obj.state==0
                disp('The SC is out of charge!');
            elseif Psys<0 && obj.state==2
                disp('The SC is full of charge!');
            else
                Idm = 0.04; % Max discharge current [A]
                Icm = 0.04; % Max charge current [A]
                Vout_0 = obj.ParaInitial(2);    % Output voltage [V]
                Vi_0   = obj.ParaInitial(4);    % Voltage of instant response capacitor [V]
                Vd_0   = obj.ParaInitial(5);    % Voltage of delayed response capacitor [V]
                ParaModel = [obj.ParaRC, Vi_0, Vd_0];
                Ri = obj.ParaRC(1);
                Rd = obj.ParaRC(4);
                Vcm = obj.Vm;
                if Psys>0
                    % Requirement of discharge (Instant response)
                    ParaInstant = [ 1, Psys ];                                                           % Set the output power as known with value Psys
                    X_ini       = [ Idm, Vout_0, Psys, Idm, Vi_0, 0 ];                                      % Initialize answers [ Iout, Vout, Pout, Ii, Vi, Il ]
                    ParaTarget  = fsolve(@(X) SCEq_RCnetwork( X, ParaModel, ParaInstant, dt ), X_ini );     % Solve model equations
                    Iout = ParaTarget(1);  % Output current [A]
                    Vout = ParaTarget(2);  % Output voltage [V]
                    Pout = ParaTarget(3);  % Output power [W]
                    Vi   = ParaTarget(5);  % Voltage of instant response capacitor [V]
                    Vd   = Vd_0;
                elseif Psys<0
                    % Chargeable (Instant response)
                    ParaInstant = [ 1, Psys ];                                                           % Set the output power as known with value Psys
                    X_ini       = [ -Icm, Vout_0, Psys, -Icm, Vi_0, 0 ];                                    % Initialize answers [ Iout, Vout, Pout, Ii, Vi, Il ]
                    ParaTarget  = fsolve(@(X) SCEq_RCnetwork( X, ParaModel, ParaInstant, dt ), X_ini );     % Solve model equations
                    Iout = ParaTarget(1);  % Output current [A]
                    Vout = ParaTarget(2);  % Output voltage [V]
                    Pout = ParaTarget(3);  % Output power [W]
                    Vi   = ParaTarget(5);  % Voltage of instant response capacitor [V]
                    Vd   = Vd_0;
                else
                    % No power demand (delayed response)
                    ParaInstant = [ 0,  0 ];
                    X_ini       = [ (Vout_0-Vd_0)/Rd, Vout_0, Vd_0, Vout_0-Vi_0, Vcm-Idm*Ri/10, 0 ];        % Initialize answers [ Id, Vout, Vd, Ii, Vi, Il ]
                    ParaTarget  = fsolve(@(X) SCEq_RCnetwork( X, ParaModel, ParaInstant, dt ), X_ini );     % Solve model equations
                    Iout = 0;              % Output current [A]
                    Vout = ParaTarget(2);  % Output voltage [V]
                    Pout = 0;              % Output power [W]
                    Vi   = ParaTarget(5);  % Voltage of instant response capacitor [V]
                    Vd   = ParaTarget(3);  % Voltage of dalayed response capacitor [V]
                    
                    %                     Iout = 0;              % Output current [A]
                    %                     Vout = Vout_0;         % Output voltage [V]
                    %                     Pout = 0;              % Output power [W]
                    %                     Vi   = Vi_0;           % Voltage of instant response capacitor [V]
                    %                     Vd   = Vd_0;           % Voltage of dalayed response capacitor [V]
                end
                % Update the capacitor state
                obj.ParaInitial(1) = Iout; % Output current [V]
                obj.ParaInitial(2) = Vout; % Output voltage [V]
                obj.ParaInitial(3) = Pout; % Output power [W]
                obj.ParaInitial(4) = Vi; % Voltage of instant response capacitor [V]
                obj.ParaInitial(5) = Vd; % Voltage of delayed response capacitor [V]
                obj.Voc = Vout;
                % Judge the capacitor state
                if Vout>=obj.Vm
                    obj.state = 2;
                elseif Vout<=obj.Vm/3
                    obj.state = 0;
                else
                    obj.state = 1;
                end
            end
        end
    end
end


function Eq = SCEq_RCnetwork( ParaTarget, ParaRC, ParaInstant, dt )
% Super capacitor RC model - Instant/Delayed response equations

% Instant response parameters
flag_inst = ParaInstant(1); % 0-delayed response mode, 1-instant response mode
var_value = ParaInstant(2); % The assumed value of variable

% Variables to be calculated
Vsc = ParaTarget(2);        % Output voltage [V]
Ii  = ParaTarget(4);        % Current of instant resposne branch [A]
Vi  = ParaTarget(5);        % Voltage of instant response capacitor [V]
Il  = ParaTarget(6);        % Leakage current [A]
switch flag_inst
    case 1
        Isc = ParaTarget(1);	% Output current [A]
        Psc = ParaTarget(3);    % Output power [W]
    case 0
        Id  = ParaTarget(1);    % Current of delayed response branch [A]
        Vd  = ParaTarget(3);    % Voltage of dalayed response capacitor [V]
    otherwise
end

% RC model parameters at current sampling time
Ri  = ParaRC(1);         % Resistance of instant response branch [Ohm]
Ci0 = ParaRC(2);         % Capacitance of instant response branch - constant term [F]
Ci1 = ParaRC(3);         % Capacitance of instant response branch - linear term coefficient [F/V]
Rd  = ParaRC(4);         % Resistance of delayed response branch [Ohm]
Cd  = ParaRC(5);         % Capacitance of delayed response branch [F]
Rl  = ParaRC(6);         % Leakage resistance [Ohm]

% RC model parameters at last sampling time
Vi_0 = ParaRC(7);        % Voltage of instant response capacitor [V]
Vd_0 = ParaRC(8);        % Voltage of delayed response capacitor [V]

% RC model equations
% 3 common equations for both instant and delayed responses
Eq(2) = Vsc - Il*Rl;
Eq(3) = Vi - Ii*Ri - Vsc;
Eq(4) = Ii + (Ci0 + Ci1*Vsc) * (Vi-Vi_0)/dt;

switch flag_inst
    case 1
        % Instant response - 3 other equations
        Eq(1) = Ii - Il - Isc;
        Eq(5) = Psc - Isc*Vsc;
        Eq(6) = Psc - var_value;
    case 0
        % Delayed response - 3 other equations
        Eq(1) = Id + Il - Ii;
        Eq(5) = Vd + Id*Rd - Vsc;
        Eq(6) = Id - Cd * (Vd-Vd_0)/dt;
end

end
