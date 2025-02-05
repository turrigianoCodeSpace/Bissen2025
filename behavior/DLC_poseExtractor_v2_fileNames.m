
% function to load in all the DLC.csv files in a directory

function [full_dlc, pose_labels, dlc_files] = DLC_poseExtractor_v2_fileNames(dlc_path)

% dlc_path = 'D:\Work\Mouse\DLC_CSV';

dlc_path = char(dlc_path);
dlc_files = dir([dlc_path, filesep, '*DLC*.csv']); % not an output

data_tab = readtable([dlc_files(1).folder filesep dlc_files(1).name],'format','auto');
bodyparts = unique(data_tab{1,3:end},'stable');
disp(['Pose extracted from DLC file: ']);
disp(bodyparts)

pose_labels = bodyparts;

full_dlc = {};
for vid_n = 1:length(dlc_files)
    dlc_name = dlc_files(vid_n).name;
    disp(['File: ',dlc_name])
    
    dlc_mat = [];
    file_loaded = 0;
    num_frames = 0;
    while file_loaded == 0
        try
            ind_file_name_sp = split(dlc_files(vid_n).name,'DLC');
            ind_file_name = [ind_file_name_sp{1},'_LabeledBouts.csv'];
            lab_file = csvread([dlc_files(1).folder, filesep, ind_file_name],1);
            last_frame = lab_file(end,2);

            dlc_mat = csvread([dlc_files(1).folder filesep dlc_files(vid_n).name], 3);
        catch
            disp(['File not found: ',[dlc_name, 'DLC*.csv']])
            dlc_mat = [];

            pause(3)
        end
            
        if ~isempty(dlc_mat)
    
            if last_frame > size(dlc_mat,1)
                disp('frame num mismatch')
                keyboard
            end            
            file_loaded = 1;
            disp('File Loaded!')
        end
    end
    
%     full_dlc = [full_dlc; dlc_mat(:,2:end)];
    full_dlc{vid_n} = dlc_mat(:,2:end);
end


fclose('all');

% Quickly plot dlc output
% 
% figure; hold on
% scatter(full_dlc(:,1),full_dlc(:,2),4,'k',...
%     'markerfacealpha',0.01,...
%     'markeredgealpha',0.01)
% scatter(full_dlc(:,25),full_dlc(:,26),4,'r',...
%     'markerfacealpha',0.01,...
%     'markeredgealpha',0.01)


end