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
        tabGroup
    end
    
    methods(Access = public)
        
        %constructs the EegPlots
        function this = EegPlots(varargin)
            %creates an axis for the x and y objects
            this.axis = struct();
            %defines defaults and parameter names
            options = struct('electrodes', 'no electrodes', 'tasks', 'no tasks',...
                'data', zeros(1), 'plotPanel', '', 'dataType',...
                'electrodes', 'startChannel', 1, 'endChannel', 1, 'stepsChannel',...
                1, 'timing', '', 'x', struct('label', 'x-axis', 'lim',...
                [0 60]), 'y', struct('label', 'y-axis', 'lim', [-1 1]));
            optionNames = fieldnames(options);
            
            %ensure there is an even number of parameters
            if(rem(length(varargin), 2) ~= 0)
                error('EegPlots needs propertyName, propertyValue pairs');
            end
            
            %parts params in {name; value}
            for pair = reshape(varargin, 2, [])
                paramName = pair{1};
                
                %looks for param names matching the defined parameters
                %names
                if(any(strcmp(paramName, optionNames)))
                    if(strcmp(paramName, 'x') || strcmp(paramName, 'y'))
                        this.axis.(paramName) = pair{2};
                    else
                        this.(paramName) = pair{2};
                    end
                else
                    warning('Ignoring unknown parameter %s', paramName);
                end
            end
        end
        
        function success = plot(this)
            switch this.dataType
                case 'electrodes', plotTasksByElectrode(this); success = 1;
                case 'tasks', plotElectrodesByTask(this); success = 1;
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
        %plots one electrode per subplot with all the tasks for the
        %electrode
        function success = plotTasksByElectrode(this)
            %The tab group containing each task
            this.tabGroup = uitabgroup(this.plotPanel, 'Position', [0.05 0 0.95 0.95]);
            %The channel count from this recording
            totalChannels = this.endChannel-this.startChannel+1;
            %iterate over the tasks in this recording
            index = 1;
            for task = this.tasks
                %converts cell to char
                task = task{1};
                taskTab = uitab(this.tabGroup, 'Title', task);
                %iterates over the electrodes
                for electrode = this.startChannel:this.endChannel
                    %plot in two columns for even numbers of channels
                    if(rem(totalChannels, 2) == 0)
                        subplot(totalChannels/2, 2, electrode-this.startChannel+1,...
                            'Parent', taskTab);
                        plotElectrode(this, electrode, index);
                    %plot if three columns for a multiple of three channel
                    %count
                    elseif(rem(totalChannels, 3) == 0)
                        subplot(totalChannels/3, 3, electrode-this.startChannel+1,...
                            'Parent', taskTab);
                        plotElectrode(this, electrode, index);
                    %plot in a single column
                    else
                        subplot(totalChannels, 1, electrode-this.startChannel+1,...
                            'Parent', taskTab);
                        plotElectrode(this, electrode, index);
                    end
                end
                index = index +1;
            end
            success = 1;
        end
        %plots one task per subplot with the all the electrodes from the
        %task
        function success = plotElectrodesByTask(this)
            
        end
        %plots on electrode against all acquisition time
        function success = plotElectrode(this, electrode, taskIndex)
            minIndex = this.timing.getSteps{taskIndex}(1);
            maxIndex = this.timing.getSteps{taskIndex}(2);
            minTime = minIndex*this.timing.getDt;
            maxTime = maxIndex*this.timing.getDt;
            plot(minTime:this.timing.getDt:maxTime, this.data(electrode,...
                minIndex:maxIndex));
            xlim(this.axis.x.lim);
            ylim(this.axis.y.lim);
            xlabel(this.axis.x.label);
            ylabel(this.axis.y.label);
            success = 1;
        end
    end
end

