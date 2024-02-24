%% ET_trialTC

clear mex
clear all

addpath(genpath('../../../edf-converter-master'));

%Sub = [1016:1019, 1022:1024, 1027, 1031:1045, 1048:1056];
% Sub = [1016];

% YOU USED THESE SUBJECTS:
% Sub = [1016, 1018, 1019, 1022:1024, 1027, 1031:1043];

dirs.ETfile = '../../3_results/1_et_processing/1_ETfile_preprocessed';
dirs.behavET = '../../3_results/1_et_processing/2_ET_TrialWise';
dirs.data = '../../1_data/1_behav';

% Compile data for each subject
for i = 1:length(Sub)
   
    startIndex = 1;
    endIndex = 25;
    num_blocks = 12;

    sub = num2str(Sub(i));
    fprintf('Running Subject %s \n', sub);
    
    startTimeTable = table();
    
    % setup to convert csv to mat file
    in_csv = sprintf('%s.csv', sub);

    csv_path = append('../../1_data/1_behav/', in_csv);
    Data = readtable(csv_path);
    
    % load corresponding ET file
    ETpath = fullfile(dirs.ETfile,sprintf('Subj%s',sub));
    load(ETpath);
        
    for b = 1:num_blocks

        filename = sprintf('%s.mat', sub);
        
        % save behav mat file
        filepath = append('../../1_data/1_behav/',filename);
        save(filepath, 'Data')
    
        % load behav mat file
        behav_path = dir(fullfile(dirs.data,filename));
        thisData = load(fullfile(dirs.data,behav_path.name));
 
        ET_Start_Index = find(strcmp(ETfile.Events.Messages.info,sprintf("BLOCK%i_START", b))); %start index of run
        ET_Start_Time = ETfile.Events.Messages.time(ET_Start_Index);
        
        for t = startIndex:endIndex % loop through trials in block
            
            % When did this trial start/end in the behavioral data file
            trialStart = thisData.Data(t,4);
            trialStart = trialStart{:,1} * 1000;
            
            trialEnd = thisData.Data(t,10);
            trialEnd = trialEnd{:,1} * 1000;
            
            % When did this trial start/end in the eye-tracking data
            trialStartET = ET_Start_Time + trialStart;
            trialStartET = round(trialStartET);
            
            trialEndET = ET_Start_Time + trialEnd;
            trialEndET = round(trialEndET);
            
            % When was StimOn in the behavioral data file
            StimOn = thisData.Data(t,5);
            StimOn = StimOn{:,1} * 1000;
            
            % When was StimOn in the eye-tracking data
            StimOnET = ET_Start_Time + StimOn;
            StimOnET = round(StimOnET);
            
            % When was StimOff in the behavioral data file
            % if rt is NaN, the participant viewed the image for 5 seconds
            if isnan(thisData.Data{t,8})
                rt = 5000;
            else
                rt = thisData.Data(t,8);
                rt = rt{:,1} * 1000;
            end
            
            StimOff = StimOn + rt;
            
            % When was StimOff in the eye-tracking data
            StimOffET = ET_Start_Time + StimOff;
            StimOffET = round(StimOffET);
            
            % save values in table
            T1 = table(trialStart, trialStartET, StimOn, StimOnET, StimOff, StimOffET, trialEnd, trialEndET, 'VariableNames', {'trialStart','trialStartET','StimOn','StimOnET','StimOff', 'StimOffET','trialEnd','trialEndET'});
            startTimeTable = [startTimeTable; T1];
            
        end
        
        startIndex = startIndex + 25;
        endIndex = endIndex + 25;
    end
    
    save_path = fullfile(dirs.behavET, sprintf('Subj%s.mat', sub));
    
    save(save_path, 'Data', 'startTimeTable');
end
