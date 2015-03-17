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
allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs

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

save PLC_EEG_GrandAve_Precond_36subsNo27.mat results

%save PLC_EEG_GrandAve_Precond_45subsNo2753.mat results
%save PLC_EEG_GrandAve_Precond_All48subs.mat results
%save PLC_EEG_GrandAve_Precond_All51subs.mat results

%% Make grand averages-Postcond 

clear all

%allsubs = [1:5 7:44 46 47 49:51 53:57];
%allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57]; %list of all 48
%subs
%allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs

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

save PLC_EEG_GrandAve_Postcond_36subsNo27.mat results

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

allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57];
Ozchan = 30:33;
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
    %eval(['save PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    
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
    %eval(['save PLC_EEG_Sub' num2str(s) '_Postcond_Oz_ERPs.mat Oz';]);
    
    allERPsColor = [allERPsColor; Oz.ColorCSp; Oz.ColorCSm];
    allERPsGray = [allERPsGray; Oz.GrayCSp; Oz.GrayCSm];
    
end
grandygrandpostc = mean(allERPsColor,1); %Make the grand-grand average
grandygrandpostg = mean(allERPsGray,1);

grandycolor = [grandygrandprec; grandygrandpostc]; grandycolor = mean(grandycolor,1);
grandygray = [grandygrandpreg; grandygrandpostg]; grandygray = mean(grandygray,1);

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


%%  Get mean amplitudes for each individual: precond; 3/16/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:69; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114

allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53

clear Oz
AllColorC1P1C2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));

    ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
    ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));

    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSpN1 = mean(Oz.GrayCSp(94:102));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSmN1 = mean(Oz.GrayCSm(94:102));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];
    
end


save PLC_EEG_PrecondNewComponents_MeanAmp_45subs AllColorC1P1C2 AllGrayP1N1P2


%%  Get mean amplitudes for each individual: postcond B4; 3/16/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:61; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114

allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57]; %removing 2,7,53

clear Oz
AllColorC1P1C2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));

    ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
    ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));

    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSpN1 = mean(Oz.GrayCSp(94:102));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSmN1 = mean(Oz.GrayCSm(94:102));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];
    
end


save PLC_EEG_PostB4_MeanAmp_45subs AllColorC1P1C2 AllGrayP1N1P2

%% B5
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];

clear Oz
AllColorC1P1C2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
    ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));

    ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
    ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));

    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSpN1 = mean(Oz.GrayCSp(94:102));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSmN1 = mean(Oz.GrayCSm(94:102));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];
    
end


save PLC_EEG_PostB5_MeanAmp_45subs AllColorC1P1C2 AllGrayP1N1P2

%% B6
allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];

clear Oz
AllColorC1P1C2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
    ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
    ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(82:90));

    ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
    ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(82:90));

    
    GrayCSpP1 = mean(Oz.GrayCSp(81:89));
    GrayCSpN1 = mean(Oz.GrayCSp(94:102));
    GrayCSpP2 = mean(Oz.GrayCSp(104:124)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(81:89));
    GrayCSmN1 = mean(Oz.GrayCSm(94:102));
    GrayCSmP2 = mean(Oz.GrayCSm(104:124)); %using a broader window here

AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];
    
end


save PLC_EEG_PostB6_MeanAmp_45subs AllColorC1P1C2 AllGrayP1N1P2


%% Exploratory point-by-point ttest of Time(Pre/Post)*CS(+/-) interaction
%Color condition, early time window
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allTimebyCS = [];
allH0 = [];
allPs = [];

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
%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(PostcondColorCSp,1) , 'r--');
plot(horz, mean(PostcondColorCSm,1) , 'g--');

plot(horz,allPs, 'k');
legend('Pre Color CS+', 'Pre Color CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost_ColorERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%ttest for interaction for C1P1 trough-to-peak difference
c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
[H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1, pc1p1 = 0.0031

%ttest for interaction for P1C2 peak-to-trough difference
p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
[H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0, pp1c2 = 0.19

%% Gray condition, early time window
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57]; %removing 2,7,53
allTimebyCS = [];
allH0 = [];
allPs = [];

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
%ttest for interaction for each time point
for i = 1:length(allTimebyCS)
    interaction = allTimebyCS(:,i);
    [H0, p] = ttest(interaction, 0);
    allH0 = [allH0 H0];
    allPs = [allPs p];
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b:'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g:');

plot(horz, mean(PostcondGrayCSp,1) , 'b--');
plot(horz, mean(PostcondGrayCSm,1) , 'g--');

plot(horz,allPs, 'r');
legend('Pre Gray CS+', 'Pre Gray CS-', 'Post Gray CS+', 'Post Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost_GrayERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%% Exploratory point-by-point ttest of Time(Pre/PostB4)*CS(+/-) interaction
%Color condition, early time window
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57];

allTimebyCS = [];
allH0 = [];
allPs = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

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
    allPs = [allPs p]; %data point 83-86 p < .1
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(PostcondColorCSp,1) , 'r--');
plot(horz, mean(PostcondColorCSm,1) , 'g--');

plot(horz,allPs, 'k');
legend('Pre Color CS+', 'Pre Color CS-', 'PostB4 Color CS+', 'PostB4 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB4_ColorERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%ttest for interaction for C1P1 trough-to-peak difference
c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
[H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1 , pc1p1 = 0.004

%ttest for interaction for P1C2 peak-to-trough difference
p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
[H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0 , pp1c2 = 0.187

%% Gray condition
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54 56 57];

allTimebyCS = [];
allH0 = [];
allPs = [];

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
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b:'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g:');

plot(horz, mean(PostcondGrayCSp,1) , 'b--');
plot(horz, mean(PostcondGrayCSm,1) , 'g--');

plot(horz,allPs, 'r');
legend('Pre Gray CS+', 'Pre Gray CS-', 'PostB4 Gray CS+', 'PostB4 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB4_GrayERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%% Exploratory point-by-point ttest of Time(Pre/PostB5)*CS(+/-) interaction
%Color condition, early time window
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];

allTimebyCS = [];
allH0 = [];
allPs = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

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
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(PostcondColorCSp,1) , 'r--');
plot(horz, mean(PostcondColorCSm,1) , 'g--');

plot(horz,allPs, 'k');
legend('Pre Color CS+', 'Pre Color CS-', 'PostB5 Color CS+', 'PostB5 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB5_ColorERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%ttest for interaction for C1P1 trough-to-peak difference
c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
[H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 1 , pc1p1 = 0.036

%ttest for interaction for P1C2 peak-to-trough difference
p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
[H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0 , pp1c2 = 0.93

%% Gray condition
allsubs = [1 3:5 8:29 31 33 34 37:44 46 47 50 51 54:57];

allTimebyCS = [];
allH0 = [];
allPs = [];

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
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b:'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g:');

plot(horz, mean(PostcondGrayCSp,1) , 'b--');
plot(horz, mean(PostcondGrayCSm,1) , 'g--');

plot(horz,allPs, 'r');
legend('Pre Gray CS+', 'Pre Gray CS-', 'PostB5 Gray CS+', 'PostB5 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB5_GrayERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%% Exploratory point-by-point ttest of Time(Pre/PostB6)*CS(+/-) interaction
%Color condition, early time window
allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];

allTimebyCS = [];
allH0 = [];
allPs = [];

PrecondColorCSp = [];
PrecondColorCSm = [];
PostcondColorCSp = [];
PostcondColorCSm = [];

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
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(PostcondColorCSp,1) , 'r--');
plot(horz, mean(PostcondColorCSm,1) , 'g--');

plot(horz,allPs, 'k');
legend('Pre Color CS+', 'Pre Color CS-', 'PostB6 Color CS+', 'PostB6 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB6_ColorERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

%ttest for interaction for C1P1 trough-to-peak difference
c1p1 = allTimebyCS(:,78) - allTimebyCS(:,75);
[H0c1p1, pc1p1] = ttest(c1p1, 0); %H0 = 0 , pc1p1 = 0.40

%ttest for interaction for P1C2 peak-to-trough difference
p1c2 = allTimebyCS(:,86) - allTimebyCS(:,78);
[H0p1c2, pp1c2] = ttest(p1c2, 0); %H0 = 0 , pp1c2 = 0.16

%% Gray condition
allsubs = [1 3:5 8:14 16:29 31 33 34 37:44 46 47 50 51 54:55 57];

allTimebyCS = [];
allH0 = [];
allPs = [];

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
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b:'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g:');

plot(horz, mean(PostcondGrayCSp,1) , 'b--');
plot(horz, mean(PostcondGrayCSm,1) , 'g--');

plot(horz,allPs, 'r');
legend('Pre Gray CS+', 'Pre Gray CS-', 'PostB6 Gray CS+', 'PostB6 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePostB6_GrayERPs_45subs_TimebyCS_pval.jpg');
close(gcf);

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

 
    
%% topomap based on grand average - precond

load PLC_EEG_GrandAve_Precond_All48subs.mat results

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

load PLC_EEG_GrandAve_Postcond_All48subs.mat results
resultsp = results;

load PLC_EEG_GrandAve_Precond_All48subs.mat results

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
    
    GrayCSpP1(c) = mean(graycsp(81:89)); %a regular 9-datapoint interval generated
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
