function [ success ] = plotTasksInChannels( y, stepTimes, Facq, yChanNames,...
    taskNames, xALabel, title )
%plotTasksInChannels: plots each channel in a subplot with different
%colored tasks.

Fn = Facq/2;

figure;
set(gcf, 'Position', [100, 100, 1049, 895], 'numbertitle', 'off',...
        'name', title);
%for each electrode    
for i = 1:size(y,1)
    %uses a new plot for each electrode
    subplot(8, 1, i);
    
    %for each task
    for step=stepTimes
        %the number of measurments in each step
        stepLength = length(step{1}(1):step{1}(2));
        %determines the max frequency domain for each task
        F = -Fn+Facq/stepLength:Facq/stepLength:Fn;
        
        plot(F, y(i, step{1}(1):step{1}(2)));
        hold on;
    end
    xlim([0 Fn]);
    xlabel(xALabel);
    ylabel(yChanNames{i});
end
legend(taskNames, 'Location', 'bestoutside');
