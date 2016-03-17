classdef popupmenuTools
    %popupmenuTools - A module for popupmenuActions I perform often
    %   removeItem(popupmenu, removalIndex, defaultMessage)
    %       removes the item at removal index from the popupmenu. If the 
    %       popupmenu is empty after the item is removed the defaultMessage 
    %       put in the first index
    
    properties
    end
    
    methods(Static)
        function testResult = isPopupmenu(testee)
            testResult = strcmp(get(testee, 'Style'), 'popupmenu');
        end
        
        %given a popupmenu with choices list
        function [itemNames, items] = removeItem(menu, itemNames, varargin)
            %if the items are only strings
            if(nargin == 4)
                index = varargin{1};
                defaultMessage = varargin{2};
            %if items are item, name pairs
            elseif(nargin == 5)
                items = varargin{1};
                index = varargin{2};
                defaultMessage = varargin{3};
                
                items{index} = [];
                items = items(~cellfun(@isempty, items));
            end
            %If this is not a popup
            if(popupmenuTools.isPopupmenu(menu) == 0)
                error(['Can"t removeItem from object of type: ' class(menu)...
                    ' Object must be a popupmenu']);
            end
            initialIndex = get(menu, 'Value');
            %When removing from a popup with more than one item
            if(length(itemNames) > 1)
                %remove the item at index
                itemNames{index} = [];
                itemNames = itemNames(~cellfun(@isempty, itemNames));
                %if removing the current index
                if(index == initialIndex && index ~= 1)
                    %set the selected index one earlier
                    set(menu, 'String', itemNames, 'Value', initialIndex-1);
                else
                    %don't worry about the selected index
                    set(menu, 'String', itemNames);
                end
            %if there's only one item in the menu
            else
                itemNames = {};
                %set the popupmeny to the default prompr popupmenu
                set(menu, 'String', defaultMessage);
            end
        end
        
        %item is the current item selected in the popupmenu
        function item = selectedItem(varargin)
            switch length(varargin)
                case 1,...
                    menu = varargin{1};
                    items = get(menu, 'String');
                    item = items{get(menu, 'Value')};
                case 2,...
                    itemNames = varargin{1};
                    items = varargin{2};
                    index = get(itemNames, 'Value');
                    item = items{index};
                otherwise,
                    error('Bad params');
            end
        end
    end
    
end

