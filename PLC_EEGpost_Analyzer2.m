%PLC_EEGpost_Analyzer2.m
%Created by YY, 7/31/14

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
%% Re-referencing eye channels and Epoching/Baseline correction
%Horizontal eye channels (99/EX3 and 100/EX4) are referenced to each
%other; vertical eye channel is referenced to C25(89).
%NEW November 2010: Data from channel C25(89) are grabbed before
%re-referencing, since step 3 subtracts C25 from itself, zeroing it out.
%After re-referencing and before resaving, data from C25 are restored.

%Suffix "epochs": -200 to 300ms

%allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected for
%1st visit
allsubs = [22:25 27 28 32:35 37:40 44 46:52 54 55 57];%[1:2 7 9 10 12 13 15:18 20][21:25 27 28 32:35 37:40 44 46:52 54 55 57];%Subjects whose EEG has been collected as retest


for s = allsubs
    initial = subinitials(s,:);
    
    bs = 4:6;
    
    for b = bs %For each block included in these analyses
        
        %Re-reference fear files
        filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_evt_fil.set');
        EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset
        
        channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
        %Note on the next 3 lines: pop_reref creates a mini-matrix of the
        %channels included in referencing, and renumbers them based on that.
        %This is why these lines call for channels "1" and "2" instead of "99"
        %or "100". Took way too long to figure that out!
        EEG = pop_reref(EEG, [1 2], 'exclude', [1:96 99:111], 'keepref', 'on'); %1st step: chan 97(LHEOG/EX3) = new ref.Chan 98 (EX4) is referenced to Chan97 (EX3)
        EEG = pop_reref(EEG, 2, 'exclude', [1:96 99:111], 'keepref', 'on'); %2nd step: chan 98(RHEOG/EX4) = new ref% this line of code does not reref to EX4- it still rerefs to EX3!
        EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:98 100:111], 'keepref', 'on'); %3rd step: C25(89) = new ref. Chan 99 (EXG5) is referenced to C25
        EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in
              
        %Epoching
        epochname = strcat('PLC_Sub',num2str(s),'block',num2str(b),'epochs');
        EEG = pop_epoch( EEG, {1 2 501 502}, [-0.2   0.3], 'newname', epochname, 'epochinfo', 'yes'); %the onset of first gabor(target) is time 0
        
        %Baseline removal
        EEG = pop_rmbase( EEG, [-200 0]);
        
        EEG = eeg_checkset(EEG);
        
        savefile2 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc.set');
        EEG = pop_saveset(EEG, savefile2); %#ok<NASGU> %Save epochs
        clear EEG
    end
end

%% Re-referencing eye channels and Epoching/Baseline correction
%% -Sub3,4,42,43
%Horizontal eye channels (99/EX3 and 100/EX4) are referenced to each
%other; vertical eye channel is referenced to C25(89).
%NEW November 2010: Data from channel C25(89) are grabbed before
%re-referencing, since step 3 subtracts C25 from itself, zeroing it out.
%After re-referencing and before resaving, data from C25 are restored.

%Suffix "epochs": -200 to 300ms

%allsubs = [1:5 7:44 46:57];%Data for Sub6 and Sub45 weren't collected for
%1st visit
allsubs = [3 4 42 43];%Subjects whose EEG has been collected as retest


for s = allsubs
    initial = subinitials(s,:);
    
    bs = 4:6;
    
    for b = bs %For each block included in these analyses
        
        %Re-reference fear files
        filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_evt_fil.set');
        EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset
        
        channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
        %Note on the next 3 lines: pop_reref creates a mini-matrix of the
        %channels included in referencing, and renumbers them based on that.
        %This is why these lines call for channels "1" and "2" instead of "99"
        %or "100". Took way too long to figure that out!
        EEG = pop_reref(EEG, [1 2], 'exclude', [1:254 257:267], 'keepref', 'on'); %1st step: chan 255(LHEOG/EX3) = new ref.Chan256 (EX4) is referenced to Chan255 (EX3)
        EEG = pop_reref(EEG, 2, 'exclude', [1:254 257:267], 'keepref', 'on'); %2nd step: chan 256(RHEOG/EX4) = new ref.%this step is useless
        EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:256 258:267], 'keepref', 'on'); %3rd step: C25(89) = new ref. Chan257(Ex5) is referenced to C25.
        EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in
                
        %Epoching
        epochname = strcat('PLC_Sub',num2str(s),'block',num2str(b),'epochs');
        EEG = pop_epoch( EEG, {1 2 501 502}, [-0.2   0.3], 'newname', epochname, 'epochinfo', 'yes'); %the onset of first gabor(target) is time 0
        
        %Baseline removal
        EEG = pop_rmbase( EEG, [-200 0]);
        
        EEG = eeg_checkset(EEG);
        
        savefile2 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_reref_blc.set');
        EEG = pop_saveset(EEG, savefile2); %#ok<NASGU> %Save epochs
        clear EEG
    end
end

%% Use re-referenced eye channels to mark trials with eye movements.
% +-75 uV for marking rejected trials

allsubs = [1:2 7 9 10 12 13 15:18 20:25 27 28 32:35 37:40 44 46:52 54 55 57];

allsubs_feareyerejinfo = []; %c1 = sub#, c2 = block#, c3 = # of rej trials

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        filenamei = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc.set');
        EEG = pop_loadset(filenamei); %Load up results of last cell
        
        %     if p == 42 || p==44
        %     EEG = pop_eegthresh(EEG,1,99:101,-90,90,-0.2,0.3,0,0); %On EX3, EX4 and EX5, mark trials outside -75 to 75 uV
        %     else
        EEG = pop_eegthresh(EEG,1,97:99,-75,75,-0.2,0.3,0,0); %On EX3, EX4 and EX5, mark trials outside -75 to 75 uV
        %     end
        
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %Include all rejection types; creates EEG.reject.rejglobal
        eyerejtriallocs = find(EEG.reject.rejglobal);
        eyehowmany = length(eyerejtriallocs);
        
        eyeline = [s b eyehowmany]; %c1 = sub#, c2 = block#, c3 = # of rej trials
        
        allsubs_feareyerejinfo = [allsubs_feareyerejinfo; eyeline]; %#ok<AGROW>
        
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_eyerejtriallocs eyerejtriallocs']); %Save rejected trial locations
        
        clear EEG
    end
end
save PLC_EEGpost_allsubs_eyerejinfo_Norm allsubs_feareyerejinfo

%% Use re-referenced eye channels to mark trials with eye movements.
% +-75 uV for marking rejected trials

allsubs = [3 4 42 43];

allsubs_feareyerejinfo = []; %c1 = sub#, c2 = block#, c3 = # of rej trials

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        filenamei = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_reref_blc.set');
        EEG = pop_loadset(filenamei); %Load up results of last cell
        
        EEG = pop_eegthresh(EEG,1,255:257,-75,75,-0.2,0.3,0,0); %On EX3, EX4 and EX5, mark trials outside -75 to 75 uV
        
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %Include all rejection types; creates EEG.reject.rejglobal
        eyerejtriallocs = find(EEG.reject.rejglobal);
        eyehowmany = length(eyerejtriallocs);
        
        eyeline = [s b eyehowmany]; %c1 = sub#, c2 = block#, c3 = # of rej trials
        
        allsubs_feareyerejinfo = [allsubs_feareyerejinfo; eyeline]; %#ok<AGROW>
        
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_eyerejtriallocs eyerejtriallocs']); %Save rejected trial locations
        
        clear EEG
    end
end
save PLC_EEGpost_allsubs_eyerejinfo_Sub344243 allsubs_feareyerejinfo

%% Threshold each channel and save marked-trials info.
% +- 75 uV for marking rejected trials
allsubs = [1:2 7 9 10 12 13 15:18 20:25 27 28 32:35 37:40 44 46:52 54 55 57];

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        filename6 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc.set');
        EEG = pop_loadset(filename6); %Load up baseline-corrected data
        allrejtrialtest = cell(101,3); %Col 1 = chan #, col 2 = # of rejected trials for that chan, col 3 = trial #s flagged for rejection for that chan
        
        for c = 1:99 %For each channel
            allrejtrialtest{c,1} = c; %Col 1 = chan #
            EEG = pop_eegthresh(EEG,1,c,-75,75,-0.2,0.3,0,0);
            EEG = eeg_checkset( EEG );
            [EEG,com] = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %Updates EEG.reject.rejglobal
            
            facerejtr = find(EEG.reject.rejglobal); %"this channel's rej trials"; finds all trial #s that were rejected by pop_eegthresh
            allrejtrialtest{c,2} = length(facerejtr); %Col 2 = # of rejected trials
            allrejtrialtest{c,3} = facerejtr; %Col 3 = trial #s flagged for rejection for that chan
        end
        
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejtrialtest allrejtrialtest']);
        clear EEG
        
    end
end

%% Threshold each channel and save marked-trials info.-sub3,4,42,43
% +- 75 uV for marking rejected trials
allsubs = [3 4 42 43];

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        filename6 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_reref_blc.set');
        EEG = pop_loadset(filename6); %Load up baseline-corrected data
        allrejtrialtest = cell(257,3); %Col 1 = chan #, col 2 = # of rejected trials for that chan, col 3 = trial #s flagged for rejection for that chan
        
        for c =  [1:96 255:257] %For each channel
            allrejtrialtest{c,1} = c; %Col 1 = chan #
            EEG = pop_eegthresh(EEG,1,c,-75,75,-0.2,0.3,0,0);
            EEG = eeg_checkset( EEG );
            [EEG,com] = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %Updates EEG.reject.rejglobal
            
            facerejtr = find(EEG.reject.rejglobal); %"this channel's rej trials"; finds all trial #s that were rejected by pop_eegthresh
            allrejtrialtest{c,2} = length(facerejtr); %Col 2 = # of rejected trials
            allrejtrialtest{c,3} = facerejtr; %Col 3 = trial #s flagged for rejection for that chan
        end
        
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejtrialtest allrejtrialtest']);
        clear EEG
        
    end
end


%% Exclude channels, save corresponding info, and mark artifacts on just the included EEG channels.
allsubs = [1:2 7 9 10 12 13 15:18 20:25 27 28 32:35 37:40 44 46:52 54 55 57];

howmanysubs = length(allsubs); %1 row/subj
allsubs_feareegBintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4, col6 = blk5, col7 = blk6
allsubs_feareegMintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4
allsubs_feareegFintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4

fintrow = 1; %Row counter

backofhead = [1 14:22 25:38 41:50 54:57]; %New channels of interest: back of head
midofhead = [2:13 23:24 39 40 51:53 58:66];
frontofhead = 67:96;

%Preallocation for giant-chaninfo-arrays
fearallchaninfo = cell(howmanysubs,13); %Cell array w/1 row per subj and 9 columns to store info
frow = 1; %Since included subjs are sometimes nonconsecutive, use "row" to fill in each row

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        fchanexc = []; %Matrix of excluded channels & # of rejected trials in each
        fchaninc = []; %Matrix of included channels
        
        eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejtrialtest.mat']); %Load up all marked trials info
        
        for c = 1:99 %For each channel
            facerejtr = allrejtrialtest{c,2}; %# of rejected face trials for that channel
            
            z=30; %25% of 120 trials
            
            if facerejtr > z %If # of rej face trials is >25% of total trials
                fchanexc = [fchanexc c]; %#ok<AGROW> %Add channel to "excluded channels" matrix
            else %Otherwise, add channel to "included channels" matrix
                fchaninc = [fchaninc c]; %#ok<AGROW>
            end
        end
        
        if ~isempty(fchanexc); %If any channels were excluded
            sprintf('%s','The following channels will be excluded:')
            sprintf('%d'' ',fchanexc) %Display onscreen which channels were excluded
        else %If no channels were excluded
            sprintf('%s','All channels will be included')
        end
        chaninfo.chanexc=fchanexc;
        chaninfo.chaninc=fchaninc;
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_chaninfo chaninfo']); %Save excluded & included channels matrices
        
        fearallchaninfo{frow,1} = s; %col 1 = subj #
        
        switch b
            case (1) %For block 1
                fearallchaninfo{frow,2}=chaninfo.chanexc; %col 2 = excl. chans for block 1 for this subj
                fearallchaninfo{frow,3}=chaninfo.chaninc; %col 3 = incl. chans for block 1 for this subj
            case (2) %For block 2
                fearallchaninfo{frow,4}=chaninfo.chanexc; %col 4 = excl. for block 2
                fearallchaninfo{frow,5}=chaninfo.chaninc; %col 5 = incl. for block 2
            case (3) %For block 3
                fearallchaninfo{frow,6}=chaninfo.chanexc; %col 6 = excl. block 3
                fearallchaninfo{frow,7}=chaninfo.chaninc; %col 7 = incl. block 3
            case (4) %For block 4
                fearallchaninfo{frow,8}=chaninfo.chanexc; %col 8 = excl. block 4
                fearallchaninfo{frow,9}=chaninfo.chaninc; %col 9 = incl. block 4
            case (5) %For block 5
                fearallchaninfo{frow,10}=chaninfo.chanexc; %col 6 = excl. block 5
                fearallchaninfo{frow,11}=chaninfo.chaninc; %col 7 = incl. block 5
            case (6) %For block 6
                fearallchaninfo{frow,12}=chaninfo.chanexc; %col 8 = excl. block 6
                fearallchaninfo{frow,13}=chaninfo.chaninc; %col 9 = incl. block 6
        end
        
        bchanintlog = (chaninfo.chaninc==1) | (chaninfo.chaninc > 13) & (chaninfo.chaninc < 23) | (chaninfo.chaninc > 24) & (chaninfo.chaninc < 39) | (chaninfo.chaninc > 40) & (chaninfo.chaninc < 51) | (chaninfo.chaninc > 53) & (chaninfo.chaninc < 58) ; %New narrower included channels of interest
        bchanint = chaninfo.chaninc(bchanintlog); %Only grabs a channel of interest if it has enough good trials to be included
        
        mchanintlog = (chaninfo.chaninc > 1) & (chaninfo.chaninc < 14) | (chaninfo.chaninc > 22) & (chaninfo.chaninc < 25) | (chaninfo.chaninc > 38) & (chaninfo.chaninc < 41) | (chaninfo.chaninc > 50) & (chaninfo.chaninc < 54) | (chaninfo.chaninc > 57) & (chaninfo.chaninc < 67) | (chaninfo.chaninc==102);
        mchanint = chaninfo.chaninc(mchanintlog); %Same for middle-of-head
        
        fchanintlog = (chaninfo.chaninc > 66) & (chaninfo.chaninc < 97); %Same for front-of-head
        fchanint = chaninfo.chaninc(fchanintlog);
        
        %Mark artifacts on just the included channels of interest.  In 3
        %batches, one for each section of the head.
        filename4 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc.set'); %Dataset free of previous thresholding
        EEG = pop_loadset(filename4);
        
        %Back-of-head
        EEG = pop_eegthresh(EEG,1,bchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just back-of-head channels, window of -200 to 300 ms
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Bintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Bintrejtriallocs Bintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegBintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegBintrejtrials{fintrow,2} = Bintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegBintrejtrials{fintrow,3} = Bintrejtriallocs;
            case(3)
                allsubs_feareegBintrejtrials{fintrow,4} = Bintrejtriallocs;
            case(4)
                allsubs_feareegBintrejtrials{fintrow,5} = Bintrejtriallocs;
            case(5)
                allsubs_feareegBintrejtrials{fintrow,6} = Bintrejtriallocs;
            case(6)
                allsubs_feareegBintrejtrials{fintrow,7} = Bintrejtriallocs;
        end
        
        %Middle-of-head
        EEG = pop_eegthresh(EEG,1,mchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just middle-of-head channels
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Mintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Mintrejtriallocs Mintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegMintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegMintrejtrials{fintrow,2} = Mintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegMintrejtrials{fintrow,3} = Mintrejtriallocs;
            case(3)
                allsubs_feareegMintrejtrials{fintrow,4} = Mintrejtriallocs;
            case(4)
                allsubs_feareegMintrejtrials{fintrow,5} = Mintrejtriallocs;
            case(5)
                allsubs_feareegMintrejtrials{fintrow,6} = Mintrejtriallocs;
            case(6)
                allsubs_feareegMintrejtrials{fintrow,7} = Mintrejtriallocs;
        end
        
        %Front-of-head
        EEG = pop_eegthresh(EEG,1,fchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just front-of-head channels
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Fintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Fintrejtriallocs Fintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegFintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegFintrejtrials{fintrow,2} = Fintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegFintrejtrials{fintrow,3} = Fintrejtriallocs;
            case(3)
                allsubs_feareegFintrejtrials{fintrow,4} = Fintrejtriallocs;
            case(4)
                allsubs_feareegFintrejtrials{fintrow,5} = Fintrejtriallocs;
            case(5)
                allsubs_feareegFintrejtrials{fintrow,6} = Fintrejtriallocs;
            case(6)
                allsubs_feareegFintrejtrials{fintrow,7} = Fintrejtriallocs;
        end
        
        clear EEG %Keep memory from overloading
    end
    
    fintrow = fintrow + 1; %Move to next row = next subject in each channels-of-interest EEG rejtriallocs cell array (fear)
    frow = frow + 1; %Next row for fear allchaninfo matrix
end

allsubs_feareegintrejtrials.fearback = allsubs_feareegBintrejtrials;
allsubs_feareegintrejtrials.fearmiddle = allsubs_feareegMintrejtrials;
allsubs_feareegintrejtrials.fearfront = allsubs_feareegFintrejtrials;

%saved 2/8/15
save PLC_EEGpost_eegintrejtrials_Norm.mat allsubs_feareegintrejtrials
save PLC_EEGpost_ChanInfo_Norm.mat fearallchaninfo

%% Exclude channels, save corresponding info, and mark artifacts on just
%% the included EEG channels. -Sub 3,4,42,43
allsubs = [3 4 42 43];

howmanysubs = length(allsubs); %1 row/subj
allsubs_feareegBintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4, col6 = blk5, col7 = blk6
allsubs_feareegMintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4
allsubs_feareegFintrejtrials = cell(howmanysubs,7 ); %Col 1 = sub #, col 2 = EEG rej trials for block 1, col 3 = same for block 2, col 4 = for blk 3, col 5 = for blk 4

fintrow = 1; %Row counter

backofhead = [1 14:22 25:38 41:50 54:57]; %New channels of interest: back of head
midofhead = [2:13 23:24 39 40 51:53 58:66];
frontofhead = 67:96;

%Preallocation for giant-chaninfo-arrays
fearallchaninfo = cell(howmanysubs,13); %Cell array w/1 row per subj and 9 columns to store info
frow = 1; %Since included subjs are sometimes nonconsecutive, use "row" to fill in each row

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        fchanexc = []; %Matrix of excluded channels & # of rejected trials in each
        fchaninc = []; %Matrix of included channels
        
        eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejtrialtest.mat']); %Load up all marked trials info
        
        for c =  [1:96 255:257] %For each channel
            facerejtr = allrejtrialtest{c,2}; %# of rejected face trials for that channel
            
            z=30; %25% of 120 trials
            
            if facerejtr > z %If # of rej face trials is >25% of total trials
                fchanexc = [fchanexc c]; %#ok<AGROW> %Add channel to "excluded channels" matrix
            else %Otherwise, add channel to "included channels" matrix
                fchaninc = [fchaninc c]; %#ok<AGROW>
            end
        end
        
        if ~isempty(fchanexc); %If any channels were excluded
            sprintf('%s','The following channels will be excluded:')
            sprintf('%d'' ',fchanexc) %Display onscreen which channels were excluded
        else %If no channels were excluded
            sprintf('%s','All channels will be included')
        end
        chaninfo.chanexc=fchanexc;
        chaninfo.chaninc=fchaninc;
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_chaninfo chaninfo']); %Save excluded & included channels matrices
        
        fearallchaninfo{frow,1} = s; %col 1 = subj #
        
        switch b
            case (1) %For block 1
                fearallchaninfo{frow,2}=chaninfo.chanexc; %col 2 = excl. chans for block 1 for this subj
                fearallchaninfo{frow,3}=chaninfo.chaninc; %col 3 = incl. chans for block 1 for this subj
            case (2) %For block 2
                fearallchaninfo{frow,4}=chaninfo.chanexc; %col 4 = excl. for block 2
                fearallchaninfo{frow,5}=chaninfo.chaninc; %col 5 = incl. for block 2
            case (3) %For block 3
                fearallchaninfo{frow,6}=chaninfo.chanexc; %col 6 = excl. block 3
                fearallchaninfo{frow,7}=chaninfo.chaninc; %col 7 = incl. block 3
            case (4) %For block 4
                fearallchaninfo{frow,8}=chaninfo.chanexc; %col 8 = excl. block 4
                fearallchaninfo{frow,9}=chaninfo.chaninc; %col 9 = incl. block 4
            case (5) %For block 5
                fearallchaninfo{frow,10}=chaninfo.chanexc; %col 6 = excl. block 5
                fearallchaninfo{frow,11}=chaninfo.chaninc; %col 7 = incl. block 5
            case (6) %For block 6
                fearallchaninfo{frow,12}=chaninfo.chanexc; %col 8 = excl. block 6
                fearallchaninfo{frow,13}=chaninfo.chaninc; %col 9 = incl. block 6
        end
        
        bchanintlog = (chaninfo.chaninc==1) | (chaninfo.chaninc > 13) & (chaninfo.chaninc < 23) | (chaninfo.chaninc > 24) & (chaninfo.chaninc < 39) | (chaninfo.chaninc > 40) & (chaninfo.chaninc < 51) | (chaninfo.chaninc > 53) & (chaninfo.chaninc < 58) ; %New narrower included channels of interest
        bchanint = chaninfo.chaninc(bchanintlog); %Only grabs a channel of interest if it has enough good trials to be included
        
        mchanintlog = (chaninfo.chaninc > 1) & (chaninfo.chaninc < 14) | (chaninfo.chaninc > 22) & (chaninfo.chaninc < 25) | (chaninfo.chaninc > 38) & (chaninfo.chaninc < 41) | (chaninfo.chaninc > 50) & (chaninfo.chaninc < 54) | (chaninfo.chaninc > 57) & (chaninfo.chaninc < 67) | (chaninfo.chaninc==102);
        mchanint = chaninfo.chaninc(mchanintlog); %Same for middle-of-head
        
        fchanintlog = (chaninfo.chaninc > 66) & (chaninfo.chaninc < 97); %Same for front-of-head
        fchanint = chaninfo.chaninc(fchanintlog);
        
        %Mark artifacts on just the included channels of interest.  In 3
        %batches, one for each section of the head.
        filename4 = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_reref_blc.set'); %Dataset free of previous thresholding
        EEG = pop_loadset(filename4);
        
        %Back-of-head
        EEG = pop_eegthresh(EEG,1,bchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just back-of-head channels, window of -200 to 300 ms
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Bintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Bintrejtriallocs Bintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegBintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegBintrejtrials{fintrow,2} = Bintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegBintrejtrials{fintrow,3} = Bintrejtriallocs;
            case(3)
                allsubs_feareegBintrejtrials{fintrow,4} = Bintrejtriallocs;
            case(4)
                allsubs_feareegBintrejtrials{fintrow,5} = Bintrejtriallocs;
            case(5)
                allsubs_feareegBintrejtrials{fintrow,6} = Bintrejtriallocs;
            case(6)
                allsubs_feareegBintrejtrials{fintrow,7} = Bintrejtriallocs;
        end
        
        %Middle-of-head
        EEG = pop_eegthresh(EEG,1,mchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just middle-of-head channels
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Mintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Mintrejtriallocs Mintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegMintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegMintrejtrials{fintrow,2} = Mintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegMintrejtrials{fintrow,3} = Mintrejtriallocs;
            case(3)
                allsubs_feareegMintrejtrials{fintrow,4} = Mintrejtriallocs;
            case(4)
                allsubs_feareegMintrejtrials{fintrow,5} = Mintrejtriallocs;
            case(5)
                allsubs_feareegMintrejtrials{fintrow,6} = Mintrejtriallocs;
            case(6)
                allsubs_feareegMintrejtrials{fintrow,7} = Mintrejtriallocs;
        end
        
        %Front-of-head
        EEG = pop_eegthresh(EEG,1,fchanint,-75,75,-0.2,0.3,1,0); %Do thresholding on just front-of-head channels
        EEG = eeg_checkset(EEG); %Check for errors
        [EEG,com] = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); %#ok<NASGU> %EEG.reject.rejglobal now has all marked trials for EEGchans
        
        Fintrejtriallocs = find(EEG.reject.rejglobal); %Obtain rejected trial #s
        eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_Fintrejtriallocs Fintrejtriallocs']); %Save rejected trial locations
        
        allsubs_feareegFintrejtrials{fintrow,1} = s;
        switch b %For each of the 4 blocks
            case(1)
                allsubs_feareegFintrejtrials{fintrow,2} = Fintrejtriallocs; %Also save locations into big matrix
            case(2)
                allsubs_feareegFintrejtrials{fintrow,3} = Fintrejtriallocs;
            case(3)
                allsubs_feareegFintrejtrials{fintrow,4} = Fintrejtriallocs;
            case(4)
                allsubs_feareegFintrejtrials{fintrow,5} = Fintrejtriallocs;
            case(5)
                allsubs_feareegFintrejtrials{fintrow,6} = Fintrejtriallocs;
            case(6)
                allsubs_feareegFintrejtrials{fintrow,7} = Fintrejtriallocs;
        end
        
        clear EEG %Keep memory from overloading
    end
    
    fintrow = fintrow + 1; %Move to next row = next subject in each channels-of-interest EEG rejtriallocs cell array (fear)
    frow = frow + 1; %Next row for fear allchaninfo matrix
end

allsubs_feareegintrejtrials.fearback = allsubs_feareegBintrejtrials;
allsubs_feareegintrejtrials.fearmiddle = allsubs_feareegMintrejtrials;
allsubs_feareegintrejtrials.fearfront = allsubs_feareegFintrejtrials;

%saved 2/8/15
save PLC_EEGpost_eegintrejtrials_Sub344243.mat allsubs_feareegintrejtrials
save PLC_EEGpost_ChanInfo_Sub344243.mat fearallchaninfo

%% Concatenate rejected trial #s into 1 large matrix & delete doubles.
%Trial rejection input:
%1. Trials flagged by eyechan thresholding.
%2. Trials flagged by EEGchan-of-interest thresholding.
%3. Trials noted in run notes as bad.  None so far!
allsubs = [1:4 7 9 10 12 13 15:18 20:25 27 28 32:35 37:40 42:44 46:52 54 55 57];

howmanysubs = length(allsubs);
allsubs_fearallBrejtrials = cell(howmanysubs, 13);
allsubs_fearallMrejtrials = cell(howmanysubs, 13);
allsubs_fearallFrejtrials = cell(howmanysubs, 13);
thesections = ['B' 'M' 'F']; %Need the letters B, M, and F for running each of the 3 things
frowB = 1; %Since subj #s are sometimes nonconsecutive, use rows
frowM = 1;
frowF = 1;
allrejtypetallyB = [];
allrejtypetallyM = [];
allrejtypetallyF = [];

for s = allsubs
    
    bs = 4:6;
    
    
    for b = bs
        
        for v = thesections
            
            eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_eyerejtriallocs eyerejtriallocs']); %Load up eyechan marked trials info (in 1 row)
            eval(['allfrejtrials' num2str(v) ' = eyerejtriallocs;']); %Put eye rej trials into matrix of all rej trials for this subj, block, & section
            eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_' num2str(v) 'intrejtriallocs ' num2str(v) 'intrejtriallocs']); %Load up EEGchan-of-interest marked trials info (in 1 row)
            eval(['allfrejtrials' num2str(v) ' = [allfrejtrials' num2str(v) ' ' num2str(v) 'intrejtriallocs];']); %Add EEG marked trials to all rej trials matrix
            eval(['allfrejtrials' num2str(v) ' = sort(allfrejtrials' num2str(v) ');']); %Sort all rej trials matrix
            
            %This part deletes doubles (same value 2x or more in a row)
            f = 2; %Start at 2 because each comparison is between the item & the item before it
            eval(['e = length(allfrejtrials' num2str(v) ');']);
            while f <= e
                if eval(['allfrejtrials' num2str(v) '(f) == allfrejtrials' num2str(v) '(f-1)']) %Doubles will always be next to each other because matrix has been sorted
                    eval(['allfrejtrials' num2str(v) '(f) = [];']); %Delete the 2nd one
                    eval(['e = length(allfrejtrials' num2str(v) ');']); %Matrix is now 1 shorter
                else %If there isn't a match
                    f = f+1; %Move to the next value
                    eval(['e = length(allfrejtrials' num2str(v) ');']); %Matrix is still the same size
                end
            end
            
            %Save final marked trials matrix, both individually & all subjs
            eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_finalall' num2str(v) 'rejtrials allfrejtrials' num2str(v) ';']);
            eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',1} = s;']); %Col 1 = subj #
            switch b
                case(1)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',2} = length(allfrejtrials' num2str(v) ');']); %Col 2 = # of rejected trials for block 1
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',3} = allfrejtrials' num2str(v) ';']); %Col 3 = locations of rejected trials for block 1
                case(2)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',4} = length(allfrejtrials' num2str(v) ');']); %Col 4 = # of rejected trials for block 2
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',5} = allfrejtrials' num2str(v) ';']); %Col 5 = locations of rejected trials for block 2
                case(3)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',6} = length(allfrejtrials' num2str(v) ');']); %Col 6 = # of rejected trials for block 3
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',7} = allfrejtrials' num2str(v) ';']); %Col 7 = locations of rejected trials for block 3
                case(4)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',8} = length(allfrejtrials' num2str(v) ');']); %Col 8 = # of rejected trials for block 4
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',9} = allfrejtrials' num2str(v) ';']); %Col 9 = locations of rejected trials for block 4
                case(5)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',6} = length(allfrejtrials' num2str(v) ');']); %Col 6 = # of rejected trials for block 3
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',7} = allfrejtrials' num2str(v) ';']); %Col 11 = locations of rejected trials for block 3
                case(6)
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',8} = length(allfrejtrials' num2str(v) ');']); %Col 8 = # of rejected trials for block 4
                    eval(['allsubs_fearall' num2str(v) 'rejtrials{frow' num2str(v) ',9} = allfrejtrials' num2str(v) ';']); %Col 12 = locations of rejected trials for block 4
                    
            end
            
            eyes = length(eyerejtriallocs); %Tally # of eye movement rejected trials
            eval(['eegs = length(' num2str(v) 'intrejtriallocs);']); %Tally # of rej trials due to activity on EEG channels of interest
            eval(['total = length(allfrejtrials' num2str(v) ');']); %Tally total # of rej trials (will be less than sum of cols 3&4 due to overlap)
            tally = [s b eyes eegs total]; %#ok<NASGU> %Col 1 = sub #, col2 = block#, col 3 = eye movements, col 4 = EEG movements, col 5 = total
            eval(['allrejtypetally' num2str(v) ' = [allrejtypetally' num2str(v) '; tally];']); %#ok<AGROW>
            
            %Convert final marked trials matrix to logical; save
            x=120; %120 trials per block
            rejectbinary = zeros(1,x); %Preallocate zeros, 1 for each trials
            eval(['stupid = 1:length(allfrejtrials' num2str(v) ');']); %Can't do this on next line for some reason, so am doing it here instead
            for p = stupid %For each trial flagged for rejection
                eval(['a = allfrejtrials' num2str(v) '(p);']); %Assign that trial # to a variable
                rejectbinary(a) = 1; %That trial #'s spot in the zeros matrix becomes 1
            end
            rejectlogical = logical(rejectbinary); %#ok<NASGU> %Converts the zeros-and-ones matrix to a logical for use in EEG.reject.rejglobal
            eval(['save PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejlogical' num2str(v) ' rejectlogical']);
        end
    end
    frowB = frowB + 1; %Move to next row
    frowM = frowM + 1;
    frowF = frowF + 1;
end

allsubs_fearfinalallrejtrials.fearback = allsubs_fearallBrejtrials;
allsubs_fearfinalallrejtrials.fearmiddle = allsubs_fearallMrejtrials;
allsubs_fearfinalallrejtrials.fearfront = allsubs_fearallFrejtrials;

allrejtypetally.fearback = allrejtypetallyB;
allrejtypetally.fearmiddle = allrejtypetallyM;
allrejtypetally.fearfront = allrejtypetallyF;

save PLC_EEGpost_finalallrejtrials allsubs_fearfinalallrejtrials
save PLC_EEGpost_rejtypetally allrejtypetally

%% Actually reject marked trials
%Based on P1 window rejected trials above, it is determined that
%Sub 48 52 be removed from further EEG analysis due to too many
%movements and preculiar extraneous experimental conditions (ie. refusal to
%use chin rest, physiological symptoms during experiment, no contignency
%retained,etc.)

allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];

thesections = ['B' 'M' 'F']; %Need the letters B, M, and F for running each of the 3 things
for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        
        for v = thesections
            
            eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_allrejlogical' num2str(v) ' rejectlogical']);
            if s==3||s==4||s==42||s==43
                filenamef = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_reref_blc.set'); %Dataset free of previous thresholding
                
            else
                filenamef = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc.set'); %Dataset free of previous thresholding
            end
            
            EEG = pop_loadset(filenamef);
            EEG.reject.rejglobal = rejectlogical; %Assign logical results of previous cell to EEG.reject.rejglobal
            EEG = pop_rejepoch(EEG, EEG.reject.rejglobal, 0); %#ok<NASGU> %Rejects marked trials
            if v=='B'
                savefilef = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Barej.set');
            elseif v=='M'
                savefilef = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Marej.set');
            elseif v=='F'
                savefilef = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Farej.set');
            else
                sprintf('%s','WTF IS HAPPENING')
            end
            EEG = pop_saveset(EEG, savefilef); %Resave w/"arej" in title
            clear EEG
            
        end
    end
end