classdef EegGui < handle
    %EegGui Provides a gui for loading data, filtering, 
    %   Detailed explanation goes here
    
    properties(Access = private)
        %the figure handle containing controls and plots
        eegFigHandle
        %The panel containing plots
        
        %the panel containing controls
        menuPanel
        
    end
    
    methods(Access = private)
        %When the figure is resized
        %Then resiz the panels within the figure
        function success =  resizeFig(hObject)
            figWidth = this.eegFigHandle.Position(3);
            figHeight = this.eegFigHandle.Position(4);
            
            success = 1;
        end
        
        %class deconstructor - handles the cleaning up of the class &
        %figure. Either the class or the figure can initiate the closing
        %condition, this function makes sure both are cleaned up
        function Close_fcn(this)
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(this.eegFigHandle.figure1,  'closerequestfcn', '');
            %delete the figure
            delete(this.eegFigHandle.figure1);
            %clear out the pointer to the figure - prevents memory leaks
            this.eegFigHandle = [];
        end
    end
    
    methods(Access = public)
        %constructs the gui
        function this = EegGui()
            %extends handdle
            this.eegFigHandle = guihandles();
            
            %puts a menue panel at the left side of the gui
            this.menuPanel = uipanel(this.eegFigHandle, 'Title', 'controls',...
                'FontSize', 11, 'BackgroundColor', 'white', 'Position',...
                [0 0 100 100]);
            
            set(this.eegFigHandle.figure1,  'closerequestfcn', @(src,event) Close_fcn(this));
        end
    end
    
end

