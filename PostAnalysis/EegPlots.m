classdef EegPlots
    %EegPlots -- EegPlots( electrodes, tasks, xAxis, yAxis)
    %   -the data contained in the plots
    %   -electrodes is a cell array of electrode names. ie {'Cz', 'Pz'}
    %   -tasks is a cell array of the name of each experiment ie. {'rest',
    %       'blink'}
    %   -x is an optional struct containing info about the x-axis ie. 
    %       struct( 'label', 'x-axis', 'lim', [0 60])
    %   -y is an optional struct with info about the y-axis
    %WARNING: Domain must be a cell inside a cell
    
    
    properties(Access = private)
        
        plotPanel
            axis
        data
            startChannel
            endChannel
            stepsChannel
        dataType
            electrodes
            tasks
        timing
    end
    
    methods(Access = public)
        
        %constructs the EegPlots
        function this = EegPlots(electrodes, tasks, data, plotPanel,...
                dataType, varargin)
            %allows case insentive parameters and ignore unknown parameters
            parser = inputParser;
            parser.StructExpand = 0;
            
            %creates default axis when none are expressed
            defaultXAxis = struct('label', 'x-axis', 'lim', [0 60]);
            defaultYAxis = struct('label', 'y-axis', 'lim', [-1 1]);
            
            %defines and orders the parameters
            %electrodes must be the first parameter to EegPlots
            addRequired(parser, 'electrodes');
            %tasks must be the second parameter to EegPlots
            addRequired(parser, 'tasks');
            %data must be the third parameter to EegPlots
            addRequired(parser, 'data');
            %Panel to add the plots to. Control is handled from the gui
            %class
            addRequired(parser, 'plotPanel');
            %Electrodes or tasks are the primary plotted element
            addRequired(parser, 'dataType');
            %start and end channel corresponsing to a index of data
            addRequired(parser, 'startChannel');
            addRequired(parser, 'endChannel');
            addRequired(parser, 'stepsChannel');
            %the axis can be in any order
            addParameter(parser, 'x', defaultXAxis);
            addParameter(parser, 'y', defaultYAxis);
            
            %parses and passes the arguments to the EegPlots object
            parse(parser, varargin{:});
            this.axis.x = parser.Results.x;
            this.axis.y = parser.Results.y;
            this.electrodes = parser.Results.electrodes;
            this.tasks = parser.Results.tasks;
            this.data = parser.Results.data;
            this.plotPanel = parser.Results.plotPanel;
            this.dataType = parser.Resulsts.dataType;
            this.startChannel = parser.Results.startChannel;
            this.endChannel = parser.Results.endChannel;
            this.stepsChannel = parser.Results.stepsChannel;
            
        end
        
        function success = plot(this)
            switch this.dataType
                case 'electrodes', plotTasksByElectrode(this); success = 1;
                case 'tasks', plotElectodesByTask(this); success = 1;
                otherwise, warndlg('domains must be set to "electrodes" or "tasks"');
                    success = 0;
            end
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
        
        %validates and sets the electrodes object
        function setElectrodes(this, electrodes)
            if(iscellstr(electrodes))
                this.electrodes = electrodes;
            else
                warning(strcat(electrodes, ' is not a cell array of strings'));
            end
        end
        function electrodes = getElectrodes(this)
            electrodes = this.electrodes;
        end
        
        %validates and sets the tasks object
        function setTasks(this, tasks)
            if(iscellstr(tasks))
                this.tasks = tasks;
            else
                warning(strcat(tasks, ' is not a cell array of strings'));
            end
        end
        function tasks = getTasks(this)
            tasks = this.tasks;
        end
    end
    
    methods(Access = private)
        
    end
end

