classdef EegTiming
    %EegTiming Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        %2d array of steps vs start and end time of each step.
        steps
            %steps.startTime
            %steps.endTime
        %the frequency measurements were taken at
        acquisitionFrequency
        %The minimum frequency which can be detected is Facq/2
        nyquistFrequency
        %the maximum time in this recording
        maxTime
    end
    
    methods(Access = public)
        %constructor for EegTiming
        function this = EegTiming(varargin)
            this;
            
            %creates an input parser whihc allows structs
            parser = inputParser;
            parser.StructExpand = 0;
            
            %steps and acquisition frequency are required parameters
            addParameter(parser, 'steps', @Steps.isSteps);
            addParameter(parser, 'acquisitionFrequency', @isnumeric);
            
            %parses the parameters
            parse(parser, varargin{:});
            this.steps = parser.Results.steps;
            this.acquisitionFrequency = parser.Results.acquisitionFrequency;
            
            %defines nyquistFrequency and maxTime based on requied
            %parameters
            this.nyquistFrequency = this.acquisitionFrequency/2;
            this.maxTime = this.steps(end).endTime;
        end
        
        %validates and sets the acquisition frequency
        function setAcquisitionFrequency(this, acquisitionFrequency)
            if(isnumeric(acquisitionFrequency))
                this.acquisitionFrequency = acquisitionFrequency;
            else
                warning(strcat(acquisitionFrequency, ' is not numeric'));
            end
        end
        function acquisitionFrequency = getAcquisitionFrequency(this)
            acquisitionFrequency = this.acquisitionFrequency;
        end
        
        %validates and sets the nyquist frequency
        function setNyquistFrequency(this, nyquistFrequency)
            if(isnumeric(nyquistFrequency))
                this.nyquistFrequency = nyquistFrequency;
            else
                warning(strcat(nyquistFrequency, ' is not numeric'));
            end
        end
        function nyquistFrequency = getNyquistFrequency(this)
            nyquistFrequency = this.nyquistFrequency;
        end
        
        %validates and sets numeric max time
        function setMaxTime(this, maxTime)
            if(isnumeric(maxTime))
                this.maxTime = maxTime;
            else
                warning(strcat(maxTime, ' is not numeric'));
            end
        end
        function maxTime = getMaxTime(this)
            maxTime = this.maxTime;
        end
        
    end
    
    
end

