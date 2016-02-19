classdef Steps
    %Steps Module for various step functions
    %   isStep(testee) - checks if testee is a step object
    %   isSteps(testee) - checks if testee is an array of step objects
    
    %the fields a step would have if it were a class
    properties(Access = private)
        startTime
        endTime
    end
    
    methods(Static)
        function isStep = isStep(testee)
            %checks if all the data types match a steps data types
            isStep = isstruct(testee) && isnumeric(testee.startTime) &&...
                    isnumeric(testee.endTime);
            %ensures the step has an increasing time vector
            isStep = isStep && (testee.startTime < testee.endTime);
        end
        
        function isSteps = isSteps(testee)
            %checks if its an array
            isSteps = ismatrix(testee);
            %checks if every element of testee is a step
            for test = testee
                isSteps = Steps.isStep(test);
            end
        end
    end
    
end

