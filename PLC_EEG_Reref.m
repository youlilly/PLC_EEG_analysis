%% Debug EEGlab pop_reref function
%Feb 5, 2015

%% Without reref

s = 1;
b = 1;

%Re-reference fear files
filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt_fil.set');
EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset

channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
%Note on the next 3 lines: pop_reref creates a mini-matrix of the
%channels included in referencing, and renumbers them based on
%that.
%This is why these lines call for channels "1" and "2" instead of "99"
%or "100". Took way too long to figure that out!
% EEG = pop_reref(EEG, [1 2], 'exclude', [1:98 101:111], 'keepref', 'on'); %1st step: chan 99(LHEOG/EX3) = new ref.
% EEG = pop_reref(EEG, 2, 'exclude', [1:98 101:111], 'keepref', 'on'); %2nd step: chan 100(RHEOG/EX4) = new ref
% EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:100 102:111], 'keepref', 'on'); %3rd step: C25(89) = new ref
% EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in
%
plot(EEG.data(89,:,1),'k--');hold on
plot(EEG.data(97,:,1), 'k');hold on
plot(EEG.data(98,:,1), 'b');hold on
plot(EEG.data(99,:,1), 'g');hold on
plot(EEG.data(100,:,1), 'm');hold on
plot(EEG.data(101,:,1), 'r');hold on
legend('Chan89','Chan97','Chan98','Chan99','Chan100','Chan101')

eval(['saveas(gcf,''Reref_Sub' num2str(s) 'Block' num2str(b) 'test0.tif'');']);
close(gcf)


%% Emily's filtering methods using Chan99 Chan100
clear all

s = 1;
b = 1;

%Re-reference fear files
filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt_fil.set');
EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset

channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
%Note on the next 3 lines: pop_reref creates a mini-matrix of the
%channels included in referencing, and renumbers them based on that.
%This is why these lines call for channels "1" and "2" instead of "99"
%or "100". Took way too long to figure that out!
EEG = pop_reref(EEG, [1 2], 'exclude', [1:98 101:111], 'keepref', 'on'); %1st step: chan 99(LHEOG/EX3) = new ref.
EEG = pop_reref(EEG, 2, 'exclude', [1:98 101:111], 'keepref', 'on'); %2nd step: chan 100(RHEOG/EX4) = new ref
EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:100 102:111], 'keepref', 'on'); %3rd step: C25(89) = new ref
EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in

plot(EEG.data(89,5200:5700),'k--');hold on
plot(EEG.data(97,5200:5700), 'k');hold on
plot(EEG.data(98,5200:5700), 'b');hold on
plot(EEG.data(99,5200:5700), 'g');hold on
plot(EEG.data(100,5200:5700), 'm');hold on
plot(EEG.data(101,5200:5700), 'r');
legend('Chan89','Chan97','Chan98','Chan99','Chan100','Chan101')

eval(['saveas(gcf,''Reref_Sub' num2str(s) 'Block' num2str(b) 'test_YYrerefline3.tif'');']);
%close(gcf)

%% Correct filtering methods using EX3 EX4
clear all

s = 1;
b = 1;

%Re-reference fear files
filenamerr = strcat('EEG_PLC_Sub',num2str(s),'block',num2str(b),'_evt_fil.set');
EEG = pop_loadset(filenamerr); %Load event-altered & filtered EEG dataset

channelC25 = EEG.data(89,:); %Grabs data from channel C25, which will soon become the ref channel for EX5
%Note on the next 3 lines: pop_reref creates a mini-matrix of the
%channels included in referencing, and renumbers them based on
%that.
%This is why these lines call for channels "1" and "2" instead of "99"
% %or "100". Took way too long to figure that out!
%  EEG = pop_reref(EEG, [1 2], 'exclude', [1:96 99:111], 'keepref', 'on'); %1st step: chan 99(LHEOG/EX3) = new ref.
%  EEG = pop_reref(EEG, 2, 'exclude', [1:98 101:111], 'keepref', 'on'); %2nd step: chan 100(RHEOG/EX4) = new ref
EEG = pop_reref(EEG, 1, 'exclude', [1:88 90:98 100:111], 'keepref', 'on'); %3rd step: C25(89) = new ref
% % EEG.data(89,:) = channelC25; %Step 3 zeroes out C25/89, so let's add the data back in

plot(EEG.data(89,5200:5700),'k--');hold on
plot(EEG.data(97,5200:5700), 'k');hold on
plot(EEG.data(98,5200:5700), 'b');hold on
plot(EEG.data(99,5200:5700), 'g');hold on
plot(EEG.data(100,5200:5700), 'm');hold on
plot(EEG.data(101,5200:5700), 'r');
legend('Chan89','Chan97','Chan98','Chan99','Chan100','Chan101')

eval(['saveas(gcf,''Reref_Sub' num2str(s) 'Block' num2str(b) 'test_YYrerefline3.tif'');']);
%close(gcf)