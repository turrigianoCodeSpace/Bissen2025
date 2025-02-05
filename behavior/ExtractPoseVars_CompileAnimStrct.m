function [pose_strct, beh_strct] = ExtractPoseVars_CompileAnimStrct(dlc_path, dlc_strct, beh_vid_strct, vid_meta)


set_vid_fps = vid_meta.set_vid_fps;
vid_type = vid_meta.vid_type;
px_per_cm = vid_meta.px_per_cm;

head_inds = [1,2,3,4];
body_inds = [5,6,7];
crick_inds = [24,25,26];
tail_inds = [7:12];

conf_thresh = 0.82;
speed_cutoff = 40;
smooth_crick_ON = 1;

vid_files = dir([dlc_path,'*',vid_type]);
dlc_files = dir([dlc_path,'*DLC*.csv']);

head_speeds = {};
body_speeds = {};
azimuth = {};
crickDelta = {};
distTrav = {};
tailTort = {};
tailAng = {};
bodyLen = {};

full_vid_fps = [];
% loop thru hunt structure to process DLC of given poses and calculate
% pose measures
for vid_i = 1:length(dlc_strct)
    vid_data = dlc_strct{vid_i};

    vid_split = split(dlc_files(vid_i).name,'DLC');
    vid_name = [vid_split{1},vid_type];
    vid_found = 0;
%     for i = 1:length(vid_files)
%         if strcmp(vid_name, vid_files(i).name)
%             disp(['Video found: ',vid_name])
% 
%             vid_path = [dlc_files(vid_i).folder, filesep, vid_name];
%             obj = VideoReader(vid_path);
%             vid_fps = round(obj.FrameRate);
% 
%             disp(['Frame rate: ',num2str(vid_fps)])
% 
%             if set_vid_fps ~= vid_fps
%                 disp(['Warning this does not equal set fps of: ',num2str(set_vid_fps)])
%             end
%             vid_found = 1;
%         end
%     end

    if vid_found == 0
        disp(['Corresponding video not found: ',vid_name])
        vid_fps = set_vid_fps;
    end
    full_vid_fps(vid_i) = vid_fps;

    vid_head_x = [];
    vid_head_y = [];
    vid_head_conf = [];
    vid_body_x = [];
    vid_body_y = [];
    vid_body_conf = [];
    vid_crick_x = [];
    vid_crick_y = [];
    vid_crick_conf = [];    
    tail_pose_x = [];
    tail_pose_y = [];
    tail_pose_conf = [];
    for i = 1:length(head_inds)
        col_ind = (head_inds(i)-1)*3 + 1;
        vid_head_x(:,i) = vid_data(:,col_ind);
        vid_head_y(:,i) = vid_data(:,col_ind+1);
        vid_head_conf(:,i) = vid_data(:,col_ind+2);
        vid_head_x(vid_head_conf(:,i) < conf_thresh,i) = NaN;
        vid_head_y(vid_head_conf(:,i) < conf_thresh,i) = NaN;
    end

    for i = 1:length(body_inds)
        col_ind = (body_inds(i)-1)*3 + 1;
        vid_body_x(:,i) = vid_data(:,col_ind);
        vid_body_y(:,i) = vid_data(:,col_ind+1);
        vid_body_conf(:,i) = vid_data(:,col_ind+2);
        vid_body_x(vid_body_conf(:,i) < conf_thresh,i) = NaN;
        vid_body_y(vid_body_conf(:,i) < conf_thresh,i) = NaN;        
    end

    for i = 1:length(tail_inds)
        col_ind = (tail_inds(i)-1)*3 + 1;
        tail_pose_x(:,i) = vid_data(:,col_ind);
        tail_pose_y(:,i) = vid_data(:,col_ind+1);
        tail_pose_conf(:,i) = vid_data(:,col_ind+2);
        tail_pose_x(tail_pose_conf(:,i) < conf_thresh,i) = NaN;
        tail_pose_y(tail_pose_conf(:,i) < conf_thresh,i) = NaN;        
    end

    for i = 1:length(crick_inds)
        col_ind = (crick_inds(i)-1)*3 + 1;
        vid_crick_x(:,i) = vid_data(:,col_ind);
        vid_crick_y(:,i) = vid_data(:,col_ind+1);
        vid_crick_conf(:,i) = vid_data(:,col_ind+2);
        vid_crick_x(vid_crick_conf(:,i) < conf_thresh,i) = NaN;
        vid_crick_y(vid_crick_conf(:,i) < conf_thresh,i) = NaN; 
    end
    vid_crick_x = mean(vid_crick_x,2,'omitnan');
    vid_crick_y = mean(vid_crick_y,2,'omitnan');

    if smooth_crick_ON
%         vid_crick_x = smooth(vid_crick_x,round(vid_fps/8),'moving'); 
%         vid_crick_y = smooth(vid_crick_y,round(vid_fps/8),'moving');  

%         max_dist_jump = 30;
        nan_ind_x = isnan(vid_crick_x);
        nan_ind_y = isnan(vid_crick_y);

        x = 1:length(vid_crick_x);
        vid_crick_x_int = interp1(x(~nan_ind_x),vid_crick_x(~nan_ind_x),x);
        nan_ind_x_int = isnan(vid_crick_x_int);
%         vid_crick_x_sm_temp = smooth(vid_crick_x_int(~nan_ind_x_int),round(vid_fps)*4,'lowess');
        vid_crick_x = vid_crick_x_int';
%         vid_crick_x(~nan_ind_x_int) = vid_crick_x_sm_temp;
        

        y = 1:length(vid_crick_y);
        vid_crick_y_int = interp1(y(~nan_ind_y),vid_crick_y(~nan_ind_y),y);
        nan_ind_y_int = isnan(vid_crick_y_int);
%         vid_crick_y_sm_temp = smooth(vid_crick_y_int(~nan_ind_y_int),round(vid_fps)*4,'lowess');
        vid_crick_y = vid_crick_y_int';
%         vid_crick_y(~nan_ind_y_int) = vid_crick_y_sm_temp;


%         vid_crick_x(nan_ind_x) = 0;
%         vid_crick_y(nan_ind_y) = 0;
%         vid_crick_x = smooth(vid_crick_x,round(vid_fps),'rlowess'); 
%         vid_crick_y = smooth(vid_crick_y,round(vid_fps),'rlowess');  
%         vid_crick_x(nan_ind_x) = NaN;
%         vid_crick_y(nan_ind_y) = NaN;
    end    
    
%     figure;plot(vid_crick_x_orig);hold on
%     plot(vid_crick_x)
% 
%     figure; hold on
% %     plot(find(~nan_ind_x),vid_crick_x_int)
% %     plot(vid_crick_x_int)
%     plot(vid_crick_x_sm)
%     plot(vid_crick_x_orig)

    vid_head_speeds = [];
    for i = 1:length(head_inds)
        speed_i = [0; diff(sqrt(vid_head_x(:,i).^2 + vid_head_y(:,i).^2))];
        nan_ind = isnan(speed_i);
        speed_i(nan_ind) = 0;
        speed_i(speed_i > speed_cutoff | speed_i < -speed_cutoff) = 0;
        speed_i = smooth(speed_i,30,'lowess');
        speed_i(speed_i > speed_cutoff | speed_i < -speed_cutoff) = NaN;
        speed_i(nan_ind) = NaN;
        vid_head_speeds(:,i) = speed_i;

    end
    vid_body_speeds = [];
    for i = 1:length(body_inds)
        speed_i = [0; diff(sqrt(vid_body_x(:,i).^2 + vid_body_y(:,i).^2))];
        nan_ind = isnan(speed_i);
        speed_i(nan_ind) = 0;
        speed_i(speed_i > speed_cutoff | speed_i < -speed_cutoff) = 0;
        speed_i = smooth(speed_i,30,'lowess');
        speed_i(speed_i > speed_cutoff | speed_i < -speed_cutoff) = NaN;
        speed_i(nan_ind) = NaN;
        vid_body_speeds(:,i) = speed_i;

    end    
    
%     figure; hold on
%     plot(vid_body_speeds(:,1));
%     plot(vid_head_speeds(:,1));

    vid_head_speed = median(abs(vid_head_speeds(1:end,:)),2,'omitnan');
    vid_body_speed = median(abs(vid_body_speeds(1:end,:)),2,'omitnan');

%     figure; hold on
%     plot(vid_head_speed);
%     plot(vid_body_speed);

    % calc tortuosity
    tail_x_diff = tail_pose_x(:,1) - tail_pose_x(:,end);
    tail_y_diff = tail_pose_y(:,1) - tail_pose_y(:,end);
    len_butt_to_endtail = sqrt(tail_x_diff.^2 + tail_y_diff.^2);
    
    len_tail_path = zeros([size(tail_pose_x,1),1]);
    % calculate total tail path length
    for i = 1:size(tail_pose_x,2)-1
        tail_x_diff = tail_pose_x(:,i) - tail_pose_x(:,i+1);
        tail_y_diff = tail_pose_y(:,i) - tail_pose_y(:,i+1);
        segment_lens = sqrt(tail_x_diff.^2 + tail_y_diff.^2);
        len_tail_path = len_tail_path + segment_lens;
    end
    
    low_conf_inds = sum(tail_pose_conf(:,1:end) < conf_thresh,2) > 0;
    vid_tort_ratio = len_tail_path ./ len_butt_to_endtail;
    vid_tort_ratio(low_conf_inds) = NaN;

    % calculate angle between tail vectors
    tail_ind1 = 4;
    tail_ind_mid = 5;
    tail_ind2 = 6;
    conf_thresh = 0.7;
    
    vid_tail_tip_angle = [];
    for i = 1:size(tail_pose_x,1)
        if sum(tail_pose_conf(i,tail_ind1:tail_ind2) < conf_thresh) == 0
            u = [(tail_pose_x(i,tail_ind1) - tail_pose_x(i,tail_ind_mid)),...
                (tail_pose_y(i,tail_ind1) - tail_pose_y(i,tail_ind_mid)), 0];
            v = [(tail_pose_x(i,tail_ind2) - tail_pose_x(i,tail_ind_mid)),...
                (tail_pose_y(i,tail_ind2) - tail_pose_y(i,tail_ind_mid)), 0];    
            vid_tail_tip_angle(i) = atan2d(norm(cross(u,v)),dot(u,v));
        else
            vid_tail_tip_angle(i) = NaN;
        end
    end

    % get medians for head and body
    med_head_x = median(vid_head_x,2,'omitnan');
    med_head_y = median(vid_head_y,2,'omitnan');
    med_body_x = median(vid_body_x,2,'omitnan');
    med_body_y = median(vid_body_y,2,'omitnan');
    
    % exclude first head pose for this (nose)
    % using butt
    xdiff = median(vid_head_x(:,2:end),2,'omitnan') - vid_body_x(:,end);
    ydiff = median(vid_head_y(:,2:end),2,'omitnan') - vid_body_y(:,end);

% %     % using end tail
%     xdiff = median(vid_head_x(:,2:end),2,'omitnan')...
%         - median(tail_pose_x(:,2:end),2,'omitnan');
%     ydiff = median(vid_head_y(:,2:end),2,'omitnan')...
%         - median(tail_pose_y(:,2:end),2,'omitnan');
    vid_bodyLen = sqrt(xdiff.^2 + ydiff.^2); % pythagorean theorem
    vid_bodyLen = vid_bodyLen ./ median(vid_bodyLen,'omitnan');

    vid_distTrav = [];
    xdiff = [0; diff(vid_body_x(:,1))];
    ydiff = [0; diff(vid_body_y(:,1))];
    vid_distTrav = sqrt(xdiff.^2 + ydiff.^2); % pythagorean theorem

    head2crick_dist = [];
    xdiff = med_head_x - vid_crick_x;
    ydiff = med_head_y - vid_crick_y;
    head2crick_dist = sqrt(xdiff.^2 + ydiff.^2); % pythagorean theorem
    
    prev_ind = 1;
    vid_crickDelta = [];
    vid_crickDelta = [nan(1,prev_ind); ...
        head2crick_dist(prev_ind+1:end) - head2crick_dist(1:end-prev_ind)];
    
    vid_azimuth = [];
    for ind = 1:length(med_head_x)
        x1 = [med_head_x(ind) - med_body_x(ind)];
        x2 = [vid_crick_x(ind) - med_body_x(ind)];
        y1 = [med_head_y(ind) - med_body_y(ind)];
        y2 = [vid_crick_y(ind) - med_body_y(ind)];

        % https://www.mathworks.com/matlabcentral/answers/180131-how-can-i-find-the-angle-between-two-vectors-including-directional-information
        vid_azimuth(ind) = atan2d(x1*y2-y1*x2,x1*x2+y1*y2);
    end

    head_speeds{vid_i} = vid_fps*vid_head_speed/px_per_cm;
    body_speeds{vid_i} = vid_fps*vid_body_speed/px_per_cm;
    azimuth{vid_i} = vid_azimuth';
    crickDelta{vid_i} = vid_fps*vid_crickDelta/px_per_cm;
    distTrav{vid_i} = vid_distTrav/px_per_cm;
    tailTort{vid_i} = vid_tort_ratio;
    tailAng{vid_i} = vid_tail_tip_angle';
    bodyLen{vid_i} = vid_bodyLen;
end

% reformat into animals
anim_name_list = beh_vid_strct.anim_vals_vid;

pose_strct = {};
beh_strct = {};
anim_names = unique(anim_name_list);
for anim_i = 1:length(anim_names)
    anim_inds = [];
    for i = 1:length(anim_name_list)
        if strcmp(anim_names{anim_i},anim_name_list{i})
            anim_inds(end+1) = i;
        end
    end

    [anim_vid_vals, sort_ind] = sort(beh_vid_strct.day_vals_vid(anim_inds));
    
    prev_vid_val = 0;
    new_session = 1;   
    fr_total = 0;
    for vid_i = 1:length(anim_vid_vals)
        vid_val = find(unique(anim_vid_vals)==anim_vid_vals(vid_i));
        vid_ind = anim_inds(sort_ind(vid_i));

        if prev_vid_val == vid_val
            new_session = 0;
        else
            new_session = 1;
        end
        prev_vid_val = vid_val;
        
        if new_session
            pose_strct.head_speeds{anim_i}(vid_val) = head_speeds(vid_ind);
            pose_strct.body_speeds{anim_i}(vid_val) = body_speeds(vid_ind);
            pose_strct.azimuth{anim_i}(vid_val) = azimuth(vid_ind);
            pose_strct.crickDelta{anim_i}(vid_val) = crickDelta(vid_ind);
            pose_strct.distTrav{anim_i}(vid_val) = distTrav(vid_ind);
            pose_strct.tailTort{anim_i}(vid_val) = tailTort(vid_ind);
            pose_strct.tailAng{anim_i}(vid_val) = tailAng(vid_ind);
            pose_strct.bodyLen{anim_i}(vid_val) = bodyLen(vid_ind);
        
            beh_strct.beh_bouts{anim_i}(vid_val) = beh_vid_strct.beh_bouts(vid_ind);
            
            fr_total = length(head_speeds{vid_ind});
        else
            pose_strct.head_speeds{anim_i}(vid_val) = ...
                {[pose_strct.head_speeds{anim_i}{vid_val}; head_speeds{vid_ind}]};
            pose_strct.body_speeds{anim_i}(vid_val) = ...
                {[pose_strct.body_speeds{anim_i}{vid_val}; body_speeds{vid_ind}]};
            pose_strct.azimuth{anim_i}(vid_val) = ...
                {[pose_strct.azimuth{anim_i}{vid_val}; azimuth{vid_ind}]};
            pose_strct.crickDelta{anim_i}(vid_val) = ...
                {[pose_strct.crickDelta{anim_i}{vid_val}; crickDelta{vid_ind}]};
            pose_strct.distTrav{anim_i}(vid_val) = ...
                {[pose_strct.distTrav{anim_i}{vid_val}; distTrav{vid_ind}]};
            pose_strct.tailTort{anim_i}(vid_val) = ...
                {[pose_strct.tailTort{anim_i}{vid_val}; tailTort{vid_ind}]};
            pose_strct.tailAng{anim_i}(vid_val) = ...
                {[pose_strct.tailAng{anim_i}{vid_val}; tailAng{vid_ind}]};
            pose_strct.bodyLen{anim_i}(vid_val) = ...
                {[pose_strct.bodyLen{anim_i}{vid_val}; bodyLen{vid_ind}]};

            
            beh_bouts_toAdd = beh_vid_strct.beh_bouts{vid_ind};
            beh_bouts_toAdd(:,1:2) = beh_bouts_toAdd(:,1:2) + fr_total;
            beh_strct.beh_bouts{anim_i}(vid_val) = ...
                {[beh_strct.beh_bouts{anim_i}{vid_val}; beh_bouts_toAdd]};

            fr_total = fr_total + length(head_speeds{vid_ind});
        end

    end

    beh_strct.vid_day_vals{anim_i} = unique(anim_vid_vals);
    pose_strct.vid_fps{anim_i} = full_vid_fps(unique(anim_vid_vals));
end
beh_strct.anim_names = anim_names;

