%% compare corr

% test whether the correlation generated in e_ISC is higher than the correlation between the 
% participant's eye-gaze pattern with the eye-gaze pattern of all
% participants in the neutral condition

% do the subtraction and see if that difference is positive

clear mex
clear all 

%removing participants with poor data quality
% Sub = [1016:1019, 1022:1024, 1027, 1031:1035, 1037:1039, 1041:1045, 1048:1051, 1053:1055];

% YOU USED THESE SUBJECTS:
Sub = [1016, 1018, 1019, 1022:1024, 1027, 1031:1043];

inp_files = dir('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-neutral/');

% removing DS_Store
inp_files(1,:) = [];
inp_files(1,:) = [];
inp_files(1,:) = [];

% vectorize the data for each subject 

indir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/3_singleSubjectMatrices/';
mkdir indir

for i = 1:length(inp_files)
    
    % looking at the averaged data
    
    falldir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-fall/';
    standdir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/4_singleAverageMatrices/mot-stand/';
    
    fall_matrix = table2array(readtable(sprintf('%s%s', falldir, inp_files(i).name)));
    stand_matrix = table2array(readtable(sprintf('%s%s', standdir, inp_files(i).name)));
    
    fall_vector = reshape(fall_matrix, 2500, 1);
    stand_vector = reshape(stand_matrix, 2500, 1);

    % looking at data for each subject
    for j = 1:length(Sub)
        
        sub = num2str(Sub(j));
        fprintf('Running Subject %s \n', sub);
            
       % for each subject, find whether they were motivated to make a fall or stand judgment
            
       % if they were motivated to make a fall judgment
       if isfile(sprintf('%ssub-%s/mot-fall/%s', indir, sub, inp_files(i).name))
           
          this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-fall/%s", indir, sub, inp_files(i).name)));
          this_sub_vector = reshape(this_sub_img, 2500, 1);

          % compute correlation for the data of each subject and the average
          this_sub_img_corr = corr(stand_vector, this_sub_vector);
           
          outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot/mot_opp/mot-fall/%s/", inp_files(i).name)));
          isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot/mot_opp/mot-fall/%s/", inp_files(i).name));

          %save the matrix with the correlation coefficients in the corresponding folder
          writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
           
        %   if they were motivated to make a stand judgment
       elseif isfile(sprintf('%ssub-%s/mot-stand/%s', indir, sub, inp_files(i).name))
           
          this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-stand/%s", indir, sub, inp_files(i).name)));
          this_sub_vector = reshape(this_sub_img, 2500, 1);
          this_sub_img_corr = corr(fall_vector, this_sub_vector);
           
          outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot/mot_opp/mot-stand/%s/", inp_files(i).name)));
          isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot/mot_opp/mot-stand/%s/", inp_files(i).name));

          % save the matrix with the correlation coefficients in the corresponding folder
          writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
       end
    end
end