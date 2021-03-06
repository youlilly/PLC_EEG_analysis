%PLC_EEG_Analyzer3.m
%Created by YY, 1/22/15

%% Extract ERPs
%Sub 48 52 (updated 2/8/15; old rej: 16,48,49,52) be removed from further EEG analysis due to too many
%movements and preculiar extraneous experimental conditions (ie. refusal to
%use chin rest, physiological symptoms during experiment, no contignency
%retained,etc.)

%allsubs = [1:5 7:15 17:44 46 47 50 51 53:57];

%allsubs = [1:5 7:44 46 47 49:51 53:57];
allsubs = [2 7 16 33 37 38 54 55];

backofhead = [1 14:22 25:38 41:50 54:57]; %New channels of interest: back of head
midofhead = [2:13 23:24 39 40 51:53 58:66]; %Middle of head
frontofhead = 67:96; %Front of head
thesections = ['B' 'M' 'F'];
cleaneventall = cell(180, 1);
counter = 0;

for s = allsubs
    
    if s == 56 || s == 15
        bs = 1:5;
    elseif s == 55
        bs = [1:3 5:6];
    else
        bs = 1:6;
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
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_ica_epochs_blc_Barej.set'); %Want to load back-of-head fear file
                thesechans = backofhead; %Channel loop will use back-of-head channels
            elseif v=='M' %If working with mid-of-head file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_ica_epochs_blc_Marej.set'); %Want to load mid-of-head fear file
                thesechans = midofhead;
            elseif v=='F'
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_ica_epochs_blc_Farej.set'); %Want to load front-of-head fear file
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
        
        eval(['save PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Save it all for fear
        clear cleandata %To save memory
        clear results
    end %Of block loop
end %Of subject loop

%% Average ERPs for each block (1-6)

allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53

for s = allsubs
    
    if s == 56 || s == 15
        bs = 1:5;
    elseif s == 55
        bs = [1:3 5:6];
    else
        bs = 1:6;
    end
    
    for b = bs
        if s == 16 || s == 37 || s == 54
            eval(['load PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Save it all for fear
        else
            eval(['load PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs.mat results';]); %Save it all for fear
        end
        
        GrayCSp = cell(96,1);
        GrayCSm = cell(96,1);
        ColCSp = cell(96,1);
        ColCSm = cell(96,1);
        
        for c = 1:96
            if c == 1 %Only have to do this part once for each subj & block (during channel 1)
                horz = results.horz;  %Will become the x-axis later, when graphing
                epochdur = results.epochdur; %Tells us how long the epoch is (in ms)
            end
            
            GrayCSp{c} = mean(results.GrayCSp{c},1);
            GrayCSm{c} = mean(results.GrayCSm{c},1);
            ColCSp{c} = mean(results.ColCSp{c},1);
            ColCSm{c} = mean(results.ColCSm{c},1);
        end
        clear results %To save memory--these are big files!

        results.horz = horz; %Will use later to graph
        results.epochdur=epochdur;
        
        results.GrayCSp = GrayCSp;
        results.GrayCSm = GrayCSm;
        results.ColCSp = ColCSp;
        results.ColCSm = ColCSm;
        
        eval(['save PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]); %Save it all for each subject
        
    end
    
end

%% Average ERPs for Precond blocks.
%allsubs = [1:5 7:15 17:44 46 47 50 51 53:57];
%allsubs = [1:5 7:44 46 47 49:51 53:57];
allsubs = [2 7 16 33 37 38 54 55];

for s = allsubs
    
    bs = 1:3;
    
    %Preallocate cell arrays for each subject's averages.
    GrayCSp = cell(96,1);   
    GrayCSm = cell(96,1);   
    ColCSp = cell(96,1);    
    ColCSm = cell(96,1);   
    
    for c = 1:96 %For each channel
        %Preallocate condition matrices for this channel
        %Preallocate condition matrices
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        
        for b = bs %For each of the 3 blocks of precond
            
            eval(['load PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Load fear file
            eval(['load PLC_EEG_Sub' num2str(s) '_block' num2str(b) '_chaninfo_ica chaninfo']); %Load fear file channel info
            
            
            if c == 1 %Only have to do this part once for each subj & block (during channel 1)  
                if b == 1 %Only have to do this part once for each subject 
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
    
    
    eval(['save PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]); %Save it all for each subject

end %Of subject loop

%% Average ERPs for Postcond blocks.
%allsubs = [1:5 7:15 17:44 46 47 50 51 53:57];
%allsubs = [1:5 7:44 46 47 49:51 53:57];
allsubs = [2 7 16 33 37 38 54 55];

for s = allsubs
    
    if s == 56 || s == 15
        bs = 4:5;
    elseif s == 55
        bs = 5:6;
    else
        bs = 4:6;
    end
    
    %Preallocate cell arrays for each subject's averages.
    GrayCSp = cell(96,1);   
    GrayCSm = cell(96,1);    
    ColCSp = cell(96,1);    
    ColCSm = cell(96,1);    
    
    for c = 1:96 %For each channel
        %Preallocate condition matrices for this channel
        %Preallocate condition matrices
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        
        for b = bs %For each of the 3 blocks of precond
            
            eval(['load PLC_EEG_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Load fear file
            eval(['load PLC_EEG_Sub' num2str(s) '_block' num2str(b) '_chaninfo_ica chaninfo']); %Load fear file channel info
            
            
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
    
    
    eval(['save PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]); %Save it all for each subject

end %Of subject loop



%% Make grand averages-Precond 

clear all

%allsubs = [1:5 7:44 46 47 49:51 53:57];
%allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57];
%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53, 45 subs
%allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

GrayCSp = cell(96,1);
GrayCSm = cell(96,1);
ColCSp = cell(96,1);
ColCSm = cell(96,1);

for c = 1:96 %For each channel
    %Preallocate condition matrices for this channel
    graycsp = [];
    graycsm = [];
    colcsp = [];
    colcsm = [];
    
    for s = allsubs
        
        if s == 16 || s == 37 || s == 54
            eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]);
        else
            eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs.mat results';]);
        end
        
        if s == 1 && c == 1 %Only have to do this once
            horz = results.horz;
            epochdur = results.epochdur;
        else
        end
        
        graycsp = [graycsp; results.GrayCSp{c}];
        graycsm = [graycsm; results.GrayCSm{c}];
        colcsp = [colcsp; results.ColCSp{c}];
        colcsm = [colcsm; results.ColCSm{c}];
        
        
        clear results
    end %Of subject loop
    %Averaging ERPs from each subject & assigning them to grand avg cells.
    GrayCSp{c} = mean(graycsp,1);
    GrayCSm{c} = mean(graycsm,1);
    ColCSp{c} = mean(colcsp,1);
    ColCSm{c} = mean(colcsm,1);
end %Of channel loop

results.horz = horz;
results.epochdur = epochdur;


results.GrayCSp = GrayCSp;
results.GrayCSm = GrayCSm;
results.ColCSp = ColCSp;
results.ColCSm = ColCSm;

save PLC_EEG_GrandAve_Precond_39subs_032315.mat results

%save PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
%save PLC_EEG_GrandAve_Precond_All48subs.mat results
%save PLC_EEG_GrandAve_Precond_All51subs.mat results

%% Make grand averages-Postcond 

clear all

%allsubs = [1:5 7:44 46 47 49:51 53:57];
%allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57]; %list of all 48
%subs
%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
%allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

GrayCSp = cell(96,1);
GrayCSm = cell(96,1);
ColCSp = cell(96,1);
ColCSm = cell(96,1);

for c = 1:96 %For each channel
    %Preallocate condition matrices for this channel
    graycsp = [];
    graycsm = [];
    colcsp = [];
    colcsm = [];
    
    for s = allsubs
        if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]);            
        else
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs.mat results';]);
        end
        
        if s == 1 && c == 1 %Only have to do this once
            horz = results.horz;
            epochdur = results.epochdur;
        else
        end
        
        graycsp = [graycsp; results.GrayCSp{c}];
        graycsm = [graycsm; results.GrayCSm{c}];
        colcsp = [colcsp; results.ColCSp{c}];
        colcsm = [colcsm; results.ColCSm{c}];
        
        
        clear results
    end %Of subject loop
    %Averaging ERPs from each subject & assigning them to grand avg cells.
    GrayCSp{c} = mean(graycsp,1);
    GrayCSm{c} = mean(graycsm,1);
    ColCSp{c} = mean(colcsp,1);
    ColCSm{c} = mean(colcsm,1);
end %Of channel loop

results.horz = horz;
results.epochdur = epochdur;


results.GrayCSp = GrayCSp;
results.GrayCSm = GrayCSm;
results.ColCSp = ColCSp;
results.ColCSm = ColCSm;

save PLC_EEG_GrandAve_Postcond_39subs_032315.mat results

%save PLC_EEG_GrandAve_Postcond_45subsNo2753.mat results

%save PLC_EEG_GrandAve_Postcond_All51subs.mat results

%% Make grand average Pre-Post (block 1-6)

for b = 1:6
    if b == 1 || b == 2 || b == 3 || b==5
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];
    elseif b == 4
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57];
    else
        allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];
    end
    
    GrayCSp = cell(96,1);
    GrayCSm = cell(96,1);
    ColCSp = cell(96,1);
    ColCSm = cell(96,1);
    
    for c = 1:96
        
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        for s = allsubs
            eval(['load PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]);
            if s == 1 && c == 1 %Only have to do this once
                horz = results.horz;
                epochdur = results.epochdur;
            else
            end
            
            graycsp = [graycsp; results.GrayCSp{c}];
            graycsm = [graycsm; results.GrayCSm{c}];
            colcsp = [colcsp; results.ColCSp{c}];
            colcsm = [colcsm; results.ColCSm{c}];
                        
            clear results
        end
        %Averaging ERPs from each subject & assigning them to grand avg cells.
        GrayCSp{c} = mean(graycsp,1);
        GrayCSm{c} = mean(graycsm,1);
        ColCSp{c} = mean(colcsp,1);
        ColCSm{c} = mean(colcsm,1);
        
    end
    
    results.horz = horz;
    results.epochdur = epochdur;
    
    results.GrayCSp = GrayCSp;
    results.GrayCSm = GrayCSm;
    results.ColCSp = ColCSp;
    results.ColCSm = ColCSm;
    
    eval(['save PLC_EEG_GrandAve_Block' num2str(b) '_ERPs_45subsNo2753.mat results';]); %Save it all for each subject
    
end

%% Plot grand average Blockwise
%Ave Precond vs. Block4 
load PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
precond = results;

load PLC_EEG_GrandAve_Block4_ERPs_45subsNo2753.mat results
postcond = results;

horz = precond.horz-200;

mkdir('GrandAveERPs_PrePost_Blockwise_45subs_031515');
cd('GrandAveERPs_PrePost_Blockwise_45subs_031515');

    for c = 30:33;
        figure;
        plot(horz, precond.GrayCSp{c,:} , 'b--'); hold on;
        plot(horz, precond.GrayCSm{c,:} , 'k--');
        plot(horz, precond.ColCSp{c,:} , 'r--');
        plot(horz, precond.ColCSm{c,:} , 'g--');
        
        plot(horz, postcond.GrayCSp{c,:} , 'b'); hold on;
        plot(horz, postcond.GrayCSm{c,:} , 'k');
        plot(horz, postcond.ColCSp{c,:} , 'r');
        plot(horz, postcond.ColCSm{c,:} , 'g');
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'PostB4 Gray CS+', 'PostB4 Gray CS-', 'PostB4 Color CS+', 'PostB4 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePostB4_45subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end
    

%Ave Precond vs. Block5 
load PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
precond = results;

load PLC_EEG_GrandAve_Block5_ERPs_45subsNo2753.mat results
postcond = results;

horz = precond.horz-200;

%mkdir('GrandAveERPs_PrePost_Blockwise_45subs_031515');
cd('GrandAveERPs_PrePost_Blockwise_45subs_031515');

    for c = 30:33;
        figure;
        plot(horz, precond.GrayCSp{c,:} , 'b--'); hold on;
        plot(horz, precond.GrayCSm{c,:} , 'k--');
        plot(horz, precond.ColCSp{c,:} , 'r--');
        plot(horz, precond.ColCSm{c,:} , 'g--');
        
        plot(horz, postcond.GrayCSp{c,:} , 'b'); hold on;
        plot(horz, postcond.GrayCSm{c,:} , 'k');
        plot(horz, postcond.ColCSp{c,:} , 'r');
        plot(horz, postcond.ColCSm{c,:} , 'g');
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'PostB5 Gray CS+', 'PostB5 Gray CS-', 'PostB5 Color CS+', 'PostB5 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePostB5_45subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end
    
    
%Ave Precond vs. Block6 
load PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
precond = results;

load PLC_EEG_GrandAve_Block6_ERPs_45subsNo2753.mat results
postcond = results;

horz = precond.horz-200;

%mkdir('GrandAveERPs_PrePost_Blockwise_45subs_031515');
cd('GrandAveERPs_PrePost_Blockwise_45subs_031515');

    for c = 30:33;
        figure;
        plot(horz, precond.GrayCSp{c,:} , 'b--'); hold on;
        plot(horz, precond.GrayCSm{c,:} , 'k--');
        plot(horz, precond.ColCSp{c,:} , 'r--');
        plot(horz, precond.ColCSm{c,:} , 'g--');
        
        plot(horz, postcond.GrayCSp{c,:} , 'b'); hold on;
        plot(horz, postcond.GrayCSm{c,:} , 'k');
        plot(horz, postcond.ColCSp{c,:} , 'r');
        plot(horz, postcond.ColCSm{c,:} , 'g');
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'PostB6 Gray CS+', 'PostB6 Gray CS-', 'PostB6 Color CS+', 'PostB6 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePostB6_45subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end    
    
%% Plot grand average Pre-Post-Post2


%load PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
load PLC_EEG_GrandAve_Precond_36subsNo27.mat results
precond = results;

clear results
%load PLC_EEG_GrandAve_Postcond_45subsNo2753.mat results
load PLC_EEG_GrandAve_Postcond_36subsNo27.mat results

postcond = results;
clear results
load  PLC_EEG_GrandAve_Postcond2_36subsNo27.mat results
postcond2 = results;

mkdir('GrandAveERPs_36_36subs_030515');
cd('GrandAveERPs_36_36subs_030515');

horz = precond.horz-200;

for c = 30:33%[1 14:22 25:38 41:50 54:57];
    figure;
    plot(horz, precond.GrayCSp{c,:} , 'b:'); hold on;
    plot(horz, precond.GrayCSm{c,:} , 'k:');
    plot(horz, precond.ColCSp{c,:} , 'r:');
    plot(horz, precond.ColCSm{c,:} , 'g:');
    
    plot(horz, postcond.GrayCSp{c,:} , 'b--');
    plot(horz, postcond.GrayCSm{c,:} , 'k--');
    plot(horz, postcond.ColCSp{c,:} , 'r--');
    plot(horz, postcond.ColCSm{c,:} , 'g--');

    plot(horz, postcond2.GrayCSp{c,:} , 'b');
    plot(horz, postcond2.GrayCSm{c,:} , 'k');
    plot(horz, postcond2.ColCSp{c,:} , 'r');
    plot(horz, postcond2.ColCSm{c,:} , 'g');
        
    legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Post2 Gray CS+', 'Post2 Gray CS-', 'Post2 Color CS+', 'Post2 Color CS-', 'Location', 'northwest');
    
    eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePostPost2_36_36_subs_Chan' num2str(c) '.tif'');']);
    close(gcf)
    
    
end

% Oz = [28 30 31 32 44]
% Pz = [24 34 35 36 40];
% Cz = [1 2 38 63 84];
% Fz = [75 81 82 83 86];



%% Plot individual ERPs Pre-Post
clear all
%allsubs = [1:5 7:44 46 47 49:51 53:57];
allsubs = [2 7 16 33 37 38 54 55];

Oz = [28 30 31 32 44];
Pz = [24 34 35 36 40];
Cz = [1 2 38 63 84];
Fz = [75 81 82 83 86];


for s = allsubs
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]);
    precond = results;
    clear results
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]);
    postcond = results;
    clear results
    
horz = precond.horz-200;
    
    for c = [31 35];
        figure;
        plot(horz, precond.GrayCSp{c,:} , 'b--'); hold on;
        plot(horz, precond.GrayCSm{c,:} , 'k--');
        plot(horz, precond.ColCSp{c,:} , 'r--');
        plot(horz, precond.ColCSm{c,:} , 'g--');
        
        plot(horz, postcond.GrayCSp{c,:} , 'b'); hold on;
        plot(horz, postcond.GrayCSm{c,:} , 'k');
        plot(horz, postcond.ColCSp{c,:} , 'r');
        plot(horz, postcond.ColCSm{c,:} , 'g');
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_Sub' num2str(s) '_Chan' num2str(c) '_ica.tif'');']);
        close(gcf)
        
        
    end
    
end

%% Compute individual Oz (A30-B1) ERPs (S1) for Block 4-6 (Postcond)

allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];
Ozchan = 30:33;

for b = 4:6
    if b == 1 || b == 2 || b == 3 || b==5
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];
    elseif b == 4
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57];
    else
        allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];
    end    
    %precond Oz ERPs for each individual
    for s = allsubs
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        eval(['load PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]);
        
        horz =results.horz-200;
        
        for c = Ozchan
            graycsp = [graycsp; results.GrayCSp{c}];
            graycsm = [graycsm; results.GrayCSm{c}];
            colcsp = [colcsp; results.ColCSp{c}];
            colcsm = [colcsm; results.ColCSm{c}];
        end
        Oz.GrayCSp = mean(graycsp,1);
        Oz.GrayCSm = mean(graycsm,1);
        Oz.ColorCSp = mean(colcsp,1);
        Oz.ColorCSm = mean(colcsm,1);
        Oz.hor = horz;
        
        eval(['save PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Oz_ERPs.mat Oz';]);
        
    end
    
end

%% Plot individual Blockwise Oz
for b = 4:6
    if b == 1 || b == 2 || b == 3 || b==5
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];
    elseif b == 4
        allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57];
    else
        allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];
    end
    
    for s = allsubs
        eval(['load PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Oz_ERPs.mat Oz';]);
        
        horz = Oz.hor;
        figure;
        plot(horz, Oz.GrayCSp , 'b-'); hold on;
        plot(horz, Oz.GrayCSm , 'k-');
        plot(horz, Oz.ColorCSp , 'r-');
        plot(horz, Oz.ColorCSm , 'g-');
        legend('Gray CS+','Gray CS-','Color CS+', 'Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_ERP.tif'');']);
        close(gcf)
    end
    
end

%% Compute individual Oz (A30-B1) ERPs (S1) for Precond and Postcond
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 Subs
%allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57];
Ozchan = [31:34 26 27 42 43]%[31:34];%[31:33 27 43];%[31:34 26 27 42 43]; %new oz channels 07/19/15
allERPsColor = [];
allERPsGray = [];

%precond Oz ERPs for each individual
for s = allsubs
    graycsp = [];
    graycsm = [];
    colcsp = [];
    colcsm = [];
    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs.mat results';]);
    end
    horz =results.horz-200;
    
    for c = Ozchan
        graycsp = [graycsp; results.GrayCSp{c}];
        graycsm = [graycsm; results.GrayCSm{c}];
        colcsp = [colcsp; results.ColCSp{c}];
        colcsm = [colcsm; results.ColCSm{c}];
    end
    Oz.GrayCSp = mean(graycsp,1);
    Oz.GrayCSm = mean(graycsm,1);
    Oz.ColorCSp = mean(colcsp,1);
    Oz.ColorCSm = mean(colcsm,1);
    Oz.hor = horz;
   % eval(['save PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    
    allERPsColor = [allERPsColor; Oz.ColorCSp; Oz.ColorCSm];
    allERPsGray = [allERPsGray; Oz.GrayCSp; Oz.GrayCSm];
end
grandygrandprec = mean(allERPsColor,1); %Make the grand-grand average
grandygrandpreg = mean(allERPsGray,1);

%postcond ERPs for each individual
allERPsColor = [];
allERPsGray = [];

for s = allsubs
    graycsp = [];
    graycsm = [];
    colcsp = [];
    colcsm = [];
    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs.mat results';]);
    end
    horz =results.horz-200;
    
    for c = Ozchan
        graycsp = [graycsp; results.GrayCSp{c}];
        graycsm = [graycsm; results.GrayCSm{c}];
        colcsp = [colcsp; results.ColCSp{c}];
        colcsm = [colcsm; results.ColCSm{c}];
    end
    Oz.GrayCSp = mean(graycsp,1);
    Oz.GrayCSm = mean(graycsm,1);
    Oz.ColorCSp = mean(colcsp,1);
    Oz.ColorCSm = mean(colcsm,1);
    Oz.horz = horz;
  %  eval(['save PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    
    allERPsColor = [allERPsColor; Oz.ColorCSp; Oz.ColorCSm];
    allERPsGray = [allERPsGray; Oz.GrayCSp; Oz.GrayCSm];
    
end
grandygrandpostc = mean(allERPsColor,1); %Make the grand-grand average
grandygrandpostg = mean(allERPsGray,1);

grandycolor = [grandygrandprec; grandygrandpostc]; grandycolor = mean(grandycolor,1);
grandygray = [grandygrandpreg; grandygrandpostg]; grandygray = mean(grandygray,1);

figure;
plot(horz, grandycolor); hold on; %this plots the grand ERP for color condition across CS+/CS-, across Pre/Postcond for S1
plot(horz, grandygray);%this plots the grand ERP for gray condition across CS+/CS-, across Pre/Postcond for S1

% saveas(gcf, 'GrandColor_Gray_average_45subs.jpg');
% save GrandColor_Gray_ERP horz grandycolor grandygray
%Last updated 02/26/15
%Inspection of grandycolor along with the graph identifies 
%C1 trough:69; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114

%% Get mean amplitudes for each individual - Precond
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53

AllColorC1P1C2 = [];
AllColor150_300 = [];
AllGrayP1 = [];
AllGray150_300 = [];

ColorCSpC1P1 = [];%look at trough-to-peak C1-P1 amplitude difference: 75:78
ColorCSpC2 = [];%look at 9 datapoints window centered on point 86: 82:90
ColorCSp150_175 = []; %datapoint 90:96
ColorCSp175_200 = []; %datapoint 96:102
ColorCSp200_225 = []; %datapoint 102:109
ColorCSp225_250 = []; %datapoint 109:115
ColorCSp250_275 = []; %datapoint 115:122
ColorCSp275_300 = []; %datapoint 122:128

ColorCSmC1P1 = []; 
ColorCSmC2 = [];
ColorCSm150_175 = []; %datapoint 90:96
ColorCSm175_200 = []; %datapoint 96:102
ColorCSm200_225 = []; %datapoint 102:109
ColorCSm225_250 = []; %datapoint 109:115
ColorCSm250_275 = []; %datapoint 115:122
ColorCSm275_300 = []; %datapoint 122:128

GrayCSpP1 = []; %81:89
GrayCSp150_175 = []; %datapoint 90:96
GrayCSp175_200 = []; %datapoint 96:102
GrayCSp200_225 = []; %datapoint 102:109
GrayCSp225_250 = []; %datapoint 109:115
GrayCSp250_275 = []; %datapoint 115:122
GrayCSp275_300 = []; %datapoint 122:128

GrayCSmP1 = [];
GrayCSm150_175 = []; %datapoint 90:96
GrayCSm175_200 = []; %datapoint 96:102
GrayCSm200_225 = []; %datapoint 102:109
GrayCSm225_250 = []; %datapoint 108:114
GrayCSm250_275 = []; %datapoint 115:122
GrayCSm275_300 = []; %datapoint 122:128

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));
    ColorCSp150_175 = mean(Oz.ColorCSp(90:96));
    ColorCSp175_200 = mean(Oz.ColorCSp(96:102));
    ColorCSp200_225 = mean(Oz.ColorCSp(102:109));
    ColorCSp225_250 = mean(Oz.ColorCSp(109:115));
    ColorCSp250_275 = mean(Oz.ColorCSp(115:122));
    ColorCSp275_300 = mean(Oz.ColorCSp(122:128));
                            
    ColorCSmC1P1 =  Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));
    ColorCSm150_175 = mean(Oz.ColorCSm(90:96));
    ColorCSm175_200 = mean(Oz.ColorCSm(96:102));
    ColorCSm200_225 = mean(Oz.ColorCSm(102:109));
    ColorCSm225_250 = mean(Oz.ColorCSm(109:115));
    ColorCSm250_275 = mean(Oz.ColorCSm(115:122));
    ColorCSm275_300 = mean(Oz.ColorCSm(122:128));
    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSp150_175 = mean(Oz.GrayCSp(90:96));
    GrayCSp175_200 = mean(Oz.GrayCSp(96:102));
    GrayCSp200_225 = mean(Oz.GrayCSp(102:109));
    GrayCSp225_250 = mean(Oz.GrayCSp(109:115));
    GrayCSp250_275 = mean(Oz.GrayCSp(115:122));
    GrayCSp275_300 = mean(Oz.GrayCSp(122:128));
    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSm150_175 = mean(Oz.GrayCSm(90:96));
    GrayCSm175_200 = mean(Oz.GrayCSm(96:102));
    GrayCSm200_225 = mean(Oz.GrayCSm(102:109));
    GrayCSm225_250 = mean(Oz.GrayCSm(109:115));
    GrayCSm250_275 = mean(Oz.GrayCSm(115:122));
    GrayCSm275_300 = mean(Oz.GrayCSm(122:128));
        
AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllColor150_300 = [AllColor150_300; s ColorCSp150_175 ColorCSm150_175 ColorCSp175_200 ColorCSm175_200 ColorCSp200_225 ColorCSm200_225 ColorCSp225_250 ColorCSm225_250 ColorCSp250_275 ColorCSm250_275 ColorCSp275_300 ColorCSm275_300];
AllGrayP1 = [AllGrayP1; s GrayCSpP1 GrayCSmP1];
AllGray150_300 = [AllGray150_300; s GrayCSp150_175 GrayCSm150_175 GrayCSp175_200 GrayCSm175_200 GrayCSp200_225 GrayCSm200_225 GrayCSp225_250 GrayCSm225_250 GrayCSp250_275 GrayCSm250_275 GrayCSp275_300 GrayCSm275_300];
        
end

save PLC_EEG_Precond_MeanAmp_45subs AllColorC1P1C2 AllColor150_300 AllGrayP1 AllGray150_300


%%  Get mean amplitudes for each individual: postcond

clear Oz
AllColorC1P1C2 = [];
AllColor150_300 = [];
AllGrayP1 = [];
AllGray150_300 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));
    ColorCSp150_175 = mean(Oz.ColorCSp(90:96));
    ColorCSp175_200 = mean(Oz.ColorCSp(96:102));
    ColorCSp200_225 = mean(Oz.ColorCSp(102:109));
    ColorCSp225_250 = mean(Oz.ColorCSp(109:115));
    ColorCSp250_275 = mean(Oz.ColorCSp(115:122));
    ColorCSp275_300 = mean(Oz.ColorCSp(122:128));
                            
    ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));
    ColorCSm150_175 = mean(Oz.ColorCSm(90:96));
    ColorCSm175_200 = mean(Oz.ColorCSm(96:102));
    ColorCSm200_225 = mean(Oz.ColorCSm(102:109));
    ColorCSm225_250 = mean(Oz.ColorCSm(109:115));
    ColorCSm250_275 = mean(Oz.ColorCSm(115:122));
    ColorCSm275_300 = mean(Oz.ColorCSm(122:128));
    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSp150_175 = mean(Oz.GrayCSp(90:96));
    GrayCSp175_200 = mean(Oz.GrayCSp(96:102));
    GrayCSp200_225 = mean(Oz.GrayCSp(102:109));
    GrayCSp225_250 = mean(Oz.GrayCSp(109:115));
    GrayCSp250_275 = mean(Oz.GrayCSp(115:122));
    GrayCSp275_300 = mean(Oz.GrayCSp(122:128));
    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSm150_175 = mean(Oz.GrayCSm(90:96));
    GrayCSm175_200 = mean(Oz.GrayCSm(96:102));
    GrayCSm200_225 = mean(Oz.GrayCSm(102:109));
    GrayCSm225_250 = mean(Oz.GrayCSm(109:115));
    GrayCSm250_275 = mean(Oz.GrayCSm(115:122));
    GrayCSm275_300 = mean(Oz.GrayCSm(122:128));

AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllColor150_300 = [AllColor150_300; s ColorCSp150_175 ColorCSm150_175 ColorCSp175_200 ColorCSm175_200 ColorCSp200_225 ColorCSm200_225 ColorCSp225_250 ColorCSm225_250 ColorCSp250_275 ColorCSm250_275 ColorCSp275_300 ColorCSm275_300];
AllGrayP1 = [AllGrayP1; s GrayCSpP1 GrayCSmP1];
AllGray150_300 = [AllGray150_300; s GrayCSp150_175 GrayCSm150_175 GrayCSp175_200 GrayCSm175_200 GrayCSp200_225 GrayCSm200_225 GrayCSp225_250 GrayCSm225_250 GrayCSp250_275 GrayCSm250_275 GrayCSp275_300 GrayCSm275_300];
    
end


save PLC_EEG_Postcond_MeanAmp_45subs AllColorC1P1C2 AllColor150_300 AllGrayP1 AllGray150_300


%%  Get mean amplitudes for each individual: precond; 3/19/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:69; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110; N3 peak:
%125

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114; 

%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

clear Oz
AllColorC2N3 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(83:88));
    ColorCSpN3 = mean(Oz.ColorCSp(122:128));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(83:88));
    ColorCSmN3 = mean(Oz.ColorCSm(122:128));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:88));
    GrayCSpN1 = mean(Oz.GrayCSp(99:105));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(83:88));
    GrayCSmN1 = mean(Oz.GrayCSm(99:105));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2N3 = [AllColorC2N3; s ColorCSpC2 ColorCSmC2 ColorCSpN3 ColorCSmN3];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end


save PLC_EEG_PrecondNewComponents_MeanAmp_39subs AllColorC2N3 AllGrayP1N1P2


%%  Get mean amplitudes for each individual: precond; 3/22/15

%Use individual peak for each component

%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(84:88));
    ColorCSpP2 = mean(Oz.ColorCSp(99:123));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(98:122));
    
    GrayCSpP1 = mean(Oz.GrayCSp(82:88));
    GrayCSpN1 = mean(Oz.GrayCSp(95:105));
    GrayCSpP2 = mean(Oz.GrayCSp(107:117)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(81:87));
    GrayCSmN1 = mean(Oz.GrayCSm(93:103));
    GrayCSmP2 = mean(Oz.GrayCSm(108:118)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end


save PLC_EEG_PrecondNewComponents_MeanAmp_39subs AllColorC2P2 AllGrayP1N1P2

%%  Get mean amplitudes for each individual: postcond; 3/22/15

%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(85:89));
    ColorCSpP2 = mean(Oz.ColorCSp(97:121));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(97:121));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(106:116)); %using a broader window here
    
    GrayCSmP1 = mean(Oz.GrayCSm(82:88));
    GrayCSmN1 = mean(Oz.GrayCSm(92:102));
    GrayCSmP2 = mean(Oz.GrayCSm(106:116)); %using a broader window here
%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end


save PLC_EEG_PostcondNewComponents_MeanAmp_39subs AllColorC2P2 AllGrayP1N1P2

%%  Get mean amplitudes for each individual: postcond; 3/19/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:69; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110; N3 peak:
%125

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114; 

%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

clear Oz
AllColorC2N3 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(83:88));
    ColorCSpN3 = mean(Oz.ColorCSp(122:128));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(83:88));
    ColorCSmN3 = mean(Oz.ColorCSm(122:128));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:88));
    GrayCSpN1 = mean(Oz.GrayCSp(99:105));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here
    
    GrayCSmP1 = mean(Oz.GrayCSm(83:88));
    GrayCSmN1 = mean(Oz.GrayCSm(99:105));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2N3 = [AllColorC2N3; s ColorCSpC2 ColorCSmC2 ColorCSpN3 ColorCSmN3];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end


save PLC_EEG_PostcondNewComponents_MeanAmp_39subs AllColorC2N3 AllGrayP1N1P2

%%  Get mean amplitudes for each individual: postcond B4; 3/22/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:61; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114

allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 56]; %39 subs

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(85:89));
    ColorCSpP2 = mean(Oz.ColorCSp(97:121));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(97:121));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(106:116)); %using a broader window here
    
    GrayCSmP1 = mean(Oz.GrayCSm(82:88));
    GrayCSmN1 = mean(Oz.GrayCSm(92:102));
    GrayCSmP2 = mean(Oz.GrayCSm(106:116)); %using a broader window here
%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_PostcondB4_NewComponents_MeanAmp_39subs AllColorC2P2 AllGrayP1N1P2

%% B5

allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 55 56]; %39 subs

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(85:89));
    ColorCSpP2 = mean(Oz.ColorCSp(97:121));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(97:121));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(106:116)); %using a broader window here
    
    GrayCSmP1 = mean(Oz.GrayCSm(82:88));
    GrayCSmN1 = mean(Oz.GrayCSm(92:102));
    GrayCSmP2 = mean(Oz.GrayCSm(106:116)); %using a broader window here
%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_PostcondB5_NewComponents_MeanAmp_39subs AllColorC2P2 AllGrayP1N1P2

%% B6
allsubs = [1 3:4 8:11 13:14 16:29 33 34 38:40 42:44 46 47 50 51 54 55]; %39 subs

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(85:89));
    ColorCSpP2 = mean(Oz.ColorCSp(97:121));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(97:121));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(106:116)); %using a broader window here
    
    GrayCSmP1 = mean(Oz.GrayCSm(82:88));
    GrayCSmN1 = mean(Oz.GrayCSm(92:102));
    GrayCSmP2 = mean(Oz.GrayCSm(106:116)); %using a broader window here
%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_PostcondB6_NewComponents_MeanAmp_39subs AllColorC2P2 AllGrayP1N1P2


%% Exploratory point-by-point ttest of Time(Pre/Post)*CS(+/-) interaction
%Color condition, early time window
clear all

allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %removing 2,7,53,5,12,31,37,41,57 


PersonSCR = [-0.64	-0.88	-0.76	-0.121536792	-0.132784119	-0.656143367	0.17686803
-0.02	0.41	0.2	-0.221098569	0.213223158	0.058999586	-0.513570278
-0.33	-0.02	-0.17	0.139763219	-0.043098606	0.136588615	0.222174489
0.91	0.7	0.81	0.315867096	0.059905254	0.034403775	0.110258014
1.22	1.7	1.46	0.36877096	-0.491990139	-0.244130005	-0.126695903
1.22	-0.45	0.39	0.09901012	-0.157021963	-0.111113756	-0.127030862
-0.64	-0.88	-0.76	0.023106227	0.022587258	-0.058291022	0.13200743
-1.57	-1.02	-1.3	-0.139188915	-0.147945488	0.052168776	0.204931212
-0.95	-0.88	-0.91	0.379443926	0.043633345	-0.233022243	0.44399057
0.6	-0.88	-0.14	-0.078448693	-0.004932663	-0.423464072	-0.072641723
-1.88	-1.02	-1.45	0.141901832	0.08047412	0.368625552	-0.062432981
-1.88	0.99	-0.45	-0.040906923	0.018814522	0.18505544	-0.001740027
0.603670406	-0.161709278	0.220980564	0.569641514	0.342857485	-0.320719201	-0.02546786
-0.02	-1.17	-0.59	0.264525325	0.02816996	0.668320256	-0.072209671
0.29	0.99	0.64	0.168769341	-0.012218746	0.027660877	0.257481963
-0.02	-1.17	-0.59	-0.097414847	0.124333057	0.001831439	0.221225735
-0.33	-0.16	-0.24	-0.038107585	0.166154016	-0.063838311	0.062883983
-0.64	0.41	-0.11	-0.047451922	-0.103875478	-0.035977624	0.623207397
-0.33	0.27	-0.03	-0.355755034	-0.315810171	-0.071418923	-0.047493077
0.29	2.28	1.29	-0.198523144	-0.108344191	0.047619308	-0.297792088
1.22	0.7	0.96	-0.103234703	0.050281366	0.0275141	0.015089005
1.22	1.27	1.25	0.304204643	0.29217203	0.241923392	-0.181772084
-1.57	-0.31	-0.94	-0.115530829	-0.233143978	-0.169994163	0.07354553
0.29	0.56	0.42	-0.151165652	-0.233003507	-0.166396738	0.074125416
-1.57	1.42	-0.08	-0.254398174	0.142865601	-0.375734804	0.033990428
-0.33	-1.02	-0.67	0.229313752	0.250467973	0.032532328	0.054925349
0.29	-0.74	-0.22	0.185501308	0.025087202	-0.359806717	0.029847246
-0.64	-0.74	-0.69	0.010207711	0.051588986	-0.214563174	0.090920819
-0.33	-1.17	-0.75	-0.011989929	0.118593346	-0.112426785	-0.26309504
1.22	2.56	1.89	-0.041497311	0.392906764	0.308094454	-0.180899225
-0.64	0.13	-0.26	-0.003450558	-0.011161584	-0.229070495	-0.030300141
1.84	0.84	1.34	0.099551071	-0.123122405	0.320852966	-0.094244569
0.29	-1.17	-0.44	-0.60307947	-0.344911395	0.254558509	0.167912239
0.91	0.27	0.59	-0.140133381	-0.048098821	0.045917893	-0.082668232
1.53	-0.02	0.76	-0.291805415	0.04449716	-0.29640455	-0.012377936
0.91	-1.02	-0.05	0.360509487	-0.262573594	-0.259144626	0.069882532
0.29	-0.88	-0.29	-0.42510864	-0.216558757	-0.018030172	0.206873333
-1.57	-0.88	-1.22	-0.194993828	0.11694365	0.044729962	0.333536848
-0.33	-0.59	-0.46	-0.227142315	-0.104696288	0.364761011	0.297901282];

BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
PostColorSCRCSd = PersonSCR(:,6);
PostGraySCRCSd = PersonSCR(:,7);


%%
allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.ColorCSp - Postcond.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
end

PreColorCSp = mean(PrecondColorCSp,1);
PreColorCSm = mean(PrecondColorCSm,1);
PostColorCSp = mean(PostcondColorCSp,1);
PostColorCSm = mean(PostcondColorCSm,1);

[themin, PreColorCSpC2peak] = min(PreColorCSp(81:91)); % 81+6-1 = 86
[themin, PreColorCSmC2peak] = min(PreColorCSm(81:91)); % 86
[themin, PostColorCSpC2peak] = min(PostColorCSp(81:91)); % 87
[themin, PostColorCSmC2peak] = min(PostColorCSm(81:91));% 86

[themax, PreColorCSpP2peak] = max(PreColorCSp(103:116)); % 103+9-1 = 111
[themax, PreColorCSmP2peak] = max(PreColorCSm(103:116)); % 110
[themax, PostColorCSpP2peak] = max(PostColorCSp(103:116)); % 109
[themax, PostColorCSmP2peak] = max(PostColorCSm(103:116)); % 109

%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];
end

tallyp = [allPs' allrpi' allrpscr'];

% plotting waveforms with p values
 horz = Precond.horz;
% 
plot(horz, mean(PrecondColorCSp,1) , 'r-.'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g-.');

plot(horz, mean(PostcondColorCSp,1) , 'r-');
plot(horz, mean(PostcondColorCSm,1) , 'g-');
% 
 plot(horz,allPs, 'k'); %interaction
 plot(horz,allrpi+1, 'k--'); %interaction~BISz
 plot(horz,allrpscr+2, 'k-.'); %interaction~SCR

line([horz(83) horz(83)],[0 -7]);
line([horz(88) horz(88)],[0 -7]);

%line([horz(122) horz(122)],[0 -7]);


legend('Pre Color CS+', 'Pre Color CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost_ColorERPs_Oz31_34_39subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

% %ttest for interaction for C1P1 trough-to-peak difference
% c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
% [H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1, pc1p1 = 0.0031
% 
% %ttest for interaction for P1C2 peak-to-trough difference
% p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
% [H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0, pp1c2 = 0.19

save PrePostAve_Oz31_34_39subs_Color_TimebyCS.mat

%% Gray condition, early time window
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %removing 2,7,53,5,12,31,37,41,57 
allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];

PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.GrayCSp - Postcond.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];
end

PreGrayCSp = mean(PrecondGrayCSp,1);
PreGrayCSm = mean(PrecondGrayCSm,1);
PostGrayCSp = mean(PostcondGrayCSp,1);
PostGrayCSm = mean(PostcondGrayCSm,1);

[themax, PreGrayCSpP1peak] = max(PreGrayCSp(81:91)); % 85
[themax, PreGrayCSmP1peak] = max(PreGrayCSm(81:91)); % 84
[themax, PostGrayCSpP1peak] = max(PostGrayCSp(81:91)); % 86
[themax, PostGrayCSmP1peak] = max(PostGrayCSm(81:91));% 85

[themin, PreGrayCSpN1peak] = min(PreGrayCSp(91:107)); % 91+10-1 = 100
[themin, PreGrayCSmN1peak] = min(PreGrayCSm(91:107)); % 91+8-1 = 98
[themin, PostGrayCSpN1peak] = min(PostGrayCSp(91:107)); % 91+11-1 = 101
[themin, PostGrayCSmN1peak] = min(PostGrayCSm(91:107)); % 91+7-1 = 97

[themax, PreGrayCSpP2peak] = max(PreGrayCSp(107:122)); % 107+6-1 = 112
[themax, PreGrayCSmP2peak] = max(PreGrayCSm(107:122)); % 107+7-1 = 113
[themax, PostGrayCSpP2peak] = max(PostGrayCSp(107:122)); % 107+5-1 = 111
[themax, PostGrayCSmP2peak] = max(PostGrayCSm(107:122));% 107+5-1 = 111

%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostGraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

tallyp = [allPs' allrpi' allrpscr'];

%plotting
horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(PostcondGrayCSp,1) , 'b-');
plot(horz, mean(PostcondGrayCSm,1) , 'g-');

 plot(horz,allPs-2, 'r');
 plot(horz,allrpi-1, 'r--');
 plot(horz,allrpscr, 'k-');

line([horz(82) horz(82)],[0 6]);
line([horz(88) horz(88)],[0 6]);

%line([horz(99) horz(99)],[0 6]);
%line([horz(105) horz(105)],[0 6]);

%line([horz(104) horz(104)],[0 6]);
%line([horz(124) horz(124)],[0 6]);
legend('Pre Gray CS+', 'Pre Gray CS-', 'Post Gray CS+', 'Post Gray CS-', 'Location', 'northwest');
saveas(gcf, 'PrePost_GrayERPs_Oz31_34_39subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

save PrePostAve_Oz31_34_39subs_Gray_TimebyCS.mat

%% Plot Grand Average ERP Pre-Post Color/Gray at Oz - 3.23.15
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %39 subs

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];    
end

PreColorCSp = mean(PrecondColorCSp,1);
PreColorCSm = mean(PrecondColorCSm,1);
PostColorCSp = mean(PostcondColorCSp,1);
PostColorCSm = mean(PostcondColorCSm,1);

PreGrayCSp = mean(PrecondGrayCSp,1);
PreGrayCSm = mean(PrecondGrayCSm,1);
PostGrayCSp = mean(PostcondGrayCSp,1);
PostGrayCSm = mean(PostcondGrayCSm,1);

horz = Precond.horz;

plot(horz,PreColorCSp , 'r-.'); hold on;
plot(horz,PreColorCSm , 'g-.');

plot(horz, PostColorCSp , 'r-');
plot(horz, PostColorCSm , 'g-');

plot(horz, PreGrayCSp, 'b-.'); 
plot(horz, PreGrayCSm , 'k-.');

plot(horz, PostGrayCSp , 'b-');
plot(horz, PostGrayCSm , 'k-');

line([horz(81) horz(81)],[4 -7]);
line([horz(83) horz(83)],[4 -7]);
line([horz(87) horz(87)],[4 -7]);
line([horz(88) horz(88)],[4 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post Color CS+', 'Post Color CS-', 'Pre Gray CS+', 'Pre Gray CS-', 'Post Gray CS+', 'Post Gray CS-','Location', 'southwest');

%% Plot Grand Average ERP Pre-PostB4 Color/Gray at Oz - 3.23.15
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 56]; %39 subs

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];    
end

PreColorCSp = mean(PrecondColorCSp,1);
PreColorCSm = mean(PrecondColorCSm,1);
PostColorCSp = mean(PostcondColorCSp,1);
PostColorCSm = mean(PostcondColorCSm,1);

PreGrayCSp = mean(PrecondGrayCSp,1);
PreGrayCSm = mean(PrecondGrayCSm,1);
PostGrayCSp = mean(PostcondGrayCSp,1);
PostGrayCSm = mean(PostcondGrayCSm,1);

horz = Precond.horz;

plot(horz,PreColorCSp , 'r-.'); hold on;
plot(horz,PreColorCSm , 'g-.');

plot(horz, PostColorCSp , 'r-');
plot(horz, PostColorCSm , 'g-');

plot(horz, PreGrayCSp, 'b-.'); 
plot(horz, PreGrayCSm , 'k-.');

plot(horz, PostGrayCSp , 'b-');
plot(horz, PostGrayCSm , 'k-');

line([horz(81) horz(81)],[4 -7]);
line([horz(83) horz(83)],[4 -7]);
line([horz(87) horz(87)],[4 -7]);
line([horz(88) horz(88)],[4 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'PostB4 Color CS+', 'PostB4 Color CS-', 'Pre Gray CS+', 'Pre Gray CS-', 'PostB4 Gray CS+', 'PostB4 Gray CS-','Location', 'southwest');



%% Exploratory point-by-point ttest of Time(Pre/PostB4)*CS(+/-) interaction
%Color condition B4, early time window
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 56]; %removing 2,7,53,5,12,31,37,41,57,55 

PersonSCR = [-0.64	-0.88	-0.76	-0.121536792	-0.132784119	-0.656143367	0.17686803
-0.02	0.41	0.2	-0.221098569	0.213223158	0.058999586	-0.513570278
-0.33	-0.02	-0.17	0.139763219	-0.043098606	0.136588615	0.222174489
0.91	0.7	0.81	0.315867096	0.059905254	0.034403775	0.110258014
1.22	1.7	1.46	0.36877096	-0.491990139	-0.244130005	-0.126695903
1.22	-0.45	0.39	0.09901012	-0.157021963	-0.111113756	-0.127030862
-0.64	-0.88	-0.76	0.023106227	0.022587258	-0.058291022	0.13200743
-1.57	-1.02	-1.3	-0.139188915	-0.147945488	0.052168776	0.204931212
-0.95	-0.88	-0.91	0.379443926	0.043633345	-0.233022243	0.44399057
0.6	-0.88	-0.14	-0.078448693	-0.004932663	-0.423464072	-0.072641723
-1.88	-1.02	-1.45	0.141901832	0.08047412	0.368625552	-0.062432981
-1.88	0.99	-0.45	-0.040906923	0.018814522	0.18505544	-0.001740027
0.603670406	-0.161709278	0.220980564	0.569641514	0.342857485	-0.320719201	-0.02546786
-0.02	-1.17	-0.59	0.264525325	0.02816996	0.668320256	-0.072209671
0.29	0.99	0.64	0.168769341	-0.012218746	0.027660877	0.257481963
-0.02	-1.17	-0.59	-0.097414847	0.124333057	0.001831439	0.221225735
-0.33	-0.16	-0.24	-0.038107585	0.166154016	-0.063838311	0.062883983
-0.64	0.41	-0.11	-0.047451922	-0.103875478	-0.035977624	0.623207397
-0.33	0.27	-0.03	-0.355755034	-0.315810171	-0.071418923	-0.047493077
0.29	2.28	1.29	-0.198523144	-0.108344191	0.047619308	-0.297792088
1.22	0.7	0.96	-0.103234703	0.050281366	0.0275141	0.015089005
1.22	1.27	1.25	0.304204643	0.29217203	0.241923392	-0.181772084
-1.57	-0.31	-0.94	-0.115530829	-0.233143978	-0.169994163	0.07354553
0.29	0.56	0.42	-0.151165652	-0.233003507	-0.166396738	0.074125416
-1.57	1.42	-0.08	-0.254398174	0.142865601	-0.375734804	0.033990428
-0.33	-1.02	-0.67	0.229313752	0.250467973	0.032532328	0.054925349
0.29	-0.74	-0.22	0.185501308	0.025087202	-0.359806717	0.029847246
-0.64	-0.74	-0.69	0.010207711	0.051588986	-0.214563174	0.090920819
-0.33	-1.17	-0.75	-0.011989929	0.118593346	-0.112426785	-0.26309504
1.22	2.56	1.89	-0.041497311	0.392906764	0.308094454	-0.180899225
-0.64	0.13	-0.26	-0.003450558	-0.011161584	-0.229070495	-0.030300141
1.84	0.84	1.34	0.099551071	-0.123122405	0.320852966	-0.094244569
0.29	-1.17	-0.44	-0.60307947	-0.344911395	0.254558509	0.167912239
0.91	0.27	0.59	-0.140133381	-0.048098821	0.045917893	-0.082668232
1.53	-0.02	0.76	-0.291805415	0.04449716	-0.29640455	-0.012377936
0.91	-1.02	-0.05	0.360509487	-0.262573594	-0.259144626	0.069882532
0.29	-0.88	-0.29	-0.42510864	-0.216558757	-0.018030172	0.206873333
-0.33	-0.59	-0.46	-0.227142315	-0.104696288	0.364761011	0.297901282];

BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
PostColorSCRCSd = PersonSCR(:,6);
PostGraySCRCSd = PersonSCR(:,7);

allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];


BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
PostColorSCRCSd = PersonSCR(:,6);
PostGraySCRCSd = PersonSCR(:,7);

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.ColorCSp - Postcond.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
end
%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r-.'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g-.');

plot(horz, mean(PostcondColorCSp,1) , 'r-');
plot(horz, mean(PostcondColorCSm,1) , 'g-');

% plot(horz,allPs, 'k');
% plot(horz,allrpi+1, 'k--');
% plot(horz,allrpscr+2, 'k-.');

line([horz(83) horz(83)],[0 -7]);
line([horz(88) horz(88)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post B4 Color CS+', 'Post B4 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB4_ColorERPs_39subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

% %ttest for interaction for C1P1 trough-to-peak difference
% c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
% [H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1, pc1p1 = 0.0031
% 
% %ttest for interaction for P1C2 peak-to-trough difference
% p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
% [H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0, pp1c2 = 0.19

%save PrePostB4_39subs_Color_TimebyCS.mat


%% Gray condition
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 56]; %removing 2,7,53,5,12,31,37,41,57 
allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];


PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.GrayCSp - Postcond.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];
end

%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostGraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(PostcondGrayCSp,1) , 'b-');
plot(horz, mean(PostcondGrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 7]);
line([horz(89) horz(89)],[0 7]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post B4 Gray CS+', 'Post B4 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB4_GrayERPs_39subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePostB4_39subs_Gray_TimebyCS.mat

%% Exploratory point-by-point ttest of Time(Pre/PostB5)*CS(+/-) interaction
%Color condition, early time window

allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];


BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
PostColorSCRCSd = PersonSCR(:,6);
PostGraySCRCSd = PersonSCR(:,7);

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.ColorCSp - Postcond.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
end
%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r-.'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g-.');

plot(horz, mean(PostcondColorCSp,1) , 'r-');
plot(horz, mean(PostcondColorCSm,1) , 'g-');

plot(horz,allPs, 'k');
plot(horz,allrpi+1, 'k--');
plot(horz,allrpscr+2, 'k-.');

line([horz(81) horz(81)],[0 -7]);
line([horz(87) horz(87)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post B5 Color CS+', 'Post B5 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB5_ColorERPs_39subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

% %ttest for interaction for C1P1 trough-to-peak difference
% c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
% [H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1, pc1p1 = 0.0031
% 
% %ttest for interaction for P1C2 peak-to-trough difference
% p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
% [H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0, pp1c2 = 0.19

save PrePostB5_39subs_Color_TimebyCS.mat

%% Gray condition

allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];


PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.GrayCSp - Postcond.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];
end

%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostGraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(PostcondGrayCSp,1) , 'b-');
plot(horz, mean(PostcondGrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 7]);
line([horz(89) horz(89)],[0 7]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post B5 Gray CS+', 'Post B5 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB5_GrayERPs_39subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePostB5_39subs_Gray_TimebyCS.mat

%% Exploratory point-by-point ttest of Time(Pre/PostB6)*CS(+/-) interaction
%Color condition, early time window
allsubs = [1 3:4 8:11 13:14 16:29 33 34 38:40 42:44 46 47 50 51 54:55]; %removing 2,7,53,5,12,31,37,41,57,15,56 

PersonSCR = [-0.64	-0.88	-0.76	-0.121536792	-0.132784119	-0.656143367	0.17686803
-0.02	0.41	0.2	-0.221098569	0.213223158	0.058999586	-0.513570278
-0.33	-0.02	-0.17	0.139763219	-0.043098606	0.136588615	0.222174489
0.91	0.7	0.81	0.315867096	0.059905254	0.034403775	0.110258014
1.22	1.7	1.46	0.36877096	-0.491990139	-0.244130005	-0.126695903
1.22	-0.45	0.39	0.09901012	-0.157021963	-0.111113756	-0.127030862
-0.64	-0.88	-0.76	0.023106227	0.022587258	-0.058291022	0.13200743
-1.57	-1.02	-1.3	-0.139188915	-0.147945488	0.052168776	0.204931212
-0.95	-0.88	-0.91	0.379443926	0.043633345	-0.233022243	0.44399057
-1.88	-1.02	-1.45	0.141901832	0.08047412	0.368625552	-0.062432981
-1.88	0.99	-0.45	-0.040906923	0.018814522	0.18505544	-0.001740027
0.603670406	-0.161709278	0.220980564	0.569641514	0.342857485	-0.320719201	-0.02546786
-0.02	-1.17	-0.59	0.264525325	0.02816996	0.668320256	-0.072209671
0.29	0.99	0.64	0.168769341	-0.012218746	0.027660877	0.257481963
-0.02	-1.17	-0.59	-0.097414847	0.124333057	0.001831439	0.221225735
-0.33	-0.16	-0.24	-0.038107585	0.166154016	-0.063838311	0.062883983
-0.64	0.41	-0.11	-0.047451922	-0.103875478	-0.035977624	0.623207397
-0.33	0.27	-0.03	-0.355755034	-0.315810171	-0.071418923	-0.047493077
0.29	2.28	1.29	-0.198523144	-0.108344191	0.047619308	-0.297792088
1.22	0.7	0.96	-0.103234703	0.050281366	0.0275141	0.015089005
1.22	1.27	1.25	0.304204643	0.29217203	0.241923392	-0.181772084
-1.57	-0.31	-0.94	-0.115530829	-0.233143978	-0.169994163	0.07354553
0.29	0.56	0.42	-0.151165652	-0.233003507	-0.166396738	0.074125416
-1.57	1.42	-0.08	-0.254398174	0.142865601	-0.375734804	0.033990428
-0.33	-1.02	-0.67	0.229313752	0.250467973	0.032532328	0.054925349
0.29	-0.74	-0.22	0.185501308	0.025087202	-0.359806717	0.029847246
-0.64	-0.74	-0.69	0.010207711	0.051588986	-0.214563174	0.090920819
-0.33	-1.17	-0.75	-0.011989929	0.118593346	-0.112426785	-0.26309504
1.22	2.56	1.89	-0.041497311	0.392906764	0.308094454	-0.180899225
-0.64	0.13	-0.26	-0.003450558	-0.011161584	-0.229070495	-0.030300141
1.84	0.84	1.34	0.099551071	-0.123122405	0.320852966	-0.094244569
0.29	-1.17	-0.44	-0.60307947	-0.344911395	0.254558509	0.167912239
0.91	0.27	0.59	-0.140133381	-0.048098821	0.045917893	-0.082668232
1.53	-0.02	0.76	-0.291805415	0.04449716	-0.29640455	-0.012377936
0.91	-1.02	-0.05	0.360509487	-0.262573594	-0.259144626	0.069882532
0.29	-0.88	-0.29	-0.42510864	-0.216558757	-0.018030172	0.206873333
-1.57	-0.88	-1.22	-0.194993828	0.11694365	0.044729962	0.333536848];

allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];


BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
PostColorSCRCSd = PersonSCR(:,6);
PostGraySCRCSd = PersonSCR(:,7);

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.ColorCSp - Postcond.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    PostcondColorCSp = [PostcondColorCSp; Postcond.ColorCSp];
    PostcondColorCSm = [PostcondColorCSm; Postcond.ColorCSm];
end
%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r-.'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g-.');

plot(horz, mean(PostcondColorCSp,1) , 'r-');
plot(horz, mean(PostcondColorCSm,1) , 'g-');

plot(horz,allPs, 'k');
plot(horz,allrpi+1, 'k--');
plot(horz,allrpscr+2, 'k-.');

line([horz(81) horz(81)],[0 -7]);
line([horz(87) horz(87)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post B6 Color CS+', 'Post B6 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB6_ColorERPs_39subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

% %ttest for interaction for C1P1 trough-to-peak difference
% c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
% [H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1, pc1p1 = 0.0031
% 
% %ttest for interaction for P1C2 peak-to-trough difference
% p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
% [H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0, pp1c2 = 0.19

save PrePostB6_39subs_Color_TimebyCS.mat

%% Gray condition
allTimebyCS = [];
allH0 = [];
allPs = [];

allrpi = [];
allrpa = [];
allrpn = [];

allri = [];
allra = [];
allrn = [];

allrscr = [];
allrpscr = [];


PrecondGrayCSp = [];
PrecondGrayCSm = [];
PostcondGrayCSp = [];
PostcondGrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
    Postcond = Oz;
    
    TimebyCS = (Postcond.GrayCSp - Postcond.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    PostcondGrayCSp = [PostcondGrayCSp; Postcond.GrayCSp];
    PostcondGrayCSm = [PostcondGrayCSm; Postcond.GrayCSm];
end

%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
    
    [ri, rpi] = corr(interaction, BISz);
    [ra, rpa] = corr(interaction, BAIz);
    [rn, rpn] = corr(interaction, Anxz);
    
    allri = [allri ri];
    allra = [allra ra];
    allrn = [allrn rn];
    
    allrpi = [allrpi rpi];
    allrpa = [allrpa rpa];
    allrpn = [allrpn rpn];
    
    [rscr, rpscr] = corr(interaction, (PostGraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(PostcondGrayCSp,1) , 'b-');
plot(horz, mean(PostcondGrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 7]);
line([horz(89) horz(89)],[0 7]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post B5 Gray CS+', 'Post B5 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB6_GrayERPs_39subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePostB6_39subs_Gray_TimebyCS.mat

%% Prepare for Loreta - individual conditions - Pre Color
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %removing 2,7,53,5,12,31,37,41,57 
%sub33 needs interpolation for channel 69 and 87

for s = allsubs
    
    cd /Volumes/SAVER/PLC_EEG/ERPs

    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs.mat results';]);
    end    
    
    Precond = results;
    
    if s == 33
    %Channel C5 needs to be interpolated
    Precond.ColCSp{69,1} = (Precond.ColCSp{64,1} + Precond.ColCSp{68,1} + Precond.ColCSp{71,1})/3;
    Precond.ColCSm{69,1} = (Precond.ColCSm{64,1} + Precond.ColCSm{68,1} + Precond.ColCSm{71,1})/3;

    %Channel C23
    Precond.ColCSp{87,1} = (Precond.ColCSp{86,1} + Precond.ColCSp{88,1} + Precond.ColCSp{81,1})/3;
    Precond.ColCSm{87,1} = (Precond.ColCSm{86,1} + Precond.ColCSm{88,1} + Precond.ColCSm{81,1})/3;            
    end
       
    clear results
    
    for c = 1:96        
        colcsp = Precond.ColCSp{c};
        colcsm = Precond.ColCSm{c};
        
        ColorCSpC2(c,1) = mean(colcsp(83:88));
        ColorCSmC2(c,1) = mean(colcsm(83:88));      
    end
    
        ColorCSpC2std = double((ColorCSpC2 - mean(ColorCSpC2))./std(ColorCSpC2));
    ColorCSmC2std = double((ColorCSmC2 - mean(ColorCSmC2))./std(ColorCSmC2));

    
    cd /Volumes/SAVER/PLC_EEG/LORETA/PostPre_ColorC2
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_ColorCSpC2std.txt -ascii ColorCSpC2std;']);
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_ColorCSmC2std.txt -ascii ColorCSmC2std;']);
    
end

%% Prepare for Loreta - individual conditions - Post Color

allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %removing 2,7,53,5,12,31,37,41,57 
%sub33 needs interpolation for channel 69 and 87

for s = allsubs
    
    cd /Volumes/SAVER/PLC_EEG/ERPs
    
    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs.mat results';]);
    end
    
    Postcond = results;
    
    if s == 33
    Postcond.ColCSp{69,1} = (Postcond.ColCSp{64,1} + Postcond.ColCSp{68,1} + Postcond.ColCSp{71,1})/3;
    Postcond.ColCSm{69,1} = (Postcond.ColCSm{64,1} + Postcond.ColCSm{68,1} + Postcond.ColCSm{71,1})/3;        
    end
    
    clear results
    
    for c = 1:96        
        colcsp = Postcond.ColCSp{c} ;
        colcsm = Postcond.ColCSm{c} ;
        
        ColorCSpC2(c,1) = mean(colcsp(83:88));
        ColorCSmC2(c,1) = mean(colcsm(83:88));      
    end
    
    ColorCSpC2std = double((ColorCSpC2 - mean(ColorCSpC2))./std(ColorCSpC2));
    ColorCSmC2std = double((ColorCSmC2 - mean(ColorCSmC2))./std(ColorCSmC2));

    
    cd /Volumes/SAVER/PLC_EEG/LORETA/PostPre_ColorC2
    
    eval(['save PLC_EEG_Post_Sub' num2str(s) '_ColorCSpC2std.txt -ascii ColorCSpC2std;']);
    
    eval(['save PLC_EEG_Post_Sub' num2str(s) '_ColorCSmC2std.txt -ascii ColorCSmC2std;']);
    
end

%% Pre/Post C2 LORETA - import text files from LORETA (showing source activity) and compute difference 

allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54:56]; %removing 2,7,53,5,12,31,37,41,57

for s = 1%allsubs
    
    eval(['load PLC_EEG_Pre_Sub' num2str(s) '_ColorCSpC2std-B2T.lor -ascii;']);
    
    eval(['load PLC_EEG_Pre_Sub' num2str(s) '_ColorCSmC2std-B2T.lor -ascii;']);
    
    eval(['Pre_C2_CSd = PLC_EEG_Pre_Sub' num2str(s) '_ColorCSpC2std_B2T - PLC_EEG_Pre_Sub' num2str(s) '_ColorCSmC2std_B2T;']);
    eval(['save Pre_CS_CSd_Sub' num2str(s) '_Loreta_diff.txt -ascii Pre_C2_CSd;']);
    
    
    eval(['load PLC_EEG_Post_Sub' num2str(s) '_ColorCSpC2std-B2T.lor -ascii;']);
    
    eval(['load PLC_EEG_Post_Sub' num2str(s) '_ColorCSmC2std-B2T.lor -ascii;']);
    eval(['Post_C2_CSd = PLC_EEG_Post_Sub' num2str(s) '_ColorCSpC2std_B2T - PLC_EEG_Post_Sub' num2str(s) '_ColorCSmC2std_B2T;']);
    eval(['save Post_CS_CSd_Sub' num2str(s) '_Loreta_diff.txt -ascii Post_C2_CSd;']);

end

%% Block4, Color
allsubs = [1 3:4 8:11 13:29 33 34 38:40 42:44 46 47 50 51 54 56]; %removing 2,7,53,5,12,31,37,41,57,55

b = 4;

for s = allsubs
    cd /Volumes/SAVER/PLC_EEG/ERPs
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]); %Save it all for fear
    
    
    Postcond = results;
    clear results
    
    for c = 1:96
        
        colcsp = Postcond.ColCSp{c} ;
        colcsm = Postcond.ColCSm{c} ;
        
        ColorCSpC2(c,1) = mean(colcsp(83:88));
        ColorCSmC2(c,1) = mean(colcsm(83:88));
        
    end
    
    ColorCSpC2std = double((ColorCSpC2 - mean(ColorCSpC2))./std(ColorCSpC2));
    ColorCSmC2std = double((ColorCSmC2 - mean(ColorCSmC2))./std(ColorCSmC2));
    
    cd /Volumes/SAVER/PLC_EEG/LORETA/PostB4Pre_ColorC2
    
    
    eval(['save PLC_EEG_PostB4_Sub' num2str(s) '_ColorCSpC2std.txt -ascii ColorCSpC2std;']);
    
    eval(['save PLC_EEG_PostB4_Sub' num2str(s) '_ColorCSmC2std.txt -ascii ColorCSmC2std;']);
    
end

%% Prepare for Loreta - Pre Gray - for high BISz group

allsubs = [44,50,9,10,26,27,42,8,47,51,15,18,20,25,29,38,46,54;]; %18subs; high anx group, all have BISz scores > .29

for s = allsubs
    
    cd /Volumes/SAVER/PLC_EEG/ERPs
    
    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs.mat results';]);
    end
    
    Precond = results;
    
    clear results
    
    for c = 1:96
        graycsp = Precond.GrayCSp{c};
        graycsm = Precond.GrayCSm{c};
        
        GrayCSpP1(c,1) = mean(graycsp(81:87));
        GrayCSmP1(c,1) = mean(graycsm(81:87));
    end
    
    GrayCSpP1std = double((GrayCSpP1 - mean(GrayCSpP1))./std(GrayCSpP1));
    GrayCSmP1std = double((GrayCSmP1 - mean(GrayCSmP1))./std(GrayCSmP1));    
    
    cd /Volumes/SAVER/PLC_EEG/LORETA/PostPre_GrayP1
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_GrayCSpP1std.txt -ascii GrayCSpP1std;']);
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_GrayCSmP1std.txt -ascii GrayCSmP1std;']);
    
end

%% Prepare for Loreta - Post Gray - for high BISz group

allsubs = [44,50,9,10,26,27,42,8,47,51,15,18,20,25,29,38,46,54;]; %18subs; high anx group, all have BISz scores > .29

for s = allsubs
    
    cd /Volumes/SAVER/PLC_EEG/ERPs    
    
    if s == 16 || s == 37 || s == 54
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEG_Sub' num2str(s) '_Postcond_ERPs.mat results';]);
    end
    
    Postcond = results;
    
    
    clear results
    
    for c = 1:96
        graycsp = Postcond.GrayCSp{c};
        graycsm = Postcond.GrayCSm{c};
        
        GrayCSpP1(c,1) = mean(graycsp(81:87));
        GrayCSmP1(c,1) = mean(graycsm(81:87));
    end
    
    GrayCSpP1std = double((GrayCSpP1 - mean(GrayCSpP1))./std(GrayCSpP1));
    GrayCSmP1std = double((GrayCSmP1 - mean(GrayCSmP1))./std(GrayCSmP1));
    
    
    cd /Volumes/SAVER/PLC_EEG/LORETA/PostPre_GrayP1
    
    eval(['save PLC_EEG_Post_Sub' num2str(s) '_GrayCSpP1std.txt -ascii GrayCSpP1std;']);
    
    eval(['save PLC_EEG_Post_Sub' num2str(s) '_GrayCSmP1std.txt -ascii GrayCSmP1std;']);
    
end

%% Pre/Post Gray hBiz P1 LORETA - import text files from LORETA (showing source activity) and compute difference 
allsubs = [44,50,9,10,26,27,42,8,47,51,15,18,20,25,29,38,46,54;]; %18subs; high anx group, all have BISz scores > .29

for s = allsubs
    
    eval(['load PLC_EEG_Pre_Sub' num2str(s) '_GrayCSpP1std-B2T.lor -ascii;']);
    
    eval(['load PLC_EEG_Pre_Sub' num2str(s) '_GrayCSmP1std-B2T.lor -ascii;']);
    
    eval(['Pre_P1_CSd = PLC_EEG_Pre_Sub' num2str(s) '_GrayCSpP1std_B2T - PLC_EEG_Pre_Sub' num2str(s) '_GrayCSmP1std_B2T;']);
    eval(['save Pre_CS_CSd_Sub' num2str(s) '_Loreta_diff.txt -ascii Pre_P1_CSd;']);
    
    
    eval(['load PLC_EEG_Post_Sub' num2str(s) '_GrayCSpP1std-B2T.lor -ascii;']);
    
    eval(['load PLC_EEG_Post_Sub' num2str(s) '_GrayCSmP1std-B2T.lor -ascii;']);
    eval(['Post_P1_CSd = PLC_EEG_Post_Sub' num2str(s) '_GrayCSpP1std_B2T - PLC_EEG_Post_Sub' num2str(s) '_GrayCSmP1std_B2T;']);
    eval(['save Post_CS_CSd_Sub' num2str(s) '_Loreta_diff.txt -ascii Post_P1_CSd;']);

end

%% Prepare for Loreta - Grand Ave

load PLC_EEG_GrandAve_Precond_45subsNo2753.mat 
 
for c = 1:96
    colcsp = results.ColCSp{c};
    colcsm = results.ColCSm{c};
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    
    ColorCSpC1P1(c,1) =  mean(colcsp(75:78));
    ColorCSmC1P1(c,1) = mean(colcsm(75:78));
    ColorCSC1P1(c,1) = (ColorCSpC1P1(c,1) + ColorCSmC1P1(c,1))/2; %collapse across CS+/CS-
    
    ColorCSpC2(c,1) = mean(colcsp(82:90));
    ColorCSmC2(c,1) = mean(colcsm(82:90));
    ColorCSC2(c,1) = (ColorCSpC2(c,1) + ColorCSmC2(c,1))/2; %collapse across CS+/CS-
    
    ColorCSp150_175(c,1) = mean(colcsp(90:96));
    ColorCSp175_200(c,1) = mean(colcsp(96:102));
    ColorCSp200_225(c,1) = mean(colcsp(102:109));
    ColorCSp225_250(c,1) = mean(colcsp(109:115));
    ColorCSp250_275(c,1) = mean(colcsp(115:122));
    ColorCSp275_300(c,1) = mean(colcsp(122:128));
    
    ColorCSm150_175(c,1) = mean(colcsm(90:96));
    ColorCSm175_200(c,1) = mean(colcsm(96:102));
    ColorCSm200_225(c,1) = mean(colcsm(102:109));
    ColorCSm225_250(c,1) = mean(colcsm(109:115));
    ColorCSm250_275(c,1) = mean(colcsm(115:122));
    ColorCSm275_300(c,1) = mean(colcsm(122:128));
    
    ColorCS150_175(c,1) = (ColorCSp150_175(c,1)+ColorCSm150_175(c,1))/2;
    ColorCS175_200(c,1) = (ColorCSp175_200(c,1)+ColorCSm175_200(c,1))/2;
    ColorCS200_225(c,1) = (ColorCSp200_225(c,1)+ColorCSm200_225(c,1))/2;
    ColorCS225_250(c,1) = (ColorCSp225_250(c,1)+ColorCSm225_250(c,1))/2;
    ColorCS250_275(c,1) = (ColorCSp250_275(c,1)+ColorCSm250_275(c,1))/2;
    ColorCS275_300(c,1) = (ColorCSp275_300(c,1)+ColorCSm275_300(c,1))/2;
    
    GrayCSpP1(c,1) = mean(graycsp(81:89));
    GrayCSmP1(c,1) = mean(graycsm(81:89));
    GrayCSP1(c,1) = (GrayCSpP1(c,1) + GrayCSmP1(c,1))/2; %collapse across CS+/CS-
 
    GrayCSp150_175(c,1) = mean(graycsp(90:96));
    GrayCSp175_200(c,1) = mean(graycsp(96:102));
    GrayCSp200_225(c,1) = mean(graycsp(102:109));
    GrayCSp225_250(c,1) = mean(graycsp(109:115));
    GrayCSp250_275(c,1) = mean(graycsp(115:122));
    GrayCSp275_300(c,1) = mean(graycsp(122:128));
    
    GrayCSm150_175(c,1) = mean(graycsm(90:96));
    GrayCSm175_200(c,1) = mean(graycsm(96:102));
    GrayCSm200_225(c,1) = mean(graycsm(102:109));
    GrayCSm225_250(c,1) = mean(graycsm(109:115));
    GrayCSm250_275(c,1) = mean(graycsm(115:122));
    GrayCSm275_300(c,1) = mean(graycsm(122:128));
    
    GrayCS150_175(c,1) = (GrayCSp150_175(c,1)+GrayCSm150_175(c,1))/2;
    GrayCS175_200(c,1) = (GrayCSp175_200(c,1)+GrayCSm175_200(c,1))/2;
    GrayCS200_225(c,1) = (GrayCSp200_225(c,1)+GrayCSm200_225(c,1))/2;
    GrayCS225_250(c,1) = (GrayCSp225_250(c,1)+GrayCSm225_250(c,1))/2;
    GrayCS250_275(c,1) = (GrayCSp250_275(c,1)+GrayCSm250_275(c,1))/2;
    GrayCS275_300(c,1) = (GrayCSp275_300(c,1)+GrayCSm275_300(c,1))/2;    
 
    
end
 
    ColorCSC1P1std = double((ColorCSC1P1 - mean(ColorCSC1P1))./std(ColorCSC1P1)); 
    save PLC_EEG_precond_ColorCSC1P1std.txt -ascii ColorCSC1P1std;
    
    ColorCSC2std = double((ColorCSC2 - mean(ColorCSC2))./std(ColorCSC2)); 
    save PLC_EEG_precond_ColorCSC2std.txt -ascii ColorCSC2std;
 
    ColorCS150_175std = double((ColorCS150_175 - mean(ColorCS150_175))./std(ColorCS150_175)); 
    save PLC_EEG_precond_ColorCS150_175std.txt -ascii ColorCS150_175std;
 
    ColorCS175_200std = double((ColorCS175_200 - mean(ColorCS175_200))./std(ColorCS175_200)); 
    save PLC_EEG_precond_ColorCS175_200std.txt -ascii ColorCS175_200std;
    
    ColorCS200_225std = double((ColorCS200_225 - mean(ColorCS200_225))./std(ColorCS200_225)); 
    save PLC_EEG_precond_ColorCS200_225std.txt -ascii ColorCS200_225std;
   
    ColorCS225_250std = double((ColorCS225_250 - mean(ColorCS225_250))./std(ColorCS225_250)); 
    save PLC_EEG_precond_ColorCS225_250std.txt -ascii ColorCS225_250std;
 
    ColorCS250_275std = double((ColorCS250_275 - mean(ColorCS250_275))./std(ColorCS250_275)); 
    save PLC_EEG_precond_ColorCS250_275std.txt -ascii ColorCS250_275std;
 
    ColorCS275_300std = double((ColorCS275_300 - mean(ColorCS275_300))./std(ColorCS275_300)); 
    save PLC_EEG_precond_ColorCS275_300std.txt -ascii ColorCS275_300std;
 
    GrayCSP1std = double((GrayCSP1 - mean(GrayCSP1))./std(GrayCSP1)); 
    save PLC_EEG_precond_GrayCSP1std.txt -ascii GrayCSP1std;
     
    GrayCS150_175std = double((GrayCS150_175 - mean(GrayCS150_175))./std(GrayCS150_175)); 
    save PLC_EEG_precond_GrayCS150_175std.txt -ascii GrayCS150_175std;
 
    GrayCS175_200std = double((GrayCS175_200 - mean(GrayCS175_200))./std(GrayCS175_200)); 
    save PLC_EEG_precond_GrayCS175_200std.txt -ascii GrayCS175_200std;
    
    GrayCS200_225std = double((GrayCS200_225 - mean(GrayCS200_225))./std(GrayCS200_225)); 
    save PLC_EEG_precond_GrayCS200_225std.txt -ascii GrayCS200_225std;
   
    GrayCS225_250std = double((GrayCS225_250 - mean(GrayCS225_250))./std(GrayCS225_250)); 
    save PLC_EEG_precond_GrayCS225_250std.txt -ascii GrayCS225_250std;
 
    GrayCS250_275std = double((GrayCS250_275 - mean(GrayCS250_275))./std(GrayCS250_275)); 
    save PLC_EEG_precond_GrayCS250_275std.txt -ascii GrayCS250_275std;
 
    GrayCS275_300std = double((GrayCS275_300 - mean(GrayCS275_300))./std(GrayCS275_300)); 
    save PLC_EEG_precond_GrayCS275_300std.txt -ascii GrayCS275_300std;
 
    
clear all
 
load PLC_EEG_GrandAve_Postcond_45subsNo2753.mat 
 
for c = 1:96
    colcsp = results.ColCSp{c};
    colcsm = results.ColCSm{c};
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    
    ColorCSpC1P1(c,1) =  mean(colcsp(75:78));
    ColorCSmC1P1(c,1) = mean(colcsm(75:78));
    ColorCSC1P1(c,1) = (ColorCSpC1P1(c,1) + ColorCSmC1P1(c,1))/2; %collapse across CS+/CS-
    
    ColorCSpC2(c,1) = mean(colcsp(82:90));
    ColorCSmC2(c,1) = mean(colcsm(82:90));
    ColorCSC2(c,1) = (ColorCSpC2(c,1) + ColorCSmC2(c,1))/2; %collapse across CS+/CS-
    
    ColorCSp150_175(c,1) = mean(colcsp(90:96));
    ColorCSp175_200(c,1) = mean(colcsp(96:102));
    ColorCSp200_225(c,1) = mean(colcsp(102:109));
    ColorCSp225_250(c,1) = mean(colcsp(109:115));
    ColorCSp250_275(c,1) = mean(colcsp(115:122));
    ColorCSp275_300(c,1) = mean(colcsp(122:128));
    
    ColorCSm150_175(c,1) = mean(colcsm(90:96));
    ColorCSm175_200(c,1) = mean(colcsm(96:102));
    ColorCSm200_225(c,1) = mean(colcsm(102:109));
    ColorCSm225_250(c,1) = mean(colcsm(109:115));
    ColorCSm250_275(c,1) = mean(colcsm(115:122));
    ColorCSm275_300(c,1) = mean(colcsm(122:128));
    
    ColorCS150_175(c,1) = (ColorCSp150_175(c,1)+ColorCSm150_175(c,1))/2;
    ColorCS175_200(c,1) = (ColorCSp175_200(c,1)+ColorCSm175_200(c,1))/2;
    ColorCS200_225(c,1) = (ColorCSp200_225(c,1)+ColorCSm200_225(c,1))/2;
    ColorCS225_250(c,1) = (ColorCSp225_250(c,1)+ColorCSm225_250(c,1))/2;
    ColorCS250_275(c,1) = (ColorCSp250_275(c,1)+ColorCSm250_275(c,1))/2;
    ColorCS275_300(c,1) = (ColorCSp275_300(c,1)+ColorCSm275_300(c,1))/2;
    
    GrayCSpP1(c,1) = mean(graycsp(81:89));
    GrayCSmP1(c,1) = mean(graycsm(81:89));
    GrayCSP1(c,1) = (GrayCSpP1(c,1) + GrayCSmP1(c,1))/2; %collapse across CS+/CS-
 
    GrayCSp150_175(c,1) = mean(graycsp(90:96));
    GrayCSp175_200(c,1) = mean(graycsp(96:102));
    GrayCSp200_225(c,1) = mean(graycsp(102:109));
    GrayCSp225_250(c,1) = mean(graycsp(109:115));
    GrayCSp250_275(c,1) = mean(graycsp(115:122));
    GrayCSp275_300(c,1) = mean(graycsp(122:128));
    
    GrayCSm150_175(c,1) = mean(graycsm(90:96));
    GrayCSm175_200(c,1) = mean(graycsm(96:102));
    GrayCSm200_225(c,1) = mean(graycsm(102:109));
    GrayCSm225_250(c,1) = mean(graycsm(109:115));
    GrayCSm250_275(c,1) = mean(graycsm(115:122));
    GrayCSm275_300(c,1) = mean(graycsm(122:128));
    
    GrayCS150_175(c,1) = (GrayCSp150_175(c,1)+GrayCSm150_175(c,1))/2;
    GrayCS175_200(c,1) = (GrayCSp175_200(c,1)+GrayCSm175_200(c,1))/2;
    GrayCS200_225(c,1) = (GrayCSp200_225(c,1)+GrayCSm200_225(c,1))/2;
    GrayCS225_250(c,1) = (GrayCSp225_250(c,1)+GrayCSm225_250(c,1))/2;
    GrayCS250_275(c,1) = (GrayCSp250_275(c,1)+GrayCSm250_275(c,1))/2;
    GrayCS275_300(c,1) = (GrayCSp275_300(c,1)+GrayCSm275_300(c,1))/2;    
 
 
end
 
    ColorCSC1P1std = double((ColorCSC1P1 - mean(ColorCSC1P1))./std(ColorCSC1P1)); 
    save PLC_EEG_postcond_ColorCSC1P1std.txt -ascii ColorCSC1P1std;
    
    ColorCSC2std = double((ColorCSC2 - mean(ColorCSC2))./std(ColorCSC2)); 
    save PLC_EEG_postcond_ColorCSC2std.txt -ascii ColorCSC2std;
 
    ColorCS150_175std = double((ColorCS150_175 - mean(ColorCS150_175))./std(ColorCS150_175)); 
    save PLC_EEG_postcond_ColorCS150_175std.txt -ascii ColorCS150_175std;
 
    ColorCS175_200std = double((ColorCS175_200 - mean(ColorCS175_200))./std(ColorCS175_200)); 
    save PLC_EEG_postcond_ColorCS175_200std.txt -ascii ColorCS175_200std;
    
    ColorCS200_225std = double((ColorCS200_225 - mean(ColorCS200_225))./std(ColorCS200_225)); 
    save PLC_EEG_postcond_ColorCS200_225std.txt -ascii ColorCS200_225std;
   
    ColorCS225_250std = double((ColorCS225_250 - mean(ColorCS225_250))./std(ColorCS225_250)); 
    save PLC_EEG_postcond_ColorCS225_250std.txt -ascii ColorCS225_250std;
 
    ColorCS250_275std = double((ColorCS250_275 - mean(ColorCS250_275))./std(ColorCS250_275)); 
    save PLC_EEG_postcond_ColorCS250_275std.txt -ascii ColorCS250_275std;
 
    ColorCS275_300std = double((ColorCS275_300 - mean(ColorCS275_300))./std(ColorCS275_300)); 
    save PLC_EEG_postcond_ColorCS275_300std.txt -ascii ColorCS275_300std;
 
    GrayCSP1std = double((GrayCSP1 - mean(GrayCSP1))./std(GrayCSP1)); 
    save PLC_EEG_postcond_GrayCSP1std.txt -ascii GrayCSP1std;
     
    GrayCS150_175std = double((GrayCS150_175 - mean(GrayCS150_175))./std(GrayCS150_175)); 
    save PLC_EEG_postcond_GrayCS150_175std.txt -ascii GrayCS150_175std;
 
    GrayCS175_200std = double((GrayCS175_200 - mean(GrayCS175_200))./std(GrayCS175_200)); 
    save PLC_EEG_postcond_GrayCS175_200std.txt -ascii GrayCS175_200std;
    
    GrayCS200_225std = double((GrayCS200_225 - mean(GrayCS200_225))./std(GrayCS200_225)); 
    save PLC_EEG_postcond_GrayCS200_225std.txt -ascii GrayCS200_225std;
   
    GrayCS225_250std = double((GrayCS225_250 - mean(GrayCS225_250))./std(GrayCS225_250)); 
    save PLC_EEG_postcond_GrayCS225_250std.txt -ascii GrayCS225_250std;
 
    GrayCS250_275std = double((GrayCS250_275 - mean(GrayCS250_275))./std(GrayCS250_275)); 
    save PLC_EEG_postcond_GrayCS250_275std.txt -ascii GrayCS250_275std;
 
    GrayCS275_300std = double((GrayCS275_300 - mean(GrayCS275_300))./std(GrayCS275_300)); 
    save PLC_EEG_postcond_GrayCS275_300std.txt -ascii GrayCS275_300std;

 
%% Prepare for Loreta - Grand Ave - new sample size
load PLC_EEG_GrandAve_Precond_39subs_032315.mat results

for c = 1:96
    colcsp = results.ColCSp{c};
    colcsm = results.ColCSm{c};
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    
    ColorCSC2(c,1) = (mean(colcsp(83:88)) + mean(colcsm(83:88)))/2; %collapse across CS+/CS-
    GrayCSP1(c,1) = (mean(graycsp(81:87)) + mean(graycsp(81:87)))/2; %collapse across CS+/CS-
    ColorCSP2(c,1) = (mean(colcsp(98:122)) + mean(colcsm(98:122)))/2;
end

    ColorCSC2std = double((ColorCSC2 - mean(ColorCSC2))./std(ColorCSC2)); 
    save PLC_EEG_pre_ColorCSC2std.txt -ascii ColorCSC2std;

    ColorCSP2std = double((ColorCSP2 - mean(ColorCSP2))./std(ColorCSP2)); 
    save PLC_EEG_pre_ColorCSP2std.txt -ascii ColorCSP2std;
        
    GrayCSP1std = double((GrayCSP1 - mean(GrayCSP1))./std(GrayCSP1)); 
    save PLC_EEG_pre_GrayCSP1std.txt -ascii GrayCSP1std;   
    
    
%% topomap based on grand average - CS+ - CS-, precond/postcond/postcond2
%last updated 032315
%Color C2

load PLC_EEG_GrandAve_Precond_39subs_032315.mat results

ColorC2CSd = zeros(1,96);

for c = 1:96
        colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    ColorCS2CSd(c) = mean(colorcsp(83:88))- mean(colorcsm(83:88));
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

figure; topoplot(ColorCS2CSd, EEG.chanlocs, 'maplimits', [-1 1], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSC2CSd_39subs_precond_topo.jpg');
%close(gcf);


load PLC_EEG_GrandAve_Precond_39subs_032315.mat results

ColorC2CSd = zeros(1,96);

for c = 1:96
        colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    ColorCS2CSd(c) = mean(colorcsp(98:122))- mean(colorcsm(98:122));
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

figure; topoplot(ColorCS2CSd, EEG.chanlocs, 'maplimits', [-1 1], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSP2CSd_39subs_precond_topo.jpg');
%close(gcf);



load PLC_EEG_GrandAve_Postcond_39subs_032315.mat results

ColorC2CSd = zeros(1,96);

for c = 1:96
        colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    ColorCS2CSd(c) = mean(colorcsp(83:88))- mean(colorcsm(83:88));
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

figure; topoplot(ColorCS2CSd, EEG.chanlocs, 'maplimits', [-1 1], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSC2CSd_39subs_postcond_topo.jpg');


load PLC_EEG_GrandAve_Post2_Block4_ERPs_32subs_032315.mat results

ColorC2CSd = zeros(1,96);

for c = 1:96
        colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    ColorCS2CSd(c) = mean(colorcsp(98:122))- mean(colorcsm(98:122));
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

figure; topoplot(ColorCS2CSd, EEG.chanlocs, 'maplimits', [-1 1.2], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSP2CSd_32subs_postcond2_topo.jpg');

%% CS+/- collapsed topo for Color C2, P2; Gray P1 at Precond (without
%% learning effect)

GrayP1 = zeros(1,96);
ColorC2 = zeros(1,96);
ColorP2 = zeros(1,96);

load PLC_EEG_GrandAve_Precond_39subs_032315.mat results

for c = 1:96
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    
    GrayP1(c) =( mean(graycsp(81:87)) + mean(graycsm(81:87)))/2;
    ColorC2(c) = ( mean(colorcsp(83:88)) + mean(colorcsm(83:88)))/2;
    ColorP2(c) = ( mean(colorcsp(98:122)) + mean(colorcsm(98:122)))/2;
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

%C2
figure; topoplot(ColorC2, EEG.chanlocs, 'maplimits', [-6 5], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorC2_39subs_precond_topo.jpg');

%P2
figure; topoplot(ColorP2, EEG.chanlocs, 'maplimits', [-6 5], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorP2_39subs_precond_topo.jpg');

%P1
figure; topoplot(GrayP1, EEG.chanlocs, 'maplimits', [-6 5], 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayP1_39subs_precond_topo.jpg');

%% old time windows

%load data....

GrayCSpP1 = zeros(1,96);
GrayCSpN1 = zeros(1,96);
GrayCSpP2 = zeros(1,96);

GrayCSmP1 = zeros(1,96);
GrayCSmN1 = zeros(1,96);
GrayCSmP2 = zeros(1,96);

GrayCSp_CSmP1 = zeros(1,96);
GrayCSp_CSmN1 = zeros(1,96);
GrayCSp_CSmP2 = zeros(1,96);

ColorCSpC1 = zeros(1,96);
ColorCSpP1 = zeros(1,96);
ColorCSpN1 = zeros(1,96);
ColorCSpP2 = zeros(1,96);

ColorCSmC1 = zeros(1,96);
ColorCSmP1 = zeros(1,96);
ColorCSmN1 = zeros(1,96);
ColorCSmP2 = zeros(1,96);

ColorCSp_CSmC1 = zeros(1,96);
ColorCSp_CSmP1 = zeros(1,96);
ColorCSp_CSmN1 = zeros(1,96);
ColorCSp_CSmP2 = zeros(1,96);

for c = 1:96
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    
    GrayCSpP1(c) = mean(graycsp(81:87)); %a regular 9-datapoint interval generated
    GrayCSpN1(c) = mean(graycsp(94:102));
    GrayCSpP2(c) = mean(graycsp(110:118));
    
    GrayCSmP1(c) = mean(graycsm(81:89));
    GrayCSmN1(c)  = mean(graycsm(94:102));
    GrayCSmP2(c)  = mean(graycsm(110:118));
    
    GrayCSp_CSmP1(c) = mean(graycsp(81:89))-mean(graycsm(81:89));
    GrayCSp_CSmN1(c)= mean(graycsp(94:102))-mean(graycsm(94:102));
    GrayCSp_CSmP2(c) = mean(graycsp(110:118))-mean(graycsm(110:118));
    
    
    ColorCSpC1(c) = mean(colorcsp(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSpP1(c) = mean(colorcsp(75:81));
    ColorCSpN1(c) = mean(colorcsp(82:90));
    ColorCSpP2(c) = mean(colorcsp(106:114));
    
    ColorCSmC1(c) = mean(colorcsm(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSmP1(c) = mean(colorcsm(75:81));
    ColorCSmN1(c) = mean(colorcsm(82:90));
    ColorCSmP2(c) = mean(colorcsm(106:114));
    
    ColorCSp_CSmC1(c) = mean(colorcsp(72:78))-mean(colorcsm(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSp_CSmP1(c) = mean(colorcsp(75:81))-mean(colorcsm(75:81));
    ColorCSp_CSmN1(c) = mean(colorcsp(82:90))-mean(colorcsm(82:90));
    ColorCSp_CSmP2(c) = mean(colorcsp(106:114))-mean(colorcsm(106:114));    
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

%Gray CSp 
figure; topoplot(GrayCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP2_allsubs_precond_topo.jpg');
close(gcf);

%Gray CSm 
figure; topoplot(GrayCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP2_allsubs_precond_topo.jpg');
close(gcf);

%Color CSp
figure; topoplot(ColorCSpC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpC1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP2_allsubs_precond_topo.jpg');
close(gcf);


%Color CSm
figure; topoplot(ColorCSmC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmC1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP2_allsubs_precond_topo.jpg');
close(gcf);

%Gray CSp-CSm
figure; topoplot(GrayCSp_CSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSp_CSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(GrayCSp_CSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmP2_allsubs_precond_topo.jpg');
close(gcf);

%Color CSp_CSm
figure; topoplot(ColorCSp_CSmC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmC1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSp_CSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmP1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSp_CSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmN1_allsubs_precond_topo.jpg');
close(gcf);

figure; topoplot(ColorCSp_CSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmP2_allsubs_precond_topo.jpg');
close(gcf);


%% topomap based on grand average - postcond
 
load PLC_EEG_GrandAve_Postcond_All48subs.mat results
 
GrayCSpP1 = zeros(1,96);
GrayCSpN1 = zeros(1,96);
GrayCSpP2 = zeros(1,96);
 
GrayCSmP1 = zeros(1,96);
GrayCSmN1 = zeros(1,96);
GrayCSmP2 = zeros(1,96);
 
GrayCSp_CSmP1 = zeros(1,96);
GrayCSp_CSmN1 = zeros(1,96);
GrayCSp_CSmP2 = zeros(1,96);
 
ColorCSpC1 = zeros(1,96);
ColorCSpP1 = zeros(1,96);
ColorCSpN1 = zeros(1,96);
ColorCSpP2 = zeros(1,96);
 
ColorCSmC1 = zeros(1,96);
ColorCSmP1 = zeros(1,96);
ColorCSmN1 = zeros(1,96);
ColorCSmP2 = zeros(1,96);
 
ColorCSp_CSmC1 = zeros(1,96);
ColorCSp_CSmP1 = zeros(1,96);
ColorCSp_CSmN1 = zeros(1,96);
ColorCSp_CSmP2 = zeros(1,96);
 
for c = 1:96
    graycsp = results.GrayCSp{c};
    graycsm = results.GrayCSm{c};
    colorcsp = results.ColCSp{c};
    colorcsm = results.ColCSm{c};
    
    GrayCSpP1(c) = mean(graycsp(81:89)); %a regular 9-datapoint interval generated
    GrayCSpN1(c) = mean(graycsp(94:102));
    GrayCSpP2(c) = mean(graycsp(110:118));
    
    GrayCSmP1(c) = mean(graycsm(81:89));
    GrayCSmN1(c)  = mean(graycsm(94:102));
    GrayCSmP2(c)  = mean(graycsm(110:118));
    
    GrayCSp_CSmP1(c) = mean(graycsp(81:89))-mean(graycsm(81:89));
    GrayCSp_CSmN1(c)= mean(graycsp(94:102))-mean(graycsm(94:102));
    GrayCSp_CSmP2(c) = mean(graycsp(110:118))-mean(graycsm(110:118));
    
    
    ColorCSpC1(c) = mean(colorcsp(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSpP1(c) = mean(colorcsp(75:81));
    ColorCSpN1(c) = mean(colorcsp(82:90));
    ColorCSpP2(c) = mean(colorcsp(106:114));
    
    ColorCSmC1(c) = mean(colorcsm(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSmP1(c) = mean(colorcsm(75:81));
    ColorCSmN1(c) = mean(colorcsm(82:90));
    ColorCSmP2(c) = mean(colorcsm(106:114));
    
    ColorCSp_CSmC1(c) = mean(colorcsp(72:78))-mean(colorcsm(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSp_CSmP1(c) = mean(colorcsp(75:81))-mean(colorcsm(75:81));
    ColorCSp_CSmN1(c) = mean(colorcsp(82:90))-mean(colorcsm(82:90));
    ColorCSp_CSmP2(c) = mean(colorcsp(106:114))-mean(colorcsm(106:114));    
end
 
filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels
 
%Gray CSp 
figure; topoplot(GrayCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP2_allsubs_postcond_topo.jpg');
close(gcf);
 
%Gray CSm 
figure; topoplot(GrayCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP2_allsubs_postcond_topo.jpg');
close(gcf);
 
%Color CSp
figure; topoplot(ColorCSpC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpC1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP2_allsubs_postcond_topo.jpg');
close(gcf);
 
 
%Color CSm
figure; topoplot(ColorCSmC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmC1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP2_allsubs_postcond_topo.jpg');
close(gcf);
 
%Gray CSp-CSm
figure; topoplot(GrayCSp_CSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSp_CSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(GrayCSp_CSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSp_CSmP2_allsubs_postcond_topo.jpg');
close(gcf);
 
%Color CSp_CSm
figure; topoplot(ColorCSp_CSmC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmC1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSp_CSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmP1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSp_CSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmN1_allsubs_postcond_topo.jpg');
close(gcf);
 
figure; topoplot(ColorCSp_CSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSp_CSmP2_allsubs_postcond_topo.jpg');
close(gcf);


%% topomap based on grand average - postcond-precond

load PLC_EEG_GrandAve_Postcond_39subs_032315.mat results
resultsp = results;

load PLC_EEG_GrandAve_Precond_39subs_032315.mat results

GrayCSpP1 = zeros(1,96);
GrayCSpN1 = zeros(1,96);
GrayCSpP2 = zeros(1,96);

GrayCSmP1 = zeros(1,96);
GrayCSmN1 = zeros(1,96);
GrayCSmP2 = zeros(1,96);

ColorCSpC1 = zeros(1,96);
ColorCSpP1 = zeros(1,96);
ColorCSpN1 = zeros(1,96);
ColorCSpP2 = zeros(1,96);

ColorCSmC1 = zeros(1,96);
ColorCSmP1 = zeros(1,96);
ColorCSmN1 = zeros(1,96);
ColorCSmP2 = zeros(1,96);

for c = 1:96
    graycsp = resultsp.GrayCSp{c} - results.GrayCSp{c}; %Postcond - precond for each channel of 1*128 datapoints
    graycsm = resultsp.GrayCSm{c} - results.GrayCSm{c};
    colorcsp = resultsp.ColCSp{c} - results.ColCSp{c};
    colorcsm = resultsp.ColCSm{c} - results.ColCSm{c};
    
    GrayCSpP1(c) = mean(graycsp(81:87)); %a regular 9-datapoint interval generated
    GrayCSpN1(c) = mean(graycsp(94:102));
    GrayCSpP2(c) = mean(graycsp(110:118));
    
    GrayCSmP1(c) = mean(graycsm(81:89));
    GrayCSmN1(c) = mean(graycsm(94:102));
    GrayCSmP2(c) = mean(graycsm(110:118));
    
    
    ColorCSpC1(c) = mean(colorcsp(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSpP1(c) = mean(colorcsp(75:81));
    ColorCSpN1(c) = mean(colorcsp(82:90));
    ColorCSpP2(c) = mean(colorcsp(106:114));
    
    ColorCSmC1(c) = mean(colorcsm(72:78)); %here, due to the closeness of peaks btw C1 and P1, used a 7-datapoint interval with some overlap btw components
    ColorCSmP1(c) = mean(colorcsm(75:81));
    ColorCSmN1(c) = mean(colorcsm(82:90));
    ColorCSmP2(c) = mean(colorcsm(106:114));
end

filename = strcat('EEG_PLC_Sub55block6_ica_epochs_blc_Farej.set'); %Dataset from a subject we're not using--just have to load up something
EEG = pop_loadset(filename);
EEG.chanlocs = readlocs('elp96test.elp', 'filetype', 'besa'); %Reads in accurate locations for all 96 EEG channels

%Gray CSp 
figure; topoplot(GrayCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(GrayCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpN1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(GrayCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSpP2_allsubs_post_pre_topo.jpg');
close(gcf);

%Gray CSm 
figure; topoplot(GrayCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(GrayCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmN1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(GrayCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'GrayCSmP2_allsubs_post_pre_topo.jpg');
close(gcf);

%Color CSp
figure; topoplot(ColorCSpC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpC1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpN1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSpP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSpP2_allsubs_post_pre_topo.jpg');
close(gcf);


%Color CSm
figure; topoplot(ColorCSmC1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmC1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmP1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmN1, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmN1_allsubs_post_pre_topo.jpg');
close(gcf);

figure; topoplot(ColorCSmP2, EEG.chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on'); %Puts electrode points in the picture & changes colors to fit the range of the vector of values
colorbar
saveas(gcf, 'ColorCSmP2_allsubs_post_pre_topo.jpg');
close(gcf);
