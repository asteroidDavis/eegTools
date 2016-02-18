classdef EegGui < handle
    %EegGui Provides a gui for loading data, filtering, 
    %   Detailed explanation goes here
    
    properties(Access = private)
        %the figure handle containing controls and plots
        eegFigHandle
        %The panel containing plots
        plotsPanel
        
        %the panel containing controls
        menuPanel
            dataSelectionPanel
                dataChoice
                    fileData
                    realTimeData
                dataPath
            tasksPanel
                tasksSelectionText
                taskSelection
                tasks
                defaultTaskMessage
                addTask
                removeTask
                electrodesSelectionText
                electrodeSelection
                stepsPerPlotText
                stepsPerPlot
        
    end
    
    methods(Access = private)
        
        %When the user clicks the + next to 'Tasks'
        function success = toggleTaskSelection(this)
            %And the task selection field is a dropdown
            if(strcmp(get(this.taskSelection, 'Style'), 'popupmenu') == 1)
                %Then the task selection field becomes editable text
                this.taskSelection = uicontrol(this.tasksPanel, 'Style',...
                    'edit', 'FontSize', 10, 'Units', 'normalized',...
                    'Position', [0 2/3 1 1/6]);
                disp('Toggled');
                success = 1;
            %Or the task selection field is editable text
            elseif(strcmp(get(this.taskSelection, 'Style'), 'edit') == 1)
                this.tasks{end+1} = get(this.taskSelection, 'String');
                %And the user added tasks
                if(size(this.tasks) >= 1)
                    %display a task selector with the added tasks
                    this.taskSelection = uicontrol(this.tasksPanel, 'Style',...
                        'popupmenu', 'FontSize', 10, 'Units', 'normalized',...
                        'Position', [0 2/3 1 1/6], 'String', this.tasks);
                else
                    %display the default task selector
                    this.taskSelection = uicontrol(this.tasksPanel, 'Style',...
                        'popupmenu', 'FontSize', 10, 'Units', 'normalized',...
                        'Position', [0 2/3 1 1/6],...
                        'String', {this.defaultTaskMessage});
                end
                success = 1;
            else
                warning(strcat('Task Selector: taskSelection is type: ',...
                    get(this.taskSelection, 'Style'), '. \nResetting to ',...
                    'popupmenu.'));
                success = 0;
            end
        end
        
    end
    
    methods(Access = public)
        %constructs the gui
        function this = EegGui()
            %extends figure
            this.eegFigHandle = figure('Visible', 'off', 'Tag', 'fig',...
                'Units', 'characters');
            
            %puts a menue panel at the left side of the gui
            this.menuPanel = uipanel('Title', 'Controls', 'FontSize', 11,...
                'BackgroundColor', 'white', 'Position', [0 0 1/3 1]);
            
            %given a data selection panel
            this.dataSelectionPanel = uipanel(this.menuPanel,...
                'Title', 'Data Selection', 'FontSize', 10,... 
                'BackgroundColor', 'white', 'Position', [0 4/5 1 1/5]);
            %Given radio buttons to select source of data
            this.dataChoice = uibuttongroup(this.dataSelectionPanel, ...
                'Position', [0 1/2 1 1/2]);
            %radio button for data from a file
            this.fileData = uicontrol(this.dataChoice, 'Style',...
                'radiobutton', 'String', 'File', 'Units', 'normalized',...
                'Position', [0 0 1/2 1]);
            %radio button for selecting real time data
            this.realTimeData = uicontrol(this.dataChoice, 'Style',...
                'radiobutton', 'String', 'real-time', 'Units',...
                'normalized', 'Position', [1/2 0 1/2 1]);
            %text field for entering file paths or i/o description
            this.dataPath = uicontrol(this.dataSelectionPanel, 'Style',...
                'edit', 'Units', 'normalized', 'Position', [0 0 1 1/2]);
            
            %controls data about each task
            this.tasksPanel = uipanel(this.menuPanel, 'Title', 'Task Info',...
                'FontSize', 11, 'BackgroundColor', 'white', 'Position',...
                [0 2/5 1 2/5]);
            %labels the task selection area
            this.tasksSelectionText = uicontrol(this.tasksPanel, 'Style', 'text',...
                'String', 'Tasks', 'FontSize', 10, 'Units', 'normalized',... 
                'BackgroundColor', 'white', 'Position', [0 5/6 1/2 1/6]);
            %provides a menu to add tasks
            this.addTask = uicontrol(this.tasksPanel, 'Style', 'pushbutton',...
                'Fontsize', 10, 'BackgroundColor', 'white', 'String', '+',...
                'Units', 'normalized', 'Position', [1/2 5/6 1/4 1/6],...
                'Callback', @(src, event) toggleTaskSelection(this));
            %provides a drop down or editable text for adding task labels
            this.defaultTaskMessage = 'Press + to add tasks';
            this.tasks = {};
            this.taskSelection = uicontrol(this.tasksPanel, 'Style',...
                'popupmenu', 'FontSize', 10, 'Units', 'normalized',...
                'Position', [0 2/3 1 1/6], 'String',...
                {this.defaultTaskMessage});

            
            %a plots panel at the right side of the gui
            this.plotsPanel = uipanel('Title', 'Plots', 'FontSize', 10, ...
                'BackgroundColor', 'white', 'Position', [1/3 0 2/3 1]);
            
        
            
            %makes the figure visible once everything is added
            this.eegFigHandle.Visible = 'on';
        end
    end
end

