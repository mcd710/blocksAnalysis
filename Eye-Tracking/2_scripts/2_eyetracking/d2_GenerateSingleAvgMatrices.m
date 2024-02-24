%% GenerateAvgMatrices
clear mex
clear all  

%removing participants with poor data quality
% Sub = [1016:1019, 1022:1024, 1027, 1031:1035, 1037:1039, 1041:1045, 1048:1051, 1053:1055];

% YOU USED THESE SUBJECTS:
Sub = [1016, 1018, 1019, 1022:1024, 1027, 1031:1043];

%Compile data for each subject
for i = 1:length(Sub)
    
    sub = num2str(Sub(i));
    fprintf('Running Subject %s \n', sub);
    
    dirs.ETfile = '../../3_results/1_et_processing/1_ETfile_preprocessed';
    dirs.behavET = '../../3_results/1_et_processing/2_ET_TrialWise/';
    
    lowerX = 660;
    upperX = 1260;
    lowerY = 240;
    upperY = 840;
    
    imgStartIndex = 1;
    
    % load behav mat file
    behav_path = fullfile(dirs.behavET, sprintf('/Subj%s.mat', sub));
    imgEndIndex = 25;
    num_blocks = 12;
    
    behavData = load(behav_path);
    behavData.startTimeTableArray = table2array(behavData.startTimeTable);
    
    % load ET file
    ETpath = fullfile(dirs.ETfile, sprintf('Subj%s', sub));
    ETData = load(ETpath);
    
    ETData.ET_time = ETData.ETfile.Events.Efix.start;
    ETData.posX = ETData.ETfile.Events.Efix.posX;
    ETData.posY = ETData.ETfile.Events.Efix.posY;
    
    % for each block
    for b = 1:num_blocks
        
        % for each image in that block
        for image = imgStartIndex:imgEndIndex % self condition
            
            % initialize arrays
            posX_arr = [];
            posY_arr = [];
            
            % if the participant responded and did not respond too quickly
            if (behavData.Data.rt(image) >= 0.2) && isempty(behavData.Data.rt(image)) == 0
                
                % to make sure we collect fixations only during the
                % stimulus presentation
                start_time = behavData.startTimeTableArray(image,4);
                end_time = behavData.startTimeTableArray(image,6);
                
                % for each fixation
                for t = 1:length(ETData.ET_time) % match trial indices
                    
                    % if the fixation starts during the stimulus
                    % presentation
                    if (ETData.ET_time(t) > start_time) && (ETData.ET_time(t) < end_time)
                        
                        % exclude positional values outside of stimulus range
                        if (ETData.posX(t) >= lowerX) && (ETData.posX(t) <= upperX) && (ETData.posY(t) >= lowerY) && (ETData.posY(t) <= upperY)
                            
                            % add posX and posY values to matrix
                            posX_arr = [posX_arr; ETData.posX(t)];
                            posY_arr = [posY_arr; ETData.posY(t)];
                            
                        end
                    end
                end
            end
            
            stim = string(behavData.Data{image,3});
            save_name = split(stim,["stim_set/",".png"]);
            
            if behavData.Data.choice(image) == "stand"
                choice = "stand";
            elseif behavData.Data.choice(image) == "fall"
                choice = "fall";
            else
                choice = "NAN";
            end
            
            if behavData.Data.motivation(image) == "stand"
                mot = "stand";
            elseif behavData.Data.motivation(image) == "fall"
                mot = "fall";
            else
                mot = "neutral";
            end
            
            if choice ~= "NAN"
                
                this_arr = [posX_arr posY_arr];
                
                save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-%s/", mot)));
                save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-%s/", mot));
                
                %if this image has no associated data saved, create a new file
                if isfile(sprintf("%simage-%s.csv", save_img_path, save_name(2))) == 0
                    disp("Creating new file...");
                      
                    writematrix(this_arr, sprintf("%simage-%s.csv", save_img_path, save_name(2)));
                    
                else
                    disp("Data for this image already exists!");
                
                    if isempty(this_arr) == 0
                  
                        % concatenate positional data
                        temp_arr = [posX_arr posY_arr];          
                        old_arr = readmatrix(sprintf("%simage-%s.csv", save_img_path, save_name(2)));
                        this_arr = [old_arr; temp_arr];

                        % add to old file
                        writematrix(this_arr, sprintf("%simage-%s.csv", save_img_path, save_name(2)));
                        
                    end
                end
                
            end
        end
        
        imgStartIndex = imgStartIndex + 25;
        imgEndIndex = imgEndIndex + 25;
    end
end

mots = ["mot-fall", "mot-stand", "mot-neutral"];

sum_files = dir('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-neutral/');

% removing DS_Store and useless filenames
sum_files(1,:) = [];
sum_files(1,:) = [];
sum_files(1,:) = [];

for i=1:length(sum_files)
    
    for j=1:3
        
        mot = mots(j);
        d = readmatrix(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/%s/%s", mot, sum_files(i).name));
        
        if height(d) > 1 % if the positional data exists
            p = gkde2(d);
            
            % to remove areas with negligible data
            img_heatmap = zeros(50);
            
            for row=1:size(p.pdf,1)
                for col=1:size(p.pdf,2)
                    img_heatmap(row,col) = p.pdf(row,col);
                end
            end
            
        end
        
        save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/%s/", mot)));
        save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/%s/", mot));
        
        %if this image has no associated data saved, create a new file
        writematrix(img_heatmap, sprintf("%s%s", save_img_path, sum_files(i).name));
    end
end