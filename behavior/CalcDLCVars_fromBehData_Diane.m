function [full_data] = CalcDLCVars_fromBehData_Diane(pose_data,beh_data,head_or_body)

% TODO
% ive changed extractposevars to concatenate the multi-vid single session
% variables so i need to change the code in this function to reflect that



CrickEnterLab = 1;
FirstAppLab = 2;
LastAppLab = 3;
CapLab = 4;
EatLab = 5;

% not used currently
ignoreLab = 6;
stuckLab = 7;

% head_or_body = 2; %1 for head, 2 for body
pre_cap_sp_sec = 15;
post_cap_sp_sec = 4;

pre_cap_tail_sec = 50;
post_cap_tail_sec = 50;

set_vid_fps = 20;

num_anims = length(pose_data.head_speeds);
anim_names = beh_data.anim_names;

full_App_data = {};
full_Attack_data = {};
full_Eat_data = {};
full_cap_timecourse = {};

for anim_i = 1:num_anims
    
    disp(['Anim: ',num2str(anim_i),' - name: ',anim_names{anim_i}])

    anim_head_speed = pose_data.head_speeds{anim_i};
    anim_body_speed = pose_data.body_speeds{anim_i};
    anim_delta = pose_data.crickDelta{anim_i};
    anim_azi = pose_data.azimuth{anim_i};
    anim_distTrav = pose_data.distTrav{anim_i};
    anim_tailTort = pose_data.tailTort{anim_i};
    anim_tailAng = pose_data.tailAng{anim_i};
    anim_bodyLen = pose_data.bodyLen{anim_i};

    anim_beh_bouts = beh_data.beh_bouts{anim_i};
    anim_vid_session_vals = beh_data.vid_day_vals{anim_i};
    anim_vid_fps = pose_data.vid_fps{anim_i};

    num_vids = length(anim_head_speed);

    anim_App_sp = nan(1,max(anim_vid_session_vals));
    anim_Attack_sp = nan(1,max(anim_vid_session_vals));
    anim_Eat_sp = nan(1,max(anim_vid_session_vals));
    anim_BL_sp = nan(1,max(anim_vid_session_vals));
    anim_ICI_sp = nan(1,max(anim_vid_session_vals));
    
    anim_BL_dist = nan(1,max(anim_vid_session_vals));
    anim_ICI_dist = nan(1,max(anim_vid_session_vals));

    anim_App_delta = nan(1,max(anim_vid_session_vals));
    anim_Attack_delta = nan(1,max(anim_vid_session_vals));
    anim_Eat_delta = nan(1,max(anim_vid_session_vals));

    anim_App_azi = nan(1,max(anim_vid_session_vals));
    anim_Attack_azi = nan(1,max(anim_vid_session_vals));
    anim_Eat_azi = nan(1,max(anim_vid_session_vals));

    anim_App_tort = nan(1,max(anim_vid_session_vals));
    anim_Attack_tort = nan(1,max(anim_vid_session_vals));
    anim_Eat_tort = nan(1,max(anim_vid_session_vals));

    anim_App_tailAng = nan(1,max(anim_vid_session_vals));
    anim_Attack_tailAng = nan(1,max(anim_vid_session_vals));
    anim_Eat_tailAng = nan(1,max(anim_vid_session_vals));
    
    anim_all_cap_tc_sp = cell([1,max(anim_vid_session_vals)]);
    anim_all_cap_tc_delta = cell([1,max(anim_vid_session_vals)]);
    anim_all_cap_tc_azi = cell([1,max(anim_vid_session_vals)]);
    anim_all_cap_tc_tort = cell([1,max(anim_vid_session_vals)]);
    anim_all_cap_tc_tAng = cell([1,max(anim_vid_session_vals)]);
    anim_all_cap_tc_bodyLen = cell([1,max(anim_vid_session_vals)]);

    
    for vid_i = 1:num_vids
        
        try

            vid_beh_bouts = anim_beh_bouts{vid_i};
            vid_head_speed = anim_head_speed{vid_i};
            vid_body_speed = anim_body_speed{vid_i};
            vid_delta = anim_delta{vid_i};
            vid_azi = abs(anim_azi{vid_i});
            vid_distTrav = anim_distTrav{vid_i};
            vid_tailTort = anim_tailTort{vid_i};
            vid_tailAng = anim_tailAng{vid_i};
            vid_bodyLen = anim_bodyLen{vid_i};

            vid_fps = anim_vid_fps(vid_i);

            if head_or_body == 1
                vid_speed = vid_head_speed;
            else
                vid_speed = vid_body_speed;
            end

            % remove crickets with ignore label
            inds_2rem = [];
            vid_beh_bouts(end+1,:) = [vid_beh_bouts(end,2),vid_beh_bouts(end,2),1];
            crickEnter_inds = find(vid_beh_bouts(:,3) == CrickEnterLab);
            for crick_i = 1:length(crickEnter_inds)-1
                beh_inds = crickEnter_inds(crick_i):crickEnter_inds(crick_i+1)-1;
                if ~isempty(beh_inds(vid_beh_bouts(beh_inds,3) == ignoreLab))
                    inds_2rem = [inds_2rem, beh_inds];
                end
                if ~isempty(beh_inds(vid_beh_bouts(beh_inds,3) == stuckLab))
                    inds_2rem = [inds_2rem, beh_inds];
                end                
            end
            vid_beh_bouts(inds_2rem,:) = [];
            
            % get beh times for baseline before hunt
            BL_frames = 1:vid_beh_bouts(1,1);
            anim_BL_sp(1,anim_vid_session_vals(vid_i)) = mean(vid_head_speed(BL_frames),'omitnan');
            anim_BL_dist(1,anim_vid_session_vals(vid_i)) = sum(vid_distTrav(BL_frames),'omitnan');
%             else
%                 
%                 if vid_beh_bouts(1,3) ~= 1
%                     vid_beh_bouts = [1,1,1; vid_beh_bouts];
%                 end
% 
%             end

            % get beh times for ICIs
            CrickEnter_inds = find(vid_beh_bouts(:,3) == CrickEnterLab);
            Eat_inds = find(vid_beh_bouts(:,3) == EatLab);
%             CrickEnter_inds(1) = []; % get rid of first which would correspond to baseline period
            if isempty(Eat_inds)
                disp(['Skipping vid because no eats found: ',num2str(vid_i)])
            else
                for i = 2:length(CrickEnter_inds)
                    hunt_rows = CrickEnter_inds(i-1):CrickEnter_inds(i);
                    hunt_eat_inds = find(vid_beh_bouts(hunt_rows,3) == EatLab);
                    
                    if isempty(hunt_eat_inds)
                        disp('missing eat label')
%                         keyboard
                    else
                        ind1 = max(hunt_eat_inds) + hunt_rows(1) - 1;
                        ind2 = CrickEnter_inds(i);
                        num_rows = sum(anim_ICI_sp(:,anim_vid_session_vals(vid_i)) > 0);
                        anim_ICI_sp(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                            nanmean(vid_speed(vid_beh_bouts(ind1,2):vid_beh_bouts(ind2,1)));
                        anim_ICI_dist(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                            sum(vid_distTrav(vid_beh_bouts(ind1,2):vid_beh_bouts(ind2,1)));
                    end
                end   
            end

            FirstApp_inds = find(vid_beh_bouts(:,3) == FirstAppLab);
            for i = 1:length(FirstApp_inds)
                ind = FirstApp_inds(i);
                num_rows = sum(anim_App_sp(:,anim_vid_session_vals(vid_i)) > 0);
                anim_App_sp(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_speed(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_App_delta(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_delta(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_App_azi(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_azi(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_App_tort(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailTort(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_App_tailAng(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailAng(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
            end
        
            Attack_inds = find(vid_beh_bouts(:,3) == LastAppLab);
            for i = 1:length(Attack_inds)
                ind = Attack_inds(i);
                num_rows = sum(anim_Attack_sp(:,anim_vid_session_vals(vid_i)) > 0);
                anim_Attack_sp(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_speed(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Attack_delta(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_delta(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Attack_azi(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_azi(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Attack_tort(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailTort(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Attack_tailAng(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailAng(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));

            end
        
            Eat_inds = find(vid_beh_bouts(:,3) == EatLab);
            for i = 1:length(Eat_inds)
                ind = Eat_inds(i);
                num_rows = sum(anim_Eat_sp(:,anim_vid_session_vals(vid_i)) > 0);
                anim_Eat_sp(num_rows+1,anim_vid_session_vals(vid_i)) = ...                
                    nanmean(vid_speed(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Eat_delta(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_delta(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Eat_azi(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_azi(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Eat_tort(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailTort(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));
                anim_Eat_tailAng(num_rows+1,anim_vid_session_vals(vid_i)) = ...
                    nanmean(vid_tailAng(vid_beh_bouts(ind,1):vid_beh_bouts(ind,2)));                
            end
        
            Cap_rows = find(vid_beh_bouts(:,3) == CapLab);
            for i = 1:length(Cap_rows)
                ind = Cap_rows(i);
                pre_ind = vid_beh_bouts(ind,2) - pre_cap_sp_sec*vid_fps;
                post_ind = vid_beh_bouts(ind,2) + post_cap_sp_sec*vid_fps;
                comb_sec = pre_cap_sp_sec+post_cap_sp_sec;

                if pre_ind < 1
                    buff_len = abs(pre_ind) + 1;
                    pre_ind = pre_ind + buff_len;
                    post_ind = post_ind + buff_len;
                    vid_tailTort = [nan(buff_len,1); vid_tailTort];
                    vid_tailAng = [nan(buff_len,1); vid_tailAng];
                end     
                if post_ind > length(vid_speed)
                    vid_speed = [vid_speed; nan(comb_sec*vid_fps,1)];
                    vid_delta = [vid_delta; nan(comb_sec*vid_fps,1)];
                    vid_azi = [vid_azi; nan(comb_sec*vid_fps,1)];
                end

                orig_inds = pre_ind:post_ind+1;
                x_orig = 1/vid_fps:1/vid_fps:(comb_sec+2/vid_fps);
                x_resamp = 1/set_vid_fps:1/set_vid_fps:(comb_sec+1/set_vid_fps);
                tc_inds = round(interp1(x_orig,orig_inds,x_resamp));

                anim_all_cap_tc_sp{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_sp{anim_vid_session_vals(vid_i)}; vid_speed(tc_inds)'];
                anim_all_cap_tc_delta{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_delta{anim_vid_session_vals(vid_i)}; vid_delta(tc_inds)'];
                anim_all_cap_tc_azi{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_azi{anim_vid_session_vals(vid_i)}; vid_azi(tc_inds)'];
            end
            
            % collect capture timecourses for longer behavior windows
            for i = 1:length(Cap_rows)
                ind = Cap_rows(i);
                pre_ind = vid_beh_bouts(ind,2) - pre_cap_tail_sec*vid_fps;
                post_ind = vid_beh_bouts(ind,2) + post_cap_tail_sec*vid_fps;
                comb_sec = post_cap_tail_sec+pre_cap_tail_sec;

                if pre_ind < 1
                    buff_len = abs(pre_ind) + 1;
                    pre_ind = pre_ind + buff_len;
                    post_ind = post_ind + buff_len;
                    vid_tailTort = [nan(buff_len,1); vid_tailTort];
                    vid_tailAng = [nan(buff_len,1); vid_tailAng];
                    vid_bodyLen = [nan(buff_len,1); vid_bodyLen];
                end                
                if post_ind > length(vid_tailTort)
                    vid_tailTort = [vid_tailTort; nan(comb_sec*vid_fps,1)];
                    vid_tailAng = [vid_tailAng; nan(comb_sec*vid_fps,1)];
                    vid_bodyLen = [vid_bodyLen; nan(comb_sec*vid_fps,1)];
                end

                orig_inds = pre_ind:post_ind+1;
                x_orig = 1/vid_fps:1/vid_fps:(comb_sec+2/vid_fps);
                x_resamp = 1/set_vid_fps:1/set_vid_fps:(comb_sec+1/set_vid_fps);
                tc_inds = round(interp1(x_orig,orig_inds,x_resamp));
                
                anim_all_cap_tc_tort{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_tort{anim_vid_session_vals(vid_i)}; vid_tailTort(tc_inds)'];
                anim_all_cap_tc_tAng{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_tAng{anim_vid_session_vals(vid_i)}; vid_tailAng(tc_inds)'];
                anim_all_cap_tc_bodyLen{anim_vid_session_vals(vid_i)} = ...
                    [anim_all_cap_tc_bodyLen{anim_vid_session_vals(vid_i)}; vid_bodyLen(tc_inds)'];                
            end

        catch ME
            disp(ME)
            keyboard
        end
    end

    anim_cap_tc_sp = [];
    anim_cap_tc_delta = [];
    anim_cap_tc_azi = [];
    anim_cap_tc_tort = [];
    anim_cap_tc_tAng = [];
    anim_cap_tc_bodyLen = [];
    for i = 1:length(anim_all_cap_tc_sp)
        anim_cap_tc_sp(i,:) = mean(anim_all_cap_tc_sp{i},'omitnan');
        anim_cap_tc_delta(i,:) = mean(anim_all_cap_tc_delta{i},'omitnan');
        anim_cap_tc_azi(i,:) = mean(anim_all_cap_tc_azi{i},'omitnan');
        anim_cap_tc_tort(i,:) = mean(anim_all_cap_tc_tort{i},'omitnan');
        anim_cap_tc_tAng(i,:) = mean(anim_all_cap_tc_tAng{i},'omitnan');
        anim_cap_tc_bodyLen(i,:) = mean(anim_all_cap_tc_bodyLen{i},'omitnan');
    end
    
    % longwinded way of turning zeros in this data to Nan. This happens
    % because the matrix will fill in zeros when the size changes...
    anim_App_sp(anim_App_sp==0) = NaN;
    anim_Attack_sp(anim_Attack_sp==0) = NaN;
    anim_Eat_sp(anim_Eat_sp==0) = NaN;
    anim_BL_sp(anim_BL_sp==0) = NaN;
    anim_ICI_sp(anim_ICI_sp==0) = NaN;
    
    anim_BL_dist(anim_BL_dist==0) = NaN;
    anim_ICI_dist(anim_ICI_dist==0) = NaN;

    anim_App_delta(anim_App_delta==0) = NaN;
    anim_Attack_delta(anim_Attack_delta==0) = NaN;
    anim_Eat_delta(anim_Eat_delta==0) = NaN;

    anim_App_azi(anim_App_azi==0) = NaN;
    anim_Attack_azi(anim_Attack_azi==0) = NaN;
    anim_Eat_azi(anim_Eat_azi==0) = NaN;

    anim_App_tort(anim_App_tort==0) = NaN;
    anim_Attack_tort(anim_Attack_tort==0) = NaN;
    anim_Eat_tort(anim_Eat_tort==0) = NaN;

    anim_App_tailAng(anim_App_tailAng==0) = NaN;
    anim_Attack_tailAng(anim_Attack_tailAng==0) = NaN;
    anim_Eat_tailAng(anim_Eat_tailAng==0) = NaN;

    % log anim data
    full_App_data.speed{anim_i} = anim_App_sp;
    full_Attack_data.speed{anim_i} = anim_Attack_sp;
    full_Eat_data.speed{anim_i} = anim_Eat_sp;
    full_BL_data.speed{anim_i} = anim_BL_sp;
    full_ICI_data.speed{anim_i} = anim_ICI_sp;

    full_BL_data.dist{anim_i} = anim_BL_dist;
    full_ICI_data.dist{anim_i} = anim_ICI_dist;

    full_App_data.delta{anim_i} = anim_App_delta;
    full_Attack_data.delta{anim_i} = anim_Attack_delta;
    full_Eat_data.delta{anim_i} = anim_Eat_delta;

    full_App_data.azi{anim_i} = anim_App_azi;
    full_Attack_data.azi{anim_i} = anim_Attack_azi;
    full_Eat_data.azi{anim_i} = anim_Eat_azi;

    full_App_data.tort{anim_i} = anim_App_tort;
    full_Attack_data.tort{anim_i} = anim_Attack_tort;
    full_Eat_data.tort{anim_i} = anim_Eat_tort;

    full_App_data.tailAng{anim_i} = anim_App_tailAng;
    full_Attack_data.tailAng{anim_i} = anim_Attack_tailAng;
    full_Eat_data.tailAng{anim_i} = anim_Eat_tailAng;

    full_cap_timecourse.speed{anim_i} = anim_cap_tc_sp;
    full_cap_timecourse.delta{anim_i} = anim_cap_tc_delta;
    full_cap_timecourse.azi{anim_i} = anim_cap_tc_azi;
    full_cap_timecourse.tort{anim_i} = anim_cap_tc_tort;
    full_cap_timecourse.tailAng{anim_i} = anim_cap_tc_tAng;
    full_cap_timecourse.bodyLen{anim_i} = anim_cap_tc_bodyLen;
end

full_data = {};
full_data.App_data = full_App_data;
full_data.Attack_data = full_Attack_data;
full_data.Eat_data = full_Eat_data;
full_data.BL_data = full_BL_data;
full_data.ICI_data = full_ICI_data;

full_data.cap_timecourse = full_cap_timecourse;

end