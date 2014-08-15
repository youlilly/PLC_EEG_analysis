%% PLC EEG SCR Analyzer
% this one uses the scralyze package (integrated with SPM8) to generate beta estimates for each
% condition 
% Created by YY May 14, 2014

%% List of subject initials

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

%% Analyses below laid out are pertaining to SCR extraction for fear
%% conditioning blocks (color and gray)
%% Grab SCR channel from the EEG data - Conditioning blocks
% Convert bdf to .set format

allsubs = [40:44 46:57];
condition = {'color';'gray'};

for a = allsubs
    initial = subinitials(a,:);
    
    if a == 37
        c1 = 1; %because sub37 gray conditioning is not properly saved
    else c1 = 1:2;
    end
    
    for c = c1
        
        ccode = condition{c,:};
            
        filename = strcat('Sub', num2str(a),'_',initial,'_fear_', ccode ,'-Deci.bdf');
        EEG = pop_biosig(filename, 'ref',[97 98] , 'rmeventchan', 'off'); %Load up bdf file

        setname = strcat('PLC_Sub',num2str(a),'_fc_',ccode);
        EEG.setname = setname;
        
    EEG = eeg_checkset( EEG ); %Check dataset for errors
    savefile = strcat('PLC_Sub',num2str(a),'_fc_',ccode);
    EEG = pop_saveset( EEG,  'filename', savefile); %Save file in .set format
        
    end
    
    
end

%% Get the latency and save the SCR channel data
% this step generates "PLC...._scr.mat" files that can be imported by
% the script "Import_fc_scr_allsub.m" that calls the "Import" functions of scralyze; 
% In order for this function to work properly, the matlab fomrat of scr data needs to contain a single column of SCR data

% Sub7 and 12 were saved using a different setting, therefore, chan263 is
% the scr channel; other subjects have chan103 as the scr channel

condition = {'color';'gray'};
eventnum = [];
allsubs = [7 12];

for a = allsubs
    if a ==37
        c1 = 1;
    else c1 = 1:2;
    end
    
    for c = c1
        eventdata = [];%store event latencies
        eventonsets = [];%store both event latencies and corresponding event type
        data = [];%saves SCR data
        
        ccode = condition{c,:};
        
        switch rem(a,2)
            case(1)
                if c ==1
                    %501 color T1, 502 color T2, 166 color T1 UCS, 266,
                    %color T2 UCS
                eventtype = [502 266 501 166 501 166 502 266 502 266 501 501 166 502 266 502 501 166 501 166 502 266 501 166 502 266 501 502 266 502 501 166 501 502];
                else
                eventtype = [101 166 102 266 102 266 101 166 101 166 102 102 266 101 101 166 102 266 101 102 266 101 166 102 101 166 102 101 166 102 266 101 102 266];
                end
            case(0)
                if c ==1
                eventtype = [502 266 501 166 502 266 501 166 501 166 502 266 501 502 502 266 501 166 502 501 166 502 266 501 502 266 501 166 501 502 266 501 166 502];
                else
                eventtype = [102 266 102 266 101 166 101 166 101 166 102 102 266 101 102 266 101 101 166 102 266 101 166 102 102 266 101 101 166 102 266 101 166 102];  
                end
                               
        end
            
        filename = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'.set');
        EEG = pop_loadset(filename); % load the EEG .set file
        
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
            
            if EEG.event(1).latency < 2000 %If the then first event has a latency less or equal than ~8s, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', 1); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            else %If the first event is legit (which it isn't on most of these files), do nothing
            end
            
        end 
        
    zf = length(EEG.event);    
    eventnum = [eventnum; a c zf];
    
        for i = 1:length(EEG.event)
           eventdata = [eventdata EEG.event(1,i).latency]; 
        end
        
    eventonsets =[eventdata; eventtype];
    
    scrfile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_event.mat');%save event onsets + types
    save(scrfile, 'eventonsets');
    
    data = EEG.data(263,:)'; %channel 103 saves SCR
    scrdatafile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_scr.mat');%save continuous SCR
    save(scrdatafile, 'data');
    
    end
    
    
end

%% Reformat and generate multiple condition file
% have onsets for both CS+/- and corresponding UCS (four conditions)
% this step generates a "PLC..._mcf.mat" file that can be loaded by the
% script "Glm_fc_allsubs.m", which calls 1st level GLM feature of scralyze
% and generates betas for each condition in each individual

allsubs = [7 12];
condition = {'color';'gray'};


for a = allsubs
    if a ==37
        c1 = 1;
    else c1 = 1:2;
    end
        
    for c = c1
    ccode = condition{c,:};
    scrfile = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    names = {'T1', 'T2', 'T1UC', 'T2UC'};
    
    if c == 1
    T1onsets = eventonsets(1,eventonsets(2,:)==501);
    T2onsets = eventonsets(1,eventonsets(2,:)==502);


    else
    T1onsets = eventonsets(1,eventonsets(2,:)==101);
    T2onsets = eventonsets(1,eventonsets(2,:)==102);                
    end
    
    
    T1UConsets = eventonsets(1,eventonsets(2,:)==166);
    T2UConsets = eventonsets(1,eventonsets(2,:)==266);
     %   T3onsets = eventonsets(1,eventonsets(2,:)==66);
      
    onsets = {T1onsets, T2onsets, T1UConsets, T2UConsets};
    mcf = strcat('PLC_Sub',num2str(a),'_fc_',ccode,'_mcf.mat');
    save(mcf, 'names', 'onsets');
    end
    
end


%% Compute 1st level constrast for each individual
% this steps calls each individual "SubX_fc_gray/color_1stGLM.mat" file and
% record the beta for each condition, tabulizing them

allsubs = [1:5 7:39];
condition = {'color';'gray'};
all_betas = []; %subno, color-code (1:color; 2:gray), CS+, CS-, UCS+, UCS-

for a = allsubs
    if a ==37
        c1 = 1;
    else c1 = 2;
    end
        
    for c = c1
    ccode = condition{c,:};
    glmfile = strcat('/Volumes/Work/SCR/Sub', num2str(a),'_fc_',ccode,'_1stGLM.mat');%save event onsets + types
    load(glmfile);
    
    if rem(a,2)==1
        all_betas = [all_betas; a c glm.beta(1,1) glm.beta(4,1) glm.beta(7,1) glm.beta(10,1)];
      
    else
        all_betas = [all_betas; a c glm.beta(4,1) glm.beta(1,1) glm.beta(10,1) glm.beta(7,1)];
         
    end

    
    end
    
end


%% Sort data into groups of subjects
%a = [];%to-be-sorted data matrix
index = [1,2,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39;];%the full group of SCR subjects
index1 = [1,2,3,4,5,7,9,10,11,13,15,17,18,19,20,21,22,24,25,27,28,31,32,33,34,38,39;];%successfully conditioned sub at the end of visit1
index2 = [1,2,3,4,7,9,10,12,17,20,21,22,23,24,25,27,28,33,34,37,38,39;];%successfully conditioned sub at the end of visit2
c = 1;
b = [];

for i = 1:length(a)
    
    ind = a(i,1);
    if ismember(ind, index2)
        b(c,:) = a(i,:);
        c = c+1;
    end
end

%% Analyses below are pertaining to Orientation Detection blocks (pre,
%% post1, post2)
%% Grab SCR channel from the EEG data - Gabor blocks 1-6, post2 4-6
% Convert bdf to .set format
ExpStatus = [1	0	1
1	1	1
1	1	1
1	1	1
1	1	NaN
NaN NaN NaN
1	1	1
0	1	NaN
1	1	1
1	1	1
1	0	2
0	1	1
1	1	0
0	0	NaN
1	1	0
0	1	0
1	1	1
1	1	0
1	1	NaN
1	1	1
1	1	1
1	1	1
0	1	1
1	1	1
1	1	1
0	0	2
1	1	1
1	1	1
0	0	NaN
1	0	2
1	1	NaN
1	0	0
1	1	1
1	1	1
1	1	1
1	0	2
0	1	1
1	1	1
1	1	1];

%%

allsubs=find(ExpStatus(:,3)==1 | ExpStatus(:,3)==0)';

for a = allsubs
    initial = subinitials(a,:);
%     
%     if a == 15
%         c1 = 1:5; %because sub37 gray conditioning is not properly saved
%     else c1 = 1:6;
%     end
    
    for c = 4:6
           
    filename = strcat('Sub', num2str(a),'_', initial, '_block', num2str(c),'post-Deci.bdf');
    EEG = pop_biosig(filename, 'ref',[97 98] , 'rmeventchan', 'off'); %Load up bdf file

    setname = strcat('EEG_Sub',num2str(a),'_block',num2str(c));
    EEG.setname = setname;
        
    EEG = eeg_checkset( EEG ); %Check dataset for errors
    
    savefile = strcat('EEG_Sub',num2str(a),'_block',num2str(c));
    EEG = pop_saveset( EEG,  'filename', savefile); %Save file in .set format
        
    end



end

%% Get the latency and save the SCR channel data - Gabor blocks
% this step generates "PLC...._scr.mat" files that can be imported by
% the script "Import_gb_scr_allsub.m" that calls the "Import" functions of scralyze; 
% In order for this function to work properly, the matlab fomrat of scr data needs to contain a single column of SCR data

% Sub7 and 12 were saved using a different setting, therefore, chan263 is
% the scr channel; other subjects have chan103 as the scr channel


eventnum = [];
allsubs = 39%[34,35,37,38,39;];
for a = allsubs

    c1 = 4:6;
    
    if a == 3 || a == 4
        scrchan  = 263;
    else
        scrchan = 103;
    end
    
    for c = c1
        eventdata = [];%store event latencies
        eventonsets = [];%store both event latencies and corresponding event type
        data = [];%saves SCR data

        
        switch c
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
            
        filename = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'.set');
        EEG = pop_loadset(filename); % load the EEG .set file
        
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
            
            if EEG.event(1).latency < 1536 %If the then first event has a latency less or equal than ~8s, it is a false trigger
            EEG = pop_editeventvals(EEG, 'delete', 1); %So delete this trigger
            z = length(EEG.event); %Number of triggers has changed, so last trigger # has changed too
            else %If the first event is legit (which it isn't on most of these files), do nothing
            end
            
        end 
        
    zf = length(EEG.event);    
    eventnum = [eventnum; a c zf];
    
        for i = 1:length(EEG.event)
           eventdata = [eventdata EEG.event(1,i).latency]; %grab event latency
        end
        
    eventonsets =[eventdata; eventtype];
    
    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_event.mat');%save event onsets + types
    save(scrfile, 'eventonsets');
    
    data = EEG.data(scrchan,:)'; %channel 103 saves SCR
    scrdatafile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_scr.mat');%save continuous SCR
    save(scrdatafile, 'data');
    
    end
    
    
end
%% Trim SCR data at the end, 6s after the last event onset
% To ensure better modelling results, getting rid of noise data at the end
% of the experiment;
% These trimmed files are then used to import to scralyze

% Post1 data sets
allsubs = [1:5 7:39];

for a = allsubs
    
    if a == 15
        c1 = 1:5;
    else
        c1 = 1:6;
    end
    
    for c = c1

    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    scrdatafile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_scr.mat');%save continuous SCR
    load(scrdatafile, 'data');
    
    lastevent = eventonsets(1,240);
 
    if length(data) > lastevent + 1536 %if the data has not ended 6s after the last event onset
    
        data(lastevent+1537:end) = [];% delete the portion of SCR data after 6s after last event onset
    
    end
    

    scrdatafile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_scr_trim.mat');%save continuous SCR
    save(scrdatafile, 'data');    
    
    end
end


% Post2 data sets

allsubs=find(ExpStatus(:,3)==1 | ExpStatus(:,3)==0)';

for a = allsubs
    
    c1 = 4:6;
    
    for c = c1

    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    scrdatafile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_scr.mat');%save continuous SCR
    load(scrdatafile, 'data');
    
    lastevent = eventonsets(1,270);
    
    if length(data) > lastevent + 1536 %if the data has not ended 6s after the last event onset
    data(lastevent+1537:end) = [];
    end
    

    scrdatafile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_scr_trim.mat');%save continuous SCR
    save(scrdatafile, 'data');    
    
    end
end

%% Reformat and generate multiple condition file
% have onsets for both CS+/- and corresponding UCS (four conditions)
% this step generates a "EEG..._mcf.mat" file that can be loaded by the
% script "Glm_gb_allsubs.m", which calls 1st level GLM feature of scralyze
% and generates betas for each condition in each individual

% Pre Cond data sets - gabor blocks 1-3
allsubs = [1:5 7:39];

for a = allsubs
%     
    for c = 1:3

    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    names = {'T1C', 'T2C', 'T1G', 'T2G'};
    

    T1Consets = eventonsets(1,eventonsets(2,:)==501);
    T2Consets = eventonsets(1,eventonsets(2,:)==502);

    T1Gonsets = eventonsets(1,eventonsets(2,:)==1);
    T2Gonsets = eventonsets(1,eventonsets(2,:)==2);                
    
    onsets = {T1Consets, T2Consets, T1Gonsets, T2Gonsets};
    
    mcffile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_mcf.mat');%save continuous SCR
    save(mcffile, 'names','onsets');    
    
    end
end


% Post Cond data sets - gabor blocks 4-6
for a = allsubs
%     
    if a == 15
        c1 = 4:5;
    else
        c1 = 4:6;
    end
%     
    for c = c1

    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    names = {'T1', 'T2', 'T1G', 'T2G', 'T1CUC', 'T2CUC', 'T1GUC', 'T2GUC'};
    
    T1Consets = eventonsets(1,eventonsets(2,:)==501);
    T2Consets = eventonsets(1,eventonsets(2,:)==502);

    T1Gonsets = eventonsets(1,eventonsets(2,:)==1);
    T2Gonsets = eventonsets(1,eventonsets(2,:)==2);                
    
    for i = 1:length(eventonsets)
       if eventonsets(2,i) == 99 %recoding the UC to four types according to the target proceding it
           switch eventonsets(2,i-1)
               case 1
                   eventonsets(2,i)= 51;
               case 2
                   eventonsets(2,i)= 52;
               case 501
                   eventonsets(2,i)= 551;                  
               case 502
                   eventonsets(2,i)= 552;              
           end
       end
    end
    
    T1CUConsets = eventonsets(1,eventonsets(2,:)==551);
    T2CUConsets = eventonsets(1,eventonsets(2,:)==552);

    T1GUConsets = eventonsets(1,eventonsets(2,:)==51);
    T2GUConsets = eventonsets(1,eventonsets(2,:)==52);                
       
    onsets = {T1Consets, T2Consets, T1Gonsets, T2Gonsets, T1CUConsets, T2CUConsets, T1GUConsets, T2GUConsets};
    
    mcffile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_mcf.mat');%save continuous SCR
    save(mcffile, 'names','onsets');    
    
    end
end



% Post2 Cond data sets - gabor blocks 4-6
allsubs=find(ExpStatus(:,3)==1 | ExpStatus(:,3)==0)';
for a = allsubs
%     
    for c = c1

    scrfile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_event.mat');%save event onsets + types
    load(scrfile, 'eventonsets');
    
    names = {'T1', 'T2', 'T1G', 'T2G', 'T1CUC', 'T2CUC', 'T1GUC', 'T2GUC'};
    
    T1Consets = eventonsets(1,eventonsets(2,:)==501);
    T2Consets = eventonsets(1,eventonsets(2,:)==502);

    T1Gonsets = eventonsets(1,eventonsets(2,:)==1);
    T2Gonsets = eventonsets(1,eventonsets(2,:)==2);                
    
    for i = 1:length(eventonsets)
       if eventonsets(2,i) == 99
           switch eventonsets(2,i-1)
               case 1
                   eventonsets(2,i)= 51;
               case 2
                   eventonsets(2,i)= 52;
               case 501
                   eventonsets(2,i)= 551;                  
               case 502
                   eventonsets(2,i)= 552;              
           end
       end
    end
    
    T1CUConsets = eventonsets(1,eventonsets(2,:)==551);
    T2CUConsets = eventonsets(1,eventonsets(2,:)==552);

    T1GUConsets = eventonsets(1,eventonsets(2,:)==51);
    T2GUConsets = eventonsets(1,eventonsets(2,:)==52);                
       
    onsets = {T1Consets, T2Consets, T1Gonsets, T2Gonsets, T1CUConsets, T2CUConsets, T1GUConsets, T2GUConsets};
    
    mcffile = strcat('EEG_Sub',num2str(a),'_block',num2str(c),'_post_mcf.mat');%save continuous SCR
    save(mcffile, 'names','onsets');    
    
    end
end

%% Compute 1st level constrast for each individual
% this steps calls each individual "EEG_SubX_blockX_1stGLM.mat" file and
% record the beta for each condition, tabulizing them

allsubs = [1:5 7:39];
% Pre Conditioning block 1-3

all_betas = []; %subno, blkno, Color CS+, Color CS-, Gray CS+, Gray CS-
for a = allsubs
betas = [];
    c1 = 1:3;
    for c = c1

    glmfile = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_norm_1stGLM.mat');
    load(glmfile);
    
        if rem(a,2)==1
            betas = [betas; a c glm.beta(1,1) glm.beta(4,1) glm.beta(7,1) glm.beta(10,1)];
      
        else
            betas = [betas; a c glm.beta(4,1) glm.beta(1,1) glm.beta(10,1) glm.beta(7,1)];
         
        end
    
    end
    
    all_betas = [all_betas; a mean(betas(:,3),1) mean(betas(:,4),1) mean(betas(:,5),1) mean(betas(:,6),1)];
    
end

%% Collate parameter estimates
% Post1 Gabor block 4-6
allsubs = [1,2,3,4,5,7,9,10,11,13,15,17,18,19,20,21,22,24,25,27,28,31,32,33,34,38,39;];%successfully conditioned sub at the end of visit1

all_betas = []; %subno, blkno, Color CS+, Color CS-, Gray CS+, Gray CS-, Color UCS, Color Safe, Gray UCS, Gray Safe
for a = allsubs
    if a ==15
        c1 = 4:5;
    else c1 = 4:6;
    end
betas = [];        

    for c = c1

    glmfile = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_norm_1stGLM.mat');
    load(glmfile);
    
    if rem(a,2)==1
        betas = [betas; a c glm.beta(1,1) glm.beta(4,1) glm.beta(7,1) glm.beta(10,1) glm.beta(13,1) glm.beta(16,1) glm.beta(19,1) glm.beta(22,1)];
      
    else
        betas = [betas; a c glm.beta(4,1) glm.beta(1,1) glm.beta(10,1) glm.beta(7,1) glm.beta(16,1) glm.beta(13,1) glm.beta(22,1) glm.beta(19,1)];
         
    end
    
    end
    
    all_betas = [all_betas; a mean(betas(:,3),1) mean(betas(:,4),1) mean(betas(:,5),1) mean(betas(:,6),1) mean(betas(:,7),1) mean(betas(:,8),1) mean(betas(:,9),1) mean(betas(:,10),1)];    
    
end

%% Collate parameter estimates
% Post2 Gabor block 4-6
allsubs = [1,2,3,4,7,9,10,12,17,20,21,22,23,24,25,27,28,33,34,37,38,39;];%successfully conditioned sub at the end of visit2
all_betas = []; %subno, blkno, Color CS+, Color CS-, Gray CS+, Gray CS-, Color UCS, Color Safe, Gray UCS, Gray Safe

for a = allsubs
    c1 = 4:6;
betas = [];

    for c = c1

    glmfile = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_post_norm_1stGLM.mat');
    load(glmfile);
    
    if rem(a,2)==1
        betas = [betas; a c glm.beta(1,1) glm.beta(4,1) glm.beta(7,1) glm.beta(10,1) glm.beta(13,1) glm.beta(16,1) glm.beta(19,1) glm.beta(22,1)];
      
    else
        betas = [betas; a c glm.beta(4,1) glm.beta(1,1) glm.beta(10,1) glm.beta(7,1) glm.beta(16,1) glm.beta(13,1) glm.beta(22,1) glm.beta(19,1)];
         
    end

    end
    all_betas = [all_betas; a mean(betas(:,3),1) mean(betas(:,4),1) mean(betas(:,5),1) mean(betas(:,6),1) mean(betas(:,7),1) mean(betas(:,8),1) mean(betas(:,9),1) mean(betas(:,10),1)];    
    
    
end



%% Sort data into groups of subjects
%a = [];%to-be-sorted data matrix
index = [1,2,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39;];%the full group of SCR subjects
index1 = [1,2,3,4,5,7,9,10,11,13,15,17,18,19,20,21,22,24,25,27,28,31,32,33,34,38,39;];%successfully conditioned sub at the end of visit1
index2 = [1,2,3,4,7,9,10,12,17,20,21,22,23,24,25,27,28,33,34,37,38,39;];%successfully conditioned sub at the end of visit2
c = 1;
b = [];

for i = 1:length(a)
    
    ind = a(i,1);
    if ismember(ind, index2)
        b(c,:) = a(i,:);
        c = c+1;
    end
end