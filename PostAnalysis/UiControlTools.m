classdef UiControlTools
    %UiContolTools Module for some uicontrol functions matlab should
    %include
    %   setFocus(uiObj)
    %   releaseFocus(uiObj)
    
    properties
    end
    
    methods(Static)
        %Given a uicontrol
        function setFocus(uiObj)
            if(isa(uiObj, 'matlab.ui.control.UIControl'))
                %focus on the object
                uicontrol(uiObj);
            else
                error(['Can"t focus on type: ' class(uiObj)]);
            end
        end
        
        function releaseFocus(uiObj)
            if(isa(uiObj, 'matlab.ui.control.UIControl'))
                if(strcmp(get(uiObj, 'enable'), 'on'))
                    set(uiObj, 'enable', 'off');
                    drawnow;
                    set(uiObj, 'enable', 'on');
                else
                    set(uiObj, 'enable', 'on');
                    drawnow;
                    set(uiObj, 'enable', 'off');
                end
            else
                error(['Can"t release focus on type: ' class(uiObj)]);
            end
        end
    end
end

