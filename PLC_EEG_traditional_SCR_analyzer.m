%% PLC EEG traditional SCR analzyer
% Adapted from Lucas' SCR scripts
% Will call a function findscr_event_related_CANlab_com.m and ANSLAB
% toolbox in the path
% Last modified 5/16/14

%% Inputs: from the scr single channel data, apply low-pass filter of 0.5hz
%% and high-pass filter of 0.0159hz
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
'CC';];
%%
allsubs = [1:5 7:39];
condition = {'color';'gray'};

for a = allsubs
    initial = subinitials(a,:);
    
    if a ==37
        c1 = 1;%sub37 gray condition is not properly saved
    else
        c1 = 1:2;
    end
    
    for c = c1
    ccode = condition{c,:};        
    scrdatafile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_scr.mat');%save continuous SCR
    load(scrdatafile);        
    
    % now low-pass filter at 5hz, using parameters generated by
    % scr_predata, based on 256hz sampling rate
    filt.b = [0.0579,0.0579];
    filt.a = [1, -0.8842];

    data = scr_filtfilt(filt.b, filt.a, data);
    
    % now high-pass filter at 0.0159hz, using parameters generated by
    % scr_predata, based on 256hz sampling rate
    filt.b = [0.9998, -0.9998];
    filt.a = [1, -0.9996];

    data = scr_filtfilt(filt.b, filt.a, data);  
    
    scrdatafile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_scr_fil.mat');%save continuous SCR
    save(scrdatafile, 'data');       
    
    end
    
end

%% Conditioning block 1 & 2
% Gabor onsets (targetonTimes), time window [-1000 3000]
% UCS onsets, time window [-1000 5000]

Allsub_peak = cell(2,4); %for 2 color/gray (color-1, gray-2) and 2 levels of CS (CS+ 1, CS- 2, UCS threat 3, UCS safety 4)
Allsub_peaklat = cell(2,4);



allsubs = [1:5 7:39];
condition = {'color';'gray'};
sr = 1000;%The sampling rate of the Biosemi data; this will be used further down, but can be set here because it will be consistent for all subjects

for a = allsubs
    
    if a ==37
        c1 = 1;%sub37 gray condition is not properly saved
    else
        c1 = 1:2;
    end
    
%Declare varialbes to store peak values
FCcsP_peak = [];
FCcsN_peak = [];
FCUCS_peak = [];
FCSafe_peak = [];

FGcsP_peak = [];
FGcsN_peak = [];
FGUCS_peak = [];
FGSafe_peak = [];

%Declare variables to store peak latencies
FCcsP_peaklat = [];
FCcsN_peaklat = [];
FCUCS_peaklat = [];
FCSafe_peaklat = [];

FGcsP_peaklat = [];
FGcsN_peaklat = [];
FGUCS_peaklat = [];
FGSafe_peaklat = [];    
        
    for c = c1
    ccode = condition{c,:};             
    
        onsetfile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_event.mat');%save event onsets + types; %load the matlab file with onset times (targetontTimes)
        load(onsetfile);
        
        
        scrfile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_scr_fil.mat'); %load prefiltered (0.5hz lowpass) scr data file
        load(scrfile);


        T1UConsets = eventonsets(1,eventonsets(2,:)==166);
        T2UConsets = eventonsets(1,eventonsets(2,:)==266);    
        
            if strcmp(ccode,'color') %Fear Color condition
                
                    T1onsets = eventonsets(1,eventonsets(2,:)==501);
                    T2onsets = eventonsets(1,eventonsets(2,:)==502);
                    
                    if rem(a,2) == 1
                        
                    for i=1:length(T1onsets)
                        t1 = T1onsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCcsP_peak = [FCcsP_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCcsP_peaklat  = [FCcsP_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{1,1} = [Allsub_peak{1,1}; a mean(FCcsP_peak)];
                    Allsub_peaklat{1,1} = [Allsub_peaklat{1,1}; a mean(FCcsP_peaklat)];
                    
                    for i = 1:length(T2onsets)
                        t1 = T2onsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCcsN_peak = [FCcsN_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCcsN_peaklat  = [FCcsN_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{1,2} = [Allsub_peak{1,2}; a mean(FCcsN_peak)];
                    Allsub_peaklat{1,2} = [Allsub_peaklat{1,2}; a mean(FCcsN_peaklat)]; 
                    
                    for i=1:length(T1UConsets)
                        t1 = T1UConsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCUCS_peak = [FCUCS_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCUCS_peaklat  = [FCUCS_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{1,3} = [Allsub_peak{1,3}; a mean(FCUCS_peak)];
                    Allsub_peaklat{1,3} = [Allsub_peaklat{1,3}; a mean(FCUCS_peaklat)];
                    
                    for i = 1:length(T2UConsets)
                        t1 = T2UConsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCSafe_peak = [FCSafe_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCSafe_peaklat  = [FCSafe_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{1,4} = [Allsub_peak{1,4}; a mean(FCSafe_peak)];
                    Allsub_peaklat{1,4} = [Allsub_peaklat{1,4}; a mean(FCSafe_peaklat)];                         
                    
                    elseif rem(a,2) ==0 %T2 is CS+
                        
                    for i=1:length(T1onsets)
                        t1 = T1onsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCcsP_peak = [FCcsP_peak peak]; %this variable is not changed to save effort, but it actually saves CS-
                        FCcsP_peaklat  = [FCcsP_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{1,2} = [Allsub_peak{1,2}; a mean(FCcsP_peak)];
                    Allsub_peaklat{1,2} = [Allsub_peaklat{1,2}; a mean(FCcsP_peaklat)];
                    
                    for i = 1:length(T2onsets)
                        t1 = T2onsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCcsN_peak = [FCcsN_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCcsN_peaklat  = [FCcsN_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{1,1} = [Allsub_peak{1,1}; a mean(FCcsN_peak)];
                    Allsub_peaklat{1,1} = [Allsub_peaklat{1,1}; a mean(FCcsN_peaklat)]; 
                    
                    for i=1:length(T1UConsets)
                        t1 = T1UConsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCUCS_peak = [FCUCS_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCUCS_peaklat  = [FCUCS_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{1,4} = [Allsub_peak{1,4}; a mean(FCUCS_peak)];
                    Allsub_peaklat{1,4} = [Allsub_peaklat{1,4}; a mean(FCUCS_peaklat)];
                    
                    for i = 1:length(T2UConsets)
                        t1 = T2UConsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FCSafe_peak = [FCSafe_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FCSafe_peaklat  = [FCSafe_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{1,3} = [Allsub_peak{1,3}; a mean(FCSafe_peak)];
                    Allsub_peaklat{1,3} = [Allsub_peaklat{1,3}; a mean(FCSafe_peaklat)];                         

                    end
                
                    
            elseif strcmp(ccode,'gray') %Fear Gray condition
                    T1onsets = eventonsets(1,eventonsets(2,:)==101);
                    T2onsets = eventonsets(1,eventonsets(2,:)==102);       
                   
                    if rem(a,2) == 1
                        
                    for i=1:length(T1onsets)
                        t1 = T1onsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGcsP_peak = [FGcsP_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGcsP_peaklat  = [FGcsP_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{2,1} = [Allsub_peak{2,1}; a mean(FGcsP_peak)];
                    Allsub_peaklat{2,1} = [Allsub_peaklat{2,1}; a mean(FGcsP_peaklat)];
                    
                    for i = 1:length(T2onsets)
                        t1 = T2onsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGcsN_peak = [FGcsN_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGcsN_peaklat  = [FGcsN_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{2,2} = [Allsub_peak{2,2}; a mean(FGcsN_peak)];
                    Allsub_peaklat{2,2} = [Allsub_peaklat{2,2}; a mean(FGcsN_peaklat)]; 
                    
                    for i=1:length(T1UConsets)
                        t1 = T1UConsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGUCS_peak = [FGUCS_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGUCS_peaklat  = [FGUCS_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{2,3} = [Allsub_peak{2,3}; a mean(FGUCS_peak)];
                    Allsub_peaklat{2,3} = [Allsub_peaklat{2,3}; a mean(FGUCS_peaklat)];
                    
                    for i = 1:length(T2UConsets)
                        t1 = T2UConsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGSafe_peak = [FGSafe_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGSafe_peaklat  = [FGSafe_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{2,4} = [Allsub_peak{2,4}; a mean(FGSafe_peak)];
                    Allsub_peaklat{2,4} = [Allsub_peaklat{2,4}; a mean(FGSafe_peaklat)];                         
                    
                    elseif rem(a,2) ==0 %T2 is CS+
                        
                    for i=1:length(T1onsets)
                        t1 = T1onsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGcsP_peak = [FGcsP_peak peak]; %this variable is not changed to save effort, but it actually saves CS-
                        FGcsP_peaklat  = [FGcsP_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{2,2} = [Allsub_peak{2,2}; a mean(FGcsP_peak)];
                    Allsub_peaklat{2,2} = [Allsub_peaklat{2,2}; a mean(FGcsP_peaklat)];
                    
                    for i = 1:length(T2onsets)
                        t1 = T2onsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+3000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGcsN_peak = [FGcsN_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGcsN_peaklat  = [FGcsN_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{2,1} = [Allsub_peak{2,1}; a mean(FGcsN_peak)];
                    Allsub_peaklat{2,1} = [Allsub_peaklat{2,1}; a mean(FGcsN_peaklat)]; 
                    
                    for i=1:length(T1UConsets)
                        t1 = T1UConsets(i); % the time unit is sample (1000/256ms), not ms.
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %This function is modified to accomodate the 256 sampling rate; Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGUCS_peak = [FGUCS_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGUCS_peaklat  = [FGUCS_peaklat  peaklat]; %store the peak latencies into the cell
                    end
                    
                    Allsub_peak{2,4} = [Allsub_peak{2,4}; a mean(FGUCS_peak)];
                    Allsub_peaklat{2,4} = [Allsub_peaklat{2,4}; a mean(FGUCS_peaklat)];
                    
                    for i = 1:length(T2UConsets)
                        t1 = T2UConsets(i);
                        SC1 = data(t1-1000/(1000/256):t1+5000/(1000/256),1); % set the time window to be -1000 to 4500ms centered on Gabor onset (targonTimes)
                        SC1 = [SC1; sr];
                        [peak, peaklat, basept, baselat, rtn, rtnd]=findscr_event_related_CANLab_com(SC1); %Gets information from a preexisting program designed to gather information about GSR for the short time frame
                        FGSafe_peak = [FGSafe_peak peak]; %store the peak amplitudes into the cell: color, CS+
                        FGSafe_peaklat  = [FGSafe_peaklat  peaklat]; %store the peak latencies into the cell                                           
                    end
                    
                    Allsub_peak{2,3} = [Allsub_peak{2,3}; a mean(FGSafe_peak)];
                    Allsub_peaklat{2,3} = [Allsub_peaklat{2,3}; a mean(FGSafe_peaklat)];                         
 
                    end


                
            end
     

    end
end


