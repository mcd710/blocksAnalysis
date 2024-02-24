%% ET_trialTC
% This script pre-processes the pupil timecourse from the raw edf files and
% converts it to Matlab file:
% 1. Remove eye-blinks (extends 150ms each side)
% 2. Linear interpolation of eye-blink
% 3. Linear interpolate all nans (to run filter)
% 4. Zero-phase filtering (low pass)

clear mex
clear all

%Sub = [1016:1019, 1022:1024, 1027, 1031:1045, 1048:1056];

% Sub = [1016];

% YOU USED THESE SUBJECTS:
% Sub = [1016, 1018, 1019, 1022:1024, 1027, 1031:1043];

% Compile data
for i = 1:length(Sub)
    
    sub = num2str(Sub(i));
    fprintf('Running Subject %s \n', sub);
    dirs.ETraw = '../../1_data/2_eyetracking';
    dirs.ETfile = '../../3_results/1_et_processing/1_ETfile_preprocessed';
    
    % ETraw file for unmotivated condition
    ETpath_self = fullfile(dirs.ETraw,sprintf('%s.edf', sub));

    ETraw_self = Edf2Mat(ETpath_self);
    disp(ETraw_self);
        
    ETfile = [];
    ETfile.Events.Efix =  ETraw_self.Events.Efix;
    
    save_path = fullfile(dirs.ETfile,sprintf('Subj%s.mat', sub));
    save(save_path, 'ETfile');
        
end