
allsubs = 1%[1:5 7:15 17:44 46 47 50 51 53:57];

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
                    
                %cleanevent = cell2mat(cleanevents);
                
                    switch cleanevent(j)
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
            cleaneventall{counter,1} = cleanevent;
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
        
        eval(['save PLC_EEG_Sub' num2str(s) 'Block' num2str(g) 'ERPs.mat results';]); %Save it all for fear
        clear cleandata %To save memory
        clear results 
    end %Of block loop
end %Of subject loop 