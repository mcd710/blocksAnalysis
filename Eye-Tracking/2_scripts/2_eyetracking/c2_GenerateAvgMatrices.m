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
                
                save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/mot-%s/image-%s/", mot, save_name(2))));
                save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/mot-%s/image-%s/", mot, save_name(2)));
                
                %if this image has no associated data saved, create a new file
                if isfile(sprintf("%schoice-%s.csv", save_img_path, choice)) == 0
                    disp("Creating new file...");
                      
                    writematrix(this_arr, sprintf("%schoice-%s.csv", save_img_path, choice));
                    
                else
                    disp("Data for this image already exists!");
                
                    if isempty(this_arr) == 0
                  
                        % concatenate positional data
                        temp_arr = [posX_arr posY_arr];          
                        old_arr = readmatrix(sprintf("%schoice-%s.csv", save_img_path, choice));
                        this_arr = [old_arr; temp_arr];

                        % add to old file
                        writematrix(this_arr, sprintf("%schoice-%s.csv", save_img_path, choice));
                        
                    end
                end
                
            end
        end
        
        imgStartIndex = imgStartIndex + 25;
        imgEndIndex = imgEndIndex + 25;
    end
end

mots = ["mot-fall", "mot-stand", "mot-neutral"];
choices = ["choice-stand.csv", "choice-fall.csv"];

sum_files = dir('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/mot-neutral/');
inpdir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices';
tempdir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/unambiguous';

% removing DS_Store and useless filenames
sum_files(1,:) = [];
sum_files(1,:) = [];
sum_files(1,:) = [];

for i=1:length(sum_files)
    
    % if there are no data for either stand or fall judgments, remove the image folder
    % this is so that we only look at ambiguous images for the ISC

    thisdir = sprintf('%s/mot-neutral/%s', inpdir, sum_files(i).name);
    falldir = sprintf('%s/mot-fall/%s', inpdir, sum_files(i).name);
    standdir = sprintf('%s/mot-stand/%s', inpdir, sum_files(i).name);

    if isfile(sprintf('%s/choice-fall.csv', thisdir)) == 0 || isfile(sprintf('%s/choice-stand.csv', thisdir)) == 0
        movefile(thisdir, sprintf('%s/mot-neutral', tempdir));
        
        if isdir(falldir)
            movefile(falldir, sprintf('%s/mot-fall', tempdir));
        end
        
        if isdir(standdir)
            movefile(standdir, sprintf('%s/mot-stand', tempdir));
        end
    end
    
    % for each mot type
    for j=1:3
        %for each choice type
        
        for k=1:2
            mot = mots(j);
            choice = choices(k);
            
            if isfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/%s/%s", mot, sum_files(i).name, choice))
                d = readmatrix(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/%s/%s", mot, sum_files(i).name, choice));
            
                if height(d) > 1 % if the positional data exists
                    p = gkde2(d);
                    
                    % to remove areas with negligible data
                    img_heatmap = zeros(50);
                    
                    for row=1:size(p.pdf,1)
                        for col=1:size(p.pdf,2)
                            %img_heatmap(row,col) = p.pdf(row,col);
                            
                            greatestFix = max(p.pdf);
                            if (p.pdf(row,col) >= (0.3 * greatestFix))
                                img_heatmap(row,col) = p.pdf(row,col);
                            end
                        end
                    end
                    
                end
                
                save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/%s/", mot, sum_files(i).name)));
                save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/%s/", mot, sum_files(i).name));
                
                %if this image has no associated data saved, create a new file
                writematrix(img_heatmap, sprintf("%s%s", save_img_path, choice));
            end
        end
    end
end