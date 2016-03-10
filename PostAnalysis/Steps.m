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
        
        %extracts the sample indexes for each step in a channel
        function [stepTime] = stepExtract(steps)
            stepCount = steps(end);
            for step = 0:stepCount
               stepStart = find(steps == step, 1 );
               stepEnd = find(steps == step, 1, 'last' );
               stepTime{step+1} = [stepStart stepEnd];
            end
            %corrects errors caused by the first number in steps being
            %unpredictable
            previousStep = -1;
            index = 1;
            for step = stepTime
                %initializes the previous cell the first time through
                if isa(previousStep, 'numeric')
                    previousStep = step;
                %checks if the cells overlap
                elseif step{1}(1) < previousStep{1}(2)
                    %removes the overlapping section from the greater cell
                    stepTime{index}(1) = previousStep{1}(2)+1;
                    previousStep = step;
                end
                index = index + 1;
            end    

        end
    end
    
end

