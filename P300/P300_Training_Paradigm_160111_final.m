function [sys,x0,str,ts] = Visual_P300_Training_Paradigm(t,x,u,flag,flashtime,darktime,mode,flashnum,paramode,imagescaling,centerout,cuescale,COMPort,SPS);
% Visual P300 training paradigm
% Displays a circular array of 4 or 8 circular targets and randomly flashes
% them with a given on and off timing.
% For training purposes, the array has a central area with a pointer that
% instructs the user which target to visualize
% For open-loop use, this pointer is not used.
% 
% Note that the target numbers are as follows:
%      4-targets              8 targets
%          1                       1
%                                8   5
%      4       2               4       2
%                                7   6
%          3                       3
%
%  particular input variables include:
%  flashtime
%  darktime
%  flashnum
%  paramode
%  imagescaling
%  centerout

%  Modified significantly from P300SpParadigmSingleChar_gUSBamp_8ch, 1999-2006 g.tec medical engineering GmbH

% global fig handles
global handles s control fig

basecmd = zeros([27 1],'uint8');

switch flag

    case 'New'        % The new Game Button was pressed
        %----------------------------------
        % call the newInit function
        %----------------------------------
        set(gcf,'UserData',handles);    %save the handles object in the figure's UserData
        newInit();
        handles = get(gcf,'UserData');    %load the changes of the newInit function
        %----------------------------------          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % activate the ID-INIT control line
        %Signal Processing Block has to
        %clear the Buffers and start a new
        %initialization.
        %----------------------------------
        
        set(handles.startHndl,'Visible','on');  %show the Start Button
        set(gcf,'UserData',handles);   %save the changes
        return;     %stop this step

    case 'Start'
        handles.newtrial = true;
        handles.trialnumber = 1;    %holds the number of the actual trial
        handles.run = true;     %start the 'translation'
        handles.trialmax = inf; %deleted copy spell mode Eric L.

        set(handles.startHndl,'Visible','off'); %don't show the Start Button

        %displays icons Eric L.
        set(handles.basepic,'Visible','on');                   
        set(gcf,'UserData',handles);    %save changes
        return;     %stop this step
        
    case 'Closefig'
        control.bCloseOut = true;
        
%        set_param([gcs,'/P300 Trainer/StopSimu'],'Gain','1');   %stop the Simulink Simulation
%         set_param([gcs,'/P300 Trainer/StopSimu'],'Gain','0');
%         close(gcf);     %close figure window
             return;     %stop this step
    
    case 2      %Update of discrete states
        
     
        
        if any(get(0,'Children')==fig)   %is fig a 'Child' of the root object?
            if strcmp(get(fig,'Name'),'BCI P300 Circular Target - Single Target Flash'),
                set(0,'currentfigure',fig);  %set fig to the current figure
                handles=get(gcf,'UserData'); %load the handles obejct from UserData
                
                if handles.flashcount >=(handles.numberoftargets *flashnum)
                    handles.stop = 1;
                end
        %-----------------------------
        % Execute the closeout elements
        %-----------------------------
        if control.bCloseOut
            % first stop the flashing
            handles.mode = 1;
            % now decrement the counter
            control.iCloseOutCount = control.iCloseOutCount-1;  
            % now test if we need to initiate stopping the system
            if control.iCloseOutCount==3
                display('closeout=3');
                display(gcs);
                set_param([gcs,'/StopSimu'],'Gain','1');   %stop the Simulink Simulation with a delay of 1
            end
            if control.iCloseOutCount==2
                display('closeout=2');
                display(gcs);
                set_param([gcs,'/StopSimu'],'Gain','0');   %reinitialize it to zero
%                 close(gcf);     %close figure window
            end
            if control.iCloseOutCount==1
                display('closeout=1');
%                display(gcs);
%                 set_param([gcs,'/P300 Trainer/StopSimu'],'Gain','0');   %reinitialize it to zero
                close(gcf);     %close figure window
            end
        end

        %-----------------------------
        % Displays Training Cue Eric L.
        %-----------------------------
        bDoNotDoIfFalse = false;        
                
        if handles.mode == 2
      
            trialnownum = mod(handles.trialnumber,handles.numberoftargets);
            if trialnownum==0
                trialnownum=handles.numberoftargets;
            end
                        
            for trainimage = 1:handles.numberoftargets
                if trainimage == handles.trainset(trialnownum)
                    set(handles.trainnow(trainimage),'visible','on');
                else
                    set(handles.trainnow(trainimage),'visible','off');    
                end    
            end

        end
        if handles.run 

                    if handles.newtrial       %true...the program has to wait
                        handles.newtrial=false; %before starting the next trial
                        handles.waitNextTrial=true;
                        handles.starttimeTrial=t;
      

                        for imagemove = 1:handles.numberoftargets

                            set(handles.picD(imagemove),'x',[handles.circleposition(imagemove,1) + handles.imagexpos + u(1) handles.circleposition(imagemove,1) + handles.imagexpos + handles.picwidth + u(1)],...
                                                        'y',[handles.circleposition(imagemove,2) + handles.imageypos + handles.picheight + u(2) handles.circleposition(imagemove,2) + handles.imageypos + u(2)]);


                            set(handles.picB(imagemove),'x',[handles.circleposition(imagemove,1) + handles.imagexpos + u(1) handles.circleposition(imagemove,1) + handles.imagexpos + handles.picwidth + u(1)],...
                                                        'y',[handles.circleposition(imagemove,2) + handles.imageypos + handles.picheight + u(2) handles.circleposition(imagemove,2) + handles.imageypos + u(2)]);


                            set(handles.trainnow(imagemove),'x',[cuescale*(handles.imagexpos) + u(1) cuescale*(handles.imagexpos+ handles.picwidth) + u(1)],...
                                                            'y',[cuescale*(handles.imageypos+handles.picheight) + u(2) cuescale*(handles.imageypos) + u(2)]);

                        end
                    end
                    if ~handles.waitNextTrial %&& bDoNotDoIfFalse     %false...Trial not ready
                        tDarkLetter = handles.tDarkLetter;
                        tFlash = handles.tFlash;
                        
                        if handles.newrun && handles.stop ~= true
                            handles.newrun = false;
                            handles.starttime = t;  %set the new starttime
                            handles.flashIndex = handles.randarr(handles.k);
                            handles.k = handles.k+1;
                        end
                                    
                        if handles.stop ~= true
                            if t > handles.starttime
                                if handles.draw  %highlight the object, but only once
                                    %-----------------------------
                                    % call the setClearTrigger function
                                    %-----------------------------
                                    set(gcf,'UserData',handles);    %save the handles object
                                    setClearTrigger(handles.flashIndex);     %set Trigger   !!!!!!!!
                                   
                                   
                                    handles = get(gcf,'UserData');  %load the changes of the function
                                    handles.statTrigger = true;
                                    
                                    %flashing pic Eric L.
                                    set(handles.picD(handles.flashIndex),'Visible','off')
                                    set(handles.picB(handles.flashIndex),'Visible','on')
                                    drawnow

                                    handles.draw = false;

                                elseif handles.statTrigger
                                    %-----------------------------
                                    % call the setClearTrigger function
                                    %-----------------------------
                                    set(gcf,'UserData',handles);  %save the handles object
                                    setClearTrigger(0);     %clear Trigger    !!!!!!
                                    handles.statTrigger = false;
                                end
                            end
                        else
                            handles.newrun = false;
                        end
                                                                                   
                        if t > (handles.starttime + tFlash)  %clear the FlashFields
                            if handles.clear

                                %flashing pic Eric L.
                                set(handles.picB(handles.flashIndex),'Visible','off')
                                set(handles.picD(handles.flashIndex),'Visible','on')
                                drawnow

                                handles.clear=false;
                                           
                                if handles.k > handles.numberoftargets
                                    lastelement = handles.randarr(handles.numberoftargets);
                                    handles.randarr(1) = lastelement;
                                    %-------------------------
                                    %random Flash order
                                    %-------------------------
                                    while(handles.randarr(1) == lastelement)
                                        handles.randarr = randperm(handles.numberoftargets);
                                    end
                                    handles.runnumber = handles.runnumber+1;
                                    handles.k = 1;
                                end
                            end
                        end
                                    
                        if t > (handles.starttime + tFlash + tDarkLetter)  % the next Letter will
                                                                           % flash on the screen
                            handles.draw=true;
                            handles.clear=true;
                            handles.newrun=true;    %load the new time into handles.starttime
                            
                            handles.flashcount = handles.flashcount + 1;
                            
                        end
                                            
                        if handles.stop == true
                            handles.newrun = false;

                                %--------------------------------
                                % start new trial
                                %--------------------------------

                                handles.stop = false;
                                handles.newtrial = true;
                                
                                handles.trialnumber = handles.trialnumber+1;
                                handles.flashcount = 0;

                        end
                    else
                        if t>handles.starttimeTrial+handles.trialwaitTime
                            handles.waitNextTrial = false;
                            trialmax = handles.trialmax;
                            copyStrings = handles.copyStrings;
                            correctTrials = handles.correctTrials;
                            wrongTrials = handles.wrongTrials;
                            %-----------------------------
                            % call the newInit function
                            %-----------------------------
                            set(gcf,'UserData',handles);  %save the handles object
                            newInit();
                            handles = get(gcf,'UserData');  %load the changes of the function
                            %----------------------------------
                            %activate the ID-INIT control line
                            % Signal Processing Block has to         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            % clear the Buffers and start a new
                            % initialization.
                            %----------------------------------
                            handles.run = true;
                            handles.trialmax = trialmax;
                            handles.copyStrings = copyStrings;
                            handles.correctTrials = correctTrials;
                            handles.wrongTrials = wrongTrials;
                        end
                    end
        end
                set(gcf,'UserData',handles);     %save changes to UserData of the current figure
            end
        end
        sys=[];

    case 3  % Calculates the outputs of the S-function

       %% Calcuates the output of the P300 
        if any(get(0,'Children')==fig)   %if the figure still exists for example when the
                                         %close button was already pressed.
            handles=get(gcf,'UserData'); %load the handles obejct from UserData

        %% Calculates the outputs of serial port
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
       control.counter=bitshift(control.eegdata(1),16)+bitshift(control.eegdata(2),8)+control.eegdata(3);
       control.Reg    =bitshift(control.eegdata(4),16)+bitshift(control.eegdata(5),8)+control.eegdata(6);
        

%             sys(1) = handles.outputSTIMULUSCODE;
%             sys(2) = handles.outputTARGET;
%             sys(3) = handles.trialnumber;

            sys = [handles.outputSTIMULUSCODE; handles.outputTARGET; handles.trialnumber; control.counter; control.Reg; control.channeldata; control.count];
            control.count = control.count + 1;
            
            handles.outputSTIMULUSCODE = 0;
            handles.outputTARGET = 0;
            set(gcf,'UserData',handles); %save the handles object in the figure's UserData
        end
%         sys(4) = [control.counter; control.Reg; control.data; control.count];
            
    case 0  %Initialization

        %Initialization of comport
        clear handles;
        clc;
        cmdInit = basecmd; cmdInit(1)=2;
        cmdSTOP = basecmd; cmdSTOP(1)=3;
        cmdRDATAC = basecmd; cmdRDATAC(1)=4;
        cmdWREG = basecmd; cmdWREG(1)=24;
        cmdRREG = basecmd; cmdRREG(1)=7;
        SPS = SPS*250;
        %------------------------------------
        %Configure serial port
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
        
        display(control);
        
        %------------------------------------
        % Open serial connection
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
        % clear the handles object and close
        % the old figure if it is still open
        %------------------------------------
        h=findobj('Name','BCI P300 Circular Target - Single Target Flash');
        close(h);
        %------------------------------------
        % initialize the Figure
        %------------------------------------
        
        figure('Name','BCI P300 Circular Target - Single Target Flash', ...
            'NumberTitle','off');
        set(gcf,'renderer','opengl'); %OpenGL render Eric L.
        set(gcf,'doublebuffer','on');
        colordef none; %black background Eric L.
        [flag,fig] = figflag('BCI P300 Circular Target - Single Target Flash');
        set(fig,'Visible','off', ...
            'NumberTitle','off');
        pos=get(0,'ScreenSize');    %Get the size of the screen
        pos=pos-[0 0 0 40];         %don't use the total sreen              !!!!!!!!!!!!!!!!!!
 
        set(fig, ...
            'Position',pos, ...
            'MenuBar','none', ...
            'Units','normalized');
        movegui(fig,'center');      %Move GUI figure to specified part of screen
        axesHndl = axes('Position',[0 0 1 1]);
        axis([-1 1 -1 1]);        %sets scaling for the x- and y-axes on the current plot
        axis('off');                %turns off all axis labeling
        
        hold on;                    %holds the current plot and all axis properties so that
                                    %subsequent graphing commands add to the
                                    %existing graph

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
        sizes.NumOutputs     = 3 + control.bTRegs + control.bCounter + control.channels +1;
        sizes.NumInputs      = 2;
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
% send command    
        fwrite(s,cmdRDATAC);
%         fwrite(s,4);

        %% Initionalize the P300 interface
        %-----------------------------------------
        % Internal Flash Counter
        %-----------------------------------------
        
        handles.flashcount = 0;
        
        %-----------------------------------------
        % define colors
        %-----------------------------------------
        handles.darkColor = (40/255)*[1 1 1];
        handles.backTextCol = (100/255)*[1 1 1];
        
        %-----------------------------------------
        %load the Images into Workspace
        %-----------------------------------------
        
        if paramode == 1
        handles.numberoftargets = 4;
        elseif paramode == 2
        handles.numberoftargets = 8;
        end
            screentype = [[10/16,1];[10/16,1];[10/16,1];[10/16,1];[10/16,1];[10/16,1];[10/16,1];[10/16,1]];
            handles.circleposition = centerout * [[0,1];[1,0];[0,-1];[-1,0];[0.7071,0.7071];[0.7071,-0.7071];[-0.7071,-0.7071];[-0.7071,0.7071]].*screentype;
            handles.picwidth = screentype(1,1)*2 * 0.1 * imagescaling;
            handles.picheight = 1*2 * 0.1 * imagescaling;
            handles.imagexpos = -screentype(1,1) * 0.1 * imagescaling;
            handles.imageypos = -1 * 0.1 * imagescaling;
            
            pictemp = imread('Images\Base_Color','bmp');
            handles.basepic = image([-1 1],[-1 1],pictemp,'Visible','on');
        
%             pointbase = imread('Images\Pointer\Base','bmp');
%             handles.pointbase = image( ...
%             [cuescale*(handles.imagexpos) cuescale*(handles.imagexpos+ handles.picwidth)],...
%             [cuescale*(handles.imageypos+handles.picheight) cuescale*(handles.imageypos)], ...
%             pointbase, ...
%             'Visible','on');
            
        pictempD = imread('Images\Flash\D_Dot','bmp');
        pictempB = imread('Images\Flash\B_Dot','bmp');

        for imageload = 1:handles.numberoftargets %load custom images Eric L.
            
            handles.picD(imageload) = image( ...
            [handles.circleposition(imageload,1) + handles.imagexpos handles.circleposition(imageload,1) + handles.imagexpos + handles.picwidth],...
            [handles.circleposition(imageload,2) + handles.imageypos + handles.picheight handles.circleposition(imageload,2) + handles.imageypos], ...
            pictempD, ...
            'Visible','on');
        
            handles.picB(imageload) = image( ...
            [handles.circleposition(imageload,1) + handles.imagexpos handles.circleposition(imageload,1) + handles.imagexpos + handles.picwidth],...
            [handles.circleposition(imageload,2) + handles.imageypos + handles.picheight handles.circleposition(imageload,2) + handles.imageypos], ...
            pictempB, ...
            'Visible','off');        
        
            pointtemp = imread(['Images\Pointer\',num2str(imageload)],'bmp');
            handles.trainnow(imageload) = image( ...
            [cuescale*(handles.imagexpos) cuescale*(handles.imagexpos+ handles.picwidth)],...
            [cuescale*(handles.imageypos+handles.picheight) cuescale*(handles.imageypos)], ...
            pointtemp, ...
            'Visible','off');
        end
        
        %-----------------------------------------
        % countdown to stop
        % when hit the close button, then convert bClose to true, stop
        % flashing, and countdown for 2 seconds
        % when iCloseOutCount==2 set stop button externally to 1.  This is
        % on a delay, so then switch it when iCloseOutCount==1 back to
        % zero __THEN__ close the figure.
        %-----------------------------------------
        control.bCloseOut = false;
        control.iCloseOutCount = 2*control.SPS;  

        
        
        
        
        %-----------------------------------------
        % Training Trial Number Eric L.
        %-----------------------------------------
        handles.trialnumber = 1;
        handles.trainset = randperm(handles.numberoftargets);
        handles.mode = mode;
       
        %-----------------------------
        % save the parameters also in
        % the handles structure
        %-----------------------------
        % deleted handles.mode Eric L.
        handles.flashtime = flashtime/1000;
        handles.darktime = darktime/1000;

        %-----------------------------
        % call the newInit function
        %-----------------------------
        set(gcf,'UserData',handles);    %save the handles object in the figure's UserData
        newInit();
        handles = get(gcf,'UserData');    %load the changes of the newInit function
        
        %======================================================================
        % Buttons
        %======================================================================
        % Information for all buttons
        left=0.85;
        bottom=0;
        btnWidth=0.15;
        btnHeight=0.10;

        %====================================
        % The START Button

        yPos = 0.6;
        xPos = 0.325;
        labelStr = 'START';
        callbackStr='P300_Training_Paradigm([],[],[],''Start'',[])';%Startbutton callback Eric L.
        
        %Generic Button Information
        btnPos=[xPos yPos-btnHeight btnWidth btnHeight];  %[left bottom width height]
        handles.startHndl = uicontrol( ...
            'Style','pushbutton', ...
            'FontUnits','normalized', ...
            'FontSize',0.2, ...
            'FontWeight','bold', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',labelStr, ...
            'TooltipString','Starts the Translation', ...
            'Callback',callbackStr );
        
        %====================================
        % The CLOSE button
        labelStr='Close';
        callbackStr='P300_Training_Paradigm([],[],[],''Closefig'',[])';
        uicontrol( ...
            'Style','pushbutton', ...
            'Parent', fig, ...
            'Units','normalized', ...
            'Position',[left bottom btnWidth btnHeight], ...
            'String',labelStr, ...
            'TooltipString','Closes the P300 Speller Window', ...
            'Callback',callbackStr);        
        %====================================
        % set_param([gcs,'/P300 Trainer/StopSimu'],'Gain','0');   %stop the Simulink Simulation
        %====================================
       
        set(0,'currentfigure',fig);     %after drawing in the other axes set
                                        %fig as the current figure
        set(gcf,'UserData',handles);    %save changes into UserData of the curr. figure
        set(fig,'Visible','on');       %set figure visible

    case 9          %End of simulation tasks
        cmdSTOP = basecmd; cmdSTOP(1)=3;
        fwrite(s,cmdSTOP);  %% if needed stop any acquistion on the board
        fclose(s);
        
%        set_param([gcs,'/P300 Trainer/StopSimu'],'Gain','0');
        h=findobj('Name','BCI P300 Circular Target - Single Target Flash');
        close(h);

end

%============================================
% newInit function
%   Run this function when you start a new
%   'translation'
%--------------------------------------------
function newInit()
handles = get(gcf,'UserData');    %load handles structure from UserData
%----------------------
%random Flash order
%----------------------
handles.randarr = randperm(handles.numberoftargets); 
                      %random permutation of the integers from 1 to n
%-------------------------------------------------------------
%Intialize counting variables, boolean variables and constants
%-------------------------------------------------------------
handles.run = false;    %with the Start Button you can start the 'translation'
handles.stop = false;   %when the Signal Processing Block sends the STOP-Bit
                        %this variable will be set.
handles.flashIndex = 0; %the number of the currently flashing FlashField
handles.k = 1;          %Counting variable
handles.copyStrings=cell(1);  %this cellArray is used in the UpdateCopySpell
                              %Callback-Fctn

handles.statTrigger = false;    %true if the Trigger should be set
handles.draw = true;    %true if a Field could flash
handles.clear = true;   %true if a Field could be cleared

handles.newrun = true;  %new run will start
handles.runnumber = 1;  %holds the number of the actual run

handles.trialmax = 0;   %maximum number of trials, Copy Spelling trialmax is finite
                        %will be set in the 'UpdateCopySpell' Callback-fctn
handles.waitNextTrial = false;
handles.newtrial = false;
handles.trialwaitTime = 3;  %[s] time before the next trial starts
handles.correctTrials = 0;  %holds the number of correct Trials
handles.wrongTrials = 0;    %holds the number of wrong Trials

%hold the output variable (sys)
handles.outputTARGET = 0;
handles.outputSTIMULUSCODE = 0;

handles.tDarkLetter = floor(handles.darktime/(1/64))*(1/64);  %the time how long no letter
                                                  %should flash on the screen
handles.tFlash = floor(handles.flashtime/(1/64))*(1/64);   %the FlashTime



set(gcf,'UserData',handles);    %to save the changes of the newInit function

%============================================
% setClearTrigger function
%--------------------------------------------
function setClearTrigger(flashnum) %flashnum...handles.flashIndex   !!!!!!!!
handles = get(gcf,'UserData');   %load handles structure from UserData

if flashnum ~= 0
    %-------------------------------------------------
    % set Trigger(Gain2), if the letter,on which you
    % have to look, flashes on the screen.
    % edit function to remove copyspelling and add training set Eric L.
    %-------------------------------------------------
    
    trainingnumber = handles.trialnumber;
    if handles.mode == 2
    
            trainingnumber = mod(trainingnumber,handles.numberoftargets);
            if trainingnumber==0
                trainingnumber=handles.numberoftargets;
            end
    
    if handles.trainset(trainingnumber) == handles.flashIndex
        handles.outputTARGET = 1;
    end
    
    end
    
    else
    handles.outputTARGET=0;  %clear Trigger

end

handles.outputSTIMULUSCODE=flashnum;

set(gcf,'UserData',handles);    %to save the changes of the setTrigger function

