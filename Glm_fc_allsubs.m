%-----------------------------------------------------------------------  
% Job script created by scr_job_create, 13-May-2014  19:11                
%-----------------------------------------------------------------------  
                                                                          
global settings                                                           
if isempty(settings), scr_init; end;      

allsubs = [1:5 7:39];
condition = {'color';'gray'};

for a = allsubs
    if a ==37
        c1 = 1;
    else c1 = 1:2;
    end
    
    for c = c1
    ccode = condition{c,:};    
    
    D{1} = strcat('/Volumes/Work/SCR/scr_PLC_Sub', num2str(a),'_fc_',ccode,'_scr.mat');
    C{1} = strcat('/Volumes/Work/SCR/PLC_Sub', num2str(a),'_fc_',ccode,'_mcf.mat');   
    modelfile = strcat('/Volumes/Work/SCR/Sub', num2str(a),'_fc_',ccode,'_1stGLM.mat');  
    timeunits = 'samples';                                                    
    basefunctions = 'scrf2'; %scrf provides a canonical skin conductance response function, scrf1 adds the time derivative, scrf2 adds time dispersion derivative                                                   
    normalize = [0];                                                          
    channel = [0];           
    %options.overwrite = 1;            %okay to overwrite    
    scr_glm(D, C, modelfile, timeunits, basefunctions, normalize, channel);   
    
    end
    
    clear D;
    clear C;
end