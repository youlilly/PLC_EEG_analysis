%% This is a the behavior data analyzer for PLC_EEG study
%Created by YY, May 9, 2014
%Last used: Sep 25, 2014

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
%% Check for noresponse - Visit1; indicating intentional bad responses

allsubs = ExpStatus(find(ExpStatus(:,2) ==1 | ExpStatus(:,2) ==0)',1)';
all_noresponse = [];%tally for all subs and each block
acc_by_sub = [];%averaged accuracy for all six preconditioning blocks for each sub
noresponse_by_sub = [];%averaged rate of noresponse for all six preconditioning blocks for each sub

for a = allsubs
    accsub = [];
    nrsub = [];
    
    if a == 15 || a == 56
        sb = 1:5;
    else
        sb = 1:6;
    end
    
    initials = subinitials(a,:);
    for b = sb
        eval(['load PLC_EEG_block' num2str(b) '_sub' num2str(a) '_' initials ' acc noresp;']);
        all_noresponse = [all_noresponse; a b acc noresp];
        accsub = [accsub; acc];
        nrsub = [nrsub; noresp];
    end
    acc_by_sub = [acc_by_sub; a mean(accsub)/120*100];
    noresponse_by_sub = [noresponse_by_sub; a mean(nrsub)/120*100];
    
end

%% Check for noresponse - Visit2; indicating intentional bad responses

allsubs = ExpStatus(find(ExpStatus(:,4) ==1 | ExpStatus(:,4) ==0)',1)';
all_noresponse = [];%tally for all subs and each block
acc_by_sub = [];%averaged accuracy for all six preconditioning blocks for each sub
noresponse_by_sub = [];%averaged rate of noresponse for all six preconditioning blocks for each sub

for a = allsubs
    accsub = [];
    nrsub = [];
    
    %     if a == 15 || a == 56
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
%outputs: Pre.Acc, Pre.RT, Pre.HitAcc, Pre.HitRT, Pre.CRAcc, Pre.CRRT,
%Pre.dprime

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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    
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
    
    % Acc collapsed across hit and correj
    acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/90*100;
    acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/90*100;
    acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/90*100;
    acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/90*100;
    
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
    
    for a1 = 1:2
        for a2 = 1:2
            tt = rt_hit_corr_sum{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            rt_hit_corr_sum{a1,a2} = tt(tindex);
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

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[]);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);

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
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,5)];
        
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Pre.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Pre.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Pre.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Pre.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Pre.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Pre.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Pre.HCrt(i,2)];
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Pre.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Pre.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Pre.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Pre.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Pre.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Pre.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Pre.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Pre.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Pre.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Pre.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Pre.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Pre.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Pre.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Pre.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Pre.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Pre.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Pre.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Pre.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Pre.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Pre.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Pre.HCrt(i,5)];
        
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


save PLC_beh_PreCond_all Pre

%% Accuracy and RTs broken down by angle - Postconditioning1 - blocks 4,5,6
%outputs: Post1.Acc, Post1.RT, Post1.HitAcc, Post1.HitRT, Post1.CRAcc, Post1.CRRT,
%Post1.dprime
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


for a = allsubs;
    
    if a == 15 || a ==56
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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    
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
    if a == 15 || a==56
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
        
        acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/60*100;
        acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/60*100;
        acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/60*100;
        acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/60*100;
        
        
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
        
        acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/90*100;
        acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/90*100;
        acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/90*100;
        acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/90*100;
        
    end
    
    
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
    
    
    for a1 = 1:2
        for a2 = 1:2
            tt = rt_hit_corr_sum{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            rt_hit_corr_sum{a1,a2} = tt(tindex);
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

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[]);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);


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
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,5)];
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post1.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Post1.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post1.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Post1.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Post1.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Post1.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Post1.HCrt(i,2)];
        
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post1.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Post1.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post1.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Post1.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Post1.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Post1.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Post1.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post1.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Post1.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post1.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Post1.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Post1.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Post1.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Post1.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post1.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Post1.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post1.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Post1.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Post1.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Post1.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Post1.HCrt(i,5)];
        
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

save PLC_beh_PostCond1_all Post1

%% Gabor Ratings - Visit 1

%allsubs = find(ExpStatus(:,1) ==1 | ExpStatus(:,1) ==0)';
%sub15,50(need to check this),56 didn't complete the ratings
allsubs = [1,2,3,4,5,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,46,47,48,49,51,52,53,54,55,57;];
Risk = zeros(55,19);
Valence = zeros(55,19);
FearR = zeros(55,19);
DisgR = zeros(55,19);

for a = allsubs
    initials = subinitials(a,:);
    %rating data for the 1st visit
    eval(['load PLC_Ratings_sub' num2str(a) '_' initials '.mat pic_sorted;']);
    
    if rem(a,2) == 1
        Risk(a,:) =  [a pic_sorted(:,2)'];
        Valence(a,:) = [a pic_sorted(:,3)'];
        FearR(a,:) =[a pic_sorted(:,4)'];
        DisgR(a,:) =[a pic_sorted(:,5)'];
        
    else
        
        x = []; y = [];
        x = pic_sorted(:,2)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        Risk(a,:) = [a y];
        
        x = []; y = [];
        x = pic_sorted(:,3)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        Valence(a,:) = [a y];
        
        x = []; y = [];
        x = pic_sorted(:,4)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        FearR(a,:) = [a y];
        
        x = []; y = [];
        x = pic_sorted(:,5)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        DisgR(a,:) = [a y];
        
    end
end

%% Gabor Ratings - Visit 2

AnxGr = [1	0
    2	1
    3	1
    4	0
    5	0
    7	1
    8	1
    9	1
    10	1
    11	0
    12	1
    13	0
    14	0
    15	0
    16	0
    17	0
    18	1
    19	0
    20	1
    21	0
    22	0
    23	0
    24	1
    25	1
    26	1
    27	1
    28	0
    29	1
    30	1
    31	0
    32	0
    33	1
    34	0
    35	1
    36	1
    37	0
    38	0
    39	0
    40	0
    41	1
    42	1
    43	0
    44	1
    46	0
    47	1
    48	0
    49	0
    50	1
    51	1
    52	1
    53	1
    54	0
    55	0
    56	0
    57	0];

allsubs = ExpStatus(find(ExpStatus(:,4) ==1 | ExpStatus(:,4) ==0)',1);
AnxGr = [AnxGr ExpStatus(:,4)];
%sub15,50(need to check this),56 didn't complete the ratings
%allsubs = [1,2,3,4,5,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,46,47,48,49,51,52,53,54,55,57;];
c = 1;
anx = [];

%Grab the anxiety group from the full matrix for those who give ratings at
%2nd visit
for i = 1:length(AnxGr)
    
    ind = AnxGr(i,1);
    if ismember(ind, allsubs)
        anx(c,:) = AnxGr(i,:);
        c = c+1;
    end
end

Risk = [];
Valence = [];
FearR = [];
DisgR = [];

for a = allsubs'
    initials = subinitials(a,:);
    %rating data for the 1st visit
    eval(['load PLC_Ratings_post_sub' num2str(a) '_' initials '.mat pic_sorted;']);
    
    if rem(a,2) == 1
        Risk =  [Risk; a pic_sorted(:,2)'];
        Valence = [Valence; a pic_sorted(:,3)'];
        FearR =[FearR; a pic_sorted(:,4)'];
        DisgR =[DisgR; a pic_sorted(:,5)'];
        
    else
        
        x = []; y = [];
        x = pic_sorted(:,2)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        Risk = [Risk; a y];
        
        x = []; y = [];
        x = pic_sorted(:,3)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        Valence = [Valence; a y];
        
        x = []; y = [];
        x = pic_sorted(:,4)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        FearR = [FearR; a y];
        
        x = []; y = [];
        x = pic_sorted(:,5)';
        for i = 1:9 %reverse-code x to y for Gray, rearranging the CS+ to CS- gradient
            y(i) = x(10-i);
        end
        for i = 10:18 %reverse-code x to y for Color
            y(i) = x(28-i);
        end
        
        DisgR = [DisgR; a y];
        
    end
end


%% Accuracy and RTs broken down by angle - Postconditioning2 - blocks 4,5,6

%Choose subjects who completed session2
allsubs = ExpStatus(find(ExpStatus(:,4) ==1 | ExpStatus(:,4) ==0)',1)';

%Remove subjects with lots of no response
allsubs(allsubs ==35)=[];


all_acc = [];
all_rts = [];

correj_acc = [];
hit_acc = [];


Correj_rt = [];
Hit_rt = [];

d_prime = [];

acc_hitcorr = [];
rt_hitcorr = [];

for a = allsubs;
    
    if  a == 10
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
    
    acc_hit_corr_sum = cell(2,2);%this measure collapse hit and correj acc
    rt_hit_corr_sum = cell(2,2);%this measure collapse hit and correj rt
    
    
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
        
        acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/60*100;
        acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/60*100;
        acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/60*100;
        acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/60*100;
        
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
        
        acc_hit_corr_sum{1,1} = (length(distractor_rts_gc_angles{1,1})+length(target_rts_gc_angles{1,1}))/90*100;
        acc_hit_corr_sum{1,2} = (length(distractor_rts_gc_angles{1,2})+length(target_rts_gc_angles{1,2}))/90*100;
        acc_hit_corr_sum{2,1} = (length(distractor_rts_gc_angles{2,1})+length(target_rts_gc_angles{2,1}))/90*100;
        acc_hit_corr_sum{2,2} = (length(distractor_rts_gc_angles{2,2})+length(target_rts_gc_angles{2,2}))/90*100;
        
    end
    
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
    
    for a1 = 1:2
        for a2 = 1:2
            tt = rt_hit_corr_sum{a1,a2};
            tindex = tt > 100 & tt < (mean(tt) + 2*std(tt));
            rt_hit_corr_sum{a1,a2} = tt(tindex);
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

% Sort the responses into CS+ vs CS-
gCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
gCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[], 'HCrt',[]);
gCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);

cCS = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSp = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);
cCSm = struct('HitAcc',[],'HitRT',[],'CRAcc',[],'CRRT',[],'dprime',[],'HCacc',[],'HCrt',[]);


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
        
        %if subno is odd, T2 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post2.HitAcc(i,3)];
        gCSm.HitRT = [gCSm.HitRT; subid Post2.HitRT(i,3)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post2.CRAcc(i,3)];
        gCSm.CRRT = [gCSm.CRRT; subid Post2.CRRT(i,3)];
        gCSm.dprime = [gCSm.dprime; subid Post2.dprime(i,3)];
        gCSm.HCacc = [gCSm.HCacc; subid Post2.HCacc(i,3)];
        gCSm.HCrt = [gCSm.HCrt; subid Post2.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post2.HitAcc(i,4)];
        cCSp.HitRT = [cCSp.HitRT; subid Post2.HitRT(i,4)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post2.CRAcc(i,4)];
        cCSp.CRRT = [cCSp.CRRT; subid Post2.CRRT(i,4)];
        cCSp.dprime = [cCSp.dprime; subid Post2.dprime(i,4)];
        cCSp.HCacc = [cCSp.HCacc; subid Post2.HCacc(i,4)];
        cCSp.HCrt = [cCSp.HCrt; subid Post2.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post2.HitAcc(i,5)];
        cCSm.HitRT = [cCSm.HitRT; subid Post2.HitRT(i,5)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post2.CRAcc(i,5)];
        cCSm.CRRT = [cCSm.CRRT; subid Post2.CRRT(i,5)];
        cCSm.dprime = [cCSm.dprime; subid Post2.dprime(i,5)];
        cCSm.HCacc = [cCSm.HCacc; subid Post2.HCacc(i,5)];
        cCSm.HCrt = [cCSm.HCrt; subid Post2.HCrt(i,5)];
        
    elseif rem(subid,2)==0
        
        %if subno is even, T1 is the CS-
        gCSm.HitAcc = [gCSm.HitAcc; subid Post2.HitAcc(i,2)];
        gCSm.HitRT = [gCSm.HitRT; subid Post2.HitRT(i,2)];
        gCSm.CRAcc = [gCSm.CRAcc; subid Post2.CRAcc(i,2)];
        gCSm.CRRT = [gCSm.CRRT; subid Post2.CRRT(i,2)];
        gCSm.dprime = [gCSm.dprime; subid Post2.dprime(i,2)];
        gCSm.HCacc = [gCSm.HCacc; subid Post2.HCacc(i,2)];
        gCSm.HCrt = [gCSm.HCrt; subid Post2.HCrt(i,2)];
        
        
        %if subno is even, T2 is the CS+
        gCSp.HitAcc = [gCSp.HitAcc; subid Post2.HitAcc(i,3)];
        gCSp.HitRT = [gCSp.HitRT; subid Post2.HitRT(i,3)];
        gCSp.CRAcc = [gCSp.CRAcc; subid Post2.CRAcc(i,3)];
        gCSp.CRRT = [gCSp.CRRT; subid Post2.CRRT(i,3)];
        gCSp.dprime = [gCSp.dprime; subid Post2.dprime(i,3)];
        gCSp.HCacc = [gCSp.HCacc; subid Post2.HCacc(i,3)];
        gCSp.HCrt = [gCSp.HCrt; subid Post2.HCrt(i,3)];
        
        %if subno is odd, T1 is the CS-
        cCSm.HitAcc = [cCSm.HitAcc; subid Post2.HitAcc(i,4)];
        cCSm.HitRT = [cCSm.HitRT; subid Post2.HitRT(i,4)];
        cCSm.CRAcc = [cCSm.CRAcc; subid Post2.CRAcc(i,4)];
        cCSm.CRRT = [cCSm.CRRT; subid Post2.CRRT(i,4)];
        cCSm.dprime = [cCSm.dprime; subid Post2.dprime(i,4)];
        cCSm.HCacc = [cCSm.HCacc; subid Post2.HCacc(i,4)];
        cCSm.HCrt = [cCSm.HCrt; subid Post2.HCrt(i,4)];
        
        %if subno is odd, T2 is the CS+
        cCSp.HitAcc = [cCSp.HitAcc; subid Post2.HitAcc(i,5)];
        cCSp.HitRT = [cCSp.HitRT; subid Post2.HitRT(i,5)];
        cCSp.CRAcc = [cCSp.CRAcc; subid Post2.CRAcc(i,5)];
        cCSp.CRRT = [cCSp.CRRT; subid Post2.CRRT(i,5)];
        cCSp.dprime = [cCSp.dprime; subid Post2.dprime(i,5)];
        cCSp.HCacc = [cCSp.HCacc; subid Post2.HCacc(i,5)];
        cCSp.HCrt = [cCSp.HCrt; subid Post2.HCrt(i,5)];
        
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



save PLC_beh_PostCond2_all Post2

%% Calculate pre- and post- conditioning difference

% CS+ assignment: if odd, T1 is CS+; if even, T2 is CS+;

%% Calculate Diff1 - Accuracy, RT, dprime

%visit1 full sample
allsubs = [1,2,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,31,32,33,34,37,38,39,40,41,42,43,44,46,47,48,49,50,51,52,53,54,55,56,57;];

%remain the subid while subtacting Pre from Post1
Diff1.Acc = [Pre.Acc(:,1) Post1.Acc(:,2:5) - Pre.Acc(:,2:5)];
Diff1.RT = [Pre.RT(:,1) Post1.RT(:,2:5) - Pre.RT(:,2:5)];
Diff1.HitAcc = [Pre.Acc(:,1) Post1.HitAcc(:,2:5) - Pre.HitAcc(:,2:5)];
Diff1.HitRT = [Pre.Acc(:,1) Post1.HitRT(:,2:5) - Pre.HitRT(:,2:5)];
Diff1.CRAcc = [Pre.Acc(:,1) Post1.CRAcc(:,2:5) - Pre.CRAcc(:,2:5)];
Diff1.CRRT = [Pre.Acc(:,1) Post1.CRRT(:,2:5) - Pre.CRRT(:,2:5)];
Diff1.dprime = [Pre.Acc(:,1) Post1.dprime(:,2:5) - Pre.dprime(:,2:5)];


% Diff1.Acc = Post2.Acc;
% Diff1.RT = Post2.RT;
% Diff1.HitAcc = Post2.HitAcc;
% Diff1.HitRT = Post2.HitRT;
% Diff1.CRAcc = Post2.CRAcc;
% Diff1.CRRT = Post2.CRRT;
% Diff1.dprime = Post2.dprime;

% Look at baseline response to CS+ vs. CS-

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

Diff1.HitAccAll = [Pre.Acc(:,1) gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Diff1.HitRTAll = [Pre.Acc(:,1) gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Diff1.CRAccAll = [Pre.Acc(:,1) gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Diff1.CRRTAll = [Pre.Acc(:,1) gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Diff1.dprimeAll = [Pre.Acc(:,1) gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];


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

Diff2.HitAccAll = [gCSp.HitAcc(:,2) gCSm.HitAcc(:,2) cCSp.HitAcc(:,2) cCSm.HitAcc(:,2) gCSp.HitAcc(:,2)-gCSm.HitAcc(:,2) cCSp.HitAcc(:,2)-cCSm.HitAcc(:,2)];
Diff2.HitRTAll = [gCSp.HitRT(:,2) gCSm.HitRT(:,2) cCSp.HitRT(:,2) cCSm.HitRT(:,2) gCSp.HitRT(:,2)-gCSm.HitRT(:,2) cCSp.HitRT(:,2)-cCSm.HitRT(:,2)];
Diff2.CRAccAll = [gCSp.CRAcc(:,2) gCSm.CRAcc(:,2) cCSp.CRAcc(:,2) cCSm.CRAcc(:,2) gCSp.CRAcc(:,2)-gCSm.CRAcc(:,2) cCSp.CRAcc(:,2)-cCSm.CRAcc(:,2)];
Diff2.CRRTAll = [gCSp.CRRT(:,2) gCSm.CRRT(:,2) cCSp.CRRT(:,2) cCSm.CRRT(:,2) gCSp.CRRT(:,2)-gCSm.CRRT(:,2) cCSp.CRRT(:,2)-cCSm.CRRT(:,2)];
Diff2.dprimeAll = [gCSp.dprime(:,2) gCSm.dprime(:,2) cCSp.dprime(:,2) cCSm.dprime(:,2) gCSp.dprime(:,2)-gCSm.dprime(:,2) cCSp.dprime(:,2)-cCSm.dprime(:,2)];



