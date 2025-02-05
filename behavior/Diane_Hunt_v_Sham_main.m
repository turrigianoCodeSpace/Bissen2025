
% go through hunting and immob cricket 'hunting' DLC datasets and compare
% meaures of speed between them

% requires that the folders only contain DLC files with matching
% labeledInds.csv files

% TODO:


%%% PARAMS TO SET %%%

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% real hunting dlc path
hunt_dlc_path = 'Z:\DianeBissen\Cricket hunting videos\Craniotomy hunting videos_DLC\';

% 'sham' hunts immobilized crickets
sham_dlc_path = 'Z:\DianeBissen\Cricket hunting videos\Craniotomy immobilized crickets videos_DLC\';

% non craniotomy hunts
noncran_dlc_path = 'Z:\DianeBissen\Cricket hunting videos\Non-craniotomy videos\';

set_vid_fps = 20;
vid_type = '.avi';
px_per_cm = 11.248;

% list day strings
day_vals = [1,2,3,6];
day_strs = {'day1','day2','day3','day6'};
animal_strs = {'YFP','YB'};

%%%%%%%%%%%%%%%%%%%%%

% load pre extracted dlc sturctures?
pre_load_YES = 1;

if pre_load_YES == 1
    try
        pre_ext_dlc_path = "\\files.brandeis.edu\turrigiano-lab\BrianCary\CODE\CricketCode\Diane\stored_data\full_extracted_dlc_strcts_3cond.mat";
        load(pre_ext_dlc_path);
    catch
        pre_ext_dlc_path = "Z:\BrianCary\CODE\CricketCode\Diane\stored_data\full_extracted_dlc_strcts_3cond.mat";
        load(pre_ext_dlc_path);
    end
else

    % load dlc variables into structure
    [hunt_dlc, crick_pose_labels, hunt_dlc_files] = DLC_poseExtractor_v2_fileNames(hunt_dlc_path);
    % hunt_dlc_files = dir([hunt_dlc_path,'*DLC*.csv']);
    
    [sham_dlc, sham_pose_labels] = DLC_poseExtractor_v2_fileNames(sham_dlc_path);
    sham_dlc_files = dir([sham_dlc_path,'*DLC*.csv']);
    
    [noncran_dlc, noncran_pose_labels] = DLC_poseExtractor_v2_fileNames(noncran_dlc_path);
    noncran_dlc_files = dir([noncran_dlc_path,'*DLC*.csv']);

end

%% load and check data

% load behavior labeledinds data into structure matching dlc structure
hunt_behBout_files = dir([hunt_dlc_path,'*LabeledBouts*.csv']);
sham_behBout_files = dir([sham_dlc_path,'*LabeledBouts*.csv']);
noncran_behBout_files = dir([noncran_dlc_path,'*LabeledBouts*.csv']);
hunt_behInd_files = dir([hunt_dlc_path,'*LabeledInds*.csv']);
sham_behInd_files = dir([sham_dlc_path,'*LabeledInds*.csv']);
noncran_behInd_files = dir([noncran_dlc_path,'*LabeledInds*.csv']);


bout_lab_str = '_LabeledBouts';
% check beh and dlc files in same order...
for dlc_i = 1:length(hunt_dlc_files)
    beh_file_sp = split(hunt_behBout_files(dlc_i).name,bout_lab_str);
    filename_i = beh_file_sp{1};
    if isempty(strfind(hunt_dlc_files(dlc_i).name,filename_i))
        disp('file mismatch')
        keyboard
    end
end
for dlc_i = 1:length(sham_dlc_files)
    beh_file_sp = split(sham_behBout_files(dlc_i).name,bout_lab_str);
    filename_i = beh_file_sp{1};
    if isempty(strfind(sham_dlc_files(dlc_i).name,filename_i))
        disp('file mismatch')
        keyboard
    end
end
% bout_lab_str = 'LabeledBouts';
for dlc_i = 1:length(noncran_dlc_files)
    beh_file_sp = split(noncran_behBout_files(dlc_i).name,bout_lab_str);
    filename_i = beh_file_sp{1};
    if isempty(strfind(noncran_dlc_files(dlc_i).name,filename_i))
        disp('file mismatch')
        keyboard
    end
end
disp('Files not mismatched!')

hunt_tab = readtable([hunt_dlc_path filesep hunt_behInd_files(1).name],'format','auto');
hunt_labels = hunt_tab.Properties.VariableNames(2:end);

hunt_day_vals_vid = [];
hunt_anim_vals_vid = [];
hunt_behBouts = {};
for file_i = 1:length(hunt_behBout_files)
    filename = hunt_behBout_files(file_i).name;
    try
        file_load = csvread([hunt_dlc_path, filesep, filename],1);
        hunt_behBouts{file_i} = file_load(:,1:end);
    catch
        hunt_behBouts{file_i} = [1,2,0];
    end

    for i = 1:length(day_strs)
        if ~isempty(strfind(filename,day_strs{i}))
            hunt_day_vals_vid(file_i) = day_vals(i);
        end
    end

    for i = 1:length(animal_strs)
        anim_name_ind = strfind(filename,animal_strs{i});
        if ~isempty(anim_name_ind)
            filename_str = filename(anim_name_ind:end);
            filename_str_sp = split(filename_str,'-');
            hunt_anim_vals_vid{file_i} = [filename_str_sp{1},'-',filename_str_sp{2}];
        end
    end
end
hunt_behInd_strct = {};
for file_i = 1:length(hunt_behInd_files)
    file_load = csvread([hunt_dlc_path, filesep, hunt_behInd_files(file_i).name],1);
    hunt_behInd_strct{file_i} = file_load(:,2:end);
end

noncran_tab = readtable([noncran_dlc_path filesep noncran_behInd_files(1).name],'format','auto');
noncran_labels = noncran_tab.Properties.VariableNames(2:end);

noncran_day_vals_vid = [];
noncran_anim_vals_vid = [];
noncran_behBouts = {};
for file_i = 1:length(noncran_behBout_files)
    filename = noncran_behBout_files(file_i).name;
    try
        file_load = csvread([noncran_dlc_path, filesep, filename],1);
        noncran_behBouts{file_i} = file_load(:,1:end);
    catch
        noncran_behBouts{file_i} = [1,2,0];
    end

    for i = 1:length(day_strs)
        if ~isempty(strfind(filename,day_strs{i}))
            noncran_day_vals_vid(file_i) = day_vals(i);
        end
    end

    for i = 1:length(animal_strs)
        anim_name_ind = strfind(filename,animal_strs{i});
        if ~isempty(anim_name_ind)
            filename_str = filename(anim_name_ind:end);
            filename_str_sp = split(filename_str,'-');
            noncran_anim_vals_vid{file_i} = [filename_str_sp{1},'-',filename_str_sp{2}];
        end
    end
end

sham_tab = readtable([sham_dlc_path filesep sham_behInd_files(1).name],'format','auto');
sham_labels = sham_tab.Properties.VariableNames(2:end);

% sham_day_vals = [];
sham_anim_vals_vid = [];
sham_day_vals_vid = [];
sham_behBouts = {};
for file_i = 1:length(sham_behBout_files)
    filename = sham_behBout_files(file_i).name;
    try
        file_load = csvread([sham_dlc_path, filesep, filename],1);
        sham_behBouts{file_i} = file_load(:,1:end);
    catch
        sham_behBouts{file_i} = [1,2,0];
    end    

    vid_str_ind = strfind(filename,'_VIDEO');
    if ~isempty(vid_str_ind)
        sham_day_vals_vid(file_i) = str2double(filename(vid_str_ind-1));
    end

    for i = 1:length(animal_strs)
        anim_name_ind = strfind(filename,animal_strs{i});
        if ~isempty(anim_name_ind)
            filename_str = filename(anim_name_ind:end);
            filename_str_sp = split(filename_str,'-');
            sham_anim_vals_vid{file_i} = [filename_str_sp{1},'-',filename_str_sp{2}];
        end
    end

end

%% extract speeds and compile animal structures
vid_meta = {};
vid_meta.set_vid_fps = set_vid_fps;
vid_meta.vid_type = vid_type;
vid_meta.px_per_cm = px_per_cm;

hunt_beh_vid_strct = {};
hunt_beh_vid_strct.beh_bouts = hunt_behBouts;
hunt_beh_vid_strct.day_vals_vid = hunt_day_vals_vid;
hunt_beh_vid_strct.anim_vals_vid = hunt_anim_vals_vid;
[hunt_pose_strct, hunt_beh_strct] = ExtractPoseVars_CompileAnimStrct(...
                                        hunt_dlc_path, hunt_dlc, hunt_beh_vid_strct, vid_meta);


vid_meta.set_vid_fps = 30;
sham_beh_vid_strct = {};
sham_beh_vid_strct.beh_bouts = sham_behBouts;
sham_beh_vid_strct.day_vals_vid = sham_day_vals_vid;
sham_beh_vid_strct.anim_vals_vid = sham_anim_vals_vid;
[sham_pose_strct, sham_beh_strct] = ExtractPoseVars_CompileAnimStrct(...
                                        sham_dlc_path, sham_dlc, sham_beh_vid_strct, vid_meta);

vid_meta.set_vid_fps = set_vid_fps;
noncran_beh_vid_strct = {};
noncran_beh_vid_strct.beh_bouts = noncran_behBouts;
noncran_beh_vid_strct.day_vals_vid = noncran_day_vals_vid;
noncran_beh_vid_strct.anim_vals_vid = noncran_anim_vals_vid;
[noncran_pose_strct, noncran_beh_strct] = ExtractPoseVars_CompileAnimStrct(...
                                        noncran_dlc_path, noncran_dlc, noncran_beh_vid_strct, vid_meta);




head_or_body = 1; % 1 for head 2 for body
[hunt_data] = CalcDLCVars_fromBehData_Diane(hunt_pose_strct,hunt_beh_strct,head_or_body);

[sham_data] = CalcDLCVars_fromBehData_Diane(sham_pose_strct,sham_beh_strct,head_or_body);

[noncran_data] = CalcDLCVars_fromBehData_Diane(noncran_pose_strct,noncran_beh_strct,head_or_body);



%% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Plotting %%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% scatters
str = '#A2142F'; % deep red color
red_color = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;


cond_str = 'sham';
beh_str = 'Attack'; %App, Attack, Eat, BL, ICI
dlc_var_str = 'speed';

input_data = eval([cond_str,'_data.',beh_str,'_data.',dlc_var_str]);

data_toplot = nan(length(input_data),size(input_data{1},2));
for anim_i = 1:length(input_data)
    data_row = mean(input_data{anim_i},1,'omitnan');
    data_toplot(anim_i,1:length(data_row)) = mean(input_data{anim_i},1,'omitnan');
end
data_toplot(:,sum(isnan(data_toplot))==size(data_toplot,1)) = [];

switch cond_str
    case 'hunt'
%         base_color = [1 0.3 0.3];
        base_color = red_color;
        cond_plot_name = 'Hunting';
    case 'sham'
        base_color = [0.2 0.2 0.2];
        cond_plot_name = 'Control';
    case 'noncran'
        base_color = [0.6 0.6 0.6];
        cond_plot_name = 'Non-cran Hunt';
end

switch dlc_var_str
    case 'speed'
        y_str = 'Head Speed (cm/sec)';
        % ylabel('Body Speed (px/sec)','FontSize',14)
    case 'azi'
         y_str = 'Azimuth - Angle to cricket (deg)';
    case 'delta'
        y_str = 'Animal to cricket delta (cm/sec)';
    case 'tort'
        y_str = 'Tail tortuosity ratio';
    case 'tailAng'
        y_str = 'Tail Angle (deg)';
    case 'bodyLen'
        y_str = 'Body Length (cm)';
    case 'dist'
        y_str = 'Distance Traveled (cm)';
end

c_coefs = linspace(0.5,1,size(data_toplot,2));
colors_toPlot = [];
for i = 1:size(data_toplot,2)
    colors_toPlot(i,:) = base_color.*c_coefs(i);
end

figure_coords = [550 543 514 381];
f2 = figure('Position',figure_coords);
p1 = UnivarScatter_ATP(data_toplot,'BoxType','SEM',...
    'Width',1.25,'Compression',120,'MarkerFaceColor',colors_toPlot,...
    'PointSize',35,'StdColor','none','SEMColor',[0 0 0],...
    'Whiskers','lines','WhiskerLineWidth',2,'MarkerEdgeColor',colors_toPlot);

box off

ylabel(y_str)
xticks(1:length(day_strs))
x_lab_strs = day_strs;
set(gca,'XTickLabel',x_lab_strs,'XTickLabelRotation',45,'FontSize',10)
set(gca,'TickLabelInterpreter','none')

title_str = {['Behavior data across days (animal avgs)'],...
             ['Cond=',cond_plot_name,' -- Beh=',beh_str,' -- DLCvar=',dlc_var_str]};
title(title_str,'FontSize',12)


% ylim([150 1600])
% ylim([125 180])
ylim([0 11])
% ylim([0 6.5])


t = table(data_toplot(:,1),data_toplot(:,2),data_toplot(:,3),data_toplot(:,4),...
            'VariableNames',{'day1','day2','day3','day6'});
Sesh = [1, 2, 3, 4];
% Fit the repeated measures model
rmModel = fitrm(t, 'day1-day6~1', 'WithinDesign', Sesh);
rmANOVA = ranova(rmModel) % general test for all conditions

% tests specific pairs
[c] = multcompare(rmModel,'Time') % defaults to tukey-kramer critical value

p_cons12 = c.pValue(1);
p_cons13 = c.pValue(2);


% % first round stats
% groups = {[1,2],[1,3],[1,4]}; % groups to do stats comoparison
% p_vals = [];
% for i = 1:length(groups)
%     [p,h,stats] = signrank(data_toplot(:,groups{i}(1)),data_toplot(:,groups{i}(2)));
% %     [h,p,ci,stats] = ttest2(data_toplot(:,groups{i}(1)),data_toplot(:,groups{i}(2)));
%     p_vals(end+1) = p*length(groups);
% end
% 
% not_sig_inds = p_vals > 0.05;
% p_vals(not_sig_inds) = [];
% groups(not_sig_inds) = [];
% 
% sigstar(groups,p_vals)

% %test normality
% norm_data = (data_toplot(:) - nanmean(data_toplot(:)))/nanstd(data_toplot(:));
% [h,p,ksstat,cv] = kstest(norm_data)
% 
% figure;
% hist(norm_data,10)


%% plot ICI speed double graph

cond_str = 'sham';
beh_str = 'ICI';
dlc_var_str = 'speed';

if strcmp(cond_str,'sham')
    xvals = [1,3,5,7];
else
    xvals = [1.75,3.75,5.75,7.75];
end

input_data = eval([cond_str,'_data.',beh_str,'_data.',dlc_var_str]);

if strcmp(cond_str,'sham')
    
    data_toplot_sham = nan(length(input_data),size(input_data{1},2));
    for anim_i = 1:length(input_data)
        data_row = mean(input_data{anim_i},1,'omitnan');
        data_toplot_sham(anim_i,1:length(data_row)) = mean(input_data{anim_i},1,'omitnan');
    end
    data_toplot_sham(:,sum(isnan(data_toplot_sham))==size(data_toplot_sham,1)) = [];

else
    data_toplot_hunt = nan(length(input_data),size(input_data{1},2));
    for anim_i = 1:length(input_data)
        data_row = mean(input_data{anim_i},1,'omitnan');
        data_toplot_hunt(anim_i,1:length(data_row)) = mean(input_data{anim_i},1,'omitnan');
    end
    data_toplot_hunt(:,sum(isnan(data_toplot_hunt))==size(data_toplot_hunt,1)) = [];    
end

switch cond_str
    case 'hunt'
%         base_color = [1 0.3 0.3];
        base_color = red_color;
        cond_plot_name = 'Hunting';
    case 'sham'
        base_color = [0.2 0.2 0.2];
        cond_plot_name = 'Control';
    case 'noncran'
        base_color = [0.6 0.6 0.6];
        cond_plot_name = 'Non-cran Hunt';
end

switch dlc_var_str
    case 'speed'
        y_str = 'Head Speed (cm/sec)';
        % ylabel('Body Speed (px/sec)','FontSize',14)
    case 'azi'
         y_str = 'Azimuth - Angle to cricket (deg)';
    case 'delta'
        y_str = 'Animal to cricket delta (cm/sec)';
    case 'tort'
        y_str = 'Tail tortuosity ratio';
    case 'tailAng'
        y_str = 'Tail Angle (deg)';
    case 'bodyLen'
        y_str = 'Body Length (cm)';
    case 'dist'
        y_str = 'Distance Traveled (cm)';
end

c_coefs = linspace(0.5,1,size(data_toplot_sham,2));
colors_toPlot = [];
for i = 1:size(data_toplot_sham,2)
%     colors_toPlot(i,:) = base_color.*c_coefs(i);
    colors_toPlot(i,:) = base_color;
end

figure_coords = [550 543 514 381];
if strcmp(cond_str,'sham')
    f2 = figure('Position',figure_coords); hold on;
    p1 = UnivarScatter_ATP(data_toplot_sham,'BoxType','SEM',...
        'Width',1.25,'Compression',120,'MarkerFaceColor',colors_toPlot,...
        'PointSize',35,'StdColor','none','SEMColor',[0 0 0],...
        'Whiskers','lines','WhiskerLineWidth',2,'MarkerEdgeColor',colors_toPlot,...
        'X_VALS',xvals);
else
    p2 = UnivarScatter_ATP(data_toplot_hunt,'BoxType','SEM',...
        'Width',1.25,'Compression',120,'MarkerFaceColor',colors_toPlot,...
        'PointSize',35,'StdColor','none','SEMColor',[0 0 0],...
        'Whiskers','lines','WhiskerLineWidth',2,'MarkerEdgeColor',colors_toPlot,...
        'X_VALS',xvals);
end
box off

ylabel(y_str)
xticks([1.375,3.375,5.375,7.375])
x_lab_strs = day_strs;
set(gca,'XTickLabel',x_lab_strs,'XTickLabelRotation',45,'FontSize',10)
set(gca,'TickLabelInterpreter','none')

title_str = {['Behavior data across days (animal avgs)'],...
             ['Cond=',cond_plot_name,' -- Beh=',beh_str,' -- DLCvar=',dlc_var_str]};
title(title_str,'FontSize',12)

% ylim([150 1600])
% ylim([125 180])
% ylim([0 11])
ylim([0 6.5])

% legend([p1{1},p2{2}],{'Mock','Hunt'})

% format data for anova
beh_data = [];
% days = {};
days = [];
cond = {};
for i = 1:size(data_toplot_sham,2)
    beh_i = data_toplot_sham(:,i);
    beh_data = [beh_data; beh_i];
% 
%     day_i = {};
%     day_i(1:length(beh_i)) = cellstr(int2str(i));
%     days = [days; day_i'];
%     
    day_i = i*ones([length(beh_i),1]);
    days = [days; day_i];
end
cond1_len = length(beh_data);
cond(1:cond1_len) = cellstr('mock');

if exist('data_toplot_hunt')
    for i = 1:size(data_toplot_hunt,2)
        beh_i = data_toplot_hunt(:,i);
        beh_data = [beh_data; beh_i];
    
    %     day_i = {};
    %     day_i(1:length(beh_i)) = cellstr(int2str(i));
    %     days = [days; day_i'];
    
        day_i = i*ones([length(beh_i),1]);
        days = [days; day_i];
    end
    cond(cond1_len+1:length(beh_data)) = cellstr('hunt');
    
    cond = cond';
    
    [p,tbl,stats] = anovan(beh_data,{cond days},'model',2,'varnames',{'cond','days'})
    [results,~,~,gnames] = multcompare(stats,"Dimension",[1 2]);
    
    coeffs = {stats.coeffnames, stats.coeffs};
end

%% plot the timecourse of speed
sessions_toPlot = [6];
dlc_var_str = 'tailAng'; %tailAng etc.

test_presec = 5;

for sesh_i = sessions_toPlot

    sesh_toPlot = sesh_i;
    hunt_cap_timecourse = eval(['hunt_data.cap_timecourse.',dlc_var_str]);
    hunt_tc_toplot = [];
    for anim_i = 1:length(hunt_cap_timecourse)
        anim_data = hunt_cap_timecourse{anim_i};
        if size(anim_data,1) < sesh_toPlot(end)
            hunt_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot(1:end-1),:),1,'omitnan');
        else
            hunt_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot,:),1,'omitnan');
        end    
    end
    
    % have to resmple sham/control due to diff fps
    sham_cap_timecourse = eval(['sham_data.cap_timecourse.',dlc_var_str]);
    sham_tc_toplot = [];
    for anim_i = 1:length(sham_cap_timecourse)
        anim_data = sham_cap_timecourse{anim_i};
        if size(anim_data,1) < sesh_toPlot(end)
            sham_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot(1:end-1),:),1,'omitnan');
        else
            sham_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot,:),1,'omitnan');
        end    
    end
    
    noncran_cap_timecourse = eval(['noncran_data.cap_timecourse.',dlc_var_str]);
    noncran_tc_toplot = [];
    for anim_i = 1:length(noncran_cap_timecourse)
        anim_data = noncran_cap_timecourse{anim_i};
        if size(anim_data,1) < sesh_toPlot(end)
            noncran_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot(1:end-1),:),1,'omitnan');
        else
            noncran_tc_toplot(anim_i,:) = mean(anim_data(sesh_toPlot,:),1,'omitnan');
        end    
    end
    
    figure_coords = [78 576 626 383];
    f3 = figure('Position',figure_coords);
    
    Colors = [0 0 0; 0.45 0.45 0.45; red_color];

    switch dlc_var_str
        case 'speed'
            xlim([-15,5])
            pre_cap_sec = 15;
            y_str = 'Head Speed (cm/sec)';
            % ylabel('Body Speed (px/sec)','FontSize',14)
        case 'azi'
            xlim([-15,5])
            pre_cap_sec = 15;
             y_str = 'Azimuth - Angle to cricket (deg)';
        case 'delta'
            xlim([-15,5])
            pre_cap_sec = 15;
            y_str = 'Animal to cricket delta (cm/sec)';
        case 'tort'
            xlim([-50,50])
            pre_cap_sec = 50;
            y_str = 'Tail tortuosity ratio';
        case 'tailAng'
            xlim([-50,50])
            pre_cap_sec = 50;
            y_str = 'Tail Angle (deg)';
        case 'bodyLen'
            xlim([-50,50])
            pre_cap_sec = 50;
            y_str = 'Body Length (cm)';
    end
    
    vid_fps = set_vid_fps;
    edges_toPlot = 1/vid_fps:1/vid_fps:size(hunt_tc_toplot,2)/vid_fps;
    edges_toPlot = edges_toPlot - pre_cap_sec;
    % plot(edges_toPlot,sham_cap_timecourse','color',[0 0 0 0.1])
    hold on;
    
    alpha = 0.2;
    sh_color = Colors(1,:);
    s1 = stdshade(sham_tc_toplot,alpha,sh_color,edges_toPlot,1,'sem');
    s1.LineWidth = 2;
    
%     alpha = 0.45;
%     sh_color = Colors(2,:);
%     s2 = stdshade(noncran_tc_toplot,alpha,sh_color,edges_toPlot,1,'sem');
%     s2.LineWidth = 2;
    
    sh_color = Colors(3,:);
    s3 = stdshade(hunt_tc_toplot,alpha,sh_color,edges_toPlot,1,'sem');
    s3.LineWidth = 2;
    ylabel(y_str,'FontSize',14)
    xlabel('Seconds to Capture')
    
    legend([s1, s3],{'control','hunting'},...
        'location','northwest')
    
    title_str = {['Timecourse around capture'],...
                 ['DLCvar=',dlc_var_str,' -- HuntSesion=',num2str(sesh_toPlot)]};
    title(title_str,'FontSize',12)


end


ylim([1, 1.2])
ylim([0.8, 1.3])
ylim([0, 10])
ylim([0, 140])
ylim([145, 175])





% plot time course overlay by day

% data_toplot = {};
% for day_i = 1:length(day_strs)
%     data_toplot{day_i} = sham_cap_timecourse(sham_cap_day_vals==day_i,:);
% end

cond_str = 'hunt';
day_inds_toplot = [1,4];
test_presec = 2.5;


tc_data = eval([cond_str,'_cap_timecourse']);
hunt_cap_day_vals = [1,2,3,0,0,4];
data_toplot = {};
for day_i = day_inds_toplot
    day_num = (day_i);

    day_data = [];
    for anim_i = 1:length(tc_data)
        day_data = [day_data; tc_data{anim_i}(hunt_cap_day_vals==day_num,:)];
    end

    data_toplot{day_i} = day_data;
end



figure_coords = [101 493 618 435];
f3 = figure('Position',figure_coords);

% Colors = [0 0.6 0; 0.15 0.8 0.15; 0.3 1 0.3; 0.5 1 0.5];
% Colors = [0.15 0.15 0.15; 0.25 0.25 0.25; 0.55 0.55 0.55; 0.75 0.75 0.75];

switch cond_str
    case 'hunt'
%         base_color = [1 0.3 0.3];
        base_color = red_color;
        cond_plot_name = 'Hunting';
    case 'sham'
%         base_color = [0.2 0.2 0.2];
        base_color = [0.5 0.5 0.5];
        cond_plot_name = 'Control';
    case 'noncran'
        base_color = [0.6 0.6 0.6];
        cond_plot_name = 'Non-cran Hunt';
end

switch dlc_var_str
    case 'speed'
        y_str = 'Head Speed (cm/sec)';
        % ylabel('Body Speed (px/sec)','FontSize',14)
    case 'azi'
         y_str = 'Azimuth - Angle to cricket (deg)';
    case 'delta'
        y_str = 'Animal to cricket delta (cm/sec)';
    case 'tort'
        y_str = 'Tail tortuosity ratio';
    case 'tailAng'
        y_str = 'Tail Angle (deg)';
    case 'bodyLen'
        y_str = 'Body Length (cm)';
    case 'dist'
        y_str = 'Distance Traveled (cm)';
end

c_coefs = linspace(0.3,1,size(data_toplot,2));
colors_toPlot = [];
for i = 1:size(data_toplot,2)
    colors_toPlot(i,:) = base_color.*c_coefs(i);
end

edges_toPlot = 1/vid_fps:1/vid_fps:size(data_toplot{1},2)/vid_fps;
edges_toPlot = edges_toPlot - pre_cap_sec;
hold on;

shades = {};
alpha = 0.3;
for i = day_inds_toplot
    sh_color = colors_toPlot(i,:);
    shades{i} = stdshade(data_toplot{i},alpha,sh_color,edges_toPlot,1,'sem');
    shades{i}.LineWidth = 2;
end

ylabel(y_str,'FontSize',14)
xlabel('Seconds to Capture')
legend([shades{:}], day_strs(day_inds_toplot))
% title('Head speed timecourse around capture - by day - ')
title_str = {['Timecourse data across days (animal avgs)'],...
             ['Cond=',cond_plot_name,' -- Beh=',beh_str,' -- DLCvar=',dlc_var_str]};
title(title_str)


% do stat test
test_inds = (edges_toPlot >= -test_presec) & (edges_toPlot < 0);
day1_data_totest = nanmean(data_toplot{1}(:,test_inds),2);
day6_data_totest = nanmean(data_toplot{4}(:,test_inds),2);


[p,h,stats] = signrank(day1_data_totest,day6_data_totest)
[h,p,ci,stats] = ttest2(day1_data_totest,day6_data_totest)


% %test normality
% data_tonorm = day6_data_totest;
% norm_data = (data_tonorm(:) - nanmean(data_tonorm(:)))/nanstd(data_tonorm(:));
% [h,p,ksstat,cv] = kstest(norm_data)
% 
% figure;
% hist(norm_data,10)


