%% ISC
clear mex
clear all 

%removing participants with poor data quality
Sub = [1016:1019, 1022:1024, 1027, 1031:1035, 1037:1039, 1041:1045, 1048:1051, 1053:1055];

inp_files = dir('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/6_motconAverageMatrices/mot-neutral/');

% removing DS_Store
inp_files(1,:) = [];
inp_files(1,:) = [];
inp_files(1,:) = [];

% vectorize the data for each subject 

indir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/5_motconSubjectMatrices/';
mkdir indir
    
for i = 1:length(inp_files)
    
    % looking at the averaged data
    
    motcon_dir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/6_motconAverageMatrices/mot-con/';
    motincon_dir = '../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/6_motconAverageMatrices/mot-incon/';
    
    motcon_matrix = table2array(readtable(sprintf('%s%s', motcon_dir, inp_files(i).name)));
    motincon_matrix = table2array(readtable(sprintf('%s%s', motincon_dir, inp_files(i).name)));
    
    motcon_vector = reshape(motcon_matrix, 2500, 1);
    motincon_vector = reshape(motincon_matrix, 2500, 1);

    % looking at data for each subject
    for j = 1:length(Sub)
        
        sub = num2str(Sub(j));
        fprintf('Running Subject %s \n', sub);
            
       % for each subject, find whether they were motivated to make a fall or stand judgment
            
       % if they made a motivation consistent judgment
       if isfile(sprintf('%ssub-%s/mot-con/%s', indir, sub, inp_files(i).name))
           
          this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-con/%s", indir, sub, inp_files(i).name)));
          this_sub_vector = reshape(this_sub_img, 2500, 1);

          % compute correlation for the data of each subject and the average
          this_sub_img_corr = corr(motcon_vector, this_sub_vector);
           
          outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot_v2/mot_same/mot-con/%s/", inp_files(i).name)));
          isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot_v2/mot_same/mot-con/%s/", inp_files(i).name));

          %save the matrix with the correlation coefficients in the corresponding folder
          writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
           
       % if they made a motivation inconsistent judgment
       elseif isfile(sprintf('%ssub-%s/mot-incon/%s', indir, sub, inp_files(i).name))
           
          this_sub_img = table2array(readtable(sprintf("%ssub-%s/mot-incon/%s", indir, sub, inp_files(i).name)));
          this_sub_vector = reshape(this_sub_img, 2500, 1);
          this_sub_img_corr = corr(motincon_vector, this_sub_vector);
           
          outdir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot_v2/mot_same/mot-incon/%s/", inp_files(i).name)));
          isc_matrix = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/2_isc/isc_mot_v2/mot_same/mot-incon/%s/", inp_files(i).name));

          % save the matrix with the correlation coefficients in the corresponding folder
          writematrix(this_sub_img_corr, sprintf('%s%s.txt', isc_matrix, sub));
       end
    end
end