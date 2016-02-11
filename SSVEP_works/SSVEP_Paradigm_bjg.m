function [sys,x0,str,ts] = PSU_Acquire_151125(t,x,u,flag,COMPort,SPS)
% 1999-2006 g.tec medical engineering GmbH
% 12/25 put case 2 into case 3
% removed start button

global handles s control


basecmd = zeros([27 1],'uint8');

switch flag
    
    
    
    
    
    case 3  % Calculates the outputs of the S-function
        
        % change the flash piece
           dPhase = mod(u(1)*t,1);
           stateNow = dPhase<u(2);
           bStateChanged = (stateNow~=control.bFlashState);
           if bStateChanged
               if stateNow
                    outputSingleScan(control.Sdaq,0);%control.Sdaq
               else
                    outputSingleScan(control.Sdaq,1);%control.Sdaq
               end
               control.bFlashState = stateNow;
           end
           % 3) if moved or state changed, redraw
           control.FlashState = -1 + 2*stateNow;
                      


        
        % Now read data: First look to see if data is available
        control.iBA = get(s,'BytesAvailable');
        while (control.iBA<control.BPS)
            control.iBA = get(s,'BytesAvailable');
        end

        
        control.eegdata=fread(s,control.BPS,'uint8');
        
        %Do two's complement
        
%            control.channeldata = (bitshift(control.eegdata(control.HB),16)+bitshift(control.eegdata(control.MB),8)+control.eegdata(control.LB)-control.offset)*control.scaling;
            control.channeldata32 = (bitshift(control.eegdata(control.HB),16)+bitshift(control.eegdata(control.MB),8)+control.eegdata(control.LB));
            for index = 1:8
                Sdata = dec2bin(control.channeldata32(index),24);
                concatS = [Sdata([1 1 1 1 1 1 1 1]) Sdata];
                control.channeldata(index) = control.scaling*(typecast(uint32(bin2dec(concatS)),'int32'));
                % use twos complement  if (msb = bitshift(x, -(numBits - 1) )) then value=-1* ( bitcmp(x, numBits) + 1 ) else value=x;

%                     if ( bitshift(control.channeldata32(index), -23 )==1)
%                        % control.channeldata(index) = control.scaling*control.channeldata32(index);
%                        % control.channeldata(index) = -control.scaling*(1.0*bitcmp(control.channeldata32(index)+control.bAddIt,'uint32')+1);
%                        % note that compliment of an unsigned integer is equal
%                        % to the value subtracted from it's maximum
%                         control.channeldata(index) = -control.scaling*(1.0*intmax('uint32')-1.0*control.channeldata32(index)+1);
%     %                   control.channeldata(index) = -(bitshift(bitcmp(bitshift(control.channeldata32(index),8),'int32'),-8) + 1 );
%     %                   control.channeldata(index) = -control.scaling*(bitshift(bitcmp(bitshift(control.channeldata32(index),8),'int32'),-8) + 1 );
%                     else
%                         %control.channeldata(index) = control.scaling*control.channeldata32(index);
%                         control.channeldata(index) = control.scaling*control.channeldata32(index);
%                     end
            end
%            control.channeldata = control.channeldata32*control.scaling;
            %
            %                 temp=control.counter;
            control.counter=bitshift(control.eegdata(1),16)+bitshift(control.eegdata(2),8)+control.eegdata(3);
            control.Reg    =bitshift(control.eegdata(4),16)+bitshift(control.eegdata(5),8)+control.eegdata(6);
            
            %             if (temp-control.counter>1)
            %                 error('Packet drop event occured');
            %             end
            
            
            %control.status=(bitshift(control.eegdata(4),16)+ bitshift(control.eegdata(5),8)+control.eegdata(6))/control.scaling;
            %
            %             if  (control.eegdata(5)||control.eegdata(6) )
            %                 error('Some channels may not be working correctly');
            %             end
            %
            
            
%         else
%             
%             control.channeldata = (bitshift(control.eegdata(control.HB),16)+bitshift(control.eegdata(control.MB),8)+control.eegdata(control.LB)-control.offset)*control.scaling;
%             %
%             %                 temp=control.counter;
%             control.counter=bitshift(control.eegdata(1),16)+bitshift(control.eegdata(2),8)+control.eegdata(3);
%             %                     %
%             %                     %                 %             if (temp-control.counter>1)
%             %                     %                 %                 error('Packet drop event occured');
%             %                     %                 %             end
%             %                     %
%             %                     %
%             %                     control.status=(bitshift(control.eegdata(4),16)+ bitshift(control.eegdata(5),8)+control.eegdata(6))/control.scaling;
%             %
%         end
        
            % Output
            sys = [control.FlashState; control.counter; control.Reg; control.channeldata; control.count];
%                sys = [control.counter; control.Reg; control.channeldata; control.count];
                % sys = zeros(11,1);
                %              sys = [handles.outputSTIMULUSCODE;handles.outputTARGET;handles.trialnumber;control.eegdata;handles.count];
                control.count=control.count+1;
                
                
                
        
    case 2

        
    case 0  %Initialization
        %------------------------------------
        % clear the handles object and close
        % the old figure if it is still open
        %------------------------------------
        clear handles;    
        
        clc;
        
%         basecmd = zeros([27 1],'uint8');
%         cmdID = basecmd; cmdID(1)=1;
        cmdInit = basecmd; cmdInit(1)=2;
        cmdSTOP = basecmd; cmdSTOP(1)=3;
        cmdRDATAC = basecmd; cmdRDATAC(1)=4;
        cmdWREG = basecmd; cmdWREG(1)=24;
        cmdRREG = basecmd; cmdRREG(1)=7;
%         cmdSDATAC = basecmd; cmdSDATAC(1)=6;
%         cmdRREG = basecmd; cmdRREG(1)=7;
%         cmdSN = basecmd; cmdSN(1)=17;
        % override the SPS
        SPS = SPS*250;
        
        %------------------------------------
        % Configure serial Port
        %------------------------------------
        s = serial(strcat('COM',num2str(COMPort)));
        set(s, 'BaudRate', 128000, 'StopBits', 1);
        set(s, 'Terminator', 'LF', 'Parity', 'none');
        set(s, 'FlowControl', 'none');
        ipBufSize = 30*SPS; % one second worth of dat
        set(s, 'InputBufferSize',ipBufSize);
        
        
        
        %------------------------------------
        % Initialize handles values  
        %------------------------------------
        control.count = 0;
        
        %------------------------------------
        % Initialize values - needs to be updated for more than 8 channel board  
        %------------------------------------
        control.bTRegs = 1; %% EEG board sends the register values = 1; 
        control.bCounter = 1;
        control.channels=8;
        control.BPS = 3*(control.channels+control.bCounter+control.bTRegs);  %% BPS is BytesPerSample
        control.eegdata=zeros(control.BPS,1,'uint32');
        control.SPS=250;
        control.counter=0;
        control.status=0;
        control.channeldata32=zeros(8,1,'uint32');
        control.channeldata=zeros(8,1,'double');
        
        chans = 0:(control.channels-1);
        control.HB = 3*(control.bTRegs+control.bCounter)+3*chans+1;
        control.MB = 3*(control.bTRegs+control.bCounter)+3*chans+2;
        control.LB = 3*(control.bTRegs+control.bCounter)+3*chans+3;
        control.offset = 2^23;
        control.scaling = 2.4 * 1e6 * 1/(2^23-1);% assumes that 2.4 volts, converted to microvolts, no gain; %1/(2^23-1)*2400000/6;
        
        control.iBA = 0;
        
        % need stuff for SSVEP flashing
        control.FlashState = 0.5;
        control.bFlashState = 0;
        
        display(control);
        
        
        %------------------------------------
        %************************************
        % Open NI device
        %************************************
        %------------------------------------

       
        control.Sdaq = daq.createSession('ni');
        addDigitalChannel(control.Sdaq,'dev1','Port1/Line3','OutputOnly');
        
        display('Opened NI device');

        %------------------------------------
        %************************************
        % Open serial connection
        %************************************
        %------------------------------------
        
        fopen(s);
        
        while  strcmp(s.Status,'closed')
            
            fopen(s);
            
        end
        
        fwrite(s,cmdSTOP);  % if needed stop any acquistion on the board
        
        % flush the com buffer
        
        control.iBA = get(s,'BytesAvailable');
        if (control.iBA~=0)
            bOut = fread(s,control.iBA);
        end
        
        
        fwrite(s,cmdInit); %% initialize the board, recall that this returns 26 bytes of register data
        cow = 0;
        control.iBA = get(s,'BytesAvailable');
        while ( control.iBA<26)
            control.iBA = get(s,'BytesAvailable');
        end
        bOut = fread(s,26);
        %% The values in bOut are the current values of the registers.
        %% we want to change the register values to 
        % set the sampling rate
        % and set the gain
        % Note that for an ADS1299:
        % SPS is held in register 2
        % with map:
        %  REG = 246 SPS = 250
        %  REG = 245 SPS = 500
        %  REG = 244 SPS = 1000
        % Gain are in registers 5-12 (4+channel_number)
        %  RGain =   7  Gain = 1
        %  RGain =  23  Gain = 2
        %  RGain =  71  Gain = 8
        %  RGain =  87  Gain = 12
        %  RGain = 103  Gain = 24
        
        cmdWREG_here = cmdWREG;
        cmdWREG_here(2:end) = bOut;
        cmdWREG_here(1+2) = 246;   % SPS of 250
        cmdWREG_here(1+6:13) = 23; % gain of 2
        fwrite(s,cmdWREG_here); %% initialize the board, recall that this returns 26 bytes of register data
        
        disp ('Device connected');
        
        %------------------------------------
        % Indentification
        %------------------------------------
        % Initialize get Channels
        %        fwrite(s,1),Channels=fread(s,1);
        %
        %        channels=Channels;
        %------------------------------------
        % Program or WREG
        %------------------------------------
        %fwrite(s,2);
        
        
%         switch SPS
%             case 1
%                 cmd=129;
%             case 2
%                 cmd=131;
%             case 3
%                 cmd=133;
%             case 4
%                 cmd=135;
%             case 5
%                 cmd=137;
%                 
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %------------------------------------
        % Do the seting sizes stuff - whatever it might mean
        %------------------------------------
        sizes=simsizes;             %SIMSIZES...utility used to set S-function sizes
        %For example:
        %sizes = simsizes;
        %This returns an uninitialized structure of the form:
        %sizes.NumContStates   Number of continuous states
        %sizes.NumDiscStates   Number of discrete states
        %sizes.NumOutputs      Number of outputs
        %sizes.NumInputs       Number of inputs
        %sizes.DirFeedthrough  Flag for direct feedthrough
        %sizes.NumSampleTimes  Number of sample times
        sizes.NumContStates  = 0;
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs     =   1 + control.bTRegs + control.bCounter + control.channels + 1;
        sizes.NumInputs      = 2; % frequency and duty cycle
        sizes.DirFeedthrough = 1;   %has direct feedthrough
        sizes.NumSampleTimes = 1;
        
        sys=simsizes(sizes);     %After initializing the structure above to fit the
        %specifications of the S-function, SIMSIZES should be called
        %again to convert the structure into a vector that can be
        %processed by Simulink. For example:
        %    sys = simsizes(sizes);
        x0  = [];
        str = [];
        ts  = [1/control.SPS 0];    %inherited sample time run at the same rate
        %as the block to which it is connected

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
        % send command
       
        fwrite(s,cmdRDATAC);
%         fwrite(s,4);
        
        
        
    case 9          %End of simulation tasks
%         cmdID = basecmd; cmdID(1)=1;
%         cmdInit = basecmd; cmdInit(1)=2;
        cmdSTOP = basecmd; cmdSTOP(1)=3;
%         cmdRDATAC = basecmd; cmdRDATAC(1)=4;
%         cmdSDATAC = basecmd; cmdSDATAC(1)=6;
%         cmdRREG = basecmd; cmdRREG(1)=7;
%         cmdSN = basecmd; cmdSN(1)=17;
        fwrite(s,cmdSTOP);  %% if needed stop any acquistion on the board
        fclose(s);
        
        
        
end





