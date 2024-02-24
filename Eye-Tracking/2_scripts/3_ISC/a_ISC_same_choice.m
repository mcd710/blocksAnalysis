%% ISC
clear mex
clear all 

% Sub = [1016:1019, 1022:1024, 1027, 1031:1035, 1037:1039, 1041:1045, 1048:1051, 1053:1055];

% YOU USED THESE SUBJECTS:
Sub = [1016, 1018, 1019, 1022:1024, 1027, 1031:1043];

inp_files = dir('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/mot-neutral/');

% removing DS_Store
inp_files(1,:) = [];
inp_files(1,:) = [];
inp_files(1,:) = [];

% vectorize the data for each subject 
        
for i = 1:length(inp_files)
    
    % looking at the averaged data
    
    thisdir = sprintf('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/mot-neutral/%s', inp_files(i).name);
    mkdir thisdir
    
    fall_matrix = table2array(readtable(sprintf('%s/choice-fall.csv', thisdir)));
    stand_matrix = table2array(readtable(sprintf('%s/choice-stand.csv', thisdir)));
    
    fall_vector = reshape(fall_matrix, 2500, 1);
    stand_vector = reshape(stand_matrix, 2500, 1);
    
    % looking at data for each subject
    for j = 1:length(Sub)
        
        sub = num2str(Sub(j));
        fprintf('Running Subject %s \n', sub);
        
        indir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/1_subjectMatrices/';
        mkdir indir
        
        % only looking at subjects for which there is a neutral condition
        if isfolder(sprintf('%ssub-%s/mot-neutral/', indir, sub))
            
            imgpath = sprintf('%ssub-%s/mot-neutral/%s/%s/',indir, sub, inp_files(i).name);
            
            % for these subjects, find whether a fall or stand judgment was made for
            % this image
            
            % if they made a fall judgment
            if isfile(sprintf('%schoice-fall.csv', imgpath))
                
                this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-neutral/%s/choice-fall.csv", indir, sub, inp_files(i).name)));
                this_sub_vector = reshape(this_sub_img, 2500, 1);
                
                % compute correlation for the data of each subject and the average
                this_sub_img_corr = corr(fall_vector, this_sub_vector);
                
                outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_choice/choice_con/mot-neutral/%s/choice-fall/", inp_files(i).name)));              
                isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_choice/choice_con/mot-neutral/%s/choice-fall/", inp_files(i).name));
                
                % save the matrix with the correlation coefficients in the corresponding folder
                writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
            
            % if they made a stand judgment
            elseif isfile(sprintf("%schoice-stand.csv", imgpath))
                
                this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-neutral/%s/choice-stand.csv", indir, sub, inp_files(i).name)));
                this_sub_vector = reshape(this_sub_img, 2500, 1);
                
                this_sub_img_corr = corr(stand_vector, this_sub_vector);
                
                outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_choice/choice_con/mot-neutral/%s/choice-stand/", inp_files(i).name)));              
                isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_choice/choice_con/mot-neutral/%s/choice-stand/", inp_files(i).name));
                
                % save the matrix with the correlation coefficients in the corresponding folder
                writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
             
            end
        end
    end
end