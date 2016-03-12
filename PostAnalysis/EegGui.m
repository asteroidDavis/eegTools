classdef EegGui < handle
    %EegGui Provides a gui for loading data, filtering, 
    %   Detailed explanation goes here
    
    properties(Access = private)
        %the figure handle containing controls and plots
        eegFigHandle
        %The panel containing plots
        plotsPanel
            refresh
            plots
            timing
        
        %the panel containing controls
        menuPanel
            dataSelectionPanel
                dataType
                    fileData
                    realTimeData
                dataChoice
                    dataName
                    dataDir
                    dataPath
                data
            tasksPanel
                tasksSelectionText
                    taskSelection
                        tasks
                        defaultTaskMessage
                    addTask
                    removeTask
                electrodesSelectionText
                    addElectrode
                    removeElectrode
                    electrodeSelection
                        defaultElectrodeMessage
                        electrodes
            domainRangePanel
                domainLabel
                    domains
                    domainTypes
                        electrodeDomain
                        taskDomain
                    firstDomain
                    lastDomain
                    stepsDomain
                rangeLabel
                    ranges
            timingPanel
                frequencyAcquisition
            filterPanel
                addFilter
                removeFilter
        
    end
    
    methods(Access = public)
        %constructs the gui
        function this = EegGui()
            %extends figure
            this.eegFigHandle = figure('Visible', 'off', 'Tag', 'fig',...
                'Units', 'normalized', 'position', [0 0 1 1]);
            
            %%%%%%%%%%%%%%%%%%%%
            %%%% Menu Panel %%%%
            %%%%%%%%%%%%%%%%%%%%
            %puts a menue panel at the left side of the gui
            this.menuPanel = uipanel('Title', 'Controls', 'FontSize', 11,...
                'BackgroundColor', 'white', 'Position', [0 0 1/4 1]);
            
            %given a data selection panel
            this.dataSelectionPanel = uipanel(this.menuPanel,...
                'Title', 'Data Selection', 'FontSize', 10,... 
                'BackgroundColor', 'white', 'Position', [0 14/15 1 1/15]);
            %Given radio buttons to select source of data
            this.dataType = uibuttongroup(this.dataSelectionPanel, ...
                'Position', [0 1/2 1/2 1/2]);
            %radio button for data from a file
            this.fileData = uicontrol(this.dataType, 'Style',...
                'radiobutton', 'String', 'File', 'Units', 'normalized',...
                'Position', [0 0 1/2 1]);
            %radio button for selecting real time data
            this.realTimeData = uicontrol(this.dataType, 'Style',...
                'radiobutton', 'String', 'rt', 'tooltip', 'real-time data',...
                'Units', 'normalized', 'Position', [1/2 0 1/2 1], 'callback',...
                @(src,event) msgbox('Real time plotting is not implemented yet :('));
            %text field for entering file paths or i/o description
            this.dataChoice = uicontrol(this.dataSelectionPanel, 'Style',...
                'pushbutton', 'Units', 'normalized', 'String', 'Choose File',...
                'Callback', @(src,event) chooseData(this),'Position',...
                [0 0 1 1/2]);
            
            %controls data about each task
            this.tasksPanel = uipanel(this.menuPanel, 'Title', 'Task Info',...
                'FontSize', 11, 'BackgroundColor', 'white', 'Position',...
                [0 12/15 1 2/15]);
            %labels the task selection area
            this.tasksSelectionText = uicontrol(this.tasksPanel, 'Style', 'text',...
                'String', 'Tasks', 'FontSize', 10, 'Units', 'normalized',... 
                'BackgroundColor', 'white', 'Position', [0 5/6 1/2 1/6]);
            %provides a menu to add tasks
            this.addTask = uicontrol(this.tasksPanel, 'Style', 'pushbutton',...
                'Fontsize', 10, 'BackgroundColor', 'white', 'String', '+',...
                'Units', 'normalized', 'Position', [1/2 5/6 1/4 1/6],...
                'Callback', @(src, event) toggleTaskSelection(this));
            this.removeTask = uicontrol(this.tasksPanel, 'Style', 'pushbutton',...
                'Fontsize', 10, 'BackgroundColor', 'white', 'String', '-',...
                'Units', 'normalized', 'Position', [3/4 5/6 1/4 1/6],...
                'Callback', @(src, event) removeSelectedTask(this));
            %provides a drop down or editable text for adding task labels
            this.defaultTaskMessage = 'Press + to add tasks';
            this.tasks = {};
            this.taskSelection = uicontrol(this.tasksPanel, 'Style',...
                'popupmenu', 'FontSize', 10, 'Units', 'normalized',...
                'Position', [0 2/3 1 1/6], 'String',...
                {this.defaultTaskMessage});
            %labels the electode selection area
            this.electrodesSelectionText = uicontrol(this.tasksPanel, 'Style',...
                'text', 'String', 'Electrodes', 'FontSize', 10, 'Units',...
                'normalized', 'BackgroundColor', 'white', 'Position',...
                [0 1/3 1/2 1/6]);
            %allows adding electrode labels
            this.addElectrode = uicontrol(this.tasksPanel, 'Style',...
                'pushbutton', 'FontSize', 10, 'BackgroundColor', 'white',...
                'String', '+', 'Units', 'normalized', 'Position',...
                [1/2 1/3 1/4 1/6], 'Callback',...
                @(src, event) toggleElectrodeSelection(this));
            %removing an electrode label
            this.removeElectrode = uicontrol(this.tasksPanel, 'Style',...
                'pushbutton', 'Fontsize', 10, 'BackgroundColor', 'white',...
                'String', '-', 'Units', 'normalized', 'Callback',... 
                @(src,event) removeSelectedElectrode(this), 'Position',...
                [3/4 1/3 1/4 1/6]);
            %a dropdown of editable electrode labels
            this.defaultElectrodeMessage = 'Press + to add electrodes';
            this.electrodes = {};
            this.electrodeSelection = uicontrol(this.tasksPanel, 'Style',...
                'popupmenu', 'FontSize', 10, 'Units', 'normalized',...
                'Position', [0 1/6 1 1/6], 'String',...
                {this.defaultElectrodeMessage});
            
            %options for editing the actual data
            this.domainRangePanel = uipanel(this.menuPanel, 'Title',...
                'Domain and Range', 'BackgroundColor', 'white', 'Position',...
                [0 10/15 1 2/15]);
            this.domainLabel = uicontrol(this.domainRangePanel, 'Style',...
                'text', 'String', 'domains','BackgroundColor', 'white',...
                'FontSize', 10, 'Units', 'normalized', 'Position',...
                [0 3/4 1/2 1/4]);
            %dropdown of available domain functions
            this.domains = uicontrol(this.domainRangePanel, 'Style',...
                'popupmenu', 'String', {'time', 'frequency'},...
                'BackgroundColor', 'white', 'Units', 'normalized',...
                'Position', [1/2 3/4 1/2 1/4]);
            %a button group for choosing electrode or task plots
            this.domainTypes = uibuttongroup(this.domainRangePanel,...
                'Position', [0 1/2 1/2 1/3]); 
            this.electrodeDomain = uicontrol(this.domainTypes, 'Style',...
                'radiobutton', 'String', 'electrodes','Units', 'normalized',...
                'Position', [0 0 1/2 1]);
            this.taskDomain = uicontrol(this.domainTypes, 'Style', 'radiobutton',...
                'String', 'tasks', 'Units', 'normalized', 'Position',...
                [1/2 0 1/2 1]);
            this.firstDomain = uicontrol(this.domainRangePanel, 'Style',...
                'edit', 'Units', 'normalized', 'tooltip', 'first channel',...
                'Position', [1/2 1/2 1/6 1/4]);
            this.lastDomain = uicontrol(this.domainRangePanel, 'Style',...
                'edit', 'Units', 'normalized', 'tooltip', 'last channel',...
                'Position', [2/3 1/2 1/6 1/4]);
            this.stepsDomain = uicontrol(this.domainRangePanel, 'Style',...
                'edit', 'Units', 'normalized', 'tooltip', 'steps channel',...
                'Position', [5/6 1/2 1/6 1/4]);
            this.rangeLabel = uicontrol(this.domainRangePanel, 'Style',...
                'text', 'String', 'ranges','BackgroundColor', 'white',...
                'FontSize', 10, 'Units', 'normalized', 'Position',...
                [0 1/4 1/2 1/4]);
            %dropdown of available range functions
            this.ranges = uicontrol(this.domainRangePanel, 'Style',...
                'popupmenu', 'String', {'voltage', 'log power',...
                'epoched', 'epoched with variance'}, 'BackgroundColor',...
                'white', 'Units', 'normalized', 'Position',...
                [1/2 1/4 1/2 1/4]);
            
            this.timingPanel = uipanel(this.menuPanel, 'Title', 'Timing',...
                'BackgroundColor', 'white', 'Position', [0 9/15 1 1/15]);
            this.frequencyAcquisition = uicontrol(this.timingPanel, 'Style',...
                'edit', 'Units', 'normalized', 'tooltip', 'Frequency of Acquisition',...
                'Position', [0 0 1 1]);
            
            %%%%%%%%%%%%%%%%%%%%%
            %%%% Plots Panel %%%%
            %%%%%%%%%%%%%%%%%%%%%
            %a plots panel at the right side of the gui
            this.plotsPanel = uipanel('Title', 'Plots', 'FontSize', 10, ...
                'BackgroundColor', 'white', 'Position', [1/4 0 3/4 1]);
            
            %given a refesh button at the top left of the plot panel
            this.refresh = uicontrol(this.plotsPanel, 'Style', 'pushbutton',...
                'FontSize', 10, 'BackgroundColo', 'white', 'String',...
                char(8635), 'Units','normalized','callback', @(src,event)...
                refreshPlots(this), 'Position',[0 0.95 0.05 0.05]);
            
            %makes the figure visible once everything is added
            this.eegFigHandle.Visible = 'on';
        end
    end
    
    methods(Access = public)
        
    end
    
    methods(Access = private)
        
        %When the user clicks the + next to 'Tasks'
        function success = toggleTaskSelection(this)
            %And the task selection field is a dropdown
            if(strcmp(get(this.taskSelection, 'Style'), 'popupmenu') == 1)
                %Then the task selection field becomes editable text
                set(this.taskSelection, 'Style', 'edit', 'String', '');
                success = 1;
            %Or the task selection field is editable text
            elseif(strcmp(get(this.taskSelection, 'Style'), 'edit') == 1)
                this.tasks{end+1} = get(this.taskSelection, 'String');
                %And the user added tasks
                if(size(this.tasks) >= 1)
                    %display a task selector with the added tasks
                    set(this.taskSelection,'Style', 'popupmenu','String',...
                        this.tasks);
                else
                    %display the default task selector
                    set(this.taskSelection, 'Style', 'popupmenu', 'String',...
                        {this.defaultTaskMessage});
                end
                success = 1;
            else
                warning(strcat('Task Selector: taskSelection is type: ',...
                    get(this.taskSelection, 'Style'), '. \nResetting to ',...
                    'popupmenu.'));
                success = 0;
            end
        end
        %When the user clicks '+' next to 'Electrodes'
        function success = toggleElectrodeSelection(this)
            %and the electrode selection task
            if(strcmp(get(this.electrodeSelection, 'Style'), 'popupmenu') == 1)
                %then the electrode selection field becomes editable text
                set(this.electrodeSelection, 'Style', 'edit', 'String', '');
                success = 1;
            %Or the electrode selection field is editable text
            elseif(strcmp(get(this.electrodeSelection, 'Style'), 'edit') == 1)
                this.electrodes{end+1} = get(this.electrodeSelection, 'String');
                %And the user added tasks
                if(size(this.electrodes) >= 1)
                    %display a task selector with the added tasks
                    set(this.electrodeSelection,'Style', 'popupmenu','String',...
                        this.electrodes);
                else
                    %display the default task selector
                    set(this.electrodeSelection, 'Style', 'popupmenu', 'String',...
                        {this.defaultElectrodeMessage});
                end
                success = 1;
            else
                warning(strcat('Electrode Selector: electrodeSelection is type: ',...
                    get(this.electrodeSelection, 'Style'), '. \nResetting to ',...
                    'popupmenu.'));
                success = 0;
            end
        end
        
        %When the user clicks the remove task button
        function success = removeSelectedTask(this)
            %if there are any added tasks 
            if(length(this.tasks) >= 1)
                %and the task selector is in drop down mode
                if(strcmp(get(this.taskSelection, 'Style'), 'popupmenu') == 1)
                    %remove the selected task from tasks
                    this.tasks{get(this.taskSelection, 'Value')} = [];
                    this.tasks = this.tasks(~cellfun(@isempty, this.tasks));
                    set(this.taskSelection, 'String', this.tasks, 'Value',...
                        length(this.tasks));
                %and the task selector is not in drop down mode
                else
                    %set the task selector to drop down mode
                    set(this.taskSelection, 'Style', 'popupmenu', 'String',...
                        this.tasks);
                end
            %if there are no added tasks
            else
                %display the default message in a drop down menu
                set(this.taskSelection, 'Style', 'popupmenu', 'String',...
                        this.defaultTaskMessage);
            end
            success = 1;
        end
        %When the user clicks the remove electrode button
        function success = removeSelectedElectrode(this)
            %if there are any added electrodes
            if(length(this.electrodes) >= 1)
                %and the electrode selector is in drop down mode
                if(strcmp(get(this.electrodeSelection, 'Style'),...
                    'popupmenu') == 1)
                    %then remove the selected electrod from electrodes
                    this.electrodes{get(this.electrodeSelection, 'Value')}...
                        = [];
                    this.electrodes = this.electrodes(~cellfun(@isempty,...
                        this.electrodes));
                    set(this.electrodeSelection, 'String', this.electrodes,...
                        'Value', length(this.electrodes));
                %and the electrode selector is not in drop down mode
                else
                    %set the electrode selector is not in drop down mode
                    set(this.electrodeSelection, 'Style', 'popupmenu',...
                        'String', this.defaultElectrodeMessage);
                end
            %if there are no added tasks    
            else
                %display the default message in the drop down
                set(this.electrodeSelection, 'Style', 'popupmenu', 'String',...
                        this.defaultElectrodeMessage);
            end
            success = 1;
        end
        
        %When refresh is clicked
        function success = refreshPlots(this)
            %Determine the xlabel
            domains = get(this.domains, 'String');
            xlabel = domains{get(this.domains, 'Value')};
            
            %determine the domain type
            domainType = get(get(this.domainTypes, 'SelectedObject'),...
                'String');
            
            %determine the ylabel
            ranges = get(this.ranges, 'String');
            ylabel = ranges{get(this.ranges, 'Value')};
            
            %determine timing info
            facq = str2double(get(this.frequencyAcquisition, 'String'));
            
            %attempts to extract timing details
            try
                %determine the channel numbering
                startChannel = str2double(get(this.firstDomain, 'String'));
                endChannel = str2double(get(this.lastDomain, 'String'));
                stepsChannel = str2double(get(this.stepsDomain, 'String'));
                %determine the step times and macx time with a timing
                %object
                this.timing = EegTiming('steps', Steps.stepExtract(this.data(...
                    stepsChannel,:)), 'acquisitionFrequency', facq);
            %sometimes the channel numbers will be wrong
            catch ME
                %if there is an error
                if(~strcmp(ME.identifier, ''))
                    %creates a dialog warning of the wrong channels
                    wrn = warndlg({'Can"t extract steps from channel ';...
                        ME.message; ME.cause; StructStrings.expand(ME.stack)});
                    waitfor(wrn);
                    %sets the steps channel to the empty string
                    set(this.stepsDomain, 'String', '');
                end
            end
            
            try 
                %initialize plots based on parameters
                this.plots = EegPlots('electrodes', this.electrodes, 'tasks',...
                    this.tasks, 'data', this.data, 'plotPanel', this.plotsPanel,...
                    'dataType', domainType, 'startChannel', startChannel,...
                    'endChannel', endChannel, 'stepsChannel', stepsChannel,...
                    'timing', this.timing, 'x', struct('label', xlabel,...
                    'lim',[0 60]), 'y', struct('label', ylabel, 'lim', [-1 1]));
                
                this.plots.plot();
                success = 1;
            catch ME
                %if there is an error
                if(~strcmp(ME.identifier, ''))
                    wrn = warndlg({'Could not plot data'; ME.message;...
                        ME.cause; 'Trace'; StructStrings.expand(ME.stack)});
                    waitfor(wrn);
                    success = 0;
                end
            end    
        end
        
        %When the user clicks choose file
        function success = chooseData(this)
            %open a file chooser
            [this.dataName, this.dataDir] = uigetfile({'*.mat'});
            %if the user cancels 
            if(isequal(this.dataName, 0))
                %do nothing and report success
                success = 1;
            %if the user picks a file
            else
                %define the dataPath
                this.dataPath = strcat(this.dataDir, this.dataName);
                %load the data
                this.data = load(this.dataPath);
                this.data = this.data.y;
                %if the data can be sent to the plot
                if(refreshPlots(this))
                    %report success
                    success = 1;
                else
                    %report failure
                    success = 0;
                end
            end
        end
    end
end

