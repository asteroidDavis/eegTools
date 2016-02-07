%max in steps
%find every value between max and 0 in steps
%return the indices in a cell array
    %step -> [minTime maxTime]
%remove any overlapping cells
    
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