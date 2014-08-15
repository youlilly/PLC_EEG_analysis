%% This is a the behavior data analyzer for PLC_EEG study
%Created by YY, May 9, 2014

%% Subject initials

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
%% Check for noresponse - indicating intentional bad responses

allsubs = find(ExpStatus(:,3) ==1 | ExpStatus(:,3) ==0)';
all_noresponse = [];%tally for all subs and each block
acc_by_sub = [];%averaged accuracy for all six preconditioning blocks for each sub
noresponse_by_sub = [];%averaged rate of noresponse for all six preconditioning blocks for each sub

for a = allsubs
    accsub = [];
    nrsub = [];
    
%     if a == 15
%         sb = 1:5;
%     else
%         sb = 1:6;
%     end
    
    initials = subinitials(a,:);
    for b = 4:6
        eval(['load PLC_EEG_block' num2str(b) '_post_sub' num2str(a) '_' initials ' acc noresp;']);
        all_noresponse = [all_noresponse; a b acc noresp];
        accsub = [accsub; acc];
        nrsub = [nrsub; noresp];
    end
    acc_by_sub = [acc_by_sub; a mean(accsub)/120*100];
    noresponse_by_sub = [noresponse_by_sub; a mean(nrsub)/120*100];
    
end


%% Accuracy and RTs broken down by angle - Preconditioning - blocks 1 - 3


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
%Let's choose subjects who are successfully conditioned right after conditioning 
allsubs = [1:5 7:29 31:34 37:39];%find(ExpStatus(:,1)==1)';

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];

Correj_rt = [];
Hit_rt = [];

d_prime = [];
    
for a = allsubs; 
    
initials = subinitials(a,:);    
    
acc_trials = [];
correct_rts = [];

correct_rts_gc_tdis = cell(2,2);% overall accurate trials, including both hit and cor rej
accuracy_gc_tdis = cell(2,2); % this saves the accuracy by taking the length of the corresponding cells above

distractor_rts_gc_angles = cell(2,2); %this saves the correct rts for correct rejection, with two target angles
target_rts_gc_angles = cell(2,2);%this saves the correct rts for hit, with two target angles 

fa_rts_gc_angles = cell(2,2); %this saves the correct rts for false alarm
miss_rts_gc_angles = cell(2,2); %this saves the correct rts for miss

acc_distractor_gc_angles = cell(2,2);
acc_target_gc_angles = cell(2,2); 


    for b = 1:3
    
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' StimR allresp rtypes;']); 

        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
           index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)         
           response_time = allresp(index);   
           targetid=StimR(index,1) ; %target id: 1, 2, 501, 502   
           distractorid=StimR(index,2) ; %distractor id: 201, 202, 203, 701, 702, 703      
           gcid = StimR(index,3); %Specifies whether the target is gray (1) or color (2)  
           tdisid = StimR(index,4); %Specifies whether the distractor is the same (1) as target or different (2)
           
           
           if rtypes(i,2) ==1 %subject pressed "same" response
                 
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                    correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                    % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123 
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147 
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color gabors
                        
                    correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                    
                      % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray 
                        
                        if  targetid ==1 && distractorid == 203 
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203 
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color
                                       
                        if  targetid == 501 && distractorid == 703
                            fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703 
                            fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                end
            
                
            elseif rtypes(i,2) ==2 %subject pressed "diff" response
                
                 
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray 
                    correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                    

                        if  targetid ==1 && distractorid == 203
                            distractor_rts_gc_angles {1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end                   
                                            
                    else % color
                        
                    correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                    

                        if  targetid ==501 && distractorid == 703  
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703 
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end    
                                   
                
                    end
                    
               elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray 
                        
                        if  distractorid == 201 
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    
                    else %color
                                       
                        if  distractorid == 701
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end    
                    
                end
            
            else    
            end
        end
        
               
        
    end


        % 360 trials for 3 blocks
        accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1})/90*100;
        accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2})/90*100;
        accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1})/90*100;
        accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2})/90*100;
        
        % Correct rejection rate
        acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/45*100;
        acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/45*100;        
        acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/45*100;        
        acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/45*100;          
        % Hit rate
        acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/45*100;
        acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/45*100;        
        acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/45*100;        
        acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/45*100;    
        
        
        dprime = cell(2,2);
        
        % Calculate d prime
        % Frist, calculate Hit and False Alarm Rate
        for a1 = 1:2
            for a2 = 1:2
                if ~isempty(miss_rts_gc_angles{a1,a2}) 
                Hit_rate = length(target_rts_gc_angles{a1,a2})/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                else
                Hit_rate = (length(target_rts_gc_angles{a1,a2})-0.5)/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                end
                
                if ~isempty(fa_rts_gc_angles{a1,a2}) 
                FA_rate = length(fa_rts_gc_angles{a1,a2})/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );
                else
                FA_rate = 0.5/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );    
                end
                % Then, obtain the Z(Hit), Z(FA)
                zHit = norminv(Hit_rate);
                zFA = norminv(FA_rate);
        
                % Then, compute d prime
                dprime{a1,a2} = zHit - zFA;
            end
        end
        
        
        
        % RT trimming
        
        for a1 = 1:2
            for a2 = 1:2
            tt = correct_rts_gc_tdis{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            correct_rts_gc_tdis{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = target_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            target_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = distractor_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            distractor_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end        
%         
        %all accuracy collapsed across hit and correj rej
        all_rts = [all_rts;a mean(correct_rts_gc_tdis{1,1}) mean(correct_rts_gc_tdis{1,2}) mean(correct_rts_gc_tdis{2,1}) mean(correct_rts_gc_tdis{2,2})];       
        all_acc = [all_acc;a accuracy_gc_tdis{1,1} accuracy_gc_tdis{1,2} accuracy_gc_tdis{2,1} accuracy_gc_tdis{2,2}] ;
        
        %here correj_acc means correct rej; hit_acc means hit;
        correj_acc =[correj_acc;a acc_distractor_gc_angles{1,1} acc_distractor_gc_angles{1,2} acc_distractor_gc_angles{2,1} acc_distractor_gc_angles{2,2} ];
        hit_acc =[hit_acc;a acc_target_gc_angles{1,1} acc_target_gc_angles{1,2} acc_target_gc_angles{2,1} acc_target_gc_angles{2,2} ];
        
        %same as above
        Correj_rt = [Correj_rt;a mean(distractor_rts_gc_angles{1,1}) mean(distractor_rts_gc_angles{1,2}) mean(distractor_rts_gc_angles{2,1}) mean(distractor_rts_gc_angles{2,2})];
        Hit_rt = [Hit_rt;a mean(target_rts_gc_angles{1,1}) mean(target_rts_gc_angles{1,2}) mean(target_rts_gc_angles{2,1}) mean(target_rts_gc_angles{2,2}) ];
        
        %record dprime
        d_prime = [d_prime;a dprime{1,1} dprime{1,2} dprime{2,1} dprime{2,2}];
        
end

%% Accuracy and RTs broken down by angle - Postconditioning1 - blocks 4,5,6
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

allsubs=[1
2
3
4
5
7
9
10
11
13
15
17
18
19
20
21
22
24
25
27
28
31
32
33
34
38
39]';

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];
    
for a = allsubs; 

    if a == 15
    bs = 4:5;   
    else
    bs = 4:6;    
    end
    
initials = subinitials(a,:);    
    
acc_trials = [];
correct_rts = [];

correct_rts_gc_tdis = cell(2,2);% overall accurate trials, including both hit and cor rej
accuracy_gc_tdis = cell(2,2); % this saves the accuracy by taking the length of the corresponding cells above

distractor_rts_gc_angles = cell(2,2); %this saves the correct rts for correct rejection, with two target angles
target_rts_gc_angles = cell(2,2);%this saves the correct rts for hit, with two target angles 

fa_rts_gc_angles = cell(2,2); %this saves the correct rts for false alarm
miss_rts_gc_angles = cell(2,2); %this saves the correct rts for miss

acc_distractor_gc_angles = cell(2,2);
acc_target_gc_angles = cell(2,2); 


rmat4 = [1,2,3,5,6,8,9,11,12,13,15,16,17,18,19,20,21,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,90,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,117,118,119,121,122,123,124,125,126,128,129,130,131,132,133,134,135];
rmat5 = [1,2,4,5,7,8,9,11,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,40,41,42,43,44,45,47,48,49,50,51,52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69,70,71,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135;];
rmat6 = [1,3,4,5,7,8,10,12,13,14,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53,54,55,57,58,59,60,61,62,63,64,65,66,68,69,70,71,72,73,74,75,76,77,78,79,80,81,83,84,85,86,87,88,89,90,91,92,93,94,96,97,98,99,100,101,102,103,104,105,106,108,109,110,111,112,113,114,115,117,118,119,120,121,123,124,125,126,127,128,129,130,131,132,133,134,135;];

    for b = bs
    
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' StimR allresp rtypes;']); 

        if b == 4
        indM = [rmat4' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==5
        indM = [rmat5' (1:120)']; %convert the 135-trial position to 120-trial position   
        elseif b ==6
        indM = [rmat6' (1:120)']; %convert the 135-trial position to 120-trial position               
        end
        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
           index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)
           indexn = find(indM(:,1)==index);
           response_time = allresp(indM(indexn,2));   
           
           targetid=StimR(index,1) ; %Specifies which of the IAPS images in sequence    
           distractorid=StimR(index,2) ; %Specifies which of the emo conditions is presented       
           gcid = StimR(index,3); %Specifies whether the target is gray or color   
           tdisid = StimR(index,4); %Specifies whether the distractor is the same as target or different
           
           
           if rtypes(i,2) ==1 %subject pressed "same" response
                 
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                    correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                    % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123 
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147 
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color gabors
                        
                    correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                    
                      % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray 
                        
                        if  targetid ==1 && distractorid == 203 
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203 
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color
                                       
                        if  targetid == 501 && distractorid == 703
                            fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703 
                            fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                end
            
                
            elseif rtypes(i,2) ==2 %subject pressed "diff" response
                
                 
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray 
                    correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                    

                        if  targetid ==1 && distractorid == 203
                            distractor_rts_gc_angles {1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end                   
                                            
                    else % color
                        
                    correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                    

                        if  targetid ==501 && distractorid == 703  
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703 
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end    
                                   
                
                    end
                    
               elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray 
                        
                        if  distractorid == 201 
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    
                    else %color
                                       
                        if  distractorid == 701
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end    
                    
                end
            
            else    
            end
        end
        
               
        
    end

        %for sub 15 that only did two blocks (240 trials)
        if a == 15
        accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1})/60*100;
        accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2})/60*100;
        accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1})/60*100;
        accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2})/60*100;
                  
        acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/30*100;
        acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/30*100;        
        acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/30*100;        
        acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/30*100;          
        
        acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/30*100;
        acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/30*100;        
        acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/30*100;        
        acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/30*100;   
        
        else
        % 360 trials for 3 blocks
        accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1})/90*100;
        accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2})/90*100;
        accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1})/90*100;
        accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2})/90*100;
        
        % Correct rejection rate
        acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/45*100;
        acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/45*100;        
        acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/45*100;        
        acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/45*100;          
        % Hit rate
        acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/45*100;
        acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/45*100;        
        acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/45*100;        
        acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/45*100;    
        end
        
        dprime = cell(2,2);
        
        % Calculate d prime
        % Frist, calculate Hit and False Alarm Rate
        for a1 = 1:2
            for a2 = 1:2
                if ~isempty(miss_rts_gc_angles{a1,a2}) 
                Hit_rate = length(target_rts_gc_angles{a1,a2})/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                else
                Hit_rate = (length(target_rts_gc_angles{a1,a2})-0.5)/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                end
                
                if ~isempty(fa_rts_gc_angles{a1,a2}) 
                FA_rate = length(fa_rts_gc_angles{a1,a2})/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );
                else
                FA_rate = 0.5/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );    
                end
                % Then, obtain the Z(Hit), Z(FA)
                zHit = norminv(Hit_rate);
                zFA = norminv(FA_rate);
        
                % Then, compute d prime
                dprime{a1,a2} = zHit - zFA;
            end
        end
        
        
        % RT trimming
        
        for a1 = 1:2
            for a2 = 1:2
            tt = correct_rts_gc_tdis{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            correct_rts_gc_tdis{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = target_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            target_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = distractor_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            distractor_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end    
        
        
%         
        %all accuracy collapsed across hit and correj rej
        all_rts = [all_rts;a mean(correct_rts_gc_tdis{1,1}) mean(correct_rts_gc_tdis{1,2}) mean(correct_rts_gc_tdis{2,1}) mean(correct_rts_gc_tdis{2,2})];       
        all_acc = [all_acc;a accuracy_gc_tdis{1,1} accuracy_gc_tdis{1,2} accuracy_gc_tdis{2,1} accuracy_gc_tdis{2,2}] ;
        
        %here correj_acc means correct rej; hit_acc means hit;
        correj_acc =[correj_acc;a acc_distractor_gc_angles{1,1} acc_distractor_gc_angles{1,2} acc_distractor_gc_angles{2,1} acc_distractor_gc_angles{2,2} ];
        hit_acc =[hit_acc;a acc_target_gc_angles{1,1} acc_target_gc_angles{1,2} acc_target_gc_angles{2,1} acc_target_gc_angles{2,2} ];
        
        %same as above
        Correj_rt = [Correj_rt;a mean(distractor_rts_gc_angles{1,1}) mean(distractor_rts_gc_angles{1,2}) mean(distractor_rts_gc_angles{2,1}) mean(distractor_rts_gc_angles{2,2})];
        Hit_rt = [Hit_rt;a mean(target_rts_gc_angles{1,1}) mean(target_rts_gc_angles{1,2}) mean(target_rts_gc_angles{2,1}) mean(target_rts_gc_angles{2,2}) ];
        
        %record dprime
        d_prime = [d_prime;a dprime{1,1} dprime{1,2} dprime{2,1} dprime{2,2}];
        
end

%% Gabor Ratings - at both time points

%allsubs = [1,2,3,4,7,9,10,12,17,20,21,22,23,24,25,27,28,33,34,37,38,39;]; 
allsubs = [1:4 7 9:13 15:18 20:28 30 32:39];

Risk = zeros(35,19);
Valence = zeros(35,19);
FearR = zeros(35,19);
DisgR = zeros(35,19);


for a = allsubs
    initials = subinitials(a,:);    
    %rating data for the 1st visit
    eval(['load PLC_Ratings_post_sub' num2str(a) '_' initials '.mat pic_sorted;']); 
    
    if rem(a,2) == 1
    Risk(a,:) =  [a pic_sorted(:,2)']; 
    Valence(a,:) = [a pic_sorted(:,3)'];
    FearR(a,:) =[a pic_sorted(:,4)'];
    DisgR(a,:) =[a pic_sorted(:,5)'];
    
    else
    
    x = []; y = [];    
    x = pic_sorted(:,2)';
    for i = 1:length(x) %reverse-code x to y, rearranging the CS+ to CS- gradient
    y(i) = x(19-i);
    end
    
    Risk(a,:) = [a y];

    x = []; y = [];    
    x = pic_sorted(:,3)';
    for i = 1:length(x) %reverse-code x to y, rearranging the CS+ to CS- gradient
    y(i) = x(19-i);
    end
    
    Valence(a,:) = [a y];    
    
    x = []; y = [];    
    x = pic_sorted(:,4)';
    for i = 1:length(x) %reverse-code x to y, rearranging the CS+ to CS- gradient
    y(i) = x(19-i);
    end
    
    FearR(a,:) = [a y];     
    
    x = []; y = [];    
    x = pic_sorted(:,5)';
    for i = 1:length(x) %reverse-code x to y, rearranging the CS+ to CS- gradient
    y(i) = x(19-i);
    end
    
    DisgR(a,:) = [a y];         
    
    end
end




%% Accuracy and RTs broken down by angle - Postconditioning2 - blocks 4,5,6

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

allsubs=find(ExpStatus(:,3)==1 | ExpStatus(:,3)==0)';
allsubs(25) = [];%remove subject 35 too high rate of noresponse (>50%)

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];
    
for a = allsubs; 

    if a == 15
    bs = 4:6;   
    elseif a == 10
    bs = [4 6];
    else
    bs = 4:6;    
    end
    
initials = subinitials(a,:);    
    
acc_trials = [];
correct_rts = [];

correct_rts_gc_tdis = cell(2,2);% overall accurate trials, including both hit and cor rej
accuracy_gc_tdis = cell(2,2); % this saves the accuracy by taking the length of the corresponding cells above

distractor_rts_gc_angles = cell(2,2); %this saves the correct rts for correct rejection, with two target angles
target_rts_gc_angles = cell(2,2);%this saves the correct rts for hit, with two target angles 

fa_rts_gc_angles = cell(2,2); %this saves the correct rts for false alarm
miss_rts_gc_angles = cell(2,2); %this saves the correct rts for miss

acc_distractor_gc_angles = cell(2,2);
acc_target_gc_angles = cell(2,2); 


rmat4 = [1,2,3,5,6,8,9,11,12,13,15,16,17,18,19,20,21,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,90,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,117,118,119,121,122,123,124,125,126,128,129,130,131,132,133,134,135];
rmat5 = [1,2,4,5,7,8,9,11,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,40,41,42,43,44,45,47,48,49,50,51,52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69,70,71,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135;];
rmat6 = [1,3,4,5,7,8,10,12,13,14,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53,54,55,57,58,59,60,61,62,63,64,65,66,68,69,70,71,72,73,74,75,76,77,78,79,80,81,83,84,85,86,87,88,89,90,91,92,93,94,96,97,98,99,100,101,102,103,104,105,106,108,109,110,111,112,113,114,115,117,118,119,120,121,123,124,125,126,127,128,129,130,131,132,133,134,135;];

    for b = bs
    
        eval(['load PLC_EEG_block' num2str(b) '_post_sub' num2str(a) '_' initials ' StimR allresp rtypes;']); 

        if b == 4
        indM = [rmat4' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==5
        indM = [rmat5' (1:120)']; %convert the 135-trial position to 120-trial position   
        elseif b ==6
        indM = [rmat6' (1:120)']; %convert the 135-trial position to 120-trial position               
        end
        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
           index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)
           indexn = find(indM(:,1)==index);
           response_time = allresp(indM(indexn,2));   
           
           targetid=StimR(index,1) ; %Specifies which of the IAPS images in sequence    
           distractorid=StimR(index,2) ; %Specifies which of the emo conditions is presented       
           gcid = StimR(index,3); %Specifies whether the target is gray or color   
           tdisid = StimR(index,4); %Specifies whether the distractor is the same as target or different
           
           
           if rtypes(i,2) ==1 %subject pressed "same" response
                 
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                    correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                    % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123 
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147 
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color gabors
                        
                    correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                    
                      % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray 
                        
                        if  targetid ==1 && distractorid == 203 
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203 
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    

                    else %color
                                       
                        if  targetid == 501 && distractorid == 703
                            fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703 
                            fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end
                    
                end
            
                
            elseif rtypes(i,2) ==2 %subject pressed "diff" response
                
                 
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray 
                    correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                    

                        if  targetid ==1 && distractorid == 203
                            distractor_rts_gc_angles {1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end                   
                                            
                    else % color
                        
                    correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                    

                        if  targetid ==501 && distractorid == 703  
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703 
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end    
                                   
                
                    end
                    
               elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray 
                        
                        if  distractorid == 201 
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end                               
                    
                    else %color
                                       
                        if  distractorid == 701
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702 
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end                       

                    end    
                    
                end
            
            else    
            end
        end
        
               
        
    end

        %for sub 10 who has two blocks (240 trials) saved properly
        if a == 10
        accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1})/60*100;
        accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2})/60*100;
        accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1})/60*100;
        accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2})/60*100;
                  
        acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/30*100;
        acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/30*100;        
        acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/30*100;        
        acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/30*100;          
        
        acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/30*100;
        acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/30*100;        
        acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/30*100;        
        acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/30*100;   
        
        else
        % 360 trials for 3 blocks
        accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1})/90*100;
        accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2})/90*100;
        accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1})/90*100;
        accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2})/90*100;
        
        % Correct rejection rate
        acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/45*100;
        acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/45*100;        
        acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/45*100;        
        acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/45*100;          
        % Hit rate
        acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/45*100;
        acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/45*100;        
        acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/45*100;        
        acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/45*100;    
        end
        
        dprime = cell(2,2);
        
        % Calculate d prime
        % Frist, calculate Hit and False Alarm Rate
        for a1 = 1:2
            for a2 = 1:2
                if ~isempty(miss_rts_gc_angles{a1,a2}) 
                Hit_rate = length(target_rts_gc_angles{a1,a2})/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                else
                Hit_rate = (length(target_rts_gc_angles{a1,a2})-0.5)/(length(target_rts_gc_angles{a1,a2})+ length(miss_rts_gc_angles{a1,a2}) );
                end
                
                if ~isempty(fa_rts_gc_angles{a1,a2}) 
                FA_rate = length(fa_rts_gc_angles{a1,a2})/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );
                else
                FA_rate = 0.5/(length(fa_rts_gc_angles{a1,a2})+ length(distractor_rts_gc_angles{a1,a2}) );    
                end
                % Then, obtain the Z(Hit), Z(FA)
                zHit = norminv(Hit_rate);
                zFA = norminv(FA_rate);
        
                % Then, compute d prime
                dprime{a1,a2} = zHit - zFA;
            end
        end
        
        
        % RT trimming
        
        for a1 = 1:2
            for a2 = 1:2
            tt = correct_rts_gc_tdis{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            correct_rts_gc_tdis{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = target_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            target_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end
        
        for a1 = 1:2
            for a2 = 1:2
            tt = distractor_rts_gc_angles{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            distractor_rts_gc_angles{a1,a2} = tt(tindex);
            end
        end    
        
        
%         
        %all accuracy collapsed across hit and correj rej
        all_rts = [all_rts;a mean(correct_rts_gc_tdis{1,1}) mean(correct_rts_gc_tdis{1,2}) mean(correct_rts_gc_tdis{2,1}) mean(correct_rts_gc_tdis{2,2})];       
        all_acc = [all_acc;a accuracy_gc_tdis{1,1} accuracy_gc_tdis{1,2} accuracy_gc_tdis{2,1} accuracy_gc_tdis{2,2}] ;
        
        %here correj_acc means correct rej; hit_acc means hit;
        correj_acc =[correj_acc;a acc_distractor_gc_angles{1,1} acc_distractor_gc_angles{1,2} acc_distractor_gc_angles{2,1} acc_distractor_gc_angles{2,2} ];
        hit_acc =[hit_acc;a acc_target_gc_angles{1,1} acc_target_gc_angles{1,2} acc_target_gc_angles{2,1} acc_target_gc_angles{2,2} ];
        
        %same as above
        Correj_rt = [Correj_rt;a mean(distractor_rts_gc_angles{1,1}) mean(distractor_rts_gc_angles{1,2}) mean(distractor_rts_gc_angles{2,1}) mean(distractor_rts_gc_angles{2,2})];
        Hit_rt = [Hit_rt;a mean(target_rts_gc_angles{1,1}) mean(target_rts_gc_angles{1,2}) mean(target_rts_gc_angles{2,1}) mean(target_rts_gc_angles{2,2}) ];
        
        %record dprime
        d_prime = [d_prime;a dprime{1,1} dprime{1,2} dprime{2,1} dprime{2,2}];
        
end


%% Calculate pre- and post- conditioning difference 

% CS+ assignment: if odd, T1 is CS+; if even, T2 is CS+;

Pre.Acc = [1	71.11111111	58.88888889	51.11111111	84.44444444
2	97.77777778	58.88888889	98.88888889	47.77777778
3	81.11111111	65.55555556	76.66666667	55.55555556
4	86.66666667	84.44444444	92.22222222	68.88888889
5	90	74.44444444	92.22222222	67.77777778
7	90	72.22222222	76.66666667	78.88888889
8	85.55555556	61.11111111	93.33333333	57.77777778
9	93.33333333	44.44444444	66.66666667	60
10	88.88888889	77.77777778	76.66666667	57.77777778
11	85.55555556	76.66666667	85.55555556	82.22222222
12	91.11111111	74.44444444	85.55555556	66.66666667
13	63.33333333	51.11111111	45.55555556	50
14	78.88888889	84.44444444	90	61.11111111
15	90	60	96.66666667	46.66666667
16	97.77777778	95.55555556	96.66666667	88.88888889
17	71.11111111	60	85.55555556	60
18	76.66666667	73.33333333	84.44444444	83.33333333
19	86.66666667	81.11111111	94.44444444	50
20	56.66666667	57.77777778	31.11111111	53.33333333
21	91.11111111	85.55555556	90	75.55555556
22	55.55555556	78.88888889	80	65.55555556
23	74.44444444	87.77777778	92.22222222	74.44444444
24	83.33333333	68.88888889	93.33333333	30
25	95.55555556	64.44444444	87.77777778	85.55555556
26	77.77777778	68.88888889	71.11111111	54.44444444
27	84.44444444	54.44444444	45.55555556	71.11111111
28	92.22222222	65.55555556	98.88888889	75.55555556
29	92.22222222	76.66666667	80	72.22222222
31	82.22222222	87.77777778	100	86.66666667
32	85.55555556	67.77777778	92.22222222	28.88888889
33	73.33333333	86.66666667	77.77777778	82.22222222
34	96.66666667	76.66666667	85.55555556	72.22222222
37	97.77777778	63.33333333	94.44444444	66.66666667
38	92.22222222	85.55555556	83.33333333	70
39	97.77777778	96.66666667	97.77777778	95.55555556];

Pre.RT = [1	1137.737705	1215.941176	1166.217391	1114.479452
2	889.5714286	985.4693878	814.7356322	1010.225
3	1113.514286	961.5272727	1014.21875	958.5
4	766.3066667	827.5540541	733.2531646	777.1034483
5	981.4125	939.4444444	802.1234568	853.4833333
7	1049.974026	1071.6	1020.257576	1045.716418
8	1093.48	1087.490566	1030.444444	1052.897959
9	1366.85	1294.486486	1278.339286	1216.803922
10	750.3947368	738.7727273	658.5735294	662.3265306
11	1227.891892	1207.375	1185.108108	1214
12	787.2820513	836.6935484	748.1643836	837.7068966
13	826.5789474	798.1333333	750.5897436	751.4186047
14	1014.897059	888.2465753	942.9078947	932.6923077
15	886.3636364	1057.509804	934.5301205	1085.780488
16	973.4651163	909.060241	850.9176471	871.3974359
17	776.5806452	790.5294118	682.3561644	716.0754717
18	981.515625	1019.873016	1026.027778	985.2191781
19	896.2133333	885.9264706	784.7228916	896.7954545
20	736.7142857	705.66	753.6538462	666.5
21	1067.075	1019.675676	1039.21519	1032.061538
22	947.7708333	894.7352941	915.4929577	889.0350877
23	1146.69697	941.8108108	971.8987342	901.4375
24	870.2191781	868.1166667	775.1710526	910.76
25	1020.795181	1000.839286	967.4805195	934.3947368
26	861.358209	810.6551724	839.1612903	795.6170213
27	1148.635135	1069.577778	1154.9	970.8474576
28	1224.628205	1228.625	1188.829545	1207.369231
29	1100.975	1140.772727	1101.376812	1100.403226
31	1063.070423	981.0666667	1004.275862	971.72
32	888.9295775	1093.535714	801.4875	1138.52
33	865.7419355	856.9333333	811.1641791	774.0140845
34	1047.771084	1044.136364	1010.324324	982.3387097
37	1117.988095	1068.226415	1084.02439	1038.896552
38	1033.410256	960.3835616	948.5416667	878.0344828
39	1234.717647	1307.465116	1207.08046	1229.409639];

Pre.HitAcc = [1	66.66666667	75.55555556	51.11111111	51.11111111
2	97.77777778	97.77777778	97.77777778	100
3	77.77777778	84.44444444	97.77777778	55.55555556
4	84.44444444	88.88888889	93.33333333	91.11111111
5	88.88888889	91.11111111	91.11111111	93.33333333
7	82.22222222	97.77777778	66.66666667	86.66666667
8	84.44444444	86.66666667	93.33333333	93.33333333
9	86.66666667	100	55.55555556	77.77777778
10	84.44444444	93.33333333	77.77777778	75.55555556
11	77.77777778	93.33333333	75.55555556	95.55555556
12	88.88888889	93.33333333	84.44444444	86.66666667
13	60	66.66666667	48.88888889	42.22222222
14	68.88888889	88.88888889	82.22222222	97.77777778
15	88.88888889	91.11111111	95.55555556	97.77777778
16	95.55555556	100	93.33333333	100
17	64.44444444	77.77777778	88.88888889	82.22222222
18	75.55555556	77.77777778	77.77777778	91.11111111
19	82.22222222	91.11111111	91.11111111	97.77777778
20	62.22222222	51.11111111	28.88888889	33.33333333
21	86.66666667	95.55555556	84.44444444	95.55555556
22	48.88888889	62.22222222	68.88888889	91.11111111
23	64.44444444	84.44444444	88.88888889	95.55555556
24	77.77777778	88.88888889	91.11111111	95.55555556
25	97.77777778	93.33333333	82.22222222	93.33333333
26	75.55555556	80	60	82.22222222
27	77.77777778	91.11111111	40	51.11111111
28	84.44444444	100	100	97.77777778
29	84.44444444	100	82.22222222	77.77777778
31	73.33333333	91.11111111	100	100
32	82.22222222	88.88888889	91.11111111	93.33333333
33	64.44444444	82.22222222	80	75.55555556
34	97.77777778	95.55555556	95.55555556	75.55555556
37	97.77777778	97.77777778	97.77777778	91.11111111
38	86.66666667	97.77777778	86.66666667	80
39	97.77777778	97.77777778	95.55555556	100];

Pre.HitRT = [1	1146.172414	1145.333333	1213.304348	1093.454545
2	881.6190476	899.9285714	800.5581395	828.5909091
3	1106.727273	1116.861111	995.0465116	1082.217391
4	751.7297297	780.5	709.2	747.1578947
5	970.3947368	983.0487805	793.7073171	819.4390244
7	1042.6	1056.119048	1036	1001.675676
8	1064.944444	1109.815789	1015.261905	1068.926829
9	1376.710526	1375.409091	1335.583333	1249.515152
10	763.5142857	739.195122	665.3939394	636.0909091
11	1219.848485	1234.365854	1173.15625	1193.707317
12	780.972973	792.9756098	736.8611111	759.1621622
13	800.9230769	841.3666667	756.4761905	743.7222222
14	1017.451613	1032.641026	935.6176471	948.8095238
15	881.8974359	890.9473684	954.05	904.8809524
16	1006.5	941.9318182	896.8292683	808.1363636
17	801.4074074	747.8235294	671.2972973	693.7222222
18	982.53125	980.5	1032.909091	1009.763158
19	924.4285714	855.9736842	809.325	767.2727273
20	708.0357143	796.6956522	736.1538462	771.1538462
21	1079.230769	1055.512195	1036.333333	1030.219512
22	957.0454545	939.9230769	908.7	914.7
23	1205.413793	1091.444444	1013.342105	933.4878049
24	814.8823529	918.4615385	757.6578947	833.4761905
25	1006.666667	1036.073171	956.8285714	969.2682927
26	833.78125	888.4571429	819.4615385	846.8
27	1171.171429	1128.410256	1116.235294	1160.772727
28	1249.333333	1210.744186	1204.333333	1172.604651
29	1125.416667	1091.422222	1107.771429	1085.545455
31	1080.9375	1048.410256	1014.255814	984.6976744
32	931.1142857	880.9210526	797.4	817.2195122
33	853.0714286	876.1764706	813.1428571	809
34	1052.904762	1042.512195	990.097561	1035.454545
37	1116.761905	1112.756098	1076.047619	1085.384615
38	1083.621622	989.2926829	1004.605263	878.9090909
39	1233.833333	1245	1233.930233	1180.840909];

Pre.CRAcc = [1	66.66666667	51.11111111	82.22222222	86.66666667
2	55.55555556	62.22222222	53.33333333	42.22222222
3	68.88888889	62.22222222	48.88888889	62.22222222
4	77.77777778	91.11111111	75.55555556	62.22222222
5	73.33333333	75.55555556	64.44444444	71.11111111
7	77.77777778	66.66666667	75.55555556	82.22222222
8	68.88888889	53.33333333	62.22222222	53.33333333
9	48.88888889	40	84.44444444	35.55555556
10	80	75.55555556	66.66666667	48.88888889
11	95.55555556	57.77777778	84.44444444	80
12	68.88888889	80	55.55555556	77.77777778
13	35.55555556	66.66666667	44.44444444	55.55555556
14	80	88.88888889	66.66666667	55.55555556
15	66.66666667	53.33333333	57.77777778	35.55555556
16	97.77777778	93.33333333	97.77777778	80
17	86.66666667	33.33333333	48.88888889	71.11111111
18	66.66666667	80	84.44444444	82.22222222
19	84.44444444	77.77777778	60	40
20	46.66666667	68.88888889	55.55555556	51.11111111
21	82.22222222	88.88888889	68.88888889	82.22222222
22	82.22222222	75.55555556	91.11111111	40
23	84.44444444	91.11111111	91.11111111	57.77777778
24	82.22222222	55.55555556	37.77777778	22.22222222
25	73.33333333	55.55555556	88.88888889	82.22222222
26	75.55555556	62.22222222	68.88888889	40
27	62.22222222	46.66666667	80	62.22222222
28	57.77777778	73.33333333	71.11111111	80
29	71.11111111	82.22222222	64.44444444	80
31	93.33333333	82.22222222	95.55555556	77.77777778
32	80	55.55555556	37.77777778	20
33	95.55555556	77.77777778	88.88888889	75.55555556
34	55.55555556	97.77777778	51.11111111	93.33333333
37	51.11111111	75.55555556	48.88888889	84.44444444
38	93.33333333	77.77777778	73.33333333	66.66666667
39	95.55555556	97.77777778	97.77777778	93.33333333];

Pre.CRRT = [1	1225.7	1252.565217	1130.742857	1088.216216
2	955.6086957	1011.884615	997.1818182	1026.166667
3	955.5172414	971.4230769	987	941.3846154
4	859.2352941	803.95	756.15625	812.4615385
5	952.483871	930.5	870.3214286	831.3548387
7	1070.285714	1073.133333	1057	1035.4
8	1079.233333	1098.26087	1057.884615	1048.73913
9	1271.619048	1324.5	1210.2	1231.25
10	726.7428571	767.8787879	645.6428571	695.9545455
11	1203.384615	1213.6	1205.428571	1222.823529
12	844.8333333	836.2727273	862.32	826.3529412
13	794.25	800.2758621	739.1666667	753.7083333
14	885.6470588	890.5128205	918.1034483	954.6956522
15	977.6428571	1169.913043	1089	1080.2
16	883.2325581	936.825	845.9047619	889.9411765
17	767.027027	855	710.2272727	720.2258065
18	987.962963	1026.264706	954.5277778	1019.108108
19	872.1388889	908.969697	905.8461538	883.7222222
20	654.55	739.7333333	616	719.173913
21	1011.371429	1027.128205	1041.4	1024.057143
22	865.2777778	921.8064516	862.7948718	954.1666667
23	915	965.8717949	863.1052632	953.76
24	820.7777778	935.6956522	903.1875	924.2222222
25	990	1003.708333	924.7435897	944.5675676
26	806.5454545	847.75	773.137931	820.9411765
27	1102.615385	1052.3	961.8181818	998.4074074
28	1243.416667	1220.125	1236.16129	1181.117647
29	1182.125	1123.5	1136.821429	1084.628571
31	973.975	989.1714286	975.4	957.2352941
32	1098.485714	1130.782609	1172.117647	1115.222222
33	845	851.78125	755.7567568	789.1818182
34	1041.08	1053.214286	1003.272727	970.825
37	1060.571429	1083.647059	1033.863636	1048.054054
38	984.925	944.4411765	892.9032258	877.8214286
39	1317.790698	1297.139535	1248.976744	1219.95122];

Pre.dprime = [1	0.945578242	0.867506708	1.055200847	1.167771291
2	2.149585071	2.321197152	2.093526506	2.090336218
3	1.257413007	1.324215717	1.982019745	0.451032679
4	1.777603011	2.568269226	2.30993035	1.838225738
5	1.958103459	2.039706014	1.899453365	2.057719567
7	1.688576695	2.440602071	1.164866258	2.034638637
8	1.505596671	1.291065784	1.849841642	1.58473768
9	1.08291659	2.081083542	1.236513861	0.394345429
10	1.921351206	2.193163083	1.88506054	1.597037854
11	2.465997841	1.69729768	1.704970474	2.5429094
12	1.713343682	2.34270718	1.152603636	1.87548129
13	-0.117017142	0.861454599	-0.167565326	-0.056501435
14	1.334324567	2.441280698	1.35459432	2.181621862
15	1.651367648	1.79384648	1.8974999	1.639510527
16	3.711162939	3.787633897	3.510960718	3.128169185
17	1.481135861	0.394767192	1.249791317	1.554834793
18	1.220647716	1.673167542	1.777603011	2.571881437
19	1.936760358	2.254179716	1.600975981	1.756527669
20	1.329263673	1.415139701	0.799527561	0.738966264
21	2.034638637	2.921928516	1.505596671	2.625155188
22	0.896011994	1.003399516	1.840332211	1.094281774
23	1.383257582	2.44443244	2.568269226	1.8974999
24	1.688576695	1.360350648	1.200660687	0.936578493
25	2.632800495	1.640796245	2.14450737	2.583497341
26	1.384154273	1.152943613	0.746050436	0.670519918
27	1.113465369	1.432470368	0.678573751	0.47601391
28	1.293015296	2.909473675	2.843181572	2.851496006
29	1.569526959	3.210414972	1.294231266	1.667115725
31	2.313547353	2.34583005	3.987836118	3.112042442
32	1.765488254	1.360350648	1.178147663	0.881777225
33	2.370787814	1.749361512	2.062261582	1.49571719
34	2.149585071	3.711162939	1.729143194	2.193163083
37	2.037729799	2.701951909	1.982019745	2.360522215
38	2.708499996	2.774584446	1.73369734	1.272348533
39	3.711162939	4.019749544	3.711162939	3.787633897];

Post1.Acc = [1	72.22222222	62.22222222	61.11111111	72.22222222
2	100	35.55555556	100	31.11111111
3	87.77777778	58.88888889	92.22222222	48.88888889
4	87.77777778	80	88.88888889	71.11111111
5	94.44444444	72.22222222	93.33333333	74.44444444
7	96.66666667	67.77777778	87.77777778	83.33333333
8	96.66666667	55.55555556	95.55555556	55.55555556
9	97.77777778	54.44444444	97.77777778	52.22222222
10	91.11111111	62.22222222	96.66666667	61.11111111
11	93.33333333	84.44444444	94.44444444	82.22222222
12	98.88888889	85.55555556	96.66666667	60
13	85.55555556	52.22222222	71.11111111	53.33333333
14	94.44444444	84.44444444	91.11111111	65.55555556
15	96.66666667	33.33333333	95	20
16	98.88888889	95.55555556	100	93.33333333
17	78.88888889	51.11111111	92.22222222	36.66666667
18	95.55555556	78.88888889	90	70
19	91.11111111	83.33333333	97.77777778	60
20	83.33333333	83.33333333	54.44444444	91.11111111
21	91.11111111	80	93.33333333	62.22222222
22	86.66666667	86.66666667	87.77777778	52.22222222
23	95.55555556	95.55555556	97.77777778	77.77777778
24	96.66666667	55.55555556	100	33.33333333
25	88.88888889	81.11111111	91.11111111	87.77777778
26	92.22222222	72.22222222	95.55555556	36.66666667
27	93.33333333	50	52.22222222	85.55555556
28	97.77777778	77.77777778	97.77777778	80
29	96.66666667	70	97.77777778	52.22222222
31	97.77777778	90	100	90
32	92.22222222	36.66666667	88.88888889	15.55555556
33	85.55555556	95.55555556	91.11111111	87.77777778
34	93.33333333	71.11111111	91.11111111	61.11111111
37	97.77777778	65.55555556	98.88888889	42.22222222
38	96.66666667	75.55555556	100	50
39	100	92.22222222	96.66666667	93.33333333];

Post1.RT = [1	1158.129032	1154.519231	1106.132075	1069.419355
2	851.4117647	1131.645161	797.6744186	1144.392857
3	1027.909091	1010.490196	995.5365854	976.6046512
4	732.3066667	808.0985915	639.5921053	700.2131148
5	933.8170732	874.6774194	808.8765432	806.46875
7	1106.746988	1128.525424	1103.986486	1085.849315
8	1030.025	1027.468085	967.875	990.5531915
9	1205.702381	1256.413043	1160.917647	1103.068182
10	855.5696203	810.0192308	710.8470588	711.4615385
11	1149.088608	1157.589041	1104.382716	1143.859155
12	808.7831325	885.6891892	804.7108434	856.4423077
13	839.3611111	888.5111111	801.05	801.787234
14	948.7439024	872.7	945.5	908.5172414
15	784.1111111	1020.333333	758.9272727	956.7272727
16	924.5176471	883.4625	848.627907	863.1410256
17	820.2941176	812.6444444	718.95	804.5
18	894.4698795	999.030303	833.9871795	950.7833333
19	937.3670886	952.6527778	793.0357143	987.2115385
20	701.6666667	674.2432432	709.1489362	666.85
21	981.525	925.9104478	944.8641975	933.5555556
22	910.5138889	908.5866667	885.8648649	866.9545455
23	1010.43038	966.9390244	884.3614458	950.9850746
24	821.4939759	861.7916667	758.1294118	1007.566667
25	1004.466667	1000.695652	1018.316456	1010.223684
26	864.7875	913.8387097	841.1686747	866.96875
27	1046.3625	1121.902439	1261.319149	919.7746479
28	1170.916667	1190.515152	1153.6	1162.701493
29	1068.45679	1125.333333	1029.282353	1082.886364
31	1020.390244	962.8831169	998.0813953	970.5526316
32	1090.975904	1372.212121	822.2777778	1315.857143
33	820.6712329	768.0731707	756.1898734	738.5675676
34	1116.728395	1112.416667	1075.423077	1060.921569
37	1087.083333	1087.25	1026.701149	1035.111111
38	976.9506173	962.7142857	816.5	858.0952381
39	1180.247191	1187.54321	1170.072289	1148.666667];

Post1.HitAcc = [1	68.88888889	75.55555556	68.88888889	53.33333333
2	100	100	100	100
3	82.22222222	93.33333333	100	84.44444444
4	88.88888889	86.66666667	88.88888889	88.88888889
5	100	88.88888889	93.33333333	93.33333333
7	100	93.33333333	91.11111111	84.44444444
8	95.55555556	97.77777778	95.55555556	95.55555556
9	97.77777778	97.77777778	95.55555556	100
10	88.88888889	93.33333333	95.55555556	97.77777778
11	91.11111111	95.55555556	91.11111111	97.77777778
12	97.77777778	100	95.55555556	97.77777778
13	86.66666667	84.44444444	71.11111111	71.11111111
14	91.11111111	97.77777778	91.11111111	91.11111111
15	96.66666667	96.66666667	93.33333333	96.66666667
16	97.77777778	100	100	100
17	68.88888889	88.88888889	93.33333333	91.11111111
18	95.55555556	95.55555556	86.66666667	93.33333333
19	95.55555556	86.66666667	97.77777778	97.77777778
20	95.55555556	71.11111111	60	48.88888889
21	86.66666667	95.55555556	93.33333333	93.33333333
22	80	93.33333333	80	95.55555556
23	93.33333333	97.77777778	97.77777778	97.77777778
24	95.55555556	97.77777778	100	100
25	86.66666667	91.11111111	93.33333333	88.88888889
26	88.88888889	95.55555556	95.55555556	95.55555556
27	93.33333333	93.33333333	48.88888889	55.55555556
28	97.77777778	97.77777778	95.55555556	100
29	100	93.33333333	100	95.55555556
31	95.55555556	100	100	100
32	95.55555556	88.88888889	82.22222222	95.55555556
33	86.66666667	84.44444444	93.33333333	88.88888889
34	91.11111111	95.55555556	100	82.22222222
37	100	95.55555556	100	97.77777778
38	95.55555556	97.77777778	100	100
39	100	100	93.33333333	100];

Post1.HitRT = [1	1125.37931	1172.9375	1067.4	1156.652174
2	881.4634146	821.6046512	831.7674419	763.0952381
3	1028.916667	1028.682927	983.1590909	1009.868421
4	720.7435897	744.8333333	642.1578947	637.0263158
5	905.5454545	966.5526316	794.5365854	823.575
7	1101.465116	1112.425	1067.243243	1124.457143
8	1044.85	1015.2	997.195122	948.625
9	1188.581395	1230.642857	1138.585366	1176.674419
10	835.9736842	865.15	705.3333333	716.2325581
11	1128.473684	1162	1114.692308	1099.976744
12	823.5952381	804.7674419	815.1	795.0465116
13	836.2432432	850.75	813.7741935	787.4482759
14	938.1794872	950.1904762	936.5384615	955.3333333
15	762.4444444	805.7777778	771.0357143	746.3703704
16	915.2380952	933.5813953	861.3571429	836.4772727
17	849.6	800.2631579	665.5384615	758.7948718
18	825.5641026	924.425	815.5675676	843.95
19	891.9285714	998.4210526	746.1428571	836.8536585
20	676.4390244	736.0967742	683.68	735.1904762
21	1006.842105	958.6190476	952.7	937.2195122
22	915.8235294	919.2820513	928.7647059	849.4
23	1048.538462	982.8780488	924.6341463	854.5952381
24	794.1666667	861.9302326	742.2195122	772.9545455
25	1001.166667	1007.512821	1022.625	1013.897436
26	869.8461538	859.9756098	855.2619048	826.7317073
27	1044.04878	1060.925	1210.761905	1282.92
28	1180.317073	1161.953488	1167.428571	1146.363636
29	1054.02381	1092.3	1040.627907	1017.666667
31	1008.642857	1053.428571	986.2093023	1009.953488
32	1108.372093	1072.275	829	816.5897436
33	797.9189189	844.0555556	738.0243902	778.8684211
34	1078.435897	1147.829268	1081.534884	1067.914286
37	1076.651163	1098.878049	1011.355556	1048.348837
38	999.9	943.85	821.3095238	811.9090909
39	1178.133333	1182.409091	1207.071429	1142.095238];

Post1.CRAcc = [1	64.44444444	60	80	64.44444444
2	40	31.11111111	28.88888889	33.33333333
3	68.88888889	48.88888889	37.77777778	60
4	71.11111111	88.88888889	82.22222222	60
5	64.44444444	80	77.77777778	71.11111111
7	86.66666667	48.88888889	84.44444444	82.22222222
8	64.44444444	46.66666667	77.77777778	33.33333333
9	42.22222222	66.66666667	77.77777778	26.66666667
10	53.33333333	71.11111111	75.55555556	46.66666667
11	93.33333333	75.55555556	84.44444444	80
12	80	91.11111111	48.88888889	71.11111111
13	28.88888889	75.55555556	31.11111111	75.55555556
14	86.66666667	82.22222222	75.55555556	55.55555556
15	23.33333333	43.33333333	26.66666667	13.33333333
16	97.77777778	93.33333333	100	86.66666667
17	68.88888889	33.33333333	37.77777778	35.55555556
18	64.44444444	93.33333333	77.77777778	62.22222222
19	91.11111111	75.55555556	68.88888889	51.11111111
20	71.11111111	95.55555556	88.88888889	93.33333333
21	80	80	64.44444444	60
22	88.88888889	84.44444444	91.11111111	13.33333333
23	93.33333333	97.77777778	80	75.55555556
24	84.44444444	26.66666667	31.11111111	35.55555556
25	84.44444444	77.77777778	88.88888889	86.66666667
26	71.11111111	73.33333333	46.66666667	26.66666667
27	55.55555556	44.44444444	84.44444444	86.66666667
28	75.55555556	80	82.22222222	77.77777778
29	64.44444444	75.55555556	40	64.44444444
31	93.33333333	86.66666667	91.11111111	88.88888889
32	53.33333333	20	26.66666667	4.444444444
33	100	91.11111111	93.33333333	82.22222222
34	68.88888889	73.33333333	44.44444444	77.77777778
37	55.55555556	75.55555556	35.55555556	48.88888889
38	84.44444444	66.66666667	60	40
39	95.55555556	88.88888889	95.55555556	91.11111111];

Post1.CRRT = [1	1127.192308	1163.76	1064.6	1075.666667
2	1099.352941	1148.076923	1191.461538	1103.6
3	1014.724138	1004.909091	1008.235294	952.24
4	859.71875	755.2702703	694.0285714	712.3846154
5	852.1481481	881.0294118	830	786.2258065
7	1138.162162	1078.55	1059	1094.057143
8	1011.259259	1049.35	986.2352941	1052.785714
9	1301.210526	1241.285714	1089.96875	1138
10	800.4761905	816.483871	699.7575758	741.9
11	1158.829268	1156	1131.138889	1158.857143
12	884.1714286	887.0512821	838.3181818	875.0322581
13	903.0833333	873.3125	819.4615385	789.3030303
14	863.7837838	902.7714286	890.53125	915.7916667
15	1154.571429	1002.833333	924.4285714	1129.75
16	844.1	917.4102564	840.627907	907.3684211
17	779.1034483	855.2142857	809.0588235	799.3333333
18	1024.962963	994.5	980.9090909	913.962963
19	939.5	969.09375	942.4137931	1032.772727
20	661.0322581	679.7857143	655.0769231	678.0487805
21	939.3142857	911.25	923.4285714	944.4615385
22	856.4736842	956.4166667	849.3947368	978.1666667
23	980.7	953.8333333	928.9411765	973.6969697
24	843.2	901.6666667	971.6428571	1039
25	982.4166667	1020.636364	986.7631579	1027.405405
26	895.75	933.1333333	853.5238095	892.6363636
27	1165.478261	1066.222222	914.1428571	925.25
28	1202.40625	1179.323529	1174.457143	1149.84375
29	1130.074074	1113.28125	1106.176471	1068.222222
31	955.625	970.7297297	945.972973	983.1842105
32	1320.75	1509.444444	1325.333333	1259
33	751.1395349	788.8205128	706.3589744	786.8285714
34	1131.37931	1094.677419	1062.368421	1075.454545
37	1088.458333	1086.34375	1042.9375	1028.85
38	971.3142857	957.8928571	832.7692308	921.8235294
39	1188.095238	1186.948718	1131.738095	1175.225];

Post1.dprime = [1	1.134684732	1.097653759	1.49406503	0.454015979
2	2.033200848	1.793844618	1.72991433	1.876564629
3	1.490904505	1.473230919	1.975225572	1.266240441
4	1.825225695	2.428054399	2.333378908	2.076863676
5	2.656912196	2.062261582	2.26579562	2.247255251
7	3.493962002	1.473230919	2.44443244	2.020670583
8	2.071652412	1.926223038	2.465997841	1.270560868
9	1.838127683	2.708715632	2.465997841	1.663622228
10	1.304292083	2.247255251	2.449146762	1.952875098
11	2.848714824	2.393365303	2.360522215	2.851496006
12	2.851496006	3.634176829	1.67343314	2.566508393
13	0.554137996	1.704970474	0.063930288	1.248710758
14	2.458400494	2.933741793	2.039706014	1.487339176
15	1.13204204	2.02473842	1.565082678	0.789505841
16	4.019749544	3.787633897	4.573095903	3.397319568
17	1.030222439	0.78991305	1.189763566	0.977264633
18	2.071652412	3.202374113	2.032908541	2.001944009
19	3.348052447	1.899491187	2.863595494	2.037729799
20	2.305873513	2.825839417	2.33661166	1.990720462
21	1.95239285	2.5429094	1.871450191	1.754433049
22	2.17679897	2.513979283	2.189250111	0.59051655
23	3.002171892	4.019749544	2.918332641	2.701951909
24	2.714181504	1.386949049	1.793844618	1.916183707
25	2.516160452	2.314964533	2.721726295	2.331411965
26	1.77727397	2.623349292	1.617636433	1.09670282
27	2.13043076	1.851010163	1.012893337	1.316236026
28	2.757733367	3.119609567	2.92429059	3.112042442
29	2.656912196	2.193163083	2.033200848	2.071652412
31	3.691045199	3.493962002	3.634176829	3.5071883
32	2.253770672	0.876752586	1.435529287	0.624352169
33	3.493962002	2.360522215	3.002171892	2.218841521
34	1.982173375	2.32421389	2.172362657	1.688576695
37	2.42625825	2.393365303	1.916183707	1.982019745
38	2.714181504	2.440602071	2.539895054	2.033200848
39	3.987836118	3.5071883	3.202374113	3.634176829];

Post2.Acc = [1	78.88888889	82.22222222	62.22222222	82.22222222
2	100	44.44444444	100	38.88888889
3	95.55555556	74.44444444	97.77777778	64.44444444
4	95.55555556	90	80	64.44444444
7	97.77777778	90	96.66666667	88.88888889
9	100	75.55555556	96.66666667	56.66666667
10	85	78.33333333	86.66666667	63.33333333
12	98.88888889	94.44444444	86.66666667	83.33333333
13	82.22222222	76.66666667	88.88888889	48.88888889
15	63.33333333	35.55555556	70	30
16	97.77777778	94.44444444	100	95.55555556
17	84.44444444	55.55555556	85.55555556	73.33333333
18	91.11111111	85.55555556	87.77777778	90
20	71.11111111	97.77777778	45.55555556	96.66666667
21	96.66666667	75.55555556	100	70
22	83.33333333	93.33333333	80	76.66666667
23	93.33333333	96.66666667	96.66666667	87.77777778
24	86.66666667	74.44444444	97.77777778	63.33333333
25	96.66666667	82.22222222	90	92.22222222
27	98.88888889	74.44444444	65.55555556	86.66666667
28	96.66666667	57.77777778	97.77777778	73.33333333
32	93.33333333	63.33333333	97.77777778	11.11111111
33	86.66666667	93.33333333	94.44444444	88.88888889
34	94.44444444	84.44444444	95.55555556	76.66666667
37	96.66666667	71.11111111	100	42.22222222
38	98.88888889	84.44444444	98.88888889	58.88888889
39	97.77777778	93.33333333	98.88888889	100];

Post2.RT = [1	1128.073529	1131.774648	1144.888889	1091.485294
2	907.7241379	1121.236842	872.6470588	1102.484848
3	1004.7625	964.5384615	970.4235294	940.4444444
4	599.037037	648.974359	565.6428571	660.037037
7	1023.541176	1013.544304	1057	995.2631579
9	1193.388235	1201.757576	1135.246914	1174.354167
10	785.3777778	761.4871795	748.255814	767.84375
12	809.4534884	819.7439024	788.9866667	809.5138889
13	821.1971831	849.7761194	776.5066667	812.1428571
15	864.7592593	1127.290323	801.9310345	1208.5
16	889.4883721	864.6875	829.5930233	856.7407407
17	747.9166667	809.9183673	694.36	744.4354839
18	887.164557	948.4459459	854.5333333	886.8461538
20	770.7213115	659.8333333	796.925	649.3209877
21	938.8554217	913	913.0465116	900.8983051
22	812.2916667	778.7594937	788.6911765	795.5970149
23	979.0609756	893.7160494	883.9879518	907.5135135
24	781.6753247	783.4603175	745.1529412	826.1851852
25	1029.13253	1042.671429	971.6363636	963.8076923
27	1031.435294	1016.328125	1058.839286	944.2361111
28	1152.621951	1154.354167	1131.392857	1134.081967
32	969.8227848	1338.894737	839.8902439	1378.2
33	767.25	729.025	730.7530864	710.1688312
34	1043.783133	1089.540541	1033.380952	1066.378788
37	1096.25	1045.42623	1059.337079	1036.297297
38	903.0240964	942.2465753	813.9642857	897.06
39	1127.107143	1118.04878	1086.511905	1088.651163];

Post2.HitAcc = [1	77.77777778	80	62.22222222	62.22222222
2	100	100	100	100
3	93.33333333	97.77777778	97.77777778	97.77777778
4	100	91.11111111	75.55555556	84.44444444
7	97.77777778	97.77777778	95.55555556	97.77777778
9	100	100	95.55555556	97.77777778
10	80	90	86.66666667	86.66666667
12	100	97.77777778	93.33333333	80
13	80	84.44444444	86.66666667	91.11111111
15	60	66.66666667	73.33333333	66.66666667
16	97.77777778	97.77777778	100	100
17	82.22222222	86.66666667	91.11111111	80
18	93.33333333	88.88888889	86.66666667	88.88888889
20	75.55555556	66.66666667	57.77777778	33.33333333
21	100	93.33333333	100	100
22	77.77777778	88.88888889	64.44444444	95.55555556
23	93.33333333	93.33333333	100	93.33333333
24	95.55555556	77.77777778	97.77777778	97.77777778
25	95.55555556	97.77777778	80	100
27	97.77777778	100	51.11111111	80
28	97.77777778	95.55555556	95.55555556	100
32	91.11111111	95.55555556	100	95.55555556
33	88.88888889	84.44444444	93.33333333	95.55555556
34	91.11111111	97.77777778	97.77777778	93.33333333
37	95.55555556	97.77777778	100	100
38	100	97.77777778	100	97.77777778
39	95.55555556	100	97.77777778	100];

Post2.HitRT = [1	1103.5	1152.647059	1131.037037	1158.740741
2	895.4761905	913.5227273	873.9772727	884.5581395
3	992.3658537	1036.380952	965.6904762	972.0714286
4	597.0952381	609.025	565.8787879	562.1666667
7	1030.348837	1016.571429	1055	1058.906977
9	1188.853659	1185.190476	1156.268293	1119.463415
10	764.5	840.5833333	967.9615385	723.7727273
12	823.7674419	789.8333333	799.097561	783.1714286
13	819.8529412	822.4324324	771.972973	780.9210526
15	798.2692308	944.5862069	841.3	788.137931
16	882.4418605	897.6976744	827.4418605	836.3181818
17	732.6857143	762.3243243	681.3076923	697.7352941
18	877.097561	900.6315789	853.9444444	855.0769231
20	748.65625	792.4642857	791.6	806.8
21	956.2325581	920.175	929.5	907
22	842.1428571	792.3684211	800.1071429	787.7073171
23	999.45	938.1282051	891.2142857	876.5853659
24	771.3333333	781.6060606	749.4883721	740.7142857
25	1040.488372	1023.829268	977.9428571	966.3809524
27	1013.690476	1048.767442	1054.095238	1056.647059
28	1161.170732	1136.425	1132.829268	1130.023256
32	967.8421053	971.6585366	794.9512195	884.8292683
33	771.6410256	762.6216216	721.5853659	747.3170732
34	1036.45	1050.604651	1028.47619	1033.512195
37	1100.95122	1091.767442	1050.840909	1064.636364
38	910.9761905	904.5	823.952381	811.2325581
39	1119.365854	1134.488372	1069.928571	1107.697674];

Post2.CRAcc = [1	84.44444444	80	80	84.44444444
2	37.77777778	51.11111111	37.77777778	40
3	80	68.88888889	64.44444444	64.44444444
4	93.33333333	86.66666667	66.66666667	62.22222222
7	91.11111111	88.88888889	95.55555556	82.22222222
9	80	71.11111111	80	33.33333333
10	76.66666667	80	63.33333333	63.33333333
12	97.77777778	91.11111111	80	86.66666667
13	66.66666667	86.66666667	37.77777778	60
15	42.22222222	28.88888889	28.88888889	31.11111111
16	97.77777778	91.11111111	97.77777778	93.33333333
17	84.44444444	26.66666667	71.11111111	75.55555556
18	75.55555556	95.55555556	93.33333333	86.66666667
20	97.77777778	97.77777778	95.55555556	97.77777778
21	53.33333333	97.77777778	57.77777778	82.22222222
22	95.55555556	91.11111111	93.33333333	60
23	100	93.33333333	86.66666667	88.88888889
24	97.77777778	51.11111111	80	46.66666667
25	86.66666667	77.77777778	97.77777778	86.66666667
27	75.55555556	73.33333333	93.33333333	80
28	53.33333333	62.22222222	75.55555556	71.11111111
32	82.22222222	44.44444444	17.77777778	4.444444444
33	91.11111111	95.55555556	95.55555556	82.22222222
34	80	88.88888889	68.88888889	84.44444444
37	66.66666667	75.55555556	28.88888889	55.55555556
38	86.66666667	82.22222222	66.66666667	51.11111111
39	97.77777778	88.88888889	100	100];

Post2.CRRT = [1	1107.611111	1158.028571	1064.375	1103.171429
2	1230.411765	1060.909091	1126.5	1090.647059
3	959.4705882	964.6333333	950.8518519	930.6296296
4	649.9	648	657.2857143	663
7	1000.625	1031.575	993.3902439	1004.916667
9	1176.676471	1226.129032	1174	1184.714286
10	1011.173913	776.9545455	722.3888889	1078.210526
12	800.0731707	835.8	809.4285714	809.5945946
13	868.5862069	835.4210526	800.1875	819.5
15	1075.444444	1203	1342.538462	1125.142857
16	838.0731707	893.9487179	838.9268293	875
17	795.4324324	854.5833333	720.8666667	772.6060606
18	983.71875	911.9268293	911.475	860.9210526
20	645.7209302	680.7857143	670.5609756	636.725
21	946.6521739	902.4418605	940.4	892.4444444
22	750.2857143	823.175	771.1219512	834.1923077
23	901.1428571	884.0263158	919.3243243	895.7027027
24	768.5813953	830.7727273	814.0857143	861.1
25	1024.621622	1072.823529	961.0487805	966.8648649
27	984.875	1047.78125	964.1025641	933.8823529
28	1173.727273	1155.666667	1153.84375	1124.066667
32	1292.228571	1376.15	1376.875	1383.5
33	729.6666667	722.875	686.5365854	728.4411765
34	1085.571429	1087.657895	1061.366667	1070.555556
37	1051.535714	1037.84375	1069.384615	1018.375
38	940.8648649	935.4	890.7142857	905.1363636
39	1122.309524	1100.657895	1080.880952	1096.068182];

Post2.dprime = [1	1.90545301	1.683242467	1.152943613	1.324215717
2	1.975225572	2.314402978	1.975225572	2.056663834
3	2.34270718	2.502578105	2.380239017	2.380239017
4	3.977169581	3.907720462	3.245493593	2.855159589
7	3.35750365	3.230515121	3.402576334	2.933741793
9	3.128169185	2.843181572	2.5429094	1.579147473
10	1.761906413	2.226221157	2.126850388	1.725852928
12	4.296422724	3.35750365	2.34270718	1.95239285
13	1.272348533	2.123664954	0.799449237	1.600975981
15	0.376330689	0.020522982	0.22072756	0.086996254
16	4.019749544	3.35750365	4.296422724	3.787633897
17	1.936760358	0.584488327	1.904262499	1.53369837
18	2.193163083	2.921928516	3.012987008	2.331411965
20	2.757733367	2.708715632	2.265828323	1.579147473
21	2.370199685	3.510960718	2.482759685	3.210414972
22	2.465997841	2.568269226	1.871450191	1.95463527
23	3.787633897	3.002171892	3.397319568	2.721726295
24	3.711162939	0.792564701	2.851496006	1.926223038
25	2.812059783	2.774584446	2.918332641	3.397319568
27	2.701951909	2.909473675	1.528940973	1.683242467
28	2.093526506	2.349179265	2.692500706	2.843181572
32	2.603528206	1.561577868	1.410405102	0.589544611
33	2.568269226	2.714181504	3.202374113	2.625155188
34	2.331091276	3.230515121	2.502578105	2.513979283
37	2.132015466	2.701951909	1.72991433	2.42625825
38	3.397319568	2.933741793	2.717275251	2.037729799
39	3.711162939	3.5071883	4.296422724	4.573095903];

%% Calculate Diff1 - Accuracy, RT, dprime
% 
% Diff1.Acc = [Pre.Acc(:,1) Post1.Acc(:,2:5) - Pre.Acc(:,2:5)];
% Diff1.RT = [Pre.RT(:,1) Post1.RT(:,2:5) - Pre.RT(:,2:5)];
% Diff1.HitAcc = [Pre.Acc(:,1) Post1.HitAcc(:,2:5) - Pre.HitAcc(:,2:5)];
% Diff1.HitRT = [Pre.Acc(:,1) Post1.HitRT(:,2:5) - Pre.HitRT(:,2:5)];
% Diff1.CRAcc = [Pre.Acc(:,1) Post1.CRAcc(:,2:5) - Pre.CRAcc(:,2:5)];
% Diff1.CRRT = [Pre.Acc(:,1) Post1.CRRT(:,2:5) - Pre.CRRT(:,2:5)];
% Diff1.dprime = [Pre.Acc(:,1) Post1.dprime(:,2:5) - Pre.dprime(:,2:5)];

%allsubs = [1:5 7:29 31:34 37:39];
allsubs = [1,2,3,4,7,9,10,12,17,20,21,22,23,24,25,27,28,33,34,37,38,39;];

% Look at baseline response to CS+ vs. CS-
Diff1.Acc = Post2.Acc;
Diff1.RT = Post2.RT;
Diff1.HitAcc = Post2.HitAcc;
Diff1.HitRT = Post2.HitRT;
Diff1.CRAcc = Post2.CRAcc;
Diff1.CRRT = Post2.CRRT;
Diff1.dprime = Post2.dprime;

gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);

for i = 1:length(Diff1.Acc)
    subid = Diff1.Acc(i,1);
    %save differential (Post1-Pre) Accuracy
    gCS.HitAcc(i,1) = Diff1.Acc(i,2);
    gCS.CRAcc(i,1) = Diff1.Acc(i,3);
    cCS.HitAcc(i,1) = Diff1.Acc(i,4);
    cCS.CRAcc(i,1) = Diff1.Acc(i,5);
    %save differential RT
    gCS.HitRT(i,1) = Diff1.RT(i,2);
    gCS.CRRT(i,1) = Diff1.RT(i,3);
    cCS.HitRT(i,1) = Diff1.RT(i,4);
    cCS.CRRT(i,1) = Diff1.RT(i,5);    
    
    if rem(subid,2)==1 
        
    %if subno is odd, T1 is the CS+    
    gCSp.HitAcc = [gCSp.HitAcc; subid Diff1.HitAcc(i,2)];
    gCSp.HitRT = [gCSp.HitRT; subid Diff1.HitRT(i,2)];
    gCSp.CRAcc = [gCSp.CRAcc; subid Diff1.CRAcc(i,2)];
    gCSp.CRRT = [gCSp.CRRT; subid Diff1.CRRT(i,2)];
    gCSp.dprime = [gCSp.dprime; subid Diff1.dprime(i,2)];
    
    %if subno is odd, T2 is the CS-
    gCSm.HitAcc = [gCSm.HitAcc; subid Diff1.HitAcc(i,3)];
    gCSm.HitRT = [gCSm.HitRT; subid Diff1.HitRT(i,3)];
    gCSm.CRAcc = [gCSm.CRAcc; subid Diff1.CRAcc(i,3)];
    gCSm.CRRT = [gCSm.CRRT; subid Diff1.CRRT(i,3)];
    gCSm.dprime = [gCSm.dprime; subid Diff1.dprime(i,3)];  
    
    %if subno is odd, T1 is the CS+    
    cCSp.HitAcc = [cCSp.HitAcc; subid Diff1.HitAcc(i,4)];
    cCSp.HitRT = [cCSp.HitRT; subid Diff1.HitRT(i,4)];
    cCSp.CRAcc = [cCSp.CRAcc; subid Diff1.CRAcc(i,4)];
    cCSp.CRRT = [cCSp.CRRT; subid Diff1.CRRT(i,4)];
    cCSp.dprime = [cCSp.dprime; subid Diff1.dprime(i,4)];
    
    %if subno is odd, T2 is the CS-
    cCSm.HitAcc = [cCSm.HitAcc; subid Diff1.HitAcc(i,5)];
    cCSm.HitRT = [cCSm.HitRT; subid Diff1.HitRT(i,5)];
    cCSm.CRAcc = [cCSm.CRAcc; subid Diff1.CRAcc(i,5)];
    cCSm.CRRT = [cCSm.CRRT; subid Diff1.CRRT(i,5)];
    cCSm.dprime = [cCSm.dprime; subid Diff1.dprime(i,5)];        
                
    elseif rem(subid,2)==0

    %if subno is even, T1 is the CS-    
    gCSm.HitAcc = [gCSm.HitAcc; subid Diff1.HitAcc(i,2)];
    gCSm.HitRT = [gCSm.HitRT; subid Diff1.HitRT(i,2)];
    gCSm.CRAcc = [gCSm.CRAcc; subid Diff1.CRAcc(i,2)];
    gCSm.CRRT = [gCSm.CRRT; subid Diff1.CRRT(i,2)];
    gCSm.dprime = [gCSm.dprime; subid Diff1.dprime(i,2)];
    
    %if subno is even, T2 is the CS+
    gCSp.HitAcc = [gCSp.HitAcc; subid Diff1.HitAcc(i,3)];
    gCSp.HitRT = [gCSp.HitRT; subid Diff1.HitRT(i,3)];
    gCSp.CRAcc = [gCSp.CRAcc; subid Diff1.CRAcc(i,3)];
    gCSp.CRRT = [gCSp.CRRT; subid Diff1.CRRT(i,3)];
    gCSp.dprime = [gCSp.dprime; subid Diff1.dprime(i,3)];    

    %if subno is odd, T1 is the CS-  
    cCSm.HitAcc = [cCSm.HitAcc; subid Diff1.HitAcc(i,4)];
    cCSm.HitRT = [cCSm.HitRT; subid Diff1.HitRT(i,4)];
    cCSm.CRAcc = [cCSm.CRAcc; subid Diff1.CRAcc(i,4)];
    cCSm.CRRT = [cCSm.CRRT; subid Diff1.CRRT(i,4)];
    cCSm.dprime = [cCSm.dprime; subid Diff1.dprime(i,4)];        
    
    %if subno is odd, T2 is the CS+
    cCSp.HitAcc = [cCSp.HitAcc; subid Diff1.HitAcc(i,5)];
    cCSp.HitRT = [cCSp.HitRT; subid Diff1.HitRT(i,5)];
    cCSp.CRAcc = [cCSp.CRAcc; subid Diff1.CRAcc(i,5)];
    cCSp.CRRT = [cCSp.CRRT; subid Diff1.CRRT(i,5)];
    cCSp.dprime = [cCSp.dprime; subid Diff1.dprime(i,5)];   
    
    end
    
    
end

HitAccAll = [gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
HitRTAll = [gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
CRAccAll = [gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
CRRTAll = [gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
dprimeAll = [gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

%% Sort data into groups of subjects
%a = [];%to-be-sorted data matrix
%index = [1,2,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39;];%the full group of SCR subjects
%index1 = [1,2,3,4,5,7,9,10,11,13,15,17,18,19,20,21,22,24,25,27,28,31,32,33,34,38,39;];%successfully conditioned sub at the end of visit1
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

%% Calculate Diff2 - Accuracy, RT, dprime
Presub = Pre.Acc(:,1);

for i = 1:length(Post2.Acc)
subid = Post2.Acc(i,1);

if ismember(subid,Presub)
Diff2.Acc(i,:) = [Post2.Acc(i,1) Post2.Acc(i,2:5) - Pre.Acc(i,2:5)];
Diff2.RT(i,:) = [Post2.Acc(i,1) Post2.RT(i,2:5) - Pre.RT(i,2:5)];
Diff2.HitAcc(i,:) = [Post2.Acc(i,1) Post2.HitAcc(i,2:5) - Pre.HitAcc(i,2:5)];
Diff2.HitRT(i,:) = [Post2.Acc(i,1) Post2.HitRT(i,2:5) - Pre.HitRT(i,2:5)];
Diff2.CRAcc(i,:) = [Post2.Acc(i,1) Post2.CRAcc(i,2:5) - Pre.CRAcc(i,2:5)];
Diff2.CRRT(i,:) = [Post2.Acc(i,1) Post2.CRRT(i,2:5) - Pre.CRRT(i,2:5)];
Diff2.dprime(i,:) = [Post2.Acc(i,1) Post2.dprime(i,2:5) - Pre.dprime(i,2:5)];
end
end

gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[]);

for i = 1:length(Diff2.Acc)
    subid = Diff2.Acc(i,1);
    %save differential (Post1-Pre) Accuracy
    gCS.HitAcc(i,1) = Diff2.Acc(i,2);
    gCS.CRAcc(i,1) = Diff2.Acc(i,3);
    cCS.HitAcc(i,1) = Diff2.Acc(i,4);
    cCS.CRAcc(i,1) = Diff2.Acc(i,5);
    %save differential RT
    gCS.HitRT(i,1) = Diff2.RT(i,2);
    gCS.CRRT(i,1) = Diff2.RT(i,3);
    cCS.HitRT(i,1) = Diff2.RT(i,4);
    cCS.CRRT(i,1) = Diff2.RT(i,5);    
    
    if rem(subid,2)==1 
        
    %if subno is odd, T1 is the CS+    
    gCSp.HitAcc = [gCSp.HitAcc; subid Diff2.HitAcc(i,2)];
    gCSp.HitRT = [gCSp.HitRT; subid Diff2.HitRT(i,2)];
    gCSp.CRAcc = [gCSp.CRAcc; subid Diff2.CRAcc(i,2)];
    gCSp.CRRT = [gCSp.CRRT; subid Diff2.CRRT(i,2)];
    gCSp.dprime = [gCSp.dprime; subid Diff2.dprime(i,2)];
    
    %if subno is odd, T2 is the CS-
    gCSm.HitAcc = [gCSm.HitAcc; subid Diff2.HitAcc(i,3)];
    gCSm.HitRT = [gCSm.HitRT; subid Diff2.HitRT(i,3)];
    gCSm.CRAcc = [gCSm.CRAcc; subid Diff2.CRAcc(i,3)];
    gCSm.CRRT = [gCSm.CRRT; subid Diff2.CRRT(i,3)];
    gCSm.dprime = [gCSm.dprime; subid Diff2.dprime(i,3)];  
    
    %if subno is odd, T1 is the CS+    
    cCSp.HitAcc = [cCSp.HitAcc; subid Diff2.HitAcc(i,4)];
    cCSp.HitRT = [cCSp.HitRT; subid Diff2.HitRT(i,4)];
    cCSp.CRAcc = [cCSp.CRAcc; subid Diff2.CRAcc(i,4)];
    cCSp.CRRT = [cCSp.CRRT; subid Diff2.CRRT(i,4)];
    cCSp.dprime = [cCSp.dprime; subid Diff2.dprime(i,4)];
    
    %if subno is odd, T2 is the CS-
    cCSm.HitAcc = [cCSm.HitAcc; subid Diff2.HitAcc(i,5)];
    cCSm.HitRT = [cCSm.HitRT; subid Diff2.HitRT(i,5)];
    cCSm.CRAcc = [cCSm.CRAcc; subid Diff2.CRAcc(i,5)];
    cCSm.CRRT = [cCSm.CRRT; subid Diff2.CRRT(i,5)];
    cCSm.dprime = [cCSm.dprime; subid Diff2.dprime(i,5)];        
                
    elseif rem(subid,2)==0

    %if subno is even, T1 is the CS-    
    gCSm.HitAcc = [gCSm.HitAcc; subid Diff2.HitAcc(i,2)];
    gCSm.HitRT = [gCSm.HitRT; subid Diff2.HitRT(i,2)];
    gCSm.CRAcc = [gCSm.CRAcc; subid Diff2.CRAcc(i,2)];
    gCSm.CRRT = [gCSm.CRRT; subid Diff2.CRRT(i,2)];
    gCSm.dprime = [gCSm.dprime; subid Diff2.dprime(i,2)];
    
    %if subno is even, T2 is the CS+
    gCSp.HitAcc = [gCSp.HitAcc; subid Diff2.HitAcc(i,3)];
    gCSp.HitRT = [gCSp.HitRT; subid Diff2.HitRT(i,3)];
    gCSp.CRAcc = [gCSp.CRAcc; subid Diff2.CRAcc(i,3)];
    gCSp.CRRT = [gCSp.CRRT; subid Diff2.CRRT(i,3)];
    gCSp.dprime = [gCSp.dprime; subid Diff2.dprime(i,3)];    

    %if subno is odd, T1 is the CS-  
    cCSm.HitAcc = [cCSm.HitAcc; subid Diff2.HitAcc(i,4)];
    cCSm.HitRT = [cCSm.HitRT; subid Diff2.HitRT(i,4)];
    cCSm.CRAcc = [cCSm.CRAcc; subid Diff2.CRAcc(i,4)];
    cCSm.CRRT = [cCSm.CRRT; subid Diff2.CRRT(i,4)];
    cCSm.dprime = [cCSm.dprime; subid Diff2.dprime(i,4)];        
    
    %if subno is odd, T2 is the CS+
    cCSp.HitAcc = [cCSp.HitAcc; subid Diff2.HitAcc(i,5)];
    cCSp.HitRT = [cCSp.HitRT; subid Diff2.HitRT(i,5)];
    cCSp.CRAcc = [cCSp.CRAcc; subid Diff2.CRAcc(i,5)];
    cCSp.CRRT = [cCSp.CRRT; subid Diff2.CRRT(i,5)];
    cCSp.dprime = [cCSp.dprime; subid Diff2.dprime(i,5)];   
    
    end
end

HitAccAll = [gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
HitRTAll = [gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
CRAccAll = [gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
CRRTAll = [gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
dprimeAll = [gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];



