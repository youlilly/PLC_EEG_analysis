%PLC_EEG_Analyzer1.m
%Created by YY, 7/17/14

%This program, the first in a series of three, begins the EEG data analysis
%process for study LHE.  It takes raw EEG data (in .bdf format) and uses
%EEGlab to convert the files to .set format, checks triggers in behavioral &
%EEG files to see how well they match, uses information from the behavioral
%file to label EEG events and adjust trigger times, and filter the data.
%Each cell has more detailed descriptions of its processes and outputs.

%Before running this program, ensure all EEG .bdf
%files have been decimated to 256Hz, and that they are all consistently
%named, without dates or other varying information in the filename.  Put
%all decimated .bdf files and behavioral .mat files in the folder with this
%program before you run it.
%EC originally ran this program one cell at a time.  It has not yet been
%run all at once.  Prepare for lengthy processing time if you do!

clear all
eeglab %Open up EEGlaa



%% List of Sub Initials
subinitials = ['AP';
'GD';
'DR';
'MW';
'JM';
'ES';
'KM';
'HM';
'BY';
'JD';
'ML';
'AJ';
'GR';
'AG';
'DR';
'DM';
'MJ';
'RS';
'HG';
'CB';
'AS';
'MG';
'AL';
'RV';
'JB';
'JW';
'BB';
'VG';
'EH';
'AL';
'TC';
'JK';
'NB';
'JT';
'EB';
'LB';
'ML';
'MT';
'CC';
'QL'; 
'DS';
'AD';
'LN';
'AS';
'XX';
'AY';
'MW';
'SK';
'AS';
'PB';
'AC';
'ZR';
'AK';
'MW';
'SW';
'SR';
'TG';
];

%% Convert .bdf files to .set/.dat files.

for s = allsubs
    initial = subinitials(s,:);
    
    if s == 56
        bs = 1:5; 
    elseif s ==55
        bs = [1:3 5:6];
    else
        bs = 1:6;
    end
    
    for b = bs %For each block included in these analyses
        
    filename = strcat('Sub', num2str(s),'_', initial, '_block',num2str(b),'-Deci.bdf');
    EEG =pop_biosig(filename, 'ref',[97 98] , 'rmeventchan', 'off'); %Load up bdf file
    %filename (string), 'ref' & ref channels, 'rmeventchan' off so event
    %channel is not removed after extracting events
    setname = strcat('EEG_Sub',num2str(s),'_block',num2str(b));
    EEG.setname = setname; %Describes file
    %EEGlab is putting fake triggers in some of these files, so let's get
    %rid of those before they cause trouble
    z = length(EEG.event); %For identifying last trigger
    q = 1;
        while q <= z 
            if EEG.event(1).latency <= 297 %If the first event has a latency less or equal than 1, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', 1); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            else %If the first event is legit (which it isn't on most of these files), do nothing
            end
            
            if EEG.event(q).type == 384 %If an event has a type of 384, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', q); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            q = q+1; %Move to next event
            else %If none of this crazy stuff is happening
            q = q+1; %Move to the next event
            end
        end
    EEG = eeg_checkset( EEG ); %Check dataset for errors
    savefile = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'.set');
    EEG = pop_saveset( EEG,  'filename', savefile); %Save file in .set format
    end
end

%% Check # of triggers and timing of 1st trigger (called 'st') in behav .mat file and EEG dataset to see how well they match.
allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected

clear EEG %Needs to be clear or memory will be exceeded
stdiffs = []; %Preallocate matrix of first-trigger time differences
numtrigdiffs = []; %Preallocate matrix of differences in # of triggers

for s = allsubs %For each of the 4 blocks
    initial = subinitials(s,:);
    
    if s == 56 || s == 15
        bs = 1:5; 
    elseif s ==55
        bs = [1:3 5:6];
    else
        bs = 1:6;
    end
    
    
    for b = bs%allsubs %For each subject included in these analyses
    filename1 =strcat('PLC_EEG_block',num2str(b),'_sub',num2str(s),'_',initial,'.mat');
    load(filename1);
    
    beventnum = length(StimR)*2; %total # of triggers in behav .mat file
    filename2=strcat('EEG_Sub',num2str(s),'_block',num2str(b),'.set');
    EEG = pop_loadset(filename2); %Load up EEG dataset
    eeventnum = length(EEG.event); %Length = total # of triggers in EEG event file
    numtrigdiff = eeventnum - beventnum; %Subtract # of triggers in .mat file from # of triggers in EEG event file
    thisone = [s b numtrigdiff]; %Add subj # and block # for identifying which files have problems w/nonmatching #s of triggers
    numtrigdiffs = [numtrigdiffs; thisone]; %#ok<AGROW> %Add this difference in # of triggers to matrix of them
    
%    stdiff = behavst - EEG.event(1).latency; %Subtract st time in EEG dataset from st time in .mat file
%    thisline = [s b stdiff]; %Add subj # and block # for identifying unusual st diffs
%    stdiffs = [stdiffs; thisline]; %#ok<AGROW> %Add this st diff time to matrix of them
    clear EEG %Clear out EEG dataset variable so memory is not exceeded
    end
end
save PLC_beheegdiffs numtrigdiffs

%% Label events in EEG file and adjust onset times, both based on info from .mat file.

allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected

eventnum = [];

for s = allsubs
    initial = subinitials(s,:);    
    %specific recorded blocks for certain subjects
    if s == 56 || s == 15
        bs = 1:5; 
        
    elseif s ==55
        bs = [1:3 5:6];
        
    else
        bs = 1:6;
    end
    
    %different scr channels for different subjects recorded under default
    %or preset config. files
    if s == 7 || s == 12 || s == 46 || s == 47 || s == 48 || s == 49
        scrchan  = 263;
    else
        scrchan = 103;
    end
    
    for b = bs
    
    filename1 =strcat('PLC_EEG_block',num2str(b),'_sub',num2str(s),'_',initial,'.mat');
    load(filename1);
        piconsets = results.onsets.piconTimes/1000*256;%Convert picture onset times from ms to s; *256 because decimated by 1/4
        disconsets = results.onsets.disonTimes/1000*256;
        
        if b > 3
        IAPSonsets = results.onsets.IAPSonTimes/1000*256;
        IAPSonsets = IAPSonsets(2:2:30);
        end
        
%%%%%this section deals with scr data         
        eventdata = [];%store event latencies
        eventonsets = [];%store both event latencies and corresponding event type
        data = [];%saves SCR data
        
        switch b
            case(1)
                eventtype = [2,203,501,703,502,703,502,702,502,703,2,202,501,701,502,702,1,201,502,703,1,201,501,701,501,701,1,201,2,203,502,703,2,202,501,703,2,202,502,702,502,702,502,702,1,201,501,703,2,203,1,201,1,201,502,702,501,701,1,203,501,703,501,701,501,703,502,703,2,202,502,702,1,201,1,201,502,702,2,202,2,203,501,703,2,202,2,202,1,201,2,203,502,703,2,202,2,202,502,702,501,701,502,702,1,203,1,203,2,202,501,701,2,203,502,703,2,202,501,703,1,203,2,202,1,203,2,203,1,203,502,703,2,203,501,703,2,202,501,701,2,203,502,702,2,203,2,203,501,701,501,701,1,203,2,202,501,703,501,701,2,203,1,203,501,703,502,703,501,701,1,201,501,703,1,201,502,702,501,703,1,203,1,203,1,203,502,703,501,701,1,203,502,703,502,703,2,203,1,203,502,702,1,201,1,203,502,703,502,702,501,703,502,702,501,701,2,203,502,703,501,701,1,201,501,703,2,202,501,703,1,201,1,203,1,201,2,203,502,703;];
            case(2)
                eventtype = [1,203,1,203,502,703,2,203,501,703,501,703,502,703,2,203,2,202,2,202,501,701,1,203,502,702,502,702,2,202,502,702,501,701,1,203,501,701,2,202,2,203,1,201,502,703,2,203,1,201,1,201,2,203,502,702,501,703,502,702,501,701,502,703,501,703,2,202,2,203,502,703,501,701,501,703,502,702,502,702,2,202,501,701,502,702,502,702,501,701,501,701,502,703,1,203,502,703,1,201,1,203,501,701,501,701,2,203,2,203,501,703,2,203,501,701,2,202,1,201,502,703,1,203,502,702,502,703,1,201,501,701,1,201,502,702,502,702,1,201,502,703,1,201,1,203,502,703,501,701,501,703,2,202,501,703,2,203,501,703,1,203,1,203,2,202,1,201,501,703,1,201,502,703,501,703,1,201,2,203,502,703,2,202,2,203,2,202,2,202,1,203,501,703,501,703,1,203,1,201,502,702,501,701,1,201,1,201,1,203,2,203,2,202,502,703,2,203,502,703,502,702,501,701,501,703,1,203,501,703,1,203,2,203,502,702,2,202,2,202;];
            case(3)
                eventtype = [502,703,2,203,502,702,1,203,1,201,501,703,502,702,502,703,2,202,2,202,1,203,501,703,1,201,1,203,501,703,1,203,501,701,501,701,502,703,2,203,2,203,1,201,1,201,501,703,2,203,2,202,2,203,2,203,501,701,502,703,1,201,2,203,501,701,1,203,2,203,2,203,502,702,502,703,2,202,2,202,1,203,502,703,501,703,2,202,502,702,502,702,502,702,1,203,1,203,1,201,1,201,501,703,2,202,502,703,501,701,501,703,1,203,502,702,502,703,2,203,501,703,2,202,501,701,502,702,1,201,2,202,501,701,1,201,501,701,1,203,502,702,501,701,502,703,501,703,502,703,1,203,501,701,1,203,1,203,1,203,2,203,502,702,2,202,2,203,2,203,2,202,501,703,502,703,501,701,1,203,1,201,502,703,2,202,501,703,1,201,1,201,501,701,501,703,502,702,501,703,502,702,2,202,2,202,502,702,501,701,502,703,502,703,1,201,501,701,501,703,1,201,502,703,501,701,502,702,1,201,501,703,2,203,502,702,2,203,2,202;];
            case(4)
                eventtype = [1,201,502,702,501,703,502,99,2,202,502,702,1,99,501,703,1,201,501,99,501,703,501,703,2,202,2,99,501,703,1,203,501,701,501,701,1,203,502,703,2,202,1,99,502,702,1,203,1,203,1,201,502,99,502,702,1,201,2,202,502,703,1,201,502,703,1,203,2,203,1,203,2,203,501,701,1,201,1,203,2,202,501,99,502,702,1,201,501,701,502,703,2,203,1,203,502,703,1,201,1,201,501,703,2,202,2,203,2,99,501,701,2,202,502,703,501,701,2,202,1,201,1,203,2,202,1,203,1,99,2,202,501,701,501,701,502,703,502,702,501,703,502,702,1,201,2,203,2,203,501,703,502,702,501,703,502,702,501,99,1,201,1,203,1,203,2,203,502,702,501,703,1,201,502,702,501,701,501,701,502,99,502,703,502,703,2,203,1,201,502,702,1,203,501,701,501,703,502,703,1,203,501,703,502,703,501,99,1,201,2,203,502,703,502,702,501,703,502,703,2,203,2,202,2,99,501,701,2,202,2,203,501,701,502,703,501,701,1,99,2,202,501,701,502,702,501,703,1,203,501,703,502,99,2,202,2,203,2,203,502,703,2,202,502,702,2,203,2,203;];
            case(5)
                eventtype = [502,703,1,201,1,99,502,703,2,203,501,99,501,701,502,703,502,703,2,99,2,202,502,99,2,203,501,703,1,201,501,703,502,702,2,202,1,99,2,203,1,203,501,703,501,701,501,703,1,203,501,703,2,202,2,203,501,701,2,99,501,701,1,201,1,201,2,202,502,702,501,703,501,701,2,202,501,99,502,702,501,701,2,202,2,202,501,703,502,702,502,99,502,703,1,203,502,702,1,203,1,201,501,703,2,203,1,201,2,203,2,99,1,203,502,702,2,203,502,703,501,99,502,702,501,701,2,203,2,203,2,202,1,203,501,701,1,203,2,202,1,201,2,99,2,203,501,703,1,201,501,701,2,203,501,701,501,703,1,203,502,702,1,201,1,201,2,202,2,203,501,701,2,202,2,203,1,99,501,703,1,203,502,702,502,702,1,201,501,703,502,703,1,201,2,203,502,702,502,702,1,203,501,701,2,202,501,99,1,203,502,703,1,201,501,701,502,703,501,701,2,202,2,203,502,99,1,201,502,703,502,703,1,99,501,703,502,702,502,703,502,703,2,202,1,201,501,703,1,203,1,203,502,702,1,203,501,703,2,202,501,701,1,203,502,702,502,703,502,703;];
            case(6)
                eventtype = [2,202,502,99,1,203,501,701,1,203,1,99,502,703,501,701,2,99,501,701,501,99,2,202,1,201,502,703,502,99,502,703,2,202,501,703,1,203,501,701,502,702,2,202,502,703,2,99,2,203,1,201,1,203,1,201,502,702,1,203,502,703,1,99,2,203,501,701,502,703,2,202,1,201,2,203,502,703,1,201,1,203,502,702,502,703,501,701,1,203,501,701,502,702,2,203,501,99,2,203,2,202,501,703,502,703,2,203,2,203,2,99,502,703,502,702,1,203,501,703,501,701,501,703,2,202,502,702,502,702,501,701,1,99,502,702,501,703,2,202,501,703,2,202,501,701,501,701,1,203,502,702,502,703,501,701,1,201,1,201,2,202,501,99,502,702,502,703,2,203,501,703,2,202,1,201,502,702,2,203,1,203,2,203,502,703,2,203,2,99,1,201,501,703,2,202,502,703,2,203,2,203,502,702,2,202,501,703,502,702,501,703,501,99,2,203,1,201,501,701,501,703,501,703,501,703,1,203,501,701,502,99,1,203,502,702,502,702,1,203,1,203,1,99,2,202,501,703,502,703,1,201,501,703,1,201,501,701,2,203,1,201,1,203,2,202,1,201,1,201;];
        end
            
        filename = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'.set');
        EEG = pop_loadset(filename); % load the EEG .set file
        
%%%Selectively remove initial triggers based on individual subjects
    if (s == 3 && b == 3) || (s == 36 && b == 5)
        cutoff = 5120;
    elseif s == 5 && b == 2 
        cutoff = 1792;
    elseif (s == 10 && b == 1) || (s == 14 && b == 1) || (s == 50 && b == 2)
        cutoff = 1536;
    elseif s == 11 && b == 1
        cutoff = 5888;
    elseif s == 11 && b == 2
        cutoff = 3072;
    elseif s == 12 && b == 3
        cutoff = 3840;
    elseif s == 21 && b == 5
        cutoff = 2304;
    elseif (s == 26 && b == 4) || (s == 28 && b == 3) || (s == 32 && b == 3)
        cutoff = 2816;
    elseif s == 30 && b == 5
        cutoff = 2304;
    elseif (s == 36 && b == 4) || (s == 40 && b == 5) || (s == 50 && b == 4)
        cutoff = 1024;
    elseif s == 36 && b == 6
        cutoff = 5888;
    elseif s == 42 && b == 4
        cutoff = 2560;
    else
        cutoff = 2000;
    end

        
    %EEGlab is putting fake triggers in some of these files, so let's get
    %rid of those before they cause trouble
    z = length(EEG.event); %For identifying last trigger
    q = 1;
        while q <= z 
            if EEG.event(q).type == 384 %If an event has a type of 384, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', q); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            q = q+1; %Move to next event
            else %If none of this crazy stuff is happening
            q = q+1; %Move to the next event
            end
            
            if EEG.event(1).latency < cutoff %If the then first event has a latency less or equal than ~8s, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', 1); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            else %If the first event is legit (which it isn't on most of these files), do nothing
            end
            
        end 
        
    zf = length(EEG.event);    
    eventnum = [eventnum; s b zf];
    
        for i = 1:length(EEG.event)
           eventdata = [eventdata EEG.event(1,i).latency]; %grab event latency
        end
        
%%%% Save SCR data for later use        
    eventonsets =[eventdata; eventtype];
    
    scrfile = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_event.mat');%save event onsets + types
    save(scrfile, 'eventonsets');
    
    data = EEG.data(scrchan,:)'; %channel 103 saves SCR
    scrdatafile = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_scr.mat');%save continuous SCR
    save(scrdatafile, 'data');
%%%End of scr section    
    
    
% Compute difference btw first Cogent trigger and first EEG trigger
    Diff=piconsets(1)-EEG.event(1).latency + 3;     
    %Adjust pic onset latency
    picLat = piconsets' - Diff;
    disLat = disconsets' - Diff;
    
        if b > 3
        IAPSLat = IAPSonsets' - Diff;
        end

counter = 0;
counter2 = 0;
    
    %First, assign event code
        for l=1:zf

            EEG.event(l).type = eventtype(l); %Each pic trigger gets labeled with its corresponding condition code
            
            if rem(l,2) == 1  %Odd trigger No. 
                EEG.event(l).latency = picLat((l+1)/2);

            else
                if eventtype(l) == 99
                    counter = counter + 1;
                    EEG.event(l).latency = IAPSLat(counter);
                else
                    counter2 = counter2 + 1;
                    EEG.event(l).latency = disLat(counter2);
                end
            end
            
            if eventtype(l) == 99
                    EEG.event(l-1).type = eventtype(l-1)+50;%change the eventtype of CS to a new number if it is followed by UCS
            end
        end  
        
    savefileb = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt.set'); %Add "_evt" to filename
    EEG = pop_saveset(EEG, savefileb); %Resave
    EEG = eeg_checkset( EEG ); %#ok<NASGU>
%     
    clear EEG %To keep Matlab from screaming            
        
    
    end
    
end


%% Filter data from 0.1-40Hz.
allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected

for s = allsubs
    %specific recorded blocks for certain subjects
    if s == 56 || s == 15
        bs = 1:5; 
        
    elseif s ==55
        bs = [1:3 5:6];
        
    else
        bs = 1:6;
    end
        
    for b = bs
    %for n = allsubs
    filename4=strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt.set');
    EEG = pop_loadset(filename4); %Load up event-altered EEG dataset
    EEG = pop_eegfilt( EEG, 0.1, 0, [], 0);
    %EEG, locutoff = 1, hicutoff = 0, [] = no notch filter, 0 = filter length
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfilt( EEG, 0, 40, [], 0); %Filter in 2 steps to reduce chance of crashing
    EEG = eeg_checkset( EEG );
    savefile4 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt_fil.set'); %Add "_fil" to filename
    EEG = pop_saveset(EEG, savefile4);
    clear EEG %clear dataset in memory to avoid overloading it
    end
end

%% Appendix - Rename files
allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected

for s = allsubs
    %specific recorded blocks for certain subjects
    if s == 56 || s == 15
        bs = 1:5; 
        
    elseif s ==55
        bs = [1:3 5:6];
        
    else
        bs = 1:6;
    end
    
    for b = bs
    scrfile = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_post_event.mat');%save event onsets + types
    load(scrfile);
    scrfilen = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_event.mat');%save event onsets + types
    save(scrfilen,'eventonsets');
    
        
    end
end
%%
allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected

for s = allsubs
    %specific recorded blocks for certain subjects
    if s == 56 || s == 15
        bs = 1:5; 
        
    elseif s ==55
        bs = [1:3 5:6];
        
    else
        bs = 1:6;
    end
    
    for b = bs
    scrdatafile = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_post_scr.mat');%save continuous SCR
    load(scrdatafile);
    scrdatafilen = strcat('EEG_Sub',num2str(s),'_block',num2str(b),'_scr.mat');%save continuous SCR
    save(scrdatafilen, 'data');
    
    end
end