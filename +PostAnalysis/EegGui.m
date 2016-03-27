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
                filters
                filterNames
                defaultFilterString
                filterSelection
                    filterNameLabel
                        filterName
                    filterFunctionLabel
                        filterFunction
                    filterTypeLabel
                        filterType
                    filterFrequenciesLabel
                        lowFrequency
                        highFrequency
                    filterOrderLabel
                        filterOrder
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
            
            %text field to enter acquisition frequency
            this.timingPanel = uipanel(this.menuPanel, 'Title', 'Timing',...
                'BackgroundColor', 'white', 'Position', [0 19/30 1 1/30]);
            this.frequencyAcquisition = uicontrol(this.timingPanel, 'Style',...
                'edit', 'Units', 'normalized', 'tooltip', 'Frequency of Acquisition',...
                'Position', [0 0 1 1]);
            
            %create, modify, and remove filters
            this.filters = {};
            this.filterNames = {};
            this.defaultFilterString = 'Press "+" to make a new filter';
            avaialableFilterFunctions = {'butter'};
            availableFilterTypes = {'bandpass', 'stop', 'high', 'low'};
            this.filterPanel = uipanel(this.menuPanel, 'Title', 'Filters (filtfilt)',...
                'Fontsize', 12, 'BackgroundColor', 'white', 'Position',...
                [0 14/30 1 5/30]);
            this.addFilter = uicontrol(this.filterPanel, 'Style',...
                'pushbutton', 'String', '+', 'Fontsize', 10,...
                'BackgroundColor', 'white', 'Units', 'normalized',...
                'Position', [1/2 5/6 1/4 1/6], 'callback', @(src, event)...
                createFilter(this));
            this.removeFilter = uicontrol(this.filterPanel, 'Style',...
                'pushbutton', 'String', '-', 'Fontsize', 10,...
                'BackgroundColor', 'white', 'Units', 'normalized',...
                'Position', [3/4 5/6 1/4 1/6], 'callback', @(src,event)...
                removeSelectedFilter(this));
            this.filterSelection = uicontrol(this.filterPanel, 'Style', 'popupmenu',...
                'String', {this.defaultFilterString}, 'Fontsize', 10, 'Units',...
                'normalized', 'Position', [0 5/6 1/2 1/6], 'callback',...
                @(src,event) filterData(this));
            %this stuff appears as you add a filter
            this.filterNameLabel = uicontrol(this.filterPanel, 'Style',...
                'text', 'BackgroundColor', 'white', 'String' , 'Name:',...
                'Fontsize', 10, 'Units', 'normalized', 'Position',...
                [0 2/3 1/3 1/6]);
            this.filterName = uicontrol(this.filterPanel, 'Style', 'edit',...
                'BackgroundColor', 'white', 'Fontsize', 10, 'Units',...
                'normalized', 'Position', [1/3 2/3 2/3 1/6], 'enable', 'off',...
                'callback', @(src,event) enableFilterOptions(this));
            this.filterFunctionLabel = uicontrol(this.filterPanel, 'Style',...
                'text', 'BackgroundColor', 'white', 'String',...
                'Function:', 'Fontsize', 10, 'Units',...
                'normalized', 'Position', [0 1/2 1/3 1/6]);
            this.filterFunction = uicontrol(this.filterPanel, 'Style',...
                'popupmenu', 'BackgroundColor', 'white', 'String',...
                avaialableFilterFunctions, 'Fontsize', 10, 'Units',...
                'normalized', 'Position', [1/3 1/2 2/3 1/6], 'enable', 'off');
            this.filterTypeLabel = uicontrol(this.filterPanel, 'Style',...
                'text', 'BackgroundColor', 'white', 'String', 'Type:',...
                'Fontsize', 10, 'Units', 'normalized', 'Position',...
                [0 1/3 1/3 1/6]);
            this.filterType = uicontrol(this.filterPanel, 'Style',...
                'popupmenu', 'BackgroundColor', 'white', 'String',...
                availableFilterTypes, 'FontSize', 10, 'Units', 'normalized',...
                'Position', [1/3 1/3 2/3 1/6], 'enable', 'off', 'Callback',...
                @(src, event) selectFilterType(this));
            this.filterOrderLabel = uicontrol(this.filterPanel, 'Style',...
                'text', 'BackgroundColor', 'white', 'String', 'Order:',...
                'FontSize', 10, 'Units', 'normalized', 'Position',...
                [0 1/6 1/3 1/6]);
            this.filterOrder = uicontrol(this.filterPanel, 'Style', 'edit',...
                'BackgroundColor', 'white', 'FontSize', 10, 'Units',...
                'normalized', 'Position', [1/3 1/6 2/3 1/6], 'enable', 'off');
            this.filterFrequenciesLabel = uicontrol(this.filterPanel,...
                'Style', 'text', 'BackgroundColor', 'white', 'FontSize', 10,...
                'Units', 'normalized', 'Position', [0 0 1/3 1/6], 'String',...
                'Frequencies:');
            this.lowFrequency = uicontrol(this.filterPanel, 'Style', 'edit',...
                'BackgroundColor', 'white', 'FontSize', 10, 'Units',...
                'normalized', 'Position', [1/3 0 1/3 1/6], 'tooltip',...
                'lower frequency', 'enable', 'off');
            this.highFrequency = uicontrol(this.filterPanel, 'Style', 'edit',...
                'BackgroundColor', 'white', 'FontSize', 10, 'Units',...
                'normalized', 'Position', [2/3 0 1/3 1/6], 'tooltip',...
                'higher frequency', 'enable', 'off');
            
            
            %%%%%%%%%%%%%%%%%%%%%
            %%%% Plots Panel %%%%
            %%%%%%%%%%%%%%%%%%%%%
            %a plots panel at the right side of the gui
            this.plotsPanel = uipanel('Title', 'Plots', 'FontSize', 10, ...
                'BackgroundColor', 'white', 'Position', [1/4 0 3/4 1]);
            
            %given a refesh button at the top left of the plot panel
            this.refresh = uicontrol(this.plotsPanel, 'Style', 'pushbutton',...
                'FontSize', 10, 'BackgroundColor', 'white', 'String',...
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
        function removeSelectedTask(this)
            this.tasks = popupmenuTools.removeItem(this.taskSelection,...
                this.tasks, get(this.taskSelection, 'Value'),...
                this.defaultTaskMessage);
        end
        %When the user clicks the remove electrode button
        function removeSelectedElectrode(this)
            this.electrodes = popupmenuTools.removeItem(this.electrodeSelection,...
                this.electrodes, get(this.electrodeSelection, 'Value'),...
                this.defaultElectrodeMessage);
        end
        
        %When refresh is clicked
        function refreshPlots(this)
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
                    rethrow(ME);
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
            catch ME
                %if there is an error
                if(~strcmp(ME.identifier, ''))
                    wrn = warndlg({'Could not plot data'; ME.message;...
                        ME.cause; 'Trace'; StructStrings.expand(ME.stack)});
                    waitfor(wrn);
                    rethrow(ME);
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
                success = 1;
            end
        end
        
        %Given the user clicks the plus next to the filter list
        function createFilter(this)
            %if the user has already set the filter options
            if(strcmp(get(this.filterName, 'enable'), 'on')) 
                %add the filter to the list of filters
                newFilter = Filters('name', get(this.filterName, 'String'),...
                    'filtFunction', popupmenuTools.selectedItem(this.filterFunction),...
                    'filtType', popupmenuTools.selectedItem(this.filterType),...
                    'order', str2double(get(this.filterOrder, 'String')),...
                    'frequencies',[str2double(get(this.lowFrequency, 'String'))...
                    str2double(get(this.highFrequency, 'String'))], 'facq',...
                    str2double(get(this.frequencyAcquisition, 'String')));
                filterString = newFilter.getName;
                this.filters{end+1} = newFilter;
                this.filterNames{end+1} = filterString;
                set(this.filterSelection, 'String', this.filterNames);
            %if the user has not set the filter options
            else
                %enable an edit for the filter name
                set(this.filterName, 'enable', 'on');
                %focus on the filter name
                UiControlTools.setFocus(this.filterName);
            end
        end
        
        function selectFilterType(this)
            switch popupmenuTools.selectedItem(this.filterType)
                    case {'high','low'}
                        set(this.highFrequency, 'enable', 'off');
                    otherwise
                        set(this.highFrequency, 'enable', 'on');
                        set(this.lowFrequency, 'enable', 'on');
            end
        end
        
        %Given the enters text in the filter name field
        function enableFilterOptions(this)
            %If the user pressed enter or there is text in the filter name
            if (get(this.eegFigHandle, 'currentcharacter') == 13 &&...
                    ~isempty(get(this.filterName, 'String')))
                %Then enable a dropdown of filter functions, types, order, and
                %frequencies
                set(this.filterFunction, 'enable', 'on');
                set(this.filterType, 'enable', 'on');
                set(this.filterOrder, 'enable', 'on');
                set(this.lowFrequency, 'enable', 'on');
                set(this.highFrequency, 'enable', 'on');
                %Then move focus to the filter function dropdown
                UiControlTools.releaseFocus(this.filterName);
                UiControlTools.setFocus(this.filterFunction);
            end
        end
        
        %Given the user clicks the minus next to the filter list
        function removeSelectedFilter(this)
            [this.filterNames, this.filters] = popupmenuTools.removeItem(...
                this.filterSelection, this.filterNames, this.filters,...
                get(this.filterSelection, 'Value'), this.defaultFilterString);
        end
        
        function filterData(this)
            %if a filter is selected
            if(~strcmp(get(this.filterSelection, 'String'),...
                    this.defaultFilterString))
                currentFilter = popupmenuTools.selectedItem(...
                    this.filterSelection,this.filters);
                startChannel = str2double(get(this.firstDomain, 'String'));
                endChannel = str2double(get(this.lastDomain, 'String'));
                this.data(startChannel:endChannel, :) = Filters.zeroPhaseFilt(...
                    currentFilter, this.data(startChannel:endChannel, :));
            else
                warndlg('You must create a filter first');
            end
        end
    end
end

