%PLC_EEG_Analyzer2.m
%Created by YY, 7/27/14

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
%% Re-referencing eye channels
%Horizontal eye channels (99/EX3 and 100/EX4) are referenced to each
%other; vertical eye channel is referenced to C25(89).  
%NEW November 2010: Data from channel C25(89) are grabbed before
%re-referencing, since step 3 subtracts C25 from itself, zeroing it out.
%After re-referencing and before resaving, data from C25 are restored.

%Suffix "epochs": -200 to 300ms

%allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected
allsubs = [16:44 46:57];

for s = allsubs
    initial = subinitials(s,:);
    
    if s == 56 || s == 15
        bs = 1:5; 
    elseif s ==55
        bs = [1:3 5:6];
    else
        bs = 1:6;
    end
    
    for b = bs %For each block included in these analyses
        
    %Re-reference fear files    
    filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt_fil.set');  
    EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset
    
    channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
    %Note on the next 3 lines: pop_reref creates a mini-matrix of the
    %channels included in referencing, and renumbers them based on that.
    %This is why these lines call for channels "1" and "2" instead of "99"
    %or "100". Took way too long to figure that out!
    EEG = pop_reref(EEG, [1 2], 'exclude', [1:98 101:111], 'keepref', 'on'); %1st step: chan 99(LHEOG/EX3) = new ref.
    EEG = pop_reref(EEG, 2, 'exclude', [1:98 101:111], 'keepref', 'on'); %2nd step: chan 100(RHEOG/EX4) = new ref
    EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:100 102:111], 'keepref', 'on'); %3rd step: C25(89) = new ref 
    EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in
    
    %Epoching
    epochname = strcat('PLC_Sub',num2str(s),'block',num2str(b),'epochs'); 
    EEG = pop_epoch( EEG, {1 2 501 502}, [-0.2   0.3], 'newname', epochname, 'epochinfo', 'yes'); %the onset of first gabor(target) is time 0    
    
    %Baseline removal
    EEG = pop_rmbase( EEG, [-200 0]); 
    
    EEG = eeg_checkset(EEG);
    
    savefile2 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'epochs_blc.set');     
    EEG = pop_saveset(EEG, savefile2); %#ok<NASGU> %Save epochs
    clear EEG
    end
end

