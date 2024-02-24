%% GeneratePlots
clear mex
clear all  

%Sub = [1016:1019, 1022:1024, 1027, 1031:1035, 1037:1039, 1041:1045, 1048:1051, 1053:1055];

mot_type = ["mot-fall", "mot-stand", "mot-neutral"];

%for h=1:length(Sub)
    
    %sub = num2str(Sub(h));
    
    for i=1:3
        
        %inp_files = dir(sprintf('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/1_subjectMatrices/sub-%s/%s/', sub, mot_type(i)));
        inp_files = dir(sprintf('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/', mot_type(i)));
        
        % removing DS_Store
        inp_files(1,:) = [];
        inp_files(1,:) = [];
        inp_files(1,:) = [];

        for j=1:length(inp_files)
            
            % images are sorted later
            stim = inp_files(j).name;
            stim = split(stim, ["image-"]);
            
            stim_str = append('../../0_task/stim_set/', stim(2), ".png");
            img = imread(stim_str);
            img = imresize(img, [50 50]);
            img = flip(img);
            
            %checkdir = sprintf('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/1_subjectMatrices/sub-%s/%s/image-%s/choice-', sub, mot_type(i), string(stim(2)));
            checkdir = sprintf('../../3_results/1_et_processing/3_heatmaps/1_heatmapMatrices/2_averageMatrices/%s/image-%s/choice-', mot_type(i), string(stim(2)));
            
            if isfile(sprintf('%sfall.csv', checkdir))
                choice = "fall";
            elseif isfile(sprintf('%sstand.csv', checkdir))
                choice = "stand";
            end
                
            img_heatmap = readmatrix(sprintf('%s%s', checkdir, choice));
            colormap(jet);
            
            % image is upside down
            img_heatmap = flip(img_heatmap);
            
            figure(2);
            A = surf(img_heatmap);
            
            % cleaning up figure
            set(A, 'linestyle','none');
            set(gca,'visible','off');
            xlim([0,50])
            ylim([0,50])
            colormap(jet)
            
            hold on
            
            % display stimulus image
            image(img);
            
            view(2);
            
            save_name = split(stim,["stim_set/",".png"]);
            
            %save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/3_heatmapImages/1_subjectImages/%s/image-%s/sub-%s", mot_type(i), string(save_name(2)))));            
            %save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/3_heatmapImages/1_subjectImages/%s/image-%s/sub-%s", mot_type(i), string(save_name(2)), sub));

            save_img_dir = mkdir(fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/3_heatmapImages/2_averageImages/%s", mot_type(i))));            
            save_img_path = fullfile(sprintf("../../3_results/1_et_processing/3_heatmaps/3_heatmapImages/2_averageImages/%s/image-%s", mot_type(i), string(save_name(2))));

            saveas(2, sprintf("%s.png", save_img_path));
            
            clf('reset');
            clear mot;
            clear bet;
            
        end
    end
%end