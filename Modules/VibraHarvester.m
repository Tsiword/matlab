classdef VibraHarvester < handle
    % Harvester 能量收集器模型
    
    properties
        % Harvester parameters
        Area; % Area of piezo generator [cm2]
        a = 0.00146; %The regressed parameters 
        b = 0.035; %The regressed parameters 
        c = 0.0092; %The regressed parameters 
        
        % Real time parameters
        P; % Real time power[W]
    end
    
    methods
        function obj = VibraHarvester(A,a,b,c)
            if nargin==1
                obj.Area = A; % Area of piezo cell [cm2]
            elseif nargin==5
                obj.a = a; %The regressed parameters
                obj.b = b; %The regressed parameters
                obj.c = c; %The regressed parameters
                obj.Area = A; % Area of solar cell [cm2]
            end
        end
        
        function computepower(obj,env)
            Pm = obj.a*env^2+obj.b*env+obj.c;
            obj.P = Pm*obj.Area/1000;
        end
    end
end

