classdef Filters
    %Filters -Filters from EegGui's filter panel
    %   
    
    properties(Access = private)
        name
        filtFunction
        filtType
        order
        %the frequencies for the filter
        frequencies
        facq
        %the filter function
        filterDesign
        %the filt filt zero phase filter
        dFilter
    end
    
    methods(Access = public)
        function this = Filters(varargin)
            
            %parese parameters
            options = struct('name', 'NA', 'filtFunction', 'NA', 'filtType',...
                'NA', 'order', 0, 'frequencies', [], 'facq', facq);
            optionNames = fieldnames(options);
            
            %when there are the appropriate number of parameters
            if(length(varargin) ~= 12)
                error('Bad parameters to Filters');
            end
            
            %Given name value pairs of args
            for pair = reshape(varargin, 2, [])
                paramName = pair{1};
                
                %when a param name matches the defined param names
                if(any(strcmp(paramName, optionNames)))
                    this.(paramName) = pair{2};
                else
                    error('Bad param %s', paramName);
                end
            end
            
            %set up the filter function
            switch this.filtFunction
                %implements butterworth iir filters
                case 'butter',
                    switch this.filtType
                        %butterworth iir bandpass filter
                        case 'bandpass',
                            this.filterDesign = designfilt('bandpassiir',...
                                'FilterOrder', this.order,...
                                'PassbandFrequency1', this.frequencies(1),...
                                'PassbandFrequency2', this.frequencies(2),...
                                'SampleRate', this.facq, 'DesignMethod',...
                                this.filtFunction);
                        %butterworth irr bandstop filter
                        case 'stop', 
                            this.filterDesign = designfilt('bandstopiir',...
                                'FilterOrder', this.order,...
                                'PassbandFrequency1', this.frequencies(1),...
                                'PassbandFrequency2', this.frequencies(2),...
                                'SampleRate', this.facq, 'DesignMethod',...
                                this.filtFunction);
                        %butterworth iir highpass filter
                        case 'high',
                            this.filterDesign = designfilt('highpassiir',...
                                'FilterOrder', this.order,...
                                'PassbandFrequency', this.frequencies(2),...
                                'SampleRate', this.facq, 'DesignMethod',...
                                this.filtFunction);
                        %butterworth iir lowpass filter
                        case 'low', 
                            this.filterDesign = designfilt('lowpassiir',...
                                'FilterOrder', this.order,...
                                'PassbandFrequency', this.frequencies(1),...
                                'SampleRate', this.facq);
                        otherwise
                            error('%s is not implemented', this.filtType);
                    end
                otherwise
                    error('%s is not implemented or not a filter method',...
                        this.filtFunction);
            end
        end
    end
    
    methods(Static)
        %given data and a digital filter
        function data = zeroPhaseFilt(digitalFilt, data)
            %filtfilt the data
            for i = 1:length(data)
               data(i) = filtfilt(digitalFilt, data(i)); 
            end
        end
    end
    
end

