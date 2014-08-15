%-----------------------------------------------------------------------  
% Job script created by scr_job_create, 13-May-2014  19:11                
%-----------------------------------------------------------------------  
                                                                          
global settings                                                           
if isempty(settings), scr_init; end;      

%for 1st session data
allsubs = [1:5 7:39];

%for 2nd session data
%allsubs=find(ExpStatus(:,3)==1 | ExpStatus(:,3)==0)';


for a = allsubs
    if a ==15
        c1 = 1:5;
    else c1 = 1:6;
    end
%   
%    c1 = 4:6;
    for c = c1
    
    D{1} = strcat('/Volumes/Work/SCR/scr_EEG_Sub', num2str(a),'_block', num2str(c),'_scr_trim.mat');%1st session data
    C{1} = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_mcf.mat');   %1st session data
    modelfile = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_norm_1stGLM.mat');  %1st session data
    
%     D{1} = strcat('/Volumes/Work/SCR/scr_EEG_Sub', num2str(a),'_block', num2str(c),'_post_scr_trim.mat');%2nd session data
%     C{1} = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_post_mcf.mat');   %2nd session data
%     modelfile = strcat('/Volumes/Work/SCR/EEG_Sub', num2str(a),'_block', num2str(c),'_post_norm_1stGLM.mat');  %2nd session data
    
    timeunits = 'samples';                                                    
    basefunctions = 'scrf2'; %scrf provides a canonical skin conductance response function, scrf1 adds the time derivative, scrf2 adds time dispersion derivative                                                   
    normalize = [1];                                                          
    channel = [0];           
    %options.overwrite = 1;            %okay to overwrite    
    scr_glm(D, C, modelfile, timeunits, basefunctions, normalize, channel);   
    
    end
    
    clear D;
    clear C;
end

