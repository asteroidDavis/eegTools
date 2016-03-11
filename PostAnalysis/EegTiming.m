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
        %interval between recordings
        dt
        %the maximum time in this recording
        maxTime
    end
    
    methods(Access = public)
        %constructor for EegTiming
        function this = EegTiming(varargin)
            
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
            this.maxTime = this.steps{end}(2);
            this.dt = 1/this.acquisitionFrequency;
        end
        
        %%%%%%%%%%%%%%%%%%%
        %%%% Accessors %%%%
        %%%%%%%%%%%%%%%%%%%
        function acquisitionFrequency = getAcquisitionFrequency(this)
            acquisitionFrequency = this.acquisitionFrequency;
        end
        function nyquistFrequency = getNyquistFrequency(this)
            nyquistFrequency = this.nyquistFrequency;
        end
        function maxTime = getMaxTime(this)
            maxTime = this.maxTime;
        end
        function dt = getDt(this)
            dt = this.dt;
        end
        function steps = getSteps(this)
            steps = this.steps;
        end
    end
    
    
end

