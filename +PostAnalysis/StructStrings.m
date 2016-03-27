classdef StructStrings
    %StructStrings Some tools for string manipulation of structs
    %   expand(struct) - returns a string containing new line seperated
    %       fields of the struct or struct array
    
    properties
    end
    
    methods(Static)
        %expands the contents of the struct into a string
        function contents = expand(container)
            contents = '';
            for i = 1:length(container)
                fields = fieldnames(container);
                for field = 1:length(fields)
                    if(strcmp(class(container(i).(fields{field})),'double'))
                        contents = [contents fields{field} ': '...
                            num2str(container(i).(fields{field}))...
                            SysText.newLine];
                    else
                        contents = [contents fields{field} ': '...
                            container(i).(fields{field}) SysText.newLine];
                    end
                end
                contents = [contents SysText.newLine];
            end
        end
    end
    
end

