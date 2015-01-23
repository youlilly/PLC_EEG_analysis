%PLC_EEG_Analyzer3.m
%Created by YY, 1/22/15

%% Extract ERPs
%Sub16,48,49,52 be removed from further EEG analysis due to too many
%movements and preculiar extraneous experimental conditions (ie. refusal to
%use chin rest, physiological symptoms during experiment, no contignency
%retained,etc.)

allsubs = [1:5 7:15 17:44 46 47 50 51 53:57];

backofhead = [1 14:22 25:38 41:50 54:57]; %New channels of interest: back of head
midofhead = [2:13 23:24 39 40 51:53 58:66]; %Middle of head
frontofhead = 67:96; %Front of head
thesections = ['B' 'M' 'F'];
cleaneventall = cell(180, 1);
counter = 0;

for s = allsubs
    
    if s == 56 || s == 15
        bs = 2:5;
    elseif s == 55
        bs = [2:3 5:6];
    else
        bs = 2:6;
    end
    
    for b = bs
        
        % All resp 3*2
        GrayT1 = cell(96,1);    %Gray target 1;if subno is odd, T1 is the CS+
        GrayT2 = cell(96,1);    %Gray target 2;if subno is even, T2 is the CS+
        ColT1 = cell(96,1);    %Color target 1
        ColT2 = cell(96,1);    %Color target 2
        
        
        counter = counter + 1;
        
        
        for v = thesections %For each of the 3 sections of the head
            
            if v=='B' %If working with back-of-head EEG file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_epochs_blc_Barej.set'); %Want to load back-of-head fear file
                thesechans = backofhead; %Channel loop will use back-of-head channels
            elseif v=='M' %If working with mid-of-head file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_epochs_blc_Marej.set'); %Want to load mid-of-head fear file
                thesechans = midofhead;
            elseif v=='F'
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_epochs_blc_Farej.set'); %Want to load front-of-head fear file
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
        
        eval(['save PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs.mat results';]); %Save it all for fear
        clear cleandata %To save memory
        clear results
    end %Of block loop
end %Of subject loop

%% Average ERPs for all 4 blocks of a subject together.

% This step now becomes really slow and takes 3min to run each subject


alleegcleanevents = cell(64,7); %This will end up having 52 empty rows at the top--we can put the 1st & 2nd batches in later
%allsubs = [1:3 5:6 8:15 17:22 24 25 27:39 41:46];    
             
for l = allsubs
       
       if l==1
            s= [2 3 4];
       elseif l==6
            s = [1 2 4];
       else s= [1 2 3 4];
       end
%Preallocate cell arrays for each subject's averages.
        fearL_corr_all = cell(96,1);    
        disgustL_corr_all = cell(96,1);
        neutralL_corr_all = cell (96,1);
        fearH_corr_all = cell(96,1);    
        disgustH_corr_all = cell(96,1);
        neutralH_corr_all = cell (96,1);
        
        fearL_incorr_all = cell(96,1);    
        disgustL_incorr_all = cell(96,1);
        neutralL_incorr_all = cell (96,1);
        fearH_incorr_all = cell(96,1);    
        disgustH_incorr_all = cell(96,1);
        neutralH_incorr_all = cell (96,1);
        
        fearL_noresp_all = cell(96,1);    
        disgustL_noresp_all = cell(96,1);
        neutralL_noresp_all = cell (96,1);
        fearH_noresp_all = cell(96,1);    
        disgustH_noresp_all = cell(96,1);
        neutralH_noresp_all = cell (96,1);
        
        % All resp 3*2
        fearL_allresp_all = cell(96,1);    
        disgustL_allresp_all = cell(96,1);
        neutralL_allresp_all = cell (96,1);
        fearH_allresp_all = cell(96,1);    
        disgustH_allresp_all = cell(96,1);
        neutralH_allresp_all = cell (96,1);
        
        % Collapse sf
        fear_corr_all = cell(96,1);    
        disgust_corr_all = cell(96,1);
        neutral_corr_all = cell (96,1);
        
        fear_incorr_all = cell(96,1);    
        disgust_incorr_all = cell(96,1);
        neutral_incorr_all = cell (96,1);
        
        fear_noresp_all = cell(96,1);    
        disgust_noresp_all = cell(96,1);
        neutral_noresp_all = cell (96,1);
        
        fear_allresp_all = cell(96,1);    
        disgust_allresp_all = cell(96,1);
        neutral_allresp_all = cell (96,1);
        
        % Collapse emo
        l_corr_all = cell(96,1);    
        h_corr_all = cell(96,1);
        
        l_incorr_all = cell(96,1);    
        h_incorr_all = cell(96,1);
        
        l_noresp_all = cell(96,1);    
        h_noresp_all = cell(96,1);
        
        l_allresp_all = cell(96,1);    
        h_allresp_all = cell(96,1);
        
    for c = 1:96 %For each channel
    %Preallocate condition matrices for this channel
               fearL_corr = [];    
               disgustL_corr = [];
               neutralL_corr = [];
               fearH_corr = [];    
               disgustH_corr = [];
               neutralH_corr = [];
        
               fearL_incorr = [];    
               disgustL_incorr = [];
               neutralL_incorr = [];
               fearH_incorr = [];    
               disgustH_incorr = [];
               neutralH_incorr = [];
        
               fearL_noresp = [];    
               disgustL_noresp = [];
               neutralL_noresp = [];
               fearH_noresp = [];    
               disgustH_noresp = [];
               neutralH_noresp = [];
        
        % All resp 3*2
               fearL_allresp = [];    
               disgustL_allresp = [];
               neutralL_allresp = [];
               fearH_allresp = [];    
               disgustH_allresp = [];
               neutralH_allresp = [];
        
        % Collapse sf
               fear_corr = [];    
               disgust_corr = [];
               neutral_corr = [];
        
               fear_incorr = [];    
               disgust_incorr = [];
               neutral_incorr = [];
        
               fear_noresp = [];    
               disgust_noresp = [];
               neutral_noresp = [];
        
               fear_allresp =[];    
               disgust_allresp = [];
               neutral_allresp = [];
        
        % Collapse emo
               l_corr = [];    
               h_corr = [];
        
               l_incorr = [];    
               h_incorr = [];
        
               l_noresp = [];    
               h_noresp = [];
        
               l_allresp = [];    
               h_allresp = [];
    
        for g = s %For each of the 4 blocks

        eval(['load LHEsub' num2str(l) 'block' num2str(g) 'picsERPs_nomean.mat results';]); %Load fear file
        eval(['load LHEblock' num2str(g) '_sub' num2str(l) '_chaninfo chaninfo']); %Load fear file channel info
            
            eachevents1back = [];
            eachevents1mid = [];
            eachevents1front = [];
            
            if c == 1 %Only have to do this part once for each subj & block (during channel 1)
            eval (['eachevents' num2str(g) 'back = results.cleanevents.back;']); %Back-of-head clean events
            eval (['eachevents' num2str(g) 'mid = results.cleanevents.middle;']); %Mid-of-head clean events
            eval (['eachevents' num2str(g) 'front = results.cleanevents.front;']); %Front-of-head clean events
            
                if g == 2 %Only have to do this part once for each subject (during block 1--> changed to 2 because sub1 doesn't have block1)
                horz = results.horz; %#ok<NASGU> %Will become the x-axis later, when graphing
                epochdur = results.epochdur; %Tells us how long the epoch is (in ms)
                else
                end
            else
            end

            if ~isempty(find(chaninfo.chaninc==c, 1)) %If this channel is in the included channels matrix
            %Grab mean epoch for this channel for each condition &
            %concatenate w/other 2 blocks


        fearL_corr = [fearL_corr; results.condepochs.fearL_corr_all{c}];
        disgustL_corr = [disgustL_corr; results.condepochs.disgustL_corr_all{c}];
        neutralL_corr = [neutralL_corr; results.condepochs.neutralL_corr_all{c}];
        fearH_corr = [fearH_corr; results.condepochs.fearH_corr_all{c}];
        disgustH_corr = [disgustH_corr; results.condepochs.disgustH_corr_all{c}];
        neutralH_corr = [neutralH_corr; results.condepochs.neutralH_corr_all{c}];
        
        fearL_incorr = [fearL_incorr; results.condepochs.fearL_incorr_all{c}];
        disgustL_incorr = [disgustL_incorr; results.condepochs.disgustL_incorr_all{c}];
        neutralL_incorr = [neutralL_incorr; results.condepochs.neutralL_incorr_all{c}];
        fearH_incorr = [fearH_incorr; results.condepochs.fearH_incorr_all{c}];
        disgustH_incorr = [disgustH_incorr; results.condepochs.disgustH_incorr_all{c}];
        neutralH_incorr = [neutralH_incorr; results.condepochs.neutralH_incorr_all{c}];
        
        fearL_noresp = [fearL_noresp; results.condepochs.fearL_noresp_all{c}];
        disgustL_noresp = [disgustL_noresp; results.condepochs.disgustL_noresp_all{c}];
        neutralL_noresp = [neutralL_noresp; results.condepochs.neutralL_noresp_all{c}];
        fearH_noresp = [fearH_noresp; results.condepochs.fearH_noresp_all{c}];
        disgustH_noresp = [disgustH_noresp; results.condepochs.disgustH_noresp_all{c}];
        neutralH_noresp = [neutralH_noresp; results.condepochs.neutralH_noresp_all{c}];
        
        fearL_allresp = [fearL_allresp; results.condepochs.fearL_allresp_all{c}];
        disgustL_allresp = [disgustL_allresp; results.condepochs.disgustL_allresp_all{c}];
        neutralL_allresp = [neutralL_allresp; results.condepochs.neutralL_allresp_all{c}];
        fearH_allresp = [fearH_allresp; results.condepochs.fearH_allresp_all{c}];
        disgustH_allresp = [disgustH_allresp; results.condepochs.disgustH_allresp_all{c}];
        neutralH_allresp = [neutralH_allresp; results.condepochs.neutralH_allresp_all{c}];
        
        fear_corr = [fear_corr; results.condepochs.fear_corr_all{c}];
        disgust_corr = [disgust_corr; results.condepochs.disgust_corr_all{c}];
        neutral_corr = [neutral_corr; results.condepochs.neutral_corr_all{c}];
        h_corr = [h_corr; results.condepochs.H_corr_all{c}];
        l_corr = [l_corr; results.condepochs.L_corr_all{c}];
        
        fear_incorr = [fear_incorr; results.condepochs.fear_incorr_all{c}];
        disgust_incorr = [disgust_incorr; results.condepochs.disgust_incorr_all{c}];
        neutral_incorr  = [neutral_incorr; results.condepochs.neutral_incorr_all{c}];
        h_incorr = [h_incorr; results.condepochs.H_incorr_all{c}];
        l_incorr = [l_incorr; results.condepochs.L_incorr_all{c}];
        
        fear_noresp = [fear_noresp; results.condepochs.fear_noresp_all{c}];
        disgust_noresp = [disgust_noresp; results.condepochs.disgust_noresp_all{c}];
        neutral_noresp = [neutral_noresp; results.condepochs.neutral_noresp_all{c}];
        h_noresp = [h_noresp; results.condepochs.H_noresp_all{c}];
        l_noresp = [l_noresp; results.condepochs.L_noresp_all{c}];
      
        fear_allresp = [fear_allresp; results.condepochs.fear_allresp_all{c}];
        disgust_allresp =[disgust_allresp; results.condepochs.disgust_allresp_all{c}];
        neutral_allresp = [neutral_allresp; results.condepochs.neutral_allresp_all{c}];
        h_allresp = [h_allresp; results.condepochs.H_allresp_all{c}];
        l_allresp = [l_allresp; results.condepochs.L_allresp_all{c}];
            
            

            else %If the channel was excluded, don't add anything to the concatenated matrix
            end
        clear results %To save memory--these are big files!
        end %Of block loop

    cleaneventsback = [eachevents1back eachevents2back eachevents3back eachevents4back]; %Concatenate clean event codes for all 4 blocks (back-of-head)
    cleaneventsmid = [eachevents1mid eachevents2mid eachevents3mid eachevents4mid];
    cleaneventsfront = [eachevents1front eachevents2front eachevents3front eachevents4front];

    %Now that the ERPs for each block have been collected, average them
    %together & assign them to the correct cell in the overall matrix.
    
               fearL_corr_all{c} = mean(fearL_corr,1);    
               disgustL_corr_all{c} = mean(disgustL_corr,1);
               neutralL_corr_all{c} = mean(neutralL_corr,1);
               fearH_corr_all{c} = mean(fearH_corr,1);    
               disgustH_corr_all{c} = mean(disgustH_corr,1);
               neutralH_corr_all{c} = mean(neutralH_corr,1);
        
               fearL_incorr_all{c} = mean(fearL_incorr,1);    
               disgustL_incorr_all{c} = mean(disgustL_incorr,1);
               neutralL_incorr_all{c} = mean(neutralL_incorr,1);
               fearH_incorr_all{c} = mean(fearH_incorr,1);    
               disgustH_incorr_all{c} = mean(disgustH_incorr,1);
               neutralH_incorr_all{c} = mean(neutralH_incorr,1);
        
               fearL_noresp_all{c} = mean(fearL_noresp,1);    
               disgustL_noresp_all{c} = mean(disgustL_noresp,1);
               neutralL_noresp_all{c} = mean(neutralL_noresp,1);
               fearH_noresp_all{c} = mean(fearH_noresp,1);    
               disgustH_noresp_all{c} = mean(disgustH_noresp,1);
               neutralH_noresp_all{c} = mean(neutralH_noresp,1);
        
        % All resp 3*2
               fearL_allresp_all{c} = mean(fearL_allresp,1);    
               disgustL_allresp_all{c} = mean(disgustL_allresp,1);
               neutralL_allresp_all{c} = mean(neutralL_allresp,1);
               fearH_allresp_all{c} = mean(fearH_allresp,1);    
               disgustH_allresp_all{c} = mean(disgustH_allresp,1);
               neutralH_allresp_all{c} = mean(neutralH_allresp,1);
        
        % Collapse sf
               fear_corr_all{c} = mean(fear_corr,1);    
               disgust_corr_all{c} = mean(disgust_corr,1);
               neutral_corr_all{c} = mean(neutral_corr,1);
        
               fear_incorr_all{c} = mean(fear_incorr,1);    
               disgust_incorr_all{c} = mean(disgust_incorr,1);
               neutral_incorr_all{c} = mean(neutral_incorr,1);
        
               fear_noresp_all{c} = mean(fear_noresp,1);    
               disgust_noresp_all{c} = mean(disgust_noresp,1);
               neutral_noresp_all{c} = mean(neutral_noresp,1);
        
               fear_allresp_all{c} =mean(fear_allresp,1);    
               disgust_allresp_all{c} = mean(disgust_allresp,1);
               neutral_allresp_all{c} = mean(neutral_allresp,1);
        
        % Collapse emo
               l_corr_all{c} = mean(l_corr,1);    
               h_corr_all{c} = mean(h_corr,1);
        
               l_incorr_all{c} = mean(l_incorr,1);    
               h_incorr_all{c} = mean(h_incorr,1);
        
               l_noresp_all{c} = mean(l_noresp,1);    
               h_noresp_all{c} = mean(h_noresp,1);
        
               l_allresp_all{c} = mean(l_allresp,1);    
               h_allresp_all{c} = mean(h_allresp,1);
               
    
    end %Of channel loop    

%Time to save everything!
%Creating save structure "results"
        results.horz = horz; %Will use later to graph
        results.cleanevents.back = cleaneventsback;
        results.cleanevents.middle = cleaneventsmid;
        results.cleanevents.front = cleaneventsfront;
        results.epochdur=epochdur;

        results.condepochs.fearL_corr_all=fearL_corr_all;
        results.condepochs.disgustL_corr_all=disgustL_corr_all;
        results.condepochs.neutralL_corr_all=neutralL_corr_all;
        results.condepochs.fearH_corr_all=fearH_corr_all;
        results.condepochs.disgustH_corr_all=disgustH_corr_all;
        results.condepochs.neutralH_corr_all=neutralH_corr_all;
        
        results.condepochs.fearL_incorr_all=fearL_incorr_all;
        results.condepochs.disgustL_incorr_all=disgustL_incorr_all;
        results.condepochs.neutralL_incorr_all=neutralL_incorr_all;
        results.condepochs.fearH_incorr_all=fearH_incorr_all;
        results.condepochs.disgustH_incorr_all=disgustH_incorr_all;
        results.condepochs.neutralH_incorr_all=neutralH_incorr_all;
        
        results.condepochs.fearL_noresp_all=fearL_noresp_all;
        results.condepochs.disgustL_noresp_all=disgustL_noresp_all;
        results.condepochs.neutralL_noresp_all=neutralL_noresp_all;
        results.condepochs.fearH_noresp_all=fearH_noresp_all;
        results.condepochs.disgustH_noresp_all=disgustH_noresp_all;
        results.condepochs.neutralH_noresp_all=neutralH_noresp_all;
        
        results.condepochs.fearL_allresp_all=fearL_allresp_all;
        results.condepochs.disgustL_allresp_all=disgustL_allresp_all;
        results.condepochs.neutralL_allresp_all=neutralL_allresp_all;
        results.condepochs.fearH_allresp_all=fearH_allresp_all;
        results.condepochs.disgustH_allresp_all=disgustH_allresp_all;
        results.condepochs.neutralH_allresp_all=neutralH_allresp_all;
        
        results.condepochs.fear_corr_all=fear_corr_all;
        results.condepochs.disgust_corr_all=disgust_corr_all;
        results.condepochs.neutral_corr_all=neutral_corr_all;
        results.condepochs.H_corr_all=h_corr_all;
        results.condepochs.L_corr_all=l_corr_all;
        
        results.condepochs.fear_incorr_all=fear_incorr_all;
        results.condepochs.disgust_incorr_all=disgust_incorr_all;
        results.condepochs.neutral_incorr_all=neutral_incorr_all;
        results.condepochs.H_incorr_all=h_incorr_all;
        results.condepochs.L_incorr_all=l_incorr_all;
        
        results.condepochs.fear_noresp_all=fear_noresp_all;
        results.condepochs.disgust_noresp_all=disgust_noresp_all;
        results.condepochs.neutral_noresp_all=neutral_noresp_all;
        results.condepochs.H_noresp_all=h_noresp_all;
        results.condepochs.L_noresp_all=l_noresp_all;
      
        results.condepochs.fear_allresp_all=fear_allresp_all;
        results.condepochs.disgust_allresp_all=disgust_allresp_all;
        results.condepochs.neutral_allresp_all=neutral_allresp_all;
        results.condepochs.H_allresp_all=h_allresp_all;
        results.condepochs.L_allresp_all=l_allresp_all;

eval(['save LHEsub' num2str(l) 'cleanERPs_nomean.mat results';]); %Save it all for each subject

%Add clean event info to big ol' cell array.
alleegcleanevents{l,1} = l; %#ok<AGROW> %Col 1 = subj #
alleegcleanevents{l,2} = length(results.cleanevents.front); %#ok<AGROW> %Col 2 = # of front clean events
alleegcleanevents{l,3} = results.cleanevents.front; %#ok<AGROW> %Col 3 = clean event codes for front-of-head for this subj.
alleegcleanevents{l,4} = length(results.cleanevents.middle); %#ok<AGROW> %Col 4 = # of middle clean events
alleegcleanevents{l,5} = results.cleanevents.middle; %#ok<AGROW>
alleegcleanevents{l,6} = length(results.cleanevents.back); %#ok<AGROW>
alleegcleanevents{l,7} = results.cleanevents.back; %#ok<AGROW>
end %Of subject loop 
save LHEallsubsP1cleanevents.mat alleegcleanevents %This will have 52 empty rows at the top, but whatever


%% Make grand averages.
% Output: LHE_grandpicsERPs
% Last run: 1/13/2012 excluding sub1block1 filler
% Last run: 1/30/2012 for -100 to 600 epoch
% Last ran: 3/19/12 for all 40 subjects without 7 and 23; output:
% LHE_grandpics_40

clear all

allsubs = [1:3 5:6 8:15 17:22 24 25 27:39 41:46]; 
%allsubs = 1:25;
%Preallocate grand avg cell arrays: 1 array for each condition
        fearL_corr_grand = cell(96,1);    
        disgustL_corr_grand = cell(96,1);
        neutralL_corr_grand = cell (96,1);
        fearH_corr_grand = cell(96,1);    
        disgustH_corr_grand = cell(96,1);
        neutralH_corr_grand = cell (96,1);
        
        fearL_incorr_grand = cell(96,1);    
        disgustL_incorr_grand = cell(96,1);
        neutralL_incorr_grand = cell (96,1);
        fearH_incorr_grand = cell(96,1);    
        disgustH_incorr_grand = cell(96,1);
        neutralH_incorr_grand = cell (96,1);
        
        fearL_noresp_grand = cell(96,1);    
        disgustL_noresp_grand = cell(96,1);
        neutralL_noresp_grand = cell (96,1);
        fearH_noresp_grand = cell(96,1);    
        disgustH_noresp_grand = cell(96,1);
        neutralH_noresp_grand = cell (96,1);
        
        % All resp 3*2
        fearL_allresp_grand = cell(96,1);    
        disgustL_allresp_grand = cell(96,1);
        neutralL_allresp_grand = cell (96,1);
        fearH_allresp_grand = cell(96,1);    
        disgustH_allresp_grand = cell(96,1);
        neutralH_allresp_grand = cell (96,1);
        
        % Collapse sf
        fear_corr_grand = cell(96,1);    
        disgust_corr_grand = cell(96,1);
        neutral_corr_grand = cell (96,1);
        
        fear_incorr_grand = cell(96,1);    
        disgust_incorr_grand = cell(96,1);
        neutral_incorr_grand = cell (96,1);
        
        fear_noresp_grand = cell(96,1);    
        disgust_noresp_grand = cell(96,1);
        neutral_noresp_grand = cell (96,1);
        
        fear_allresp_grand = cell(96,1);    
        disgust_allresp_grand = cell(96,1);
        neutral_allresp_grand = cell (96,1);
        
        % Collapse emo
        l_corr_grand = cell(96,1);    
        h_corr_grand = cell(96,1);
        
        l_incorr_grand = cell(96,1);    
        h_incorr_grand = cell(96,1);
        
        l_noresp_grand = cell(96,1);    
        h_noresp_grand = cell(96,1);
        
        l_allresp_grand = cell(96,1);    
        h_allresp_grand = cell(96,1);

for d = 1:96 %For each channel
 %Preallocate condition matrices for this channel
               fearL_corr = [];    
               disgustL_corr = [];
               neutralL_corr = [];
               fearH_corr = [];    
               disgustH_corr = [];
               neutralH_corr = [];
        
               fearL_incorr = [];    
               disgustL_incorr = [];
               neutralL_incorr = [];
               fearH_incorr = [];    
               disgustH_incorr = [];
               neutralH_incorr = [];
        
               fearL_noresp = [];    
               disgustL_noresp = [];
               neutralL_noresp = [];
               fearH_noresp = [];    
               disgustH_noresp = [];
               neutralH_noresp = [];
        
        % All resp 3*2
               fearL_allresp = [];    
               disgustL_allresp = [];
               neutralL_allresp = [];
               fearH_allresp = [];    
               disgustH_allresp = [];
               neutralH_allresp = [];
        
        % Collapse sf
               fear_corr = [];    
               disgust_corr = [];
               neutral_corr = [];
        
               fear_incorr = [];    
               disgust_incorr = [];
               neutral_incorr = [];
        
               fear_noresp = [];    
               disgust_noresp = [];
               neutral_noresp = [];
        
               fear_allresp =[];    
               disgust_allresp = [];
               neutral_allresp = [];
        
        % Collapse emo
               l_corr = [];    
               h_corr = [];
        
               l_incorr = [];    
               h_incorr = [];
        
               l_noresp = [];    
               h_noresp = [];
        
               l_allresp = [];    
               h_allresp = [];
    
    for m = allsubs
    eval(['load LHEsub' num2str(m) 'cleanERPs_nomean.mat results';]); 
        if m == 1 && d == 1 %Only have to do this once
        horz = results.horz; 
        epochdur = results.epochdur; 
        else
        end
        
        fearL_corr = [fearL_corr; results.condepochs.fearL_corr_all{d}];
        disgustL_corr = [disgustL_corr; results.condepochs.disgustL_corr_all{d}];
        neutralL_corr = [neutralL_corr; results.condepochs.neutralL_corr_all{d}];
        fearH_corr = [fearH_corr; results.condepochs.fearH_corr_all{d}];
        disgustH_corr = [disgustH_corr; results.condepochs.disgustH_corr_all{d}];
        neutralH_corr = [neutralH_corr; results.condepochs.neutralH_corr_all{d}];
        
        fearL_incorr = [fearL_incorr; results.condepochs.fearL_incorr_all{d}];
        disgustL_incorr = [disgustL_incorr; results.condepochs.disgustL_incorr_all{d}];
        neutralL_incorr = [neutralL_incorr; results.condepochs.neutralL_incorr_all{d}];
        fearH_incorr = [fearH_incorr; results.condepochs.fearH_incorr_all{d}];
        disgustH_incorr = [disgustH_incorr; results.condepochs.disgustH_incorr_all{d}];
        neutralH_incorr = [neutralH_incorr; results.condepochs.neutralH_incorr_all{d}];
        
        fearL_noresp = [fearL_noresp; results.condepochs.fearL_noresp_all{d}];
        disgustL_noresp = [disgustL_noresp; results.condepochs.disgustL_noresp_all{d}];
        neutralL_noresp = [neutralL_noresp; results.condepochs.neutralL_noresp_all{d}];
        fearH_noresp = [fearH_noresp; results.condepochs.fearH_noresp_all{d}];
        disgustH_noresp = [disgustH_noresp; results.condepochs.disgustH_noresp_all{d}];
        neutralH_noresp = [neutralH_noresp; results.condepochs.neutralH_noresp_all{d}];
        
        fearL_allresp = [fearL_allresp; results.condepochs.fearL_allresp_all{d}];
        disgustL_allresp = [disgustL_allresp; results.condepochs.disgustL_allresp_all{d}];
        neutralL_allresp = [neutralL_allresp; results.condepochs.neutralL_allresp_all{d}];
        fearH_allresp = [fearH_allresp; results.condepochs.fearH_allresp_all{d}];
        disgustH_allresp = [disgustH_allresp; results.condepochs.disgustH_allresp_all{d}];
        neutralH_allresp = [neutralH_allresp; results.condepochs.neutralH_allresp_all{d}];
        
        fear_corr = [fear_corr; results.condepochs.fear_corr_all{d}];
        disgust_corr = [disgust_corr; results.condepochs.disgust_corr_all{d}];
        neutral_corr = [neutral_corr; results.condepochs.neutral_corr_all{d}];
        h_corr = [h_corr; results.condepochs.H_corr_all{d}];
        l_corr = [l_corr; results.condepochs.L_corr_all{d}];
        
        fear_incorr = [fear_incorr; results.condepochs.fear_incorr_all{d}];
        disgust_incorr = [disgust_incorr; results.condepochs.disgust_incorr_all{d}];
        neutral_incorr  = [neutral_incorr; results.condepochs.neutral_incorr_all{d}];
        h_incorr = [h_incorr; results.condepochs.H_incorr_all{d}];
        l_incorr = [l_incorr; results.condepochs.L_incorr_all{d}];
        
        fear_noresp = [fear_noresp; results.condepochs.fear_noresp_all{d}];
        disgust_noresp = [disgust_noresp; results.condepochs.disgust_noresp_all{d}];
        neutral_noresp = [neutral_noresp; results.condepochs.neutral_noresp_all{d}];
        h_noresp = [h_noresp; results.condepochs.H_noresp_all{d}];
        l_noresp = [l_noresp; results.condepochs.L_noresp_all{d}];
      
        fear_allresp = [fear_allresp; results.condepochs.fear_allresp_all{d}];
        disgust_allresp =[disgust_allresp; results.condepochs.disgust_allresp_all{d}];
        neutral_allresp = [neutral_allresp; results.condepochs.neutral_allresp_all{d}];
        h_allresp = [h_allresp; results.condepochs.H_allresp_all{d}];
        l_allresp = [l_allresp; results.condepochs.L_allresp_all{d}];
        
    clear results
    end %Of subject loop
%Averaging ERPs from each subject & assigning them to grand avg cells.    
               fearL_corr_grand{d} = mean(fearL_corr,1);    
               disgustL_corr_grand{d} = mean(disgustL_corr,1);
               neutralL_corr_grand{d} = mean(neutralL_corr,1);
               fearH_corr_grand{d} = mean(fearH_corr,1);    
               disgustH_corr_grand{d} = mean(disgustH_corr,1);
               neutralH_corr_grand{d} = mean(neutralH_corr,1);
        
               fearL_incorr_grand{d} = mean(fearL_incorr,1);    
               disgustL_incorr_grand{d} = mean(disgustL_incorr,1);
               neutralL_incorr_grand{d} = mean(neutralL_incorr,1);
               fearH_incorr_grand{d} = mean(fearH_incorr,1);    
               disgustH_incorr_grand{d} = mean(disgustH_incorr,1);
               neutralH_incorr_grand{d} = mean(neutralH_incorr,1);
        
               fearL_noresp_grand{d} = mean(fearL_noresp,1);    
               disgustL_noresp_grand{d} = mean(disgustL_noresp,1);
               neutralL_noresp_grand{d} = mean(neutralL_noresp,1);
               fearH_noresp_grand{d} = mean(fearH_noresp,1);    
               disgustH_noresp_grand{d} = mean(disgustH_noresp,1);
               neutralH_noresp_grand{d} = mean(neutralH_noresp,1);
        
        % All resp 
               fearL_allresp_grand{d} = mean(fearL_allresp,1);    
               disgustL_allresp_grand{d} = mean(disgustL_allresp,1);
               neutralL_allresp_grand{d} = mean(neutralL_allresp,1);
               fearH_allresp_grand{d} = mean(fearH_allresp,1);    
               disgustH_allresp_grand{d} = mean(disgustH_allresp,1);
               neutralH_allresp_grand{d} = mean(neutralH_allresp,1);
        
        % Collapse sf
               fear_corr_grand{d} = mean(fear_corr,1);    
               disgust_corr_grand{d} = mean(disgust_corr,1);
               neutral_corr_grand{d} = mean(neutral_corr,1);
        
               fear_incorr_grand{d} = mean(fear_incorr,1);    
               disgust_incorr_grand{d} = mean(disgust_incorr,1);
               neutral_incorr_grand{d} = mean(neutral_incorr,1);
        
               fear_noresp_grand{d} = mean(fear_noresp,1);    
               disgust_noresp_grand{d} = mean(disgust_noresp,1);
               neutral_noresp_grand{d} = mean(neutral_noresp,1);
        
               fear_allresp_grand{d} =mean(fear_allresp,1);    
               disgust_allresp_grand{d} = mean(disgust_allresp,1);
               neutral_allresp_grand{d} = mean(neutral_allresp,1);
        
        % Collapse emo
               l_corr_grand{d} = mean(l_corr,1);    
               h_corr_grand{d} = mean(h_corr,1);
        
               l_incorr_grand{d} = mean(l_incorr,1);    
               h_incorr_grand{d} = mean(h_incorr,1);
        
               l_noresp_grand{d} = mean(l_noresp,1);    
               h_noresp_grand{d} = mean(h_noresp,1);
        
               l_allresp_grand{d} = mean(l_allresp,1);    
               h_allresp_grand{d} = mean(h_allresp,1); 
end %Of channel loop

results.horz = horz;
results.epochdur = epochdur;

        results.condepochs.fearL_corr_grand=fearL_corr_grand;
        results.condepochs.disgustL_corr_grand=disgustL_corr_grand;
        results.condepochs.neutralL_corr_grand=neutralL_corr_grand;
        results.condepochs.fearH_corr_grand=fearH_corr_grand;
        results.condepochs.disgustH_corr_grand=disgustH_corr_grand;
        results.condepochs.neutralH_corr_grand=neutralH_corr_grand;
        
        results.condepochs.fearL_incorr_grand=fearL_incorr_grand;
        results.condepochs.disgustL_incorr_grand=disgustL_incorr_grand;
        results.condepochs.neutralL_incorr_grand=neutralL_incorr_grand;
        results.condepochs.fearH_incorr_grand=fearH_incorr_grand;
        results.condepochs.disgustH_incorr_grand=disgustH_incorr_grand;
        results.condepochs.neutralH_incorr_grand=neutralH_incorr_grand;
        
        results.condepochs.fearL_noresp_grand=fearL_noresp_grand;
        results.condepochs.disgustL_noresp_grand=disgustL_noresp_grand;
        results.condepochs.neutralL_noresp_grand=neutralL_noresp_grand;
        results.condepochs.fearH_noresp_grand=fearH_noresp_grand;
        results.condepochs.disgustH_noresp_grand=disgustH_noresp_grand;
        results.condepochs.neutralH_noresp_grand=neutralH_noresp_grand;
        
        results.condepochs.fearL_allresp_grand=fearL_allresp_grand;
        results.condepochs.disgustL_allresp_grand=disgustL_allresp_grand;
        results.condepochs.neutralL_allresp_grand=neutralL_allresp_grand;
        results.condepochs.fearH_allresp_grand=fearH_allresp_grand;
        results.condepochs.disgustH_allresp_grand=disgustH_allresp_grand;
        results.condepochs.neutralH_allresp_grand=neutralH_allresp_grand;
        
        results.condepochs.fear_corr_grand=fear_corr_grand;
        results.condepochs.disgust_corr_grand=disgust_corr_grand;
        results.condepochs.neutral_corr_grand=neutral_corr_grand;
        results.condepochs.H_corr_grand=h_corr_grand;
        results.condepochs.L_corr_grand=l_corr_grand;
        
        results.condepochs.fear_incorr_grand=fear_incorr_grand;
        results.condepochs.disgust_incorr_grand=disgust_incorr_grand;
        results.condepochs.neutral_incorr_grand=neutral_incorr_grand;
        results.condepochs.H_incorr_grand=h_incorr_grand;
        results.condepochs.L_incorr_grand=l_incorr_grand;
        
        results.condepochs.fear_noresp_grand=fear_noresp_grand;
        results.condepochs.disgust_noresp_grand=disgust_noresp_grand;
        results.condepochs.neutral_noresp_grand=neutral_noresp_grand;
        results.condepochs.H_noresp_grand=h_noresp_grand;
        results.condepochs.L_noresp_grand=l_noresp_grand;
      
        results.condepochs.fear_allresp_grand=fear_allresp_grand;
        results.condepochs.disgust_allresp_grand=disgust_allresp_grand;
        results.condepochs.neutral_allresp_grand=neutral_allresp_grand;
        results.condepochs.H_allresp_grand=h_allresp_grand;
        results.condepochs.L_allresp_grand=l_allresp_grand;

save LHE_grandpics_40subs_nomean_080212.mat results
