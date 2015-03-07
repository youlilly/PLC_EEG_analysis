%-----------------------------------------------------------------------  
% Job script created by scr_job_create, 13-May-2014  19:11                
%-----------------------------------------------------------------------  
                                                                          
global settings                                                           
if isempty(settings), scr_init; end;      
settings.down.sr = 16;%modify down sample rate to yield an integer;5/13/2014 by YY

%for 1st session data
%allsubs = [1:5 7:39 40:44 46:57];


%for 2nd session data
allsubs = [48 52]%[1,2,3,4,7,9,10,12,13,15,16,17,18,20,21,22,23,24,25,27,28,32,33,34,37,38,39,40,42,43,44,46,47,48,49,50,51,52,54,55,57;];


for a = allsubs
%     if a == 56 || a == 15
%         c1 = 1:5;
%     elseif a == 55
%         c1 = [1:3 5:6];
%     else
%         c1 = 1:6;
%     end
    
%   
    c1 = 4:6;
    for c = c1
    
%     D{1} = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/scr_EEG_Sub', num2str(a),'_block', num2str(c),'_scr_trim.mat');%1st session data
%     C{1} = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/EEG_Sub', num2str(a),'_block', num2str(c),'_mcf.mat');   %1st session data
%     modelfile = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/EEG_Sub', num2str(a),'_block', num2str(c),'_norm_1stGLM.mat');  %1st session data
%     
    D{1} = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/scr_EEG_Sub', num2str(a),'_block', num2str(c),'_post_scr_trim.mat');%2nd session data
    C{1} = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/EEG_Sub', num2str(a),'_block', num2str(c),'_post_mcf.mat');   %2nd session data
    modelfile = strcat('/Users/bhu/Documents/PLC_EEG/SCR_gb_all/EEG_Sub', num2str(a),'_block', num2str(c),'_post_norm_1stGLM.mat');  %2nd session data
    
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

