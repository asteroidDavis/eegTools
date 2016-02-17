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
        
    end
    
    methods(Access = private)
        %When the figure is resized
        %Then resize the panels within the figure
        function success =  resizeUI(this)
            %gets the current figure position array
            outerPosition = this.eegFigHandle.OuterPosition;
            figWidth = outerPosition(3);
            figHeight = outerPosition(4);
            
            success = 1;
        end
        
    end
    
    methods(Access = public)
        %constructs the gui
        function this = EegGui()
            %extends figure
            this.eegFigHandle = figure('Visible', 'off', 'Tag', 'fig',...
                'SizeChangedFcn', @(src, event) resizeUI(this), 'Units', ...
                'characters');
            
            %puts a menue panel at the left side of the gui
            this.menuPanel = uipanel('Title', 'Controls', 'FontSize', 11,...
                'BackgroundColor', 'white', 'Position', [0 0 1/3 1]);
            
            this.plotsPanel = uipanel('Title', 'Plots', 'FontSize', 10, ...
                'BackgroundColor', 'white', 'Position', [1/3 0 2/3 1]);
            
            %makes the figure visible once everything is added
            this.eegFigHandle.Visible = 'on';
        end
    end
end

