%PLC_EEGpost_Analyzer3.m
%Created by YY, 1/22/15

%% Extract ERPs
%Based on P1 window rejected trials above, it is determined that
%Sub 48 52 (updated 2/8/15; old rej: 16,48,49,52) be removed from further EEG analysis due to too many
%movements and preculiar extraneous experimental conditions (ie. refusal to
%use chin rest, physiological symptoms during experiment, no contignency
%retained,etc.)

allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];

backofhead = [1 14:22 25:38 41:50 54:57]; %New channels of interest: back of head
midofhead = [2:13 23:24 39 40 51:53 58:66]; %Middle of head
frontofhead = 67:96; %Front of head
thesections = ['B' 'M' 'F'];
cleaneventall = cell(180, 1);
counter = 0;

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        
        % All resp 3*2
        GrayT1 = cell(96,1);    %Gray target 1;if subno is odd, T1 is the CS+
        GrayT2 = cell(96,1);    %Gray target 2;if subno is even, T2 is the CS+
        ColT1 = cell(96,1);    %Color target 1
        ColT2 = cell(96,1);    %Color target 2
        
        
        counter = counter + 1;
        
        
        for v = thesections %For each of the 3 sections of the head
            
            if v=='B' %If working with back-of-head EEG file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Barej.set'); %Want to load back-of-head fear file
                thesechans = backofhead; %Channel loop will use back-of-head channels
            elseif v=='M' %If working with mid-of-head file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Marej.set'); %Want to load mid-of-head fear file
                thesechans = midofhead;
            elseif v=='F'
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_epochs_blc_Farej.set'); %Want to load front-of-head fear file
                thesechans = frontofhead;
            else
                sprintf('%s','WTF IS HAPPENING')
            end
            
            EEG = pop_loadset(thefile); %Load up results from previous cell for this subj, block, head section
            cleandata = EEG.data; %return channel per frame*frames per epoch*number of epochs
            epochdur = EEG.pnts; %return frames per epoch
            cleanevents = [];
            cleanevents2 = [];
            %Create 1-row matrix of all event codes for clean epochs
            %Create 1-row matrix of all event codes for clean epochs
            for i=1:length(EEG.epoch)%For each clean epoch
                n = EEG.epoch(i).eventtype;
                if iscell(n)
                    for ii=1:length(n)
                        if n{ii} == 1 || n{ii} == 2 || n{ii} == 501 || n{ii} == 502
                            cleanevents = [cleanevents n(ii)];
                        end
                    end
                else
                    for ii=1:length(n)
                        if n(ii) == 1 || n(ii) == 2 || n(ii) == 501 || n(ii) == 502
                            cleanevents = [cleanevents n(ii)];
                        end
                    end
                    
                end
            end
            
            
            clear EEG %Got all the info we need, so let's clear it out to save memory
            howmanyevents = length(cleanevents);
            if v=='B' %For back-of-head file
                cleaneventsback = cleanevents; %Assign its clean events to a new matrix to avoid overwriting
            elseif v=='M' %For middle-of-head file
                cleaneventsmid = cleanevents; %Same thing
            elseif v=='F' %For front-of-head file
                cleaneventsfront = cleanevents; %Maybs don't have to do this, but it's a good idea anyway
            else
            end
            
            for m = thesechans %For each channel in this section
                %Preallocate condition matrices
                grayt1 = [];
                grayt2 = [];
                colt1 = [];
                colt2 = [];
                
                
                %For each clean event, add its epoch to the relevant condition matrix
                for j = 1:howmanyevents
                    
                    
                    switch cleanevents(j)
                        case(1) %Event code 1: Gray Target 1
                            grayt1 = [grayt1; cleandata(m,(1+epochdur*(j-1): epochdur*j))] ; %#ok<AGROW>
                            
                        case(2) %Event code 2: Gray Target 2
                            grayt2 = [grayt2; cleandata(m,(1+epochdur*(j-1): epochdur*j))] ; %#ok<AGROW>
                            
                        case(501) %Event code 501: Color Target 1
                            colt1 = [colt1; cleandata(m,(1+epochdur*(j-1): epochdur*j))] ; %#ok<AGROW>
                            
                        case(502) %Event code 502: Color Target 2
                            colt2 = [colt2; cleandata(m,(1+epochdur*(j-1): epochdur*j))] ; %#ok<AGROW>
                            
                    end %Of switch for coding events
                end %Of event loop
                
                %At this point, no averaging yet - just to be averaged later
                %when all blocks are pulled together
                GrayT1{m} = grayt1;
                GrayT2{m} = grayt2;
                ColT1{m} = colt1;
                ColT2{m} = colt2;
                
                
            end %Of channel loop
            cleaneventall{counter,1} = cleanevents;
            cleaneventall{counter,2} = [s b];
        end %Of section loop
        
        aaa=epochdur*1000/256; %Converts back from datapoint time into seconds
        horz=linspace(1, aaa, epochdur); %Vector from 1 to total # of seconds per epoch, w/as many points as are in an epoch
        %Time to save everything!
        %Creating save structure "results"
        results.horz = horz; %Will use later to graph
        results.cleandata = cleandata;
        results.cleanevents.back = cleaneventsback; %New cleanevents 5/17/11, similar structure to P1 analysis files
        results.cleanevents.middle = cleaneventsmid;
        results.cleanevents.front = cleaneventsfront;
        results.epochdur=epochdur;
        
        if rem(s,2) == 1 %if subno is odd
            results.GrayCSp = GrayT1; %T1 is CS+
            results.GrayCSm = GrayT2;
            results.ColCSp = ColT1;
            results.ColCSm = ColT2;
        else
            results.GrayCSp = GrayT2; %T2 is CS+
            results.GrayCSm = GrayT1;
            results.ColCSp = ColT2;
            results.ColCSm = ColT1;
        end
        
        eval(['save PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs.mat results';]); %Save it all for fear
        clear cleandata %To save memory
        clear results
    end %Of block loop
end %Of subject loop

%% Average ERPs for Postcond2 blocks.

allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];

for s = allsubs
    
    bs = 4:6;
    
    %Preallocate cell arrays for each subject's averages.
    GrayCSp = cell(96,1);    %Gray target 1;if subno is odd, T1 is the CS+
    GrayCSm = cell(96,1);    %Gray target 2;if subno is even, T2 is the CS+
    ColCSp = cell(96,1);    %Color target 1
    ColCSm = cell(96,1);    %Color target 2
    
    for c = 1:96 %For each channel
        %Preallocate condition matrices for this channel
        %Preallocate condition matrices
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        
        for b = bs %For each of the 3 blocks of precond
            
            eval(['load PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs.mat results';]); %Load fear file
            eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_chaninfo chaninfo']); %Load fear file channel info
            
            
            if c == 1 %Only have to do this part once for each subj & block (during channel 1)  
                if b == 5 %Only have to do this part once for each subject 
                    horz = results.horz; %#ok<NASGU> %Will become the x-axis later, when graphing
                    epochdur = results.epochdur; %Tells us how long the epoch is (in ms)
                else
                end
            else
            end
            
            if ~isempty(find(chaninfo.chaninc==c, 1)) %If this channel is in the included channels matrix
                %Grab mean epoch for this channel for each condition &
                %concatenate w/other 2 blocks
                
                
                graycsp = [graycsp; results.GrayCSp{c}];
                graycsm = [graycsm; results.GrayCSm{c}];
                colcsp = [colcsp; results.ColCSp{c}];
                colcsm = [colcsm; results.ColCSm{c}];               
                
                
            else %If the channel was excluded, don't add anything to the concatenated matrix
            end
            clear results %To save memory--these are big files!
        end %Of block loop
               
        %Now that the ERPs for each block have been collected, average them
        %together & assign them to the correct cell in the overall matrix.
        
        GrayCSp{c} = mean(graycsp,1);
        GrayCSm{c} = mean(graycsm,1);
        ColCSp{c} = mean(colcsp,1);
        ColCSm{c} = mean(colcsm,1);

        
    end %Of channel loop
    
    %Time to save everything!
    %Creating save structure "results"
    results.horz = horz; %Will use later to graph
    results.epochdur=epochdur;
    
    results.GrayCSp = GrayCSp;
    results.GrayCSm = GrayCSm;
    results.ColCSp = ColCSp;
    results.ColCSm = ColCSm;
    
    
    eval(['save PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs.mat results';]); %Save it all for each subject

end %Of subject loop

