classdef EegPlots
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        axis
        electrodes
        tasks
    end
    
    methods(Access = public)
        
        %constructs the EegPlots
        function this = EegPlots(varargin)
             %allows case insentive parameters and ignore unknown parameters
            parser = inputParser;
            parser.StructExpand = 0;
            
            %creates default axis when none are expressed
            defaultXAxis = struct('label', 'x-axis', 'lim', [0 60],...
                'domain', {{'frequency', 'time'}});
            defaultYAxis = struct('label', 'y-axis', 'lim', [-1 1],...
                'domain', {{'normalized data', 'log power'}});
            
            %defines and orders the parameters
            %electrodes must be the first parameter to EegPlots
            addRequired(parser, 'electrodes', @iscellstr);
            %tasks must be the second parameter to EegPlots
            addRequired(parser, 'tasks', @iscellstr);
            %the axis can be in any order
            addParameter(parser, 'x', defaultXAxis, @validateAxis);
            addParameter(parser, 'y', defaultYAxis, @validateAxis);
            
            %parses and passes the arguments to the EegPlots object
            parse(parser, varargin{:});
            this.axis.x = parser.Results.x;
            this.axis.y = parser.Results.y;
            this.electrodes = parser.Results.electrodes;
            this.tasks = parser.Results.tasks;
        end
        
        %validates and sets the axis object
        function setAxis(this, xAxis, yAxis)
            if(this.validateAxis(xAxis) && this.validateAxis(yAxis))
                this.axis.x = xAxis;
                this.axis.y = yAxis;
            else
                warning('xAxis, yAxis do not pass validation for axis.setAxis');
            end
        end
        function axes = getAxis(this)
           axes = this.axis;
        end
    end
    
    methods(Access = private)
        
        %Given an axis variable
        function isAxis = validateAxis(this, testee)
            %Is the vairable a struct with a label, lim, and domain
            isAxis = isstruct(testee) && ischar(testee.label) &&...
                isnumeric(testee.lim) && iscellstr(testee.domain);
        end
    end
end

