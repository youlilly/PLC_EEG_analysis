%PLC_EEGpost_Analyzer3.m
%Created by YY, 1/22/15

%% Extract ERPs
%Based on P1 window rejected trials above, it is determined that
%Sub 48 52 (updated 2/8/15; old rej: 16,48,49,52) be removed from further EEG analysis due to too many
%movements and preculiar extraneous experimental conditions (ie. refusal to
%use chin rest, physiological symptoms during experiment, no contignency
%retained,etc.)

%allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];
allsubs = [2 7 16 33 37 38 54 55];

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
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_ica_epochs_blc_Barej.set'); %Want to load back-of-head fear file
                thesechans = backofhead; %Channel loop will use back-of-head channels
            elseif v=='M' %If working with mid-of-head file
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_ica_epochs_blc_Marej.set'); %Want to load mid-of-head fear file
                thesechans = midofhead;
            elseif v=='F'
                thefile = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'post_ica_epochs_blc_Farej.set'); %Want to load front-of-head fear file
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
        
        eval(['save PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Save it all for fear
        clear cleandata %To save memory
        clear results
    end %Of block loop
end %Of subject loop

%% Average ERPs for each block at Post2 (4-6)

allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7

for s = allsubs
    
    bs = 4:6;
    
    for b = bs
        if s == 16 || s == 37 || s == 54
            eval(['load PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Save it all for fear
        else
            eval(['load PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs.mat results';]); %Save it all for fear
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
        
        eval(['save PLC_EEGpost_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]); %Save it all for each subject
        
    end
    
end

%% Average ERPs for Postcond2 blocks.

%allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];
allsubs = [2 7 16 33 37 38 54 55];
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
            
            eval(['load PLC_EEGpost_Sub' num2str(s) 'Block' num2str(b) 'ERPs_ica.mat results';]); %Load fear file
            eval(['load PLC_EEGpost_Sub' num2str(s) '_block' num2str(b) '_chaninfo_ica chaninfo']); %Load fear file channel info
            
            
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
    
    
    eval(['save PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs_ica.mat results';]); %Save it all for each subject

end %Of subject loop



%% Make grand averages-Postcond2

clear all
%allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];
%allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57];
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

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
        eval(['load PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs_ica.mat results';]);            
        else
        eval(['load PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs.mat results';]);
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

save PLC_EEG_GrandAve_Postcond2_32subs_032315.mat results


%% Make grand average Post2 (block 4-6, respectively)
%allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

for b = 4%:6
    
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
            eval(['load PLC_EEGpost_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]);
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
    
    eval(['save PLC_EEG_GrandAve_Post2_Block' num2str(b) '_ERPs_32subs_032315.mat results';]); %Save it all for each subject
    
end

%% Plot grand average Blockwise
%Ave Precond vs. Block4 
load PLC_EEG_GrandAve_Precond_36subsNo27.mat results
precond = results;

load PLC_EEG_GrandAve_Post2_Block4_ERPs_36subsNo27.mat results
postcond = results;

horz = precond.horz-200;

mkdir('GrandAveERPs_PrePost2_Blockwise_36subs_031515');
cd('GrandAveERPs_PrePost2_Blockwise_36subs_031515');

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
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'Post2B4 Gray CS+', 'Post2B4 Gray CS-', 'Post2B4 Color CS+', 'Post2B4 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePost2B4_36subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end
    

%Ave Precond vs. Block5 
load PLC_EEG_GrandAve_Precond_36subsNo27.mat results
precond = results;

load PLC_EEG_GrandAve_Post2_Block5_ERPs_36subsNo27.mat results
postcond = results;

horz = precond.horz-200;

%mkdir('GrandAveERPs_PrePost_Blockwise_45subs_031515');
cd('GrandAveERPs_PrePost2_Blockwise_36subs_031515');

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
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'Post2B5 Gray CS+', 'Post2B5 Gray CS-', 'Post2B5 Color CS+', 'Post2B5 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePost2B5_36subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end
    
    
%Ave Precond vs. Block6 
load PLC_EEG_GrandAve_Precond_36subsNo27.mat results
precond = results;

load PLC_EEG_GrandAve_Post2_Block6_ERPs_36subsNo27.mat results
postcond = results;

horz = precond.horz-200;

%mkdir('GrandAveERPs_PrePost_Blockwise_45subs_031515');
cd('GrandAveERPs_PrePost2_Blockwise_36subs_031515');

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
        
        legend('Pre Gray CS+','Pre Gray CS-','Pre Color CS+', 'Pre Color CS-', 'Post2B6 Gray CS+', 'Post2B6 Gray CS-', 'Post2B6 Color CS+', 'Post2B6 Color CS-', 'Location', 'northwest');
%        legend( 'Post Gray CS+', 'Post Gray CS-', 'Post Color CS+', 'Post Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEG_GrandAve_PrePost2B6_36subs_Chan' num2str(c) '.tif'');']);
        close(gcf)                
    end    
    
%% Plot individual ERPs Post2

clear all
%allsubs = [1:4 7 9 10 12 13 15 16 17 18 20:25 27 28 32:35 37:40 42:44 46 47 49 50 51 54 55 57];

allsubs = [2 7 16 33 37 38 54 55];

Oz = [28 30 31 32 44];
Pz = [24 34 35 36 40];
Cz = [1 2 38 63 84];
Fz = [75 81 82 83 86];


for s = allsubs
    
%     eval(['load PLC_EEG_Sub' num2str(s) '_Precond_ERPs.mat results';]);
%     precond = results;
%     clear results
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs_ica.mat results';]);
    postcond = results;
    clear results
    
horz = postcond.horz-200;
    
    for c = [31 35];
        figure;
%         plot(horz, precond.GrayCSp{c,:} , 'b--'); hold on;
%         plot(horz, precond.GrayCSm{c,:} , 'k--');
%         plot(horz, precond.ColCSp{c,:} , 'r--');
%         plot(horz, precond.ColCSm{c,:} , 'g--');
%         
        plot(horz, postcond.GrayCSp{c,:} , 'b');hold on;
        plot(horz, postcond.GrayCSm{c,:} , 'k');
        plot(horz, postcond.ColCSp{c,:} , 'r');
        plot(horz, postcond.ColCSm{c,:} , 'g');
        
        legend('Post2 Gray CS+', 'Post2 Gray CS-', 'Post2 Color CS+', 'Post2 Color CS-', 'Location', 'northwest');
        
        eval(['saveas(gcf,''PLC_EEGpost_Sub' num2str(s) '_Chan' num2str(c) '_ica.tif'');']);
        close(gcf)
        
        
    end
    
end

%% Compute individual Oz (A30-B1) ERPs (S1) for Block 4-6 (Postcond)

allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7
Ozchan = 30:33;

for b = 4:6
    
    %precond Oz ERPs for each individual
    for s = allsubs
        graycsp = [];
        graycsm = [];
        colcsp = [];
        colcsm = [];
        
        eval(['load PLC_EEGpost_Sub' num2str(s) '_Block' num2str(b) '_Averaged_ERPs.mat results';]);
        
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
        eval(['save PLC_EEGpost_Sub' num2str(s) '_Block' num2str(b) '_Oz_ERPs.mat Oz';]);
        
        
    end
    
end

%% Compute individual Oz (A30-B1) ERPs (S1) for Postcond2

%allsubs = [1:5 7:29 31 33 34 37:44 46 47 50 51 53:57];
allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7

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
        eval(['load PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs_ica.mat results';]);
    else
        eval(['load PLC_EEGpost_Sub' num2str(s) '_Postcond2_ERPs.mat results';]);
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
    %eval(['save PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
    
    allERPsColor = [allERPsColor; Oz.ColorCSp; Oz.ColorCSm];
    allERPsGray = [allERPsGray; Oz.GrayCSp; Oz.GrayCSm];
end
grandycolor = mean(allERPsColor,1); %Make the grand-grand average
grandygray = mean(allERPsGray,1);

plot(horz, grandycolor); hold on; %this plots the grand ERP for color condition across CS+/CS-, across Pre/Postcond for S1
plot(horz, grandygray);%this plots the grand ERP for gray condition across CS+/CS-, across Pre/Postcond for S1

% saveas(gcf, 'GrandColor_Gray_average_36subs_S2.jpg');
% save GrandColor_Gray_ERP_36subs_S2 horz grandycolor grandygray
%Last updated 02/26/15
%Inspection of grandycolor along with the graph identifies 
%C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 111

%Inspection of grandygray along with the graph identifies 
%P1 peak: 86; N1: 100; P2 peak: 116

%% Get mean amplitudes for each individual - Postcond2
allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57];

clear Oz
AllColorC1P1C2 = [];
AllColor150_300 = [];
AllGrayP1 = [];
AllGray150_300 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
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


save PLC_EEG_Postcond2_MeanAmp_36subs AllColorC1P1C2 AllColor150_300 AllGrayP1 AllGray150_300

%%  Get mean amplitudes for each individual: precond; 3/16/15

%Inspection of grandycolor along with the graph identifies 
%C1 trough:61; C1 peak:75; P1 peak:78; N1 peak: 86; P2 peak: 110

%Inspection of grandygray along with the graph identifies 
%P1 peak: 85; N1: 98; P2 peak: 114

allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7, 32

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

save PLC_EEG_PrecondNewComponents_MeanAmp_36subs AllColorC1P1C2 AllGrayP1N1P2

%%  Get mean amplitudes for each individual: postcond2; 3/19/15

allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55];
clear Oz
AllColorC2N3 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
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

save PLC_EEG_Postcond2NewComponents_MeanAmp_32subs AllColorC2N3 AllGrayP1N1P2

%%  Get mean amplitudes for each individual: postcond2; 3/22/15
%individual peaks for each component 

allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55];
clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(84:88));
    ColorCSpP2 = mean(Oz.ColorCSp(98:122));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(98:122));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(110:120)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(83:89));
    GrayCSmN1 = mean(Oz.GrayCSm(93:103));
    GrayCSmP2 = mean(Oz.GrayCSm(112:122)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_Postcond2NewComponents_MeanAmp_32subs AllColorC2P2 AllGrayP1N1P2


%%  Get mean amplitudes for each individual: postcond B4; 3/22/15
%Individual peaks

%allsubs = [1 3 4 9 10 12 13 15 16 17 18 20:25 27 28 32 33 34 37:40 42:44 46 47 50 51 54 55 57]; %36 subs, no 2, 7
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55];

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(84:88));
    ColorCSpP2 = mean(Oz.ColorCSp(98:122));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(98:122));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(110:120)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(83:89));
    GrayCSmN1 = mean(Oz.GrayCSm(93:103));
    GrayCSmP2 = mean(Oz.GrayCSm(112:122)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_Postcond2B4_NewComponents_MeanAmp_32subs AllColorC2P2 AllGrayP1N1P2

%% B5
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55];

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(84:88));
    ColorCSpP2 = mean(Oz.ColorCSp(98:122));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(98:122));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(110:120)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(83:89));
    GrayCSmN1 = mean(Oz.GrayCSm(93:103));
    GrayCSmP2 = mean(Oz.GrayCSm(112:122)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_Postcond2B5_NewComponents_MeanAmp_32subs AllColorC2P2 AllGrayP1N1P2

%% B6
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55];

clear Oz
AllColorC2P2 = [];
AllGrayP1N1P2 = [];

for s = allsubs
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
%     ColorCSpC1 = Oz.ColorCSp(75) - Oz.ColorCSp(69);
%     ColorCSpC1P1 = Oz.ColorCSp(78) - Oz.ColorCSp(75);
    ColorCSpC2 = mean(Oz.ColorCSp(84:88));
    ColorCSpP2 = mean(Oz.ColorCSp(98:122));

%     ColorCSmC1 = Oz.ColorCSm(75) - Oz.ColorCSm(69);                        
%     ColorCSmC1P1 = Oz.ColorCSm(78) - Oz.ColorCSm(75);
    ColorCSmC2 = mean(Oz.ColorCSm(84:88));
    ColorCSmP2 = mean(Oz.ColorCSm(98:122));
    
    GrayCSpP1 = mean(Oz.GrayCSp(83:89));
    GrayCSpN1 = mean(Oz.GrayCSp(96:106));
    GrayCSpP2 = mean(Oz.GrayCSp(110:120)); %using a broader window here

    
    GrayCSmP1 = mean(Oz.GrayCSm(83:89));
    GrayCSmN1 = mean(Oz.GrayCSm(93:103));
    GrayCSmP2 = mean(Oz.GrayCSm(112:122)); %using a broader window here

%AllColorC1P1C2 = [AllColorC1P1C2; s ColorCSpC1 ColorCSmC1 ColorCSpC1P1 ColorCSmC1P1 ColorCSpC2 ColorCSmC2];
%AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2];

AllColorC2P2 = [AllColorC2P2; s ColorCSpC2 ColorCSmC2 ColorCSpP2 ColorCSmP2];
AllGrayP1N1P2 = [AllGrayP1N1P2; s GrayCSpP1 GrayCSmP1 GrayCSpN1 GrayCSmN1 GrayCSpP2 GrayCSmP2]; 

end

save PLC_EEG_Postcond2B6_NewComponents_MeanAmp_32subs AllColorC2P2 AllGrayP1N1P2


%% Exploratory point-by-point ttest of Time(Pre/Post2)*CS(+/-) interaction
%Color condition, early time window
clear all

allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

PersonSCR = [-0.64	-0.88	-0.76	-0.121536792	-0.132784119	0.366863619	-0.3569859
-0.02	0.41	0.2	-0.221098569	0.213223158	-0.083370757	-0.020371948
-0.33	-0.02	-0.17	0.139763219	-0.043098606	0.471919875	0.262141312
1.22	1.7	1.46	0.36877096	-0.491990139	0.034038093	0.067089671
1.22	-0.45	0.39	-0.139188915	-0.147945488	0.114775733	-0.291521322
-1.57	-1.02	-1.3	-0.078448693	-0.004932663	-0.263994114	0.005962676
0.6	-0.88	-0.14	0.141901832	0.08047412	-0.09508355	0.172889885
-1.88	-1.02	-1.45	-0.040906923	0.018814522	0.172573828	0.169081742
-1.88	0.99	-0.45	0.569641514	0.342857485	-0.196825843	-0.101016624
0.603670406	-0.161709278	0.220980564	0.168769341	-0.012218746	-0.09257476	-0.312418196
0.29	0.99	0.64	-0.097414847	0.124333057	-0.151984501	0.022525672
-0.02	-1.17	-0.59	-0.038107585	0.166154016	0.189281646	-0.046357874
-0.33	-0.16	-0.24	-0.047451922	-0.103875478	-0.276717168	0.225959648
-0.64	0.41	-0.11	-0.355755034	-0.315810171	0.09821349	0.021989142
-0.33	0.27	-0.03	-0.198523144	-0.108344191	0.123112763	-0.087711434
0.29	2.28	1.29	0.304204643	0.29217203	-0.411517265	-0.115777582
1.22	1.27	1.25	-0.115530829	-0.233143978	0.03962776	-0.261270159
-1.57	-0.31	-0.94	-0.254398174	0.142865601	-0.36537068	-0.053196999
-1.57	1.42	-0.08	0.229313752	0.250467973	0.051307525	-0.308803084
-0.33	-1.02	-0.67	-0.193101176	0.350788741	0.201212913	0.13495568
0.29	-0.74	-0.22	0.185501308	0.025087202	-0.355108999	-0.359832089
-0.64	-0.74	-0.69	0.010207711	0.051588986	-0.214820225	0.078117059
-0.33	-1.17	-0.75	-0.011989929	0.118593346	-0.034980388	0.357294415
1.22	2.56	1.89	-0.041497311	0.392906764	0.167469119	0.25179714
-0.64	0.13	-0.26	-0.003450558	-0.011161584	-0.062522954	-0.432529335
1.84	0.84	1.34	0.099551071	-0.123122405	0.074360616	0.009846859
0.29	-1.17	-0.44	-0.60307947	-0.344911395	-0.086188842	0.062774807
0.91	0.27	0.59	-0.140133381	-0.048098821	-0.089972098	0.0472167
1.53	-0.02	0.76	-0.291805415	0.04449716	0.128858143	-0.004933233
0.91	-1.02	-0.05	0.360509487	-0.262573594	0.164646545	0.02973369
0.29	-0.88	-0.29	-0.42510864	-0.216558757	0.171595138	0.154972687
-1.57	-0.88	-1.22	-0.194993828	0.11694365	0.030306071	-0.070034748];

BISz = PersonSCR(:,1);
BAIz = PersonSCR(:,2);
Anxz = PersonSCR(:,3);

PreColorSCRCSd = PersonSCR(:,4);
PreGraySCRCSd = PersonSCR(:,5);
Post2ColorSCRCSd = PersonSCR(:,6);
Post2GraySCRCSd = PersonSCR(:,7);

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
Postcond2ColorCSp = [];
Postcond2ColorCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.ColorCSp - Postcond2.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    Postcond2ColorCSp = [Postcond2ColorCSp; Postcond2.ColorCSp];
    Postcond2ColorCSm = [Postcond2ColorCSm; Postcond2.ColorCSm];
end

PreColorCSp = mean(PrecondColorCSp,1);
PreColorCSm = mean(PrecondColorCSm,1);
Post2ColorCSp = mean(Postcond2ColorCSp,1);
Post2ColorCSm = mean(Postcond2ColorCSm,1);

[themin, PreColorCSpC2peak] = min(PreColorCSp(81:91)); % 81+6-1 = 86
[themin, PreColorCSmC2peak] = min(PreColorCSm(81:91)); % 86
[themin, Post2ColorCSpC2peak] = min(Post2ColorCSp(81:91)); % 86
[themin, Post2ColorCSmC2peak] = min(Post2ColorCSm(81:91));% 86

[themax, PreColorCSpP2peak] = max(PreColorCSp(103:116)); % 103+9-1 = 111
[themax, PreColorCSmP2peak] = max(PreColorCSm(103:116)); % 111
[themax, Post2ColorCSpP2peak] = max(Post2ColorCSp(103:116)); % 110
[themax, Post2ColorCSmP2peak] = max(Post2ColorCSm(103:116)); % 110

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
    
    [rscr, rpscr] = corr(interaction, (Post2ColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

%plotting waveform
horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(Postcond2ColorCSp,1) , 'r');
plot(horz, mean(Postcond2ColorCSm,1) , 'g');

% plot(horz,allPs, 'k');
% plot(horz,allrpi+1, 'k--');
% plot(horz,allrpscr+2, 'k-.');

line([horz(83) horz(83)],[0 -7]);
line([horz(88) horz(88)],[0 -7]);

line([horz(98) horz(98)],[0 -7]);
line([horz(122) horz(122)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post2 Color CS+', 'Post2 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2_ColorERPs_32subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

%save PrePost2Ave_32subs_Color_TimebyCS.mat


%% Gray condition, early time window
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
Postcond2GrayCSp = [];
Postcond2GrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.GrayCSp - Postcond2.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    Postcond2GrayCSp = [Postcond2GrayCSp; Postcond2.GrayCSp];
    Postcond2GrayCSm = [Postcond2GrayCSm; Postcond2.GrayCSm];
end

PreGrayCSp = mean(PrecondGrayCSp,1);
PreGrayCSm = mean(PrecondGrayCSm,1);
Post2GrayCSp = mean(Postcond2GrayCSp,1);
Post2GrayCSm = mean(Postcond2GrayCSm,1);

[themax, PreGrayCSpP1peak] = max(PreGrayCSp(81:91)); % 85
[themax, PreGrayCSmP1peak] = max(PreGrayCSm(81:91)); % 84
[themax, Post2GrayCSpP1peak] = max(Post2GrayCSp(81:91)); % 86
[themax, Post2GrayCSmP1peak] = max(Post2GrayCSm(81:91));% 86

[themin, PreGrayCSpN1peak] = min(PreGrayCSp(91:107)); % 91+11-1 = 101
[themin, PreGrayCSmN1peak] = min(PreGrayCSm(91:107)); % 91+8-1 = 98
[themin, Post2GrayCSpN1peak] = min(Post2GrayCSp(91:107)); % 91+11-1 = 101
[themin, Post2GrayCSmN1peak] = min(Post2GrayCSm(91:107)); % 91+8-1 = 98

[themax, PreGrayCSpP2peak] = max(PreGrayCSp(107:122)); % 107+9-1 = 115
[themax, PreGrayCSmP2peak] = max(PreGrayCSm(107:122)); % 107+9-1 = 115
[themax, Post2GrayCSpP2peak] = max(Post2GrayCSp(107:122)); % 107+9-1 = 115
[themax, Post2GrayCSmP2peak] = max(Post2GrayCSm(107:122));% 107+11-1 = 117

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
    
    [rscr, rpscr] = corr(interaction, (Post2GraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];     
    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(Postcond2GrayCSp,1) , 'b-');
plot(horz, mean(Postcond2GrayCSm,1) , 'g-');

% plot(horz,allPs-2, 'r');
% plot(horz,allrpi-1, 'r--');
% plot(horz,allrpscr, 'k-');

line([horz(82) horz(82)],[0 6]);
line([horz(88) horz(88)],[0 6]);

% line([horz(99) horz(99)],[0 6]);
% 
% line([horz(105) horz(105)],[0 6]);
% 
% %line([horz(104) horz(104)],[0 6]);
% line([horz(124) horz(124)],[0 6]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post2 Gray CS+', 'Post2 Gray CS-', 'Location', 'northwest');
saveas(gcf, 'PrePost2_GrayERPs_32subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

%save PrePost2Ave_32subs_Gray_TimebyCS.mat


%% Exploratory point-by-point ttest of Time(Pre/Post2 B4)*CS(+/-) interaction
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
Postcond2ColorCSp = [];
Postcond2ColorCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.ColorCSp - Postcond2.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    Postcond2ColorCSp = [Postcond2ColorCSp; Postcond2.ColorCSp];
    Postcond2ColorCSm = [Postcond2ColorCSm; Postcond2.ColorCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2ColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(Postcond2ColorCSp,1) , 'r');
plot(horz, mean(Postcond2ColorCSm,1) , 'g');

% plot(horz,allPs, 'k');
% plot(horz,allrpi+1, 'k--');
% plot(horz,allrpscr+2, 'k-.');

line([horz(98) horz(98)],[0 -7]);
line([horz(122) horz(122)],[0 -7]);


legend('Pre Color CS+', 'Pre Color CS-', 'Post2 B4 Color CS+', 'Post2 B4 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B4_ColorERPs_32subs_TimebyCSbyBIS_pval.jpg');
%close(gcf);

%save PrePost2B4_32subs_Color_TimebyCS.mat

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
Postcond2GrayCSp = [];
Postcond2GrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.GrayCSp - Postcond2.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    Postcond2GrayCSp = [Postcond2GrayCSp; Postcond2.GrayCSp];
    Postcond2GrayCSm = [Postcond2GrayCSm; Postcond2.GrayCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2GraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];     
    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(Postcond2GrayCSp,1) , 'b-');
plot(horz, mean(Postcond2GrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 7]);
line([horz(87) horz(87)],[0 7]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post2 B4 Gray CS+', 'Post2 B4 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B4_GrayERPs_32subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePost2B4_32subs_Gray_TimebyCS.mat

%% Plot Grand Average ERP Pre-Post2B4 Color/Gray at Oz - 3.23.15

allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

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
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block4_Oz_ERPs.mat Oz';]);
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
line([horz(98) horz(98)],[4 -7]);
line([horz(87) horz(87)],[4 -7]);
line([horz(122) horz(122)],[4 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post2B4 Color CS+', 'Post2B4 Color CS-', 'Pre Gray CS+', 'Pre Gray CS-', 'Post2B4 Gray CS+', 'Post2B4 Gray CS-','Location', 'southwest');

%% Plot Grand Average ERP Pre-Post2 Color/Gray at Oz - 3.23.15

allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

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
    
    eval(['load PLC_EEG_Sub' num2str(s) '_Postcond2_Oz_ERPs.mat Oz';]);
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
line([horz(98) horz(98)],[4 -7]);
line([horz(87) horz(87)],[4 -7]);
line([horz(122) horz(122)],[4 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post2 Color CS+', 'Post2 Color CS-', 'Pre Gray CS+', 'Pre Gray CS-', 'Post2 Gray CS+', 'Post2 Gray CS-','Location', 'southwest');


%% Exploratory point-by-point ttest of Time(Pre/Post2 B5)*CS(+/-) interaction
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
Postcond2ColorCSp = [];
Postcond2ColorCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.ColorCSp - Postcond2.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    Postcond2ColorCSp = [Postcond2ColorCSp; Postcond2.ColorCSp];
    Postcond2ColorCSm = [Postcond2ColorCSm; Postcond2.ColorCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2ColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(Postcond2ColorCSp,1) , 'r');
plot(horz, mean(Postcond2ColorCSm,1) , 'g');

plot(horz,allPs, 'k');
plot(horz,allrpi+1, 'k--');
plot(horz,allrpscr+2, 'k-.');

line([horz(81) horz(81)],[0 -7]);
line([horz(87) horz(87)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post2 B5 Color CS+', 'Post2 B5 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B5_ColorERPs_32subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePost2B5_32subs_Color_TimebyCS.mat


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
Postcond2GrayCSp = [];
Postcond2GrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block5_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.GrayCSp - Postcond2.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    Postcond2GrayCSp = [Postcond2GrayCSp; Postcond2.GrayCSp];
    Postcond2GrayCSm = [Postcond2GrayCSm; Postcond2.GrayCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2GraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];     
    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(Postcond2GrayCSp,1) , 'b-');
plot(horz, mean(Postcond2GrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 5]);
line([horz(87) horz(87)],[0 5]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post2 B5 Gray CS+', 'Post2 B5 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B5_GrayERPs_32subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePost2B5_32subs_Gray_TimebyCS.mat

%% Exploratory point-by-point ttest of Time(Pre/Post2 B6)*CS(+/-) interaction
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
Postcond2ColorCSp = [];
Postcond2ColorCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.ColorCSp - Postcond2.ColorCSm) - (Precond.ColorCSp - Precond.ColorCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondColorCSp = [PrecondColorCSp; Precond.ColorCSp];
    PrecondColorCSm = [PrecondColorCSm; Precond.ColorCSm];
    Postcond2ColorCSp = [Postcond2ColorCSp; Postcond2.ColorCSp];
    Postcond2ColorCSm = [Postcond2ColorCSm; Postcond2.ColorCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2ColorSCRCSd - PreColorSCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];    
end

horz = Precond.horz;

plot(horz, mean(PrecondColorCSp,1) , 'r:'); hold on;
plot(horz, mean(PrecondColorCSm,1) , 'g:');

plot(horz, mean(Postcond2ColorCSp,1) , 'r');
plot(horz, mean(Postcond2ColorCSm,1) , 'g');

plot(horz,allPs, 'k');
plot(horz,allrpi+1, 'k--');
plot(horz,allrpscr+2, 'k-.');

line([horz(81) horz(81)],[0 -7]);
line([horz(87) horz(87)],[0 -7]);

legend('Pre Color CS+', 'Pre Color CS-', 'Post2 B6 Color CS+', 'Post2 B6 Color CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B6_ColorERPs_32subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePost2B6_32subs_Color_TimebyCS.mat

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
Postcond2GrayCSp = [];
Postcond2GrayCSm = [];

for s = allsubs
    eval(['load PLC_EEG_Sub' num2str(s) '_Precond_Oz_ERPs.mat Oz';]);
    Precond = Oz;
    
    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block6_Oz_ERPs.mat Oz';]);
    Postcond2 = Oz;
    
    TimebyCS = (Postcond2.GrayCSp - Postcond2.GrayCSm) - (Precond.GrayCSp - Precond.GrayCSm);
    allTimebyCS = [allTimebyCS; TimebyCS];
    
    PrecondGrayCSp = [PrecondGrayCSp; Precond.GrayCSp];
    PrecondGrayCSm = [PrecondGrayCSm; Precond.GrayCSm];
    Postcond2GrayCSp = [Postcond2GrayCSp; Postcond2.GrayCSp];
    Postcond2GrayCSm = [Postcond2GrayCSm; Postcond2.GrayCSm];
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
    
    [rscr, rpscr] = corr(interaction, (Post2GraySCRCSd - PreGraySCRCSd));
    
    allrscr = [allrscr rscr];
    allrpscr = [allrpscr rpscr];     
    
end

horz = Precond.horz;

plot(horz, mean(PrecondGrayCSp,1) , 'b-.'); hold on;
plot(horz, mean(PrecondGrayCSm,1) , 'g-.');

plot(horz, mean(Postcond2GrayCSp,1) , 'b-');
plot(horz, mean(Postcond2GrayCSm,1) , 'g-');

plot(horz,allPs-2, 'r');
plot(horz,allrpi-1, 'r--');
plot(horz,allrpscr, 'k-');

line([horz(81) horz(81)],[0 5]);
line([horz(87) horz(87)],[0 5]);

legend('Pre Gray CS+', 'Pre Gray CS-', 'Post2 B6 Gray CS+', 'Post2 B6 Gray CS-', 'Location', 'southwest');
saveas(gcf, 'PrePost2B6_GrayERPs_32subs_TimebyCSbyBIS_pval.jpg');
close(gcf);

save PrePost2B6_32subs_Gray_TimebyCS.mat

%% Prepare for Loreta - Pre individual conditions
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

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
        
    for c = 1:96
        colcsp =  Precond.ColCSp{c};
        colcsm =  Precond.ColCSm{c};
        
        ColorCSpP2(c,1) = mean(colcsp(98:122));
        ColorCSmP2(c,1) = mean(colcsm(98:122));
    end
    
    ColorCSpP2std = double((ColorCSpP2 - mean(ColorCSpP2))./std(ColorCSpP2));
    ColorCSmP2std = double((ColorCSmP2 - mean(ColorCSmP2))./std(ColorCSmP2));
    
    
    cd /Volumes/SAVER/PLC_EEG/LORETA/Post2B4Pre_ColorP2
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_ColorCSpP2std.txt -ascii ColorCSpP2std;']);
    
    eval(['save PLC_EEG_Pre_Sub' num2str(s) '_ColorCSmP2std.txt -ascii ColorCSmP2std;']);
    
end

%% Prepare for Loreta - Post2b4-Pre individual conditions
allsubs = [1 3 4 9 10 13 15 16 17 18 20:25 27 28 33 34 38:40 42:44 46 47 50 51 54 55]; %32 subs, no 2,7,32,12,37,57

for s = allsubs
    
    cd /Volumes/SAVER/PLC_EEG/ERPs

    eval(['load PLC_EEGpost_Sub' num2str(s) '_Block4_Averaged_ERPs.mat results';]);
    
    Postcond2 = results;
    
    for c = 1:96
        colcsp = Postcond2.ColCSp{c} ;
        colcsm = Postcond2.ColCSm{c} ;
        
        ColorCSpP2(c,1) = mean(colcsp(98:122));
        ColorCSmP2(c,1) = mean(colcsm(98:122));
    end
    
    ColorCSpP2std = double((ColorCSpP2 - mean(ColorCSpP2))./std(ColorCSpP2));
    ColorCSmP2std = double((ColorCSmP2 - mean(ColorCSmP2))./std(ColorCSmP2));
       
    cd /Volumes/SAVER/PLC_EEG/LORETA/Post2B4Pre_ColorP2
    
    eval(['save PLC_EEG_Post2B4_Sub' num2str(s) '_ColorCSpP2std.txt -ascii ColorCSpP2std;']);
    
    eval(['save PLC_EEG_Post2B4_Sub' num2str(s) '_ColorCSmP2std.txt -ascii ColorCSmP2std;']);
    
end
%% Prepare for Loreta Grand ave Postcond2

clear all
 
load PLC_EEG_GrandAve_Postcond2_36subsNo27.mat 
 
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
    save PLC_EEG_postcond2_ColorCSC1P1std.txt -ascii ColorCSC1P1std;
    
    ColorCSC2std = double((ColorCSC2 - mean(ColorCSC2))./std(ColorCSC2)); 
    save PLC_EEG_postcond2_ColorCSC2std.txt -ascii ColorCSC2std;
 
    ColorCS150_175std = double((ColorCS150_175 - mean(ColorCS150_175))./std(ColorCS150_175)); 
    save PLC_EEG_postcond2_ColorCS150_175std.txt -ascii ColorCS150_175std;
 
    ColorCS175_200std = double((ColorCS175_200 - mean(ColorCS175_200))./std(ColorCS175_200)); 
    save PLC_EEG_postcond2_ColorCS175_200std.txt -ascii ColorCS175_200std;
    
    ColorCS200_225std = double((ColorCS200_225 - mean(ColorCS200_225))./std(ColorCS200_225)); 
    save PLC_EEG_postcond2_ColorCS200_225std.txt -ascii ColorCS200_225std;
   
    ColorCS225_250std = double((ColorCS225_250 - mean(ColorCS225_250))./std(ColorCS225_250)); 
    save PLC_EEG_postcond2_ColorCS225_250std.txt -ascii ColorCS225_250std;
 
    ColorCS250_275std = double((ColorCS250_275 - mean(ColorCS250_275))./std(ColorCS250_275)); 
    save PLC_EEG_postcond2_ColorCS250_275std.txt -ascii ColorCS250_275std;
 
    ColorCS275_300std = double((ColorCS275_300 - mean(ColorCS275_300))./std(ColorCS275_300)); 
    save PLC_EEG_postcond2_ColorCS275_300std.txt -ascii ColorCS275_300std;
 
    GrayCSP1std = double((GrayCSP1 - mean(GrayCSP1))./std(GrayCSP1)); 
    save PLC_EEG_postcond2_GrayCSP1std.txt -ascii GrayCSP1std;
     
    GrayCS150_175std = double((GrayCS150_175 - mean(GrayCS150_175))./std(GrayCS150_175)); 
    save PLC_EEG_postcond2_GrayCS150_175std.txt -ascii GrayCS150_175std;
 
    GrayCS175_200std = double((GrayCS175_200 - mean(GrayCS175_200))./std(GrayCS175_200)); 
    save PLC_EEG_postcond2_GrayCS175_200std.txt -ascii GrayCS175_200std;
    
    GrayCS200_225std = double((GrayCS200_225 - mean(GrayCS200_225))./std(GrayCS200_225)); 
    save PLC_EEG_postcond2_GrayCS200_225std.txt -ascii GrayCS200_225std;
   
    GrayCS225_250std = double((GrayCS225_250 - mean(GrayCS225_250))./std(GrayCS225_250)); 
    save PLC_EEG_postcond2_GrayCS225_250std.txt -ascii GrayCS225_250std;
 
    GrayCS250_275std = double((GrayCS250_275 - mean(GrayCS250_275))./std(GrayCS250_275)); 
    save PLC_EEG_postcond2_GrayCS250_275std.txt -ascii GrayCS250_275std;
 
    GrayCS275_300std = double((GrayCS275_300 - mean(GrayCS275_300))./std(GrayCS275_300)); 
    save PLC_EEG_postcond2_GrayCS275_300std.txt -ascii GrayCS275_300std;
