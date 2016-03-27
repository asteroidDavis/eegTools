classdef Filters < handle
    %Filters -Filters from EegGui's filter panel
    %   
    
    properties(Access = private)
        name
        filtFunction
        filtType
        order
        %the frequencies for the filter
        frequencies
        normalizedFrequencies
        facq
        %the filter function
        bDesign
        aDesign
    end
    
    methods(Access = public)
        function this = Filters(varargin)
            
            %parese parameters
            options = struct('name', 'NA', 'filtFunction', 'NA', 'filtType',...
                'NA', 'order', 0, 'frequencies', [], 'facq', 0);
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
            
            this.normalizedFrequencies = this.frequencies./this.facq;
            
            %set up the filter function
            switch this.filtFunction
                %implements butterworth iir filters
                case 'butter',
                    switch this.filtType
                        %butterworth iir bandpass filter
                        case 'bandpass',
                           [this.bDesign, this.aDesign] = butter(this.order,...
                               this.normalizedFrequencies, this.filtType);
                        %butterworth irr bandstop filter
                        case 'stop', 
                            [this.bDesign, this.aDesign] = butter(this.order,...
                               this.normalizedFrequencies, this.filtType);
                        %butterworth iir highpass filter
                        case 'high',
                            [this.bDesign, this.aDesign] = butter(this.order,...
                                this.normalizedFrequencies(1),...
                                this.filtType);
                        %butterworth iir lowpass filter
                        case 'low', 
                            [this.bDesign, this.aDesign] = butter(this.order,...
                                this.normalizedFrequencies(1),...
                                this.filtType);
                        otherwise
                            error('%s is not implemented', this.filtType);
                    end
                otherwise
                    error('%s is not implemented or not a filter method',...
                        this.filtFunction);
            end
        end
    end
    
    methods(Access = public)
        %Getters and setters
        function name = getName(this)
            name = this.name;
        end
        function setName(this, name)
            this.name = name;
        end
        function filtFunction = getFiltFunction(this)
            filtFunction = this.filtFunction;
        end
        function setFiltFunction(this, filtFunction)
            this.filtFunction = filtFunction;
        end
        function filtType = getFiltType(this)
            filtType = this.filtType;
        end
        function setFiltType(this, filtType)
            this.filtType = filtType;
        end
        function order = getOrder(this)
            order = this.order;
        end
        function setOrder(this, order)
            this.order = order;
        end
        function frequencies = getFrequencies(this)
            frequencies = this.frequencies;
        end
        function setFrequencies(this, frequencies)
            this.frequencies = frequencies;
        end
        function normalizedFrequencies = getNormalizedFrequencies(this)
            normalizedFrequencies = this.normalizedFrequencies;
        end
        function setNormalizedFrequencies(this, normalizedFrequencies)
            this.normalizedFrequencies = normalizedFrequencies;
        end
        function facq = getFacq(this)
            facq = this.facq;
        end
        function setFacq(this, facq)
            this.facq = facq;
        end
        function bDesign = getBDesign(this)
            bDesign = this.bDesign;
        end
        function setBDesign(this, bDesign)
            this.bDesign = bDesign;
        end
        function aDesign = getADesign(this)
            aDesign = this.aDesign;
        end
        function setADesign(this, aDesign)
            this.aDesign = aDesign;
        end
    end
    
    methods(Static)
        %given data and a digital filter
        function data = zeroPhaseFilt(filt, data)
            %filtfilt the data
            for i = 1:length(data(:,1))
               data(i,:) = filtfilt(filt.bDesign, filt.aDesign, data(i, :)); 
            end
        end
    end
    
end


