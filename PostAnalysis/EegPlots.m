classdef EegPlots
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        axis
%             axis.x
%                 axis.x.label
%                 axis.x.lim
%                 axis.x.domain
%             axis.y
%                 axis.y.label
%                 axis.y.lim
%                 axis.y.domain
        electrodes
        tasks
    end
    
    methods(Access = public)
        function this = EegPlots(xaxis, yaxis)
            this;
            setAxis(this, 'x', xaxis, 'y', yaxis);
        end
        
        function setAxis(this, varargin)
            %allows case insentive parameters and ignore unknown parameters
            parser = inputParser('CaseSensitive', 0, 'KeepUnmatched', 1);
            
            %creates default axis when none are expressed
            defaultXAxis = struct('label', 'x-axis', 'lim', [0 60],...
                'domain', {'frequency', 'time'});
            defaultYAxis = struct('label', 'y-axis', 'lim', [-1 1],...
                'domain', {'normalized data'});
            
            %allows named labeled unorder parameters
            addOptional(parser, 'x', defaultXAxis, @validateAxis);
            addOptional(parser, 'y', defaultYAxis, @validateAxis);
            
            parse(parser, varargin{:});
            this.axis.x = parser.Results.x;
            this.axis.y = parser.Ressults.y;
        end
        function axis = getAxis(this)
           axis = this.axis;
        end
    end
    
    methods(Access = private)
        %Given an axis variable
        function isAxis = validateAxis(testee)
            %Is the vairable a struct with a label, lim, and domain
            isAxis = isstruct(testee) &&  exist(testee.label, 'var') &&...
                exist(testee.lim, 'var') && exist(testee.domain, 'var') &&...
                ischar(testee.label) && isnumeric(testee.lim) &&...
                iscellstr(testee.domain);
        end
    end
end

