classdef SolarHarvester < handle
    % Harvester 能量收集器模型
    
    properties
        % Harvester parameters
        Area; % Area of solar cell [cm2]
        a = 2e-7; %The regressed parameters 
        b = 0.0029; %The regressed parameters 
        c = -0.0071; %The regressed parameters 
        d = 0; %The regressed parameters 
        
        % Real time parameters
        P; % Real time power[W]
    end
    
    methods
        function obj = SolarHarvester(A,a,b,c,d)
            if nargin==1
                obj.Area = A; % Area of solar cell [cm2]
            elseif nargin==5
                obj.a = a; %The regressed parameters
                obj.b = b; %The regressed parameters
                obj.c = c; %The regressed parameters
                obj.d = d; %The regressed parameters
                obj.Area = A; % Relative area of solar cell [m2]
            end
        end
        
        function computepower(obj,env1,env2)
            if nargin == 2
                G = env1; % Global irradition [W/m2]
                Pm = obj.a*G^2+obj.b*G+obj.c;
            elseif nargin == 3
                G = env1; % Global irradition [W/m2]
                T = env2; % Ambiant temperature [℃]
                Pm = -(obj.a*G+obj.b)*(T+0.03375*G)+obj.c*G+obj.d;
            end
            obj.P = Pm*obj.Area/1000;
        end
    end
end

