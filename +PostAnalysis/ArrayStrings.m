classdef ArrayStrings
    %ArrayStrings Some tools for string manipulation of arrays
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        %retruns a string containing the size in each dimensio of matrix a
        function lengths  = lengthDisp(a)
            lengths = '';
            switch ndims(a)
                case 1,lengths = length(a);
                case 2,...
                    for i = 1:size(a)
                        lengths = [lengths num2str(i) ': ' num2str(length(a(i,:))),... 
                            SysText.newLine];
                    end
                otherwise, errordlg(strcat('lengthDisp is not implemented',... 
                        'for matrix of ndim = ', ndims(a)));
                    
            end
        end
    end
    
    
end

