
%% Subject initials
clear all

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

%1- contingency correct; 0- contingency incorrect; 2 - 2nd visit: Rating only at
%retest; NaN - no 2nd visit

%Sub1-57, except for Sub6,45, from who no data was taken
ExpStatus = [1,1,0,1;2,1,1,1;3,1,1,1;4,1,1,1;5,1,1,NaN;7,1,1,1;8,0,1,NaN;9,1,1,1;10,1,1,1;11,1,0,2;12,0,1,1;13,1,1,0;14,0,0,NaN;15,1,1,0;16,0,1,0;17,1,1,1;18,1,1,0;19,1,1,NaN;20,1,1,1;21,1,1,1;22,1,1,1;23,0,1,1;24,1,1,1;25,1,1,1;26,0,0,2;27,1,1,1;28,1,1,1;29,0,0,NaN;30,1,0,2;31,1,1,NaN;32,1,0,0;33,1,1,1;34,1,1,1;35,1,1,1;36,1,0,2;37,0,1,1;38,1,1,1;39,1,1,1;40,1,1,1;41,1,1,1;42,1,1,1;43,1,1,1;44,1,0,1;46,1,1,0;47,0,0,1;48,1,1,1;49,1,1,1;50,1,1,1;51,0,0,1;52,1,1,1;53,0,0,2;54,1,1,1;55,1,1,1;56,0,0,2;57,1,1,1;];

%% Accuracy and RTs broken down by angle - Preconditioning - blocks 1 - 3
%% averaged across three blocks
%outputs: Pre.Acc, Pre.RT, Pre.HitAcc, Pre.HitRT, Pre.CRAcc, Pre.CRRT,
%Pre.dprime
%last updated 3/21/15

allsubs = ExpStatus(find(ExpStatus(:,2) ==1 | ExpStatus(:,2) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==30)=[];
allsubs(allsubs ==35)=[];
allsubs(allsubs ==36)=[];

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];

Correj_rt = [];
Hit_rt = [];

d_prime = [];

acc_hitcorr = [];
rt_hitcorr = [];

allresponseTime = [];

allRTs = [];
AllSubRTs = [];

for a = allsubs;
    
    if a == 20
        bs = 2:3;
    else
        bs = 1:3;
    end
    
    initials = subinitials(a,:);
    
    acc_trials = [];
    correct_rts = [];
    
    correct_rts_gc_tdis = cell(2,2);% overall accurate trials, including both hit and cor rej
    accuracy_gc_tdis = cell(2,2); % this saves the accuracy by taking the length of the corresponding cells above
    
    distractor_rts_gc_angles = cell(2,2); %this saves the correct rts for correct rejection, with two target angles
    target_rts_gc_angles = cell(2,2);%this saves the correct rts for hit, with two target angles
    
    fa_rts_gc_angles = cell(2,2); %this saves the rts for false alarm
    miss_rts_gc_angles = cell(2,2); %this saves the rts for miss
    
    acc_distractor_gc_angles = cell(2,2);
    acc_target_gc_angles = cell(2,2);
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    allrt_sum = cell(2,2); %this measures all rts (both correct and incorrect); 1st index, gray vs. color; 2nd index, Target1 vs. Target2 
    
    
    for b = bs
        
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' StimR allresp rtypes;']);
        
        allresponseTime = allresp(rtypes(:,1)); %find out all trials that has a non-NaN RT
        rtypes_new = [rtypes allresponseTime']; %append it to the rtypes matrix
        
        %try outlier exclusion by Q75 > 1.5*(Q75-Q25) %071515
         Q25 = quantile(allresponseTime,0.25); Q75 = quantile(allresponseTime,0.75);
         rtindex = allresponseTime < (Q75 + 1.5*(Q75-Q25)) | allresponseTime > (Q25 - 1.5*(Q75-Q25)) ;         
        
        %rt exclusion: mean +- 3sd %try mean+-3sd trimming 040115;
%        rtindex = allresponseTime > (mean(allresponseTime) - 3*std(allresponseTime)) & (allresponseTime < mean(allresponseTime) + 3*std(allresponseTime)); %try mean+-3sd trimming 040115; find out the RTs that are > 100 and < mean + 2sd

        rtypes_rttrimed = rtypes_new(rtindex,:); %generate rtypes matrix that removed trimmed RTs.
        
        remainRT = allresponseTime(rtindex);
        
        AllSubRTs = [AllSubRTs remainRT];
        
%         figure; 
%         subplot(1,2,1);
%         scatter(1:length(remainRT),remainRT);
%         subplot(1,2,2);
%         hist(remainRT);
%         
%         eval(['saveas(gcf,''Sub' num2str(a) 'block' num2str(b) 'RTscatter.jpg'');']);
%         close(gcf);
%         
        
        for i = 1:length(rtypes_rttrimed) %reminder: potential issue with duplicate rt entries
            index = rtypes_rttrimed(i,1); %get the trial no. of each presses (excluding noresp)
            response_time = rtypes_rttrimed(i,3);
            
            targetid=StimR(index,1) ; %target id: 1, 2, 501, 502
            distractorid=StimR(index,2) ; %distractor id: 201, 202, 203, 701, 702, 703
            gcid = StimR(index,3); %Specifies whether the target is gray (1) or color (2)
            tdisid = StimR(index,4); %Specifies whether the distractor is the same (1) as target or different (2)
            
            
            if rtypes_rttrimed(i,2) ==1 %subject pressed "same" response
                
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                        
                        correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123; targetid = 1
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                                                       
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color gabors
                        
                        correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                        
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color
                        
                        if  targetid == 501 && distractorid == 703
                            
                             allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                             fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703
                            
                             allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                  
                            fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
                
            elseif rtypes_rttrimed(i,2) ==2 %subject pressed "diff" response
                
                
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray
                        correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                        
                        
                        if  targetid ==1 && distractorid == 203
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            distractor_rts_gc_angles{1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else % color
                        
                        correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                        
                        
                        if  targetid ==501 && distractorid == 703
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                       
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                        
                    end
                    
                elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray
                        
                        if  distractorid == 201
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                           
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                             
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else %color
                        
                        if  distractorid == 701
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
            else
            end
        end
        
        
        
    end
    
    
    % 360 trials for 3 blocks
    accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1}); % first
    %parameter: color/gray; 2nd: hit/cr
    accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2});
    accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1});
    accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2});
    
    % Correct rejection rate
    acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/(length(distractor_rts_gc_angles{1,1}) + length(fa_rts_gc_angles{1,1}))*100;
    acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/(length(distractor_rts_gc_angles{1,2}) + length(fa_rts_gc_angles{1,2}))*100;
    acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/(length(distractor_rts_gc_angles{2,1}) + length(fa_rts_gc_angles{2,1}))*100;
    acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/(length(distractor_rts_gc_angles{2,2}) + length(fa_rts_gc_angles{2,2}))*100;
    
    % Hit rate
    acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/(length(target_rts_gc_angles{1,1})+ length(miss_rts_gc_angles{1,1})) *100;
    acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/(length(target_rts_gc_angles{1,2})+ length(miss_rts_gc_angles{1,2}))*100;
    acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/(length(target_rts_gc_angles{2,1})+ length(miss_rts_gc_angles{2,1}))*100;
    acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/(length(target_rts_gc_angles{2,2})+ length(miss_rts_gc_angles{2,2}))*100;
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/(length(allrt_sum{1,1}))*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/(length(allrt_sum{1,2}))*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/(length(allrt_sum{2,1}))*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/(length(allrt_sum{2,2}))*100;
    
    % RT collapsed across hit and correj
    rt_hit_corr_sum{1,1} = [distractor_rts_gc_angles{1,1} target_rts_gc_angles{1,1}];
    rt_hit_corr_sum{1,2} = [distractor_rts_gc_angles{1,2} target_rts_gc_angles{1,2}];
    rt_hit_corr_sum{2,1} = [distractor_rts_gc_angles{2,1} target_rts_gc_angles{2,1}];
    rt_hit_corr_sum{2,2} = [distractor_rts_gc_angles{2,2} target_rts_gc_angles{2,2}];
    
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
    
    
    
    % RT trimming - has already been done at line 187
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = correct_rts_gc_tdis{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             correct_rts_gc_tdis{a1,a2} = tt(tindex);
%         end
%     end
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = target_rts_gc_angles{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             target_rts_gc_angles{a1,a2} = tt(tindex);
%         end
%     end
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = distractor_rts_gc_angles{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             distractor_rts_gc_angles{a1,a2} = tt(tindex);
%         end
%     end
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = rt_hit_corr_sum{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             rt_hit_corr_sum{a1,a2} = tt(tindex);
%         end
%     end
    
    
    %
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
    
    %accuracy collapsed across hit and correct rej
    acc_hitcorr = [acc_hitcorr;a acc_hit_corr_sum{1,1} acc_hit_corr_sum{1,2} acc_hit_corr_sum{2,1} acc_hit_corr_sum{2,2}];
    
    %rt collapsed across hit and correct rej
    rt_hitcorr = [rt_hitcorr;a mean(rt_hit_corr_sum{1,1}) mean(rt_hit_corr_sum{1,2}) mean(rt_hit_corr_sum{2,1}) mean(rt_hit_corr_sum{2,2})];
    
    %all rts (including correct and incorrect rts)
    allRTs = [allRTs;a mean(allrt_sum{1,1}) mean(allrt_sum{1,2}) mean(allrt_sum{2,1}) mean(allrt_sum{2,2})];
end

Pre.Acc = all_acc;
Pre.RT = all_rts;
Pre.HitAcc = hit_acc;
Pre.HitRT = Hit_rt;
Pre.CRAcc = correj_acc;
Pre.CRRT = Correj_rt;
Pre.dprime = d_prime;

Pre.HCacc = acc_hitcorr;
Pre.HCrt = rt_hitcorr;

Pre.allRT = allRTs;

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[], 'allrt', []);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

for i = 1:length(Pre.Acc)
    subid = Pre.Acc(i,1);
    
    if rem(subid,2)==1
        
        %if subno is odd, T1 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Pre.HitAcc(i,2)];
        gCSp.HitRT = [gCSp.HitRT; subid Pre.HitRT(i,2)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Pre.CRAcc(i,2)];
        gCSp.CRRT = [gCSp.CRRT; subid Pre.CRRT(i,2)];
        gCSp.dprime = [gCSp.dprime; subid Pre.dprime(i,2)];
        gCSp.HCacc = [gCSp.HCacc; subid Pre.HCacc(i,2)];
        gCSp.HCrt = [gCSp.HCrt; subid Pre.HCrt(i,2)];
        gCSp.allrt = [gCSp.allrt; subid Pre.allRT(i,2)];
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,3)];
        gCSm.allrt = [gCSm.allrt; subid Pre.allRT(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,4)];
        cCSp.allrt = [cCSp.allrt; subid Pre.allRT(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,5)];
        cCSm.allrt = [cCSm.allrt; subid Pre.allRT(i,5)];       
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,2)];
        gCSm.allrt = [gCSm.allrt; subid Pre.allRT(i,2)];
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Pre.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Pre.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Pre.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Pre.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Pre.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Pre.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Pre.HCrt(i,3)];
        gCSp.allrt = [gCSp.allrt; subid Pre.allRT(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,4)];
        cCSm.allrt = [cCSm.allrt; subid Pre.allRT(i,4)];       
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,5)];
        cCSp.allrt = [cCSp.allrt; subid Pre.allRT(i,5)];
        
    end
    
    
end

%Final tally with CS+/CS- arrangement
Pre.HitAccAll = [Pre.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Pre.HitRTAll = [Pre.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Pre.CRAccAll = [Pre.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Pre.CRRTAll = [Pre.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Pre.dprimeAll = [Pre.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

Pre.HCacc = [Pre.Acc(:,1) gCSp.HCacc(:,2) gCSm.HCacc(:,2) cCSp.HCacc(:,2) cCSm.HCacc(:,2) gCSp.HCacc(:,2)-gCSm.HCacc(:,2) cCSp.HCacc(:,2)-cCSm.HCacc(:,2)];
Pre.HCrt = [Pre.Acc(:,1) gCSp.HCrt(:,2) gCSm.HCrt(:,2) cCSp.HCrt(:,2) cCSm.HCrt(:,2) gCSp.HCrt(:,2)-gCSm.HCrt(:,2) cCSp.HCrt(:,2)-cCSm.HCrt(:,2)];

Pre.allrt = [Pre.Acc(:,1) gCSp.allrt(:,2) gCSm.allrt(:,2) cCSp.allrt(:,2) cCSm.allrt(:,2) gCSp.allrt(:,2)-gCSm.allrt(:,2) cCSp.allrt(:,2)-cCSm.allrt(:,2)];


%% Accuracy and RTs broken down by angle - Preconditioning - blocks 1 - 3
%% For each block individually
%outputs: Pre.Acc, Pre.RT, Pre.HitAcc, Pre.HitRT, Pre.CRAcc, Pre.CRRT,
%Pre.dprime
%last updated 07/16/15

allsubs = ExpStatus(find(ExpStatus(:,2) ==1 | ExpStatus(:,2) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==30)=[];
allsubs(allsubs ==35)=[];
allsubs(allsubs ==36)=[];

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];

Correj_rt = [];
Hit_rt = [];

d_prime = [];

acc_hitcorr = [];
rt_hitcorr = [];

allresponseTime = [];

allRTs = [];
AllSubRTs = [];

for a = allsubs;
    
    initials = subinitials(a,:);
    
    acc_trials = [];
    correct_rts = [];
    
    correct_rts_gc_tdis = cell(2,2);% overall accurate trials, including both hit and cor rej
    accuracy_gc_tdis = cell(2,2); % this saves the accuracy by taking the length of the corresponding cells above
    
    distractor_rts_gc_angles = cell(2,2); %this saves the correct rts for correct rejection, with two target angles
    target_rts_gc_angles = cell(2,2);%this saves the correct rts for hit, with two target angles
    
    fa_rts_gc_angles = cell(2,2); %this saves the rts for false alarm
    miss_rts_gc_angles = cell(2,2); %this saves the rts for miss
    
    acc_distractor_gc_angles = cell(2,2);
    acc_target_gc_angles = cell(2,2);
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    allrt_sum = cell(2,2); %this measures all rts (both correct and incorrect); 1st index, gray vs. color; 2nd index, Target1 vs. Target2 
    
    
    for b = 3%:3
        
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' StimR allresp rtypes;']);
        
        allresponseTime = allresp(rtypes(:,1)); %find out all trials that has a non-NaN RT
        rtypes_new = [rtypes allresponseTime']; %append it to the rtypes matrix
        
        %try outlier exclusion by Q75 > 1.5*(Q75-Q25) %071515
        % Q25 = quantile(allresponseTime,0.25); Q75 = quantile(allresponseTime,0.75);
        % rtindex = allresponseTime < (Q75 + 1.5*(Q75-Q25)) | allresponseTime > (Q25 - 1.5*(Q75-Q25)) ;         
        
        %rt exclusion: mean +- 3sd %try mean+-3sd trimming 040115;
        rtindex = allresponseTime > (mean(allresponseTime) - 3*std(allresponseTime)) & (allresponseTime < mean(allresponseTime) + 3*std(allresponseTime)); %try mean+-3sd trimming 040115; find out the RTs that are > 100 and < mean + 2sd

        rtypes_rttrimed = rtypes_new(rtindex,:); %generate rtypes matrix that removed trimmed RTs.
        
        remainRT = allresponseTime(rtindex);
        
        AllSubRTs = [AllSubRTs remainRT];
        
%         figure; 
%         subplot(1,2,1);
%         scatter(1:length(remainRT),remainRT);
%         subplot(1,2,2);
%         hist(remainRT);
%         
%         eval(['saveas(gcf,''Sub' num2str(a) 'block' num2str(b) 'RTscatter.jpg'');']);
%         close(gcf);
%         
        
        for i = 1:length(rtypes_rttrimed) %reminder: potential issue with duplicate rt entries
            index = rtypes_rttrimed(i,1); %get the trial no. of each presses (excluding noresp)
            response_time = rtypes_rttrimed(i,3);
            
            targetid=StimR(index,1) ; %target id: 1, 2, 501, 502
            distractorid=StimR(index,2) ; %distractor id: 201, 202, 203, 701, 702, 703
            gcid = StimR(index,3); %Specifies whether the target is gray (1) or color (2)
            tdisid = StimR(index,4); %Specifies whether the distractor is the same (1) as target or different (2)
            
            
            if rtypes_rttrimed(i,2) ==1 %subject pressed "same" response
                
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                        
                        correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123; targetid = 1
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                                                       
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color gabors
                        
                        correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                        
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color
                        
                        if  targetid == 501 && distractorid == 703
                            
                             allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                             fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703
                            
                             allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                  
                            fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
                
            elseif rtypes_rttrimed(i,2) ==2 %subject pressed "diff" response
                
                
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray
                        correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                        
                        
                        if  targetid ==1 && distractorid == 203
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            distractor_rts_gc_angles{1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else % color
                        
                        correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                        
                        
                        if  targetid ==501 && distractorid == 703
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                       
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                        
                    end
                    
                elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray
                        
                        if  distractorid == 201
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                           
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                             
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else %color
                        
                        if  distractorid == 701
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
            else
            end
        end
        
        
  accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1}); % first
    %parameter: color/gray; 2nd: hit/cr
    accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2});
    accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1});
    accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2});
    
    % Correct rejection rate
    acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/(length(distractor_rts_gc_angles{1,1}) + length(fa_rts_gc_angles{1,1}))*100;
    acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/(length(distractor_rts_gc_angles{1,2}) + length(fa_rts_gc_angles{1,2}))*100;
    acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/(length(distractor_rts_gc_angles{2,1}) + length(fa_rts_gc_angles{2,1}))*100;
    acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/(length(distractor_rts_gc_angles{2,2}) + length(fa_rts_gc_angles{2,2}))*100;
    
    % Hit rate
    acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/(length(target_rts_gc_angles{1,1})+ length(miss_rts_gc_angles{1,1})) *100;
    acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/(length(target_rts_gc_angles{1,2})+ length(miss_rts_gc_angles{1,2}))*100;
    acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/(length(target_rts_gc_angles{2,1})+ length(miss_rts_gc_angles{2,1}))*100;
    acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/(length(target_rts_gc_angles{2,2})+ length(miss_rts_gc_angles{2,2}))*100;
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/(length(allrt_sum{1,1}))*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/(length(allrt_sum{1,2}))*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/(length(allrt_sum{2,1}))*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/(length(allrt_sum{2,2}))*100;
    
    % RT collapsed across hit and correj
    rt_hit_corr_sum{1,1} = [distractor_rts_gc_angles{1,1} target_rts_gc_angles{1,1}];
    rt_hit_corr_sum{1,2} = [distractor_rts_gc_angles{1,2} target_rts_gc_angles{1,2}];
    rt_hit_corr_sum{2,1} = [distractor_rts_gc_angles{2,1} target_rts_gc_angles{2,1}];
    rt_hit_corr_sum{2,2} = [distractor_rts_gc_angles{2,2} target_rts_gc_angles{2,2}];
    
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
    
    
    %
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
    
    %accuracy collapsed across hit and correct rej
    acc_hitcorr = [acc_hitcorr;a acc_hit_corr_sum{1,1} acc_hit_corr_sum{1,2} acc_hit_corr_sum{2,1} acc_hit_corr_sum{2,2}];
    
    %rt collapsed across hit and correct rej
    rt_hitcorr = [rt_hitcorr;a mean(rt_hit_corr_sum{1,1}) mean(rt_hit_corr_sum{1,2}) mean(rt_hit_corr_sum{2,1}) mean(rt_hit_corr_sum{2,2})];
    
    %all rts (including correct and incorrect rts)
    allRTs = [allRTs;a mean(allrt_sum{1,1}) mean(allrt_sum{1,2}) mean(allrt_sum{2,1}) mean(allrt_sum{2,2})];

        
        
    end
end
    


Pre.Acc = all_acc;
Pre.RT = all_rts;
Pre.HitAcc = hit_acc;
Pre.HitRT = Hit_rt;
Pre.CRAcc = correj_acc;
Pre.CRRT = Correj_rt;
Pre.dprime = d_prime;

Pre.HCacc = acc_hitcorr;
Pre.HCrt = rt_hitcorr;

Pre.allRT = allRTs;

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[], 'allrt', []);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

for i = 1:length(Pre.Acc)
    subid = Pre.Acc(i,1);
    
    if rem(subid,2)==1
        
        %if subno is odd, T1 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Pre.HitAcc(i,2)];
        gCSp.HitRT = [gCSp.HitRT; subid Pre.HitRT(i,2)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Pre.CRAcc(i,2)];
        gCSp.CRRT = [gCSp.CRRT; subid Pre.CRRT(i,2)];
        gCSp.dprime = [gCSp.dprime; subid Pre.dprime(i,2)];
        gCSp.HCacc = [gCSp.HCacc; subid Pre.HCacc(i,2)];
        gCSp.HCrt = [gCSp.HCrt; subid Pre.HCrt(i,2)];
        gCSp.allrt = [gCSp.allrt; subid Pre.allRT(i,2)];
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,3)];
        gCSm.allrt = [gCSm.allrt; subid Pre.allRT(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,4)];
        cCSp.allrt = [cCSp.allrt; subid Pre.allRT(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,5)];
        cCSm.allrt = [cCSm.allrt; subid Pre.allRT(i,5)];       
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,2)];
        gCSm.allrt = [gCSm.allrt; subid Pre.allRT(i,2)];
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Pre.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Pre.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Pre.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Pre.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Pre.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Pre.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Pre.HCrt(i,3)];
        gCSp.allrt = [gCSp.allrt; subid Pre.allRT(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,4)];
        cCSm.allrt = [cCSm.allrt; subid Pre.allRT(i,4)];       
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,5)];
        cCSp.allrt = [cCSp.allrt; subid Pre.allRT(i,5)];
        
    end
    
    
end

%Final tally with CS+/CS- arrangement
Pre.HitAccAll = [Pre.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Pre.HitRTAll = [Pre.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Pre.CRAccAll = [Pre.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Pre.CRRTAll = [Pre.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Pre.dprimeAll = [Pre.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

Pre.HCacc = [Pre.Acc(:,1) gCSp.HCacc(:,2) gCSm.HCacc(:,2) cCSp.HCacc(:,2) cCSm.HCacc(:,2) gCSp.HCacc(:,2)-gCSm.HCacc(:,2) cCSp.HCacc(:,2)-cCSm.HCacc(:,2)];
Pre.HCrt = [Pre.Acc(:,1) gCSp.HCrt(:,2) gCSm.HCrt(:,2) cCSp.HCrt(:,2) cCSm.HCrt(:,2) gCSp.HCrt(:,2)-gCSm.HCrt(:,2) cCSp.HCrt(:,2)-cCSm.HCrt(:,2)];

Pre.allrt = [Pre.Acc(:,1) gCSp.allrt(:,2) gCSm.allrt(:,2) cCSp.allrt(:,2) cCSm.allrt(:,2) gCSp.allrt(:,2)-gCSm.allrt(:,2) cCSp.allrt(:,2)-cCSm.allrt(:,2)];        
        
        
%% Accuracy and RTs broken down by angle - Postconditioning1 - blocks 4,5,6
%outputs: Post1.Acc, Post1.RT, Post1.HitAcc, Post1.HitRT, Post1.CRAcc, Post1.CRRT,
%Post1.dprime
allsubs = ExpStatus(find(ExpStatus(:,2) ==1 | ExpStatus(:,2) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==30)=[];
allsubs(allsubs ==35)=[];
allsubs(allsubs ==36)=[];
% allsubs(allsubs ==15)=[];
% allsubs(allsubs ==56)=[];

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];


acc_hitcorr = [];
rt_hitcorr = [];

allRTs = [];

AllSubRTs = [];


for a = allsubs;
    
    if a == 15 || a ==56
        bs = 4:5;
    else
        bs = 4:6;
    end
%    bs = 6;
    
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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    allrt_sum = cell(2,2); %this measures all rts (both correct and incorrect)
    
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
        
        indexn = [];
        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
            index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)
            indexn(i) = indM(indM(:,1)==index,2);        
        end
        
        allresponseTime = allresp(indexn); %find out all trials that has a non-NaN RT
        rtypes_new = [rtypes(:,1) indexn' rtypes(:,2) allresponseTime']; %append it to the rtypes matrix
        
        %try outlier exclusion by Q75 > 1.5*(Q75-Q25) %071515
       % Q25 = quantile(allresponseTime,0.25); Q75 = quantile(allresponseTime,0.75);
       % rtindex = allresponseTime < (Q75 + 1.5*(Q75-Q25)) | allresponseTime > (Q25 - 1.5*(Q75-Q25)) ;           
        
        rtindex = allresponseTime > (mean(allresponseTime) - 3*std(allresponseTime)) & allresponseTime < (mean(allresponseTime) + 3*std(allresponseTime)); %try mean+-3sd trimming 040115; find out the RTs that are > 100 and < mean + 2sd
        rtypes_rttrimed = rtypes_new(rtindex',:); %generate rtypes matrix that removed trimmed RTs.        
        
        remainRT = allresponseTime(rtindex);
        
        AllSubRTs = [AllSubRTs remainRT];   
        
%         figure; 
%         subplot(1,2,1);
%         scatter(1:length(remainRT),remainRT);
%         subplot(1,2,2);
%         hist(remainRT);
%         
%         eval(['saveas(gcf,''Sub' num2str(a) 'block' num2str(b) 'RTscatter.jpg'');']);
%         close(gcf);        
        
        
        for i = 1:length(rtypes_rttrimed) %reminder: potential issue with duplicate rt entries
            index = rtypes_rttrimed(i,1); %old index that corresponds to StimR
            response_time = rtypes_rttrimed(i,4);
            
            targetid=StimR(index,1) ; %Specifies which of the IAPS images in sequence
            distractorid=StimR(index,2) ; %Specifies which of the emo conditions is presented
            gcid = StimR(index,3); %Specifies whether the target is gray or color
            tdisid = StimR(index,4); %Specifies whether the distractor is the same as target or different
            
            
            if rtypes_rttrimed(i,3) ==1 %subject pressed "same" response
                
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                        
                        correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123; targetid = 1
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color gabors
                        
                        correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                        
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color
                        
                        if  targetid == 501 && distractorid == 703
                            
                           allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                           fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703
                                                                                                                                                                                                                                                                    
                           allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                  
                           fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
                
            elseif rtypes_rttrimed(i,3) ==2 %subject pressed "diff" response
                
                
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray
                        correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                        
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            distractor_rts_gc_angles{1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else % color
                        
                        correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                        
                        
                        if  targetid ==501 && distractorid == 703
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                        
                    end
                    
                elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray
                        
                        if  distractorid == 201
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];   
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                             
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else %color
                        
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                   
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
            else
            end
        end
        
        
        
    end
    
    %for sub 15 that only did two blocks (240 trials)
    accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1});
    accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2});
    accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1});
    accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2});
    
    % Correct rejection rate
    acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/(length(distractor_rts_gc_angles{1,1}) + length(fa_rts_gc_angles{1,1}))*100;
    acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/(length(distractor_rts_gc_angles{1,2}) + length(fa_rts_gc_angles{1,2}))*100;
    acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/(length(distractor_rts_gc_angles{2,1}) + length(fa_rts_gc_angles{2,1}))*100;
    acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/(length(distractor_rts_gc_angles{2,2}) + length(fa_rts_gc_angles{2,2}))*100;
    
    % Hit rate
    acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/(length(target_rts_gc_angles{1,1})+ length(miss_rts_gc_angles{1,1})) *100;
    acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/(length(target_rts_gc_angles{1,2})+ length(miss_rts_gc_angles{1,2}))*100;
    acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/(length(target_rts_gc_angles{2,1})+ length(miss_rts_gc_angles{2,1}))*100;
    acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/(length(target_rts_gc_angles{2,2})+ length(miss_rts_gc_angles{2,2}))*100;
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/(length(allrt_sum{1,1}))*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/(length(allrt_sum{1,2}))*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/(length(allrt_sum{2,1}))*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/(length(allrt_sum{2,2}))*100;
    
    
    % RT collapsed across hit and correj
    rt_hit_corr_sum{1,1} = [distractor_rts_gc_angles{1,1} target_rts_gc_angles{1,1}];
    rt_hit_corr_sum{1,2} = [distractor_rts_gc_angles{1,2} target_rts_gc_angles{1,2}];
    rt_hit_corr_sum{2,1} = [distractor_rts_gc_angles{2,1} target_rts_gc_angles{2,1}];
    rt_hit_corr_sum{2,2} = [distractor_rts_gc_angles{2,2} target_rts_gc_angles{2,2}];
    
    
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
    
    
%     % RT trimming
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = correct_rts_gc_tdis{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             correct_rts_gc_tdis{a1,a2} = tt(tindex);
%         end
%     end
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = target_rts_gc_angles{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             target_rts_gc_angles{a1,a2} = tt(tindex);
%         end
%     end
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = distractor_rts_gc_angles{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             distractor_rts_gc_angles{a1,a2} = tt(tindex);
%         end
%     end
%     
%     
%     for a1 = 1:2
%         for a2 = 1:2
%             tt = rt_hit_corr_sum{a1,a2};
%             tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
%             rt_hit_corr_sum{a1,a2} = tt(tindex);
%         end
%     end
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
    
    %accuracy collapsed across hit and correct rej
    acc_hitcorr = [acc_hitcorr;a acc_hit_corr_sum{1,1} acc_hit_corr_sum{1,2} acc_hit_corr_sum{2,1} acc_hit_corr_sum{2,2}];
    
    %rt collapsed across hit and correct rej
    rt_hitcorr = [rt_hitcorr;a mean(rt_hit_corr_sum{1,1}) mean(rt_hit_corr_sum{1,2}) mean(rt_hit_corr_sum{2,1}) mean(rt_hit_corr_sum{2,2})];
    
     %all rts (including correct and incorrect rts)
    allRTs = [allRTs;a mean(allrt_sum{1,1}) mean(allrt_sum{1,2}) mean(allrt_sum{2,1}) mean(allrt_sum{2,2})];   
end


Post1.Acc = all_acc;
Post1.RT = all_rts;
Post1.HitAcc = hit_acc;
Post1.HitRT = Hit_rt;
Post1.CRAcc = correj_acc;
Post1.CRRT = Correj_rt;
Post1.dprime = d_prime;

Post1.HCacc = acc_hitcorr;
Post1.HCrt = rt_hitcorr;

Post1.allRT = allRTs;


% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[], 'allrt', []);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);


for i = 1:length(Post1.Acc)
    subid = Post1.Acc(i,1);
    
    if rem(subid,2)==1
        
        %if subno is odd, T1 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post1.HitAcc(i,2)];
        gCSp.HitRT = [gCSp.HitRT; subid Post1.HitRT(i,2)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post1.CRAcc(i,2)];
        gCSp.CRRT = [gCSp.CRRT; subid Post1.CRRT(i,2)];
        gCSp.dprime = [gCSp.dprime; subid Post1.dprime(i,2)];
        gCSp.HCacc = [gCSp.HCacc; subid Post1.HCacc(i,2)];
        gCSp.HCrt = [gCSp.HCrt; subid Post1.HCrt(i,2)];
        gCSp.allrt = [gCSp.allrt; subid Post1.allRT(i,2)];
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,3)];
        gCSm.allrt = [gCSm.allrt; subid Post1.allRT(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,4)];
        cCSp.allrt = [cCSp.allrt; subid Post1.allRT(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,5)];
        cCSm.allrt = [cCSm.allrt; subid Post1.allRT(i,5)];
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,2)];
        gCSm.allrt = [gCSm.allrt; subid Post1.allRT(i,2)];
        
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post1.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Post1.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post1.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Post1.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Post1.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Post1.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Post1.HCrt(i,3)];
        gCSp.allrt = [gCSp.allrt; subid Post1.allRT(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,4)];
        cCSm.allrt = [cCSm.allrt; subid Post1.allRT(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,5)];
        cCSp.allrt = [cCSp.allrt; subid Post1.allRT(i,5)];
        
    end
    
    
end

%Finaly tally with CS+/CS- arrangement
Post1.HitAccAll = [Post1.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Post1.HitRTAll = [Post1.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Post1.CRAccAll = [Post1.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Post1.CRRTAll = [Post1.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Post1.dprimeAll = [Post1.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

Post1.HCacc = [Post1.Acc(:,1) gCSp.HCacc(:,2) gCSm.HCacc(:,2) cCSp.HCacc(:,2) cCSm.HCacc(:,2) gCSp.HCacc(:,2)-gCSm.HCacc(:,2) cCSp.HCacc(:,2)-cCSm.HCacc(:,2)];
Post1.HCrt = [Post1.Acc(:,1) gCSp.HCrt(:,2) gCSm.HCrt(:,2) cCSp.HCrt(:,2) cCSm.HCrt(:,2) gCSp.HCrt(:,2)-gCSm.HCrt(:,2) cCSp.HCrt(:,2)-cCSm.HCrt(:,2)];

Post1.allrt = [Post1.Acc(:,1) gCSp.allrt(:,2) gCSm.allrt(:,2) cCSp.allrt(:,2) cCSm.allrt(:,2) gCSp.allrt(:,2)-gCSm.allrt(:,2) cCSp.allrt(:,2)-cCSm.allrt(:,2)];

            
%% Accuracy and RTs broken down by angle - Postconditioning1 - blocks 4,5,6
% individual blocks
%outputs: Post1.Acc, Post1.RT, Post1.HitAcc, Post1.HitRT, Post1.CRAcc, Post1.CRRT,
%Post1.dprime
allsubs = ExpStatus(find(ExpStatus(:,2) ==1 | ExpStatus(:,2) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==30)=[];
allsubs(allsubs ==35)=[];
allsubs(allsubs ==36)=[];
 allsubs(allsubs ==15)=[];
 allsubs(allsubs ==56)=[];

all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];


acc_hitcorr = [];
rt_hitcorr = [];

allRTs = [];

AllSubRTs = [];


for a = allsubs;
    
    if a == 15 || a ==56
        bs = 4:5;
    else
        bs = 4:6;
    end
%    bs = 6;
    
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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    allrt_sum = cell(2,2); %this measures all rts (both correct and incorrect)
    
    rmat4 = [1,2,3,5,6,8,9,11,12,13,15,16,17,18,19,20,21,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,90,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,117,118,119,121,122,123,124,125,126,128,129,130,131,132,133,134,135];
    rmat5 = [1,2,4,5,7,8,9,11,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,40,41,42,43,44,45,47,48,49,50,51,52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69,70,71,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135;];
    rmat6 = [1,3,4,5,7,8,10,12,13,14,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53,54,55,57,58,59,60,61,62,63,64,65,66,68,69,70,71,72,73,74,75,76,77,78,79,80,81,83,84,85,86,87,88,89,90,91,92,93,94,96,97,98,99,100,101,102,103,104,105,106,108,109,110,111,112,113,114,115,117,118,119,120,121,123,124,125,126,127,128,129,130,131,132,133,134,135;];
    
    for b = 6%bs
        
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' StimR allresp rtypes;']);
        
        if b == 4
            indM = [rmat4' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==5
            indM = [rmat5' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==6
            indM = [rmat6' (1:120)']; %convert the 135-trial position to 120-trial position
        end
        
        indexn = [];
        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
            index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)
            indexn(i) = indM(indM(:,1)==index,2);        
        end
        
        allresponseTime = allresp(indexn); %find out all trials that has a non-NaN RT
        rtypes_new = [rtypes(:,1) indexn' rtypes(:,2) allresponseTime']; %append it to the rtypes matrix
        
        %try outlier exclusion by Q75 > 1.5*(Q75-Q25) %071515
      %  Q25 = quantile(allresponseTime,0.25); Q75 = quantile(allresponseTime,0.75);
      %  rtindex = allresponseTime < (Q75 + 1.5*(Q75-Q25)) | allresponseTime > (Q25 - 1.5*(Q75-Q25)) ;           
        
        rtindex = allresponseTime > (mean(allresponseTime) - 3*std(allresponseTime)) & allresponseTime < (mean(allresponseTime) + 3*std(allresponseTime)); %try mean+-3sd trimming 040115; find out the RTs that are > 100 and < mean + 2sd
        rtypes_rttrimed = rtypes_new(rtindex',:); %generate rtypes matrix that removed trimmed RTs.        
        
        remainRT = allresponseTime(rtindex);
        
        AllSubRTs = [AllSubRTs remainRT];   
        
%         figure; 
%         subplot(1,2,1);
%         scatter(1:length(remainRT),remainRT);
%         subplot(1,2,2);
%         hist(remainRT);
%         
%         eval(['saveas(gcf,''Sub' num2str(a) 'block' num2str(b) 'RTscatter.jpg'');']);
%         close(gcf);        
        
        
        for i = 1:length(rtypes_rttrimed) %reminder: potential issue with duplicate rt entries
            index = rtypes_rttrimed(i,1); %old index that corresponds to StimR
            response_time = rtypes_rttrimed(i,4);
            
            targetid=StimR(index,1) ; %Specifies which of the IAPS images in sequence
            distractorid=StimR(index,2) ; %Specifies which of the emo conditions is presented
            gcid = StimR(index,3); %Specifies whether the target is gray or color
            tdisid = StimR(index,4); %Specifies whether the distractor is the same as target or different
            
            
            if rtypes_rttrimed(i,3) ==1 %subject pressed "same" response
                
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                        
                        correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123; targetid = 1
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color gabors
                        
                        correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                        
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color
                        
                        if  targetid == 501 && distractorid == 703
                            
                           allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                           fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703
                                                                                                                                                                                                                                                                    
                           allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                  
                           fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
                
            elseif rtypes_rttrimed(i,3) ==2 %subject pressed "diff" response
                
                
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray
                        correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                        
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            distractor_rts_gc_angles{1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else % color
                        
                        correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                        
                        
                        if  targetid ==501 && distractorid == 703
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                        
                    end
                    
                elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray
                        
                        if  distractorid == 201
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];   
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                             
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else %color
                        
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                   
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
            else
            end
        end
        
        
        
    
    
    %for sub 15 that only did two blocks (240 trials)
    accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1});
    accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2});
    accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1});
    accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2});
    
    % Correct rejection rate
    acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/(length(distractor_rts_gc_angles{1,1}) + length(fa_rts_gc_angles{1,1}))*100;
    acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/(length(distractor_rts_gc_angles{1,2}) + length(fa_rts_gc_angles{1,2}))*100;
    acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/(length(distractor_rts_gc_angles{2,1}) + length(fa_rts_gc_angles{2,1}))*100;
    acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/(length(distractor_rts_gc_angles{2,2}) + length(fa_rts_gc_angles{2,2}))*100;
    
    % Hit rate
    acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/(length(target_rts_gc_angles{1,1})+ length(miss_rts_gc_angles{1,1})) *100;
    acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/(length(target_rts_gc_angles{1,2})+ length(miss_rts_gc_angles{1,2}))*100;
    acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/(length(target_rts_gc_angles{2,1})+ length(miss_rts_gc_angles{2,1}))*100;
    acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/(length(target_rts_gc_angles{2,2})+ length(miss_rts_gc_angles{2,2}))*100;
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/(length(allrt_sum{1,1}))*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/(length(allrt_sum{1,2}))*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/(length(allrt_sum{2,1}))*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/(length(allrt_sum{2,2}))*100;
    
    
    % RT collapsed across hit and correj
    rt_hit_corr_sum{1,1} = [distractor_rts_gc_angles{1,1} target_rts_gc_angles{1,1}];
    rt_hit_corr_sum{1,2} = [distractor_rts_gc_angles{1,2} target_rts_gc_angles{1,2}];
    rt_hit_corr_sum{2,1} = [distractor_rts_gc_angles{2,1} target_rts_gc_angles{2,1}];
    rt_hit_corr_sum{2,2} = [distractor_rts_gc_angles{2,2} target_rts_gc_angles{2,2}];
    
    
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
    
    %accuracy collapsed across hit and correct rej
    acc_hitcorr = [acc_hitcorr;a acc_hit_corr_sum{1,1} acc_hit_corr_sum{1,2} acc_hit_corr_sum{2,1} acc_hit_corr_sum{2,2}];
    
    %rt collapsed across hit and correct rej
    rt_hitcorr = [rt_hitcorr;a mean(rt_hit_corr_sum{1,1}) mean(rt_hit_corr_sum{1,2}) mean(rt_hit_corr_sum{2,1}) mean(rt_hit_corr_sum{2,2})];
    
     %all rts (including correct and incorrect rts)
    allRTs = [allRTs;a mean(allrt_sum{1,1}) mean(allrt_sum{1,2}) mean(allrt_sum{2,1}) mean(allrt_sum{2,2})];  
    end
end


Post1.Acc = all_acc;
Post1.RT = all_rts;
Post1.HitAcc = hit_acc;
Post1.HitRT = Hit_rt;
Post1.CRAcc = correj_acc;
Post1.CRRT = Correj_rt;
Post1.dprime = d_prime;

Post1.HCacc = acc_hitcorr;
Post1.HCrt = rt_hitcorr;

Post1.allRT = allRTs;


% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[], 'allrt', []);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);


for i = 1:length(Post1.Acc)
    subid = Post1.Acc(i,1);
    
    if rem(subid,2)==1
        
        %if subno is odd, T1 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post1.HitAcc(i,2)];
        gCSp.HitRT = [gCSp.HitRT; subid Post1.HitRT(i,2)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post1.CRAcc(i,2)];
        gCSp.CRRT = [gCSp.CRRT; subid Post1.CRRT(i,2)];
        gCSp.dprime = [gCSp.dprime; subid Post1.dprime(i,2)];
        gCSp.HCacc = [gCSp.HCacc; subid Post1.HCacc(i,2)];
        gCSp.HCrt = [gCSp.HCrt; subid Post1.HCrt(i,2)];
        gCSp.allrt = [gCSp.allrt; subid Post1.allRT(i,2)];
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,3)];
        gCSm.allrt = [gCSm.allrt; subid Post1.allRT(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,4)];
        cCSp.allrt = [cCSp.allrt; subid Post1.allRT(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,5)];
        cCSm.allrt = [cCSm.allrt; subid Post1.allRT(i,5)];
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,2)];
        gCSm.allrt = [gCSm.allrt; subid Post1.allRT(i,2)];
        
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post1.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Post1.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post1.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Post1.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Post1.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Post1.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Post1.HCrt(i,3)];
        gCSp.allrt = [gCSp.allrt; subid Post1.allRT(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,4)];
        cCSm.allrt = [cCSm.allrt; subid Post1.allRT(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,5)];
        cCSp.allrt = [cCSp.allrt; subid Post1.allRT(i,5)];
        
    end
    
    
end

%Finaly tally with CS+/CS- arrangement
Post1.HitAccAll = [Post1.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Post1.HitRTAll = [Post1.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Post1.CRAccAll = [Post1.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Post1.CRRTAll = [Post1.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Post1.dprimeAll = [Post1.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

Post1.HCacc = [Post1.Acc(:,1) gCSp.HCacc(:,2) gCSm.HCacc(:,2) cCSp.HCacc(:,2) cCSm.HCacc(:,2) gCSp.HCacc(:,2)-gCSm.HCacc(:,2) cCSp.HCacc(:,2)-cCSm.HCacc(:,2)];
Post1.HCrt = [Post1.Acc(:,1) gCSp.HCrt(:,2) gCSm.HCrt(:,2) cCSp.HCrt(:,2) cCSm.HCrt(:,2) gCSp.HCrt(:,2)-gCSm.HCrt(:,2) cCSp.HCrt(:,2)-cCSm.HCrt(:,2)];

Post1.allrt = [Post1.Acc(:,1) gCSp.allrt(:,2) gCSm.allrt(:,2) cCSp.allrt(:,2) cCSm.allrt(:,2) gCSp.allrt(:,2)-gCSm.allrt(:,2) cCSp.allrt(:,2)-cCSm.allrt(:,2)];

            
    %% Accuracy and RTs broken down by angle - Postconditioning2 - blocks 4,5,6

%Choose subjects who completed session2
allsubs = ExpStatus(find(ExpStatus(:,4) ==1 | ExpStatus(:,4) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==35)=[];
%allsubs(allsubs ==10)=[];


all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];


acc_hitcorr = [];
rt_hitcorr = [];

allRTs = [];


AllSubRTs = [];

for a = allsubs;
    
    if a == 10
        bs = [4 6];
    else
        bs = 4:6;
    end
    %bs = 6;
    
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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    allrt_sum = cell(2,2); %this measures all rts (both correct and incorrect)
    
    rmat4 = [1,2,3,5,6,8,9,11,12,13,15,16,17,18,19,20,21,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,90,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,117,118,119,121,122,123,124,125,126,128,129,130,131,132,133,134,135];
    rmat5 = [1,2,4,5,7,8,9,11,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,40,41,42,43,44,45,47,48,49,50,51,52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69,70,71,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,90,91,92,93,94,95,96,97,98,99,100,101,102,103,105,106,107,108,109,110,111,112,114,115,116,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135;];
    rmat6 = [1,3,4,5,7,8,10,12,13,14,16,17,18,19,20,21,22,23,25,26,27,28,29,30,31,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,50,51,52,53,54,55,57,58,59,60,61,62,63,64,65,66,68,69,70,71,72,73,74,75,76,77,78,79,80,81,83,84,85,86,87,88,89,90,91,92,93,94,96,97,98,99,100,101,102,103,104,105,106,108,109,110,111,112,113,114,115,117,118,119,120,121,123,124,125,126,127,128,129,130,131,132,133,134,135;];
    
    for b = 6%bs
        
        eval(['load PLC_EEG_block' num2str(b) '_post_sub' num2str(a) '_' initials ' StimR allresp rtypes;']);
        
        if b == 4
            indM = [rmat4' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==5
            indM = [rmat5' (1:120)']; %convert the 135-trial position to 120-trial position
        elseif b ==6
            indM = [rmat6' (1:120)']; %convert the 135-trial position to 120-trial position
        end
        
        indexn = [];
        
        for i = 1:length(rtypes) %reminder: potential issue with duplicate rt entries
            index = rtypes(i,1); %get the trial no. of each presses (excluding noresp)
            indexn(i) = indM(indM(:,1)==index,2);        
        end
        
        allresponseTime = allresp(indexn); %find out all trials that has a non-NaN RT
        rtypes_new = [rtypes(:,1) indexn' rtypes(:,2) allresponseTime']; %append it to the rtypes matrix
        
        %try outlier exclusion by Q75 > 1.5*(Q75-Q25) %071515
        Q25 = quantile(allresponseTime,0.25); Q75 = quantile(allresponseTime,0.75);
      %  rtindex = allresponseTime < (Q75 + 1.5*(Q75-Q25)) | allresponseTime > (Q25 - 1.5*(Q75-Q25)) ;         
        
        rtindex = allresponseTime > (mean(allresponseTime) - 3*std(allresponseTime)) & allresponseTime < (mean(allresponseTime) + 3*std(allresponseTime)); %try mean+-3sd trimming 040115; find out the RTs that are > 100 and < mean + 2sd
        
        rtypes_rttrimed = rtypes_new(rtindex',:); %generate rtypes matrix that removed trimmed RTs.        
 
        remainRT = allresponseTime(rtindex);
        
        AllSubRTs = [AllSubRTs remainRT];
%         
%         figure; 
%         subplot(1,2,1);
%         scatter(1:length(remainRT),remainRT);
%         subplot(1,2,2);
%         hist(remainRT);
%         
%         eval(['saveas(gcf,''Sub' num2str(a) 'block' num2str(b) 'Post2RTscatter.jpg'');']);
%         close(gcf);              
        
        for i = 1:length(rtypes_rttrimed) %reminder: potential issue with duplicate rt entries
            index = rtypes_rttrimed(i,1); %old index that corresponds to StimR
            response_time = rtypes_rttrimed(i,4);
            
            targetid=StimR(index,1) ; %Specifies which of the IAPS images in sequence
            distractorid=StimR(index,2) ; %Specifies which of the emo conditions is presented
            gcid = StimR(index,3); %Specifies whether the target is gray or color
            tdisid = StimR(index,4); %Specifies whether the distractor is the same as target or different
            
            
            if rtypes_rttrimed(i,3) ==1 %subject pressed "same" response
                
                
                if tdisid==1 %the actual trial is the "same" trial -> "Hit"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid == 1 %gray gabors
                        
                        
                        correct_rts_gc_tdis{1,1} = [correct_rts_gc_tdis{1,1} response_time]; %hit RT for gray
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 201 %33, 123; targetid = 1
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            target_rts_gc_angles{1,1} = [target_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202 %57, 147
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                                                       
                            target_rts_gc_angles{1,2} = [target_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color gabors
                        
                        correct_rts_gc_tdis{2,1} = [correct_rts_gc_tdis{2,1} response_time]; %hit RT for color
                        
                        % different target angles: 33, 57 or 123, 147
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            target_rts_gc_angles{2,1} = [target_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                        
                            target_rts_gc_angles{2,2} = [target_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                elseif tdisid ==2 %the actual trial is the "diff" trial -> "False Alarm"
                    
                    if gcid == 1 %gray
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            fa_rts_gc_angles{1,1} = [fa_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid ==203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            fa_rts_gc_angles{1,2} = [fa_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                        
                    else %color
                        
                        if  targetid == 501 && distractorid == 703
                            
                             allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                             fa_rts_gc_angles{2,1} = [fa_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid ==703
                            
                             allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                   
                             fa_rts_gc_angles{2,2} = [fa_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
                
            elseif rtypes_rttrimed(i,3) ==2 %subject pressed "diff" response
                
                
                if tdisid==2 %the actual trial is the "diff" trial -> "Correct rejection"
                    acc_trials = [acc_trials i];
                    correct_rts = [correct_rts response_time];
                    
                    if gcid ==1 %gray
                        correct_rts_gc_tdis{1,2} = [correct_rts_gc_tdis{1,2} response_time]; %Correct rejection RT for gray
                        
                        
                        if  targetid ==1 && distractorid == 203
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];
                            distractor_rts_gc_angles {1,1} = [distractor_rts_gc_angles{1,1} response_time];
                            
                        elseif targetid ==2 && distractorid == 203
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                              
                            distractor_rts_gc_angles{1,2} = [distractor_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else % color
                        
                        correct_rts_gc_tdis{2,2} = [correct_rts_gc_tdis{2,2} response_time]; %Correct rejection RT for color
                        
                        
                        if  targetid ==501 && distractorid == 703
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                            
                            distractor_rts_gc_angles{2,1} = [distractor_rts_gc_angles{2,1} response_time];
                            
                        elseif targetid ==502 && distractorid == 703
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            distractor_rts_gc_angles{2,2} = [distractor_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                        
                    end
                    
                elseif tdisid ==1 %the actual trial is the "same" trial -> "Miss"
                    
                    if gcid == 1 %gray
                        
                        if  distractorid == 201
                            
                            allrt_sum{1,1} = [allrt_sum{1,1} response_time];                            
                            miss_rts_gc_angles{1,1} = [miss_rts_gc_angles{1,1} response_time];
                            
                        elseif distractorid ==202
                            
                            allrt_sum{1,2} = [allrt_sum{1,2} response_time];                             
                            miss_rts_gc_angles{1,2} = [miss_rts_gc_angles{1,2} response_time];
                            
                        end
                        
                    else %color
                        
                        if  distractorid == 701
                            
                            allrt_sum{2,1} = [allrt_sum{2,1} response_time];                                                        
                            miss_rts_gc_angles{2,1} = [miss_rts_gc_angles{2,1} response_time];
                            
                        elseif distractorid ==702
                            
                            allrt_sum{2,2} = [allrt_sum{2,2} response_time];                                                                                    
                            miss_rts_gc_angles{2,2} = [miss_rts_gc_angles{2,2} response_time];
                            
                        end
                        
                    end
                    
                end
                
            else
            end
        end
        
        
        
    end
    
    %for sub 15 that only did two blocks (240 trials)
    accuracy_gc_tdis{1,1} = length(correct_rts_gc_tdis{1,1});
    accuracy_gc_tdis{1,2} = length(correct_rts_gc_tdis{1,2});
    accuracy_gc_tdis{2,1} = length(correct_rts_gc_tdis{2,1});
    accuracy_gc_tdis{2,2} = length(correct_rts_gc_tdis{2,2});
    
    % Correct rejection rate
    acc_distractor_gc_angles{1,1} = length(distractor_rts_gc_angles{1,1})/(length(distractor_rts_gc_angles{1,1}) + length(fa_rts_gc_angles{1,1}))*100;
    acc_distractor_gc_angles{1,2} = length(distractor_rts_gc_angles{1,2})/(length(distractor_rts_gc_angles{1,2}) + length(fa_rts_gc_angles{1,2}))*100;
    acc_distractor_gc_angles{2,1} = length(distractor_rts_gc_angles{2,1})/(length(distractor_rts_gc_angles{2,1}) + length(fa_rts_gc_angles{2,1}))*100;
    acc_distractor_gc_angles{2,2} = length(distractor_rts_gc_angles{2,2})/(length(distractor_rts_gc_angles{2,2}) + length(fa_rts_gc_angles{2,2}))*100;
    
    % Hit rate
    acc_target_gc_angles{1,1} = length(target_rts_gc_angles{1,1})/(length(target_rts_gc_angles{1,1})+ length(miss_rts_gc_angles{1,1})) *100;
    acc_target_gc_angles{1,2} = length(target_rts_gc_angles{1,2})/(length(target_rts_gc_angles{1,2})+ length(miss_rts_gc_angles{1,2}))*100;
    acc_target_gc_angles{2,1} = length(target_rts_gc_angles{2,1})/(length(target_rts_gc_angles{2,1})+ length(miss_rts_gc_angles{2,1}))*100;
    acc_target_gc_angles{2,2} = length(target_rts_gc_angles{2,2})/(length(target_rts_gc_angles{2,2})+ length(miss_rts_gc_angles{2,2}))*100;
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/(length(allrt_sum{1,1}))*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/(length(allrt_sum{1,2}))*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/(length(allrt_sum{2,1}))*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/(length(allrt_sum{2,2}))*100;
    
    
    % RT collapsed across hit and correj
    rt_hit_corr_sum{1,1} = [distractor_rts_gc_angles{1,1} target_rts_gc_angles{1,1}];
    rt_hit_corr_sum{1,2} = [distractor_rts_gc_angles{1,2} target_rts_gc_angles{1,2}];
    rt_hit_corr_sum{2,1} = [distractor_rts_gc_angles{2,1} target_rts_gc_angles{2,1}];
    rt_hit_corr_sum{2,2} = [distractor_rts_gc_angles{2,2} target_rts_gc_angles{2,2}];
    
    
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
            zFA = norminv(FA_rate); %in case of Sub51, CR rate is 0, FA rate is 1; assume CR is 0.5, and FA rate = 45/45.5 = 0.99, zFA = 2.3263; zHit = 1.2074; d' = -1.1189
            
            % Then, compute d prime
            dprime{a1,a2} = zHit - zFA;
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
    
    %accuracy collapsed across hit and correct rej
    acc_hitcorr = [acc_hitcorr;a acc_hit_corr_sum{1,1} acc_hit_corr_sum{1,2} acc_hit_corr_sum{2,1} acc_hit_corr_sum{2,2}];
    
    %rt collapsed across hit and correct rej
    rt_hitcorr = [rt_hitcorr;a mean(rt_hit_corr_sum{1,1}) mean(rt_hit_corr_sum{1,2}) mean(rt_hit_corr_sum{2,1}) mean(rt_hit_corr_sum{2,2})];
    
     %all rts (including correct and incorrect rts)
    allRTs = [allRTs;a mean(allrt_sum{1,1}) mean(allrt_sum{1,2}) mean(allrt_sum{2,1}) mean(allrt_sum{2,2})];   
end


Post2.Acc = all_acc;
Post2.RT = all_rts;
Post2.HitAcc = hit_acc;
Post2.HitRT = Hit_rt;
Post2.CRAcc = correj_acc;
Post2.CRRT = Correj_rt;
Post2.dprime = d_prime;

Post2.HCacc = acc_hitcorr;
Post2.HCrt = rt_hitcorr;

Post2.allRT = allRTs;

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[], 'allrt', []);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[], 'allrt', []);



for i = 1:length(Post2.Acc)
    subid = Post2.Acc(i,1);
    
    if rem(subid,2)==1
        
        %if subno is odd, T1 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post2.HitAcc(i,2)];
        gCSp.HitRT = [gCSp.HitRT; subid Post2.HitRT(i,2)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post2.CRAcc(i,2)];
        gCSp.CRRT = [gCSp.CRRT; subid Post2.CRRT(i,2)];
        gCSp.dprime = [gCSp.dprime; subid Post2.dprime(i,2)];
        gCSp.HCacc = [gCSp.HCacc; subid Post2.HCacc(i,2)];
        gCSp.HCrt = [gCSp.HCrt; subid Post2.HCrt(i,2)];
        gCSp.allrt = [gCSp.allrt; subid Post2.allRT(i,2)];
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post2.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Post2.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post2.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Post2.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Post2.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Post2.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Post2.HCrt(i,3)];
        gCSm.allrt = [gCSm.allrt; subid Post2.allRT(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post2.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Post2.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post2.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Post2.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Post2.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Post2.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Post2.HCrt(i,4)];
        cCSp.allrt = [cCSp.allrt; subid Post2.allRT(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post2.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Post2.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post2.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Post2.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Post2.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Post2.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Post2.HCrt(i,5)];
        cCSm.allrt = [cCSm.allrt; subid Post2.allRT(i,5)];
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post2.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Post2.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post2.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Post2.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Post2.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Post2.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Post2.HCrt(i,2)];
        gCSm.allrt = [gCSm.allrt; subid Post2.allRT(i,2)];
        
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post2.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Post2.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post2.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Post2.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Post2.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Post2.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Post2.HCrt(i,3)];
        gCSp.allrt = [gCSp.allrt; subid Post2.allRT(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post2.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Post2.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post2.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Post2.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Post2.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Post2.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Post2.HCrt(i,4)];
        cCSm.allrt = [cCSm.allrt; subid Post2.allRT(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post2.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Post2.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post2.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Post2.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Post2.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Post2.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Post2.HCrt(i,5)];
        cCSp.allrt = [cCSp.allrt; subid Post2.allRT(i,5)];
        
    end
    
    
end

%Finaly tally with CS+/CS- arrangement
Post2.HitAccAll = [Post2.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Post2.HitRTAll = [Post2.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Post2.CRAccAll = [Post2.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Post2.CRRTAll = [Post2.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Post2.dprimeAll = [Post2.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];

Post2.HCacc = [Post2.Acc(:,1) gCSp.HCacc(:,2) gCSm.HCacc(:,2) cCSp.HCacc(:,2) cCSm.HCacc(:,2) gCSp.HCacc(:,2)-gCSm.HCacc(:,2) cCSp.HCacc(:,2)-cCSm.HCacc(:,2)];
Post2.HCrt = [Post2.Acc(:,1) gCSp.HCrt(:,2) gCSm.HCrt(:,2) cCSp.HCrt(:,2) cCSm.HCrt(:,2) gCSp.HCrt(:,2)-gCSm.HCrt(:,2) cCSp.HCrt(:,2)-cCSm.HCrt(:,2)];

Post2.allrt = [Post2.Acc(:,1) gCSp.allrt(:,2) gCSm.allrt(:,2) cCSp.allrt(:,2) cCSm.allrt(:,2) gCSp.allrt(:,2)-gCSm.allrt(:,2) cCSp.allrt(:,2)-cCSm.allrt(:,2)];