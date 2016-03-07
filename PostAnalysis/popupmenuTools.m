classdef popupmenuTools
    %popupmenuTools - A module for popupmenuActions I perform often
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        %given a popupmenu with choices list
        function [menu, list] = removeItem(menu, list)
            %And the initial list position
            position = get(menu, 'Value');
            %empty the content at position
            list{position} = [];
            %reduce the size of list by filtering empty positions
            list = list(~cellfun(@isempty, list));
            %put the modified list in the popup 
            %and move the position up one
            set(menu, 'String', list, 'Value', position-1);
        end
    end
    
end

