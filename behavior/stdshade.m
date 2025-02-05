function [plot_obj,fill_obj] = stdshade(amatrix,alpha,acolor,F,smth, stdorsem)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% smusall 2010/4/23

if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end

if exist('F','var')==0 || isempty(F); 
    F=1:size(amatrix,2);
end

if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1;
end  

if ne(size(F,1),1)
    F=F';
end

amean=smooth(nanmean(amatrix),smth)';
if exist('stdorsem') == 0
    stdorsem = 'std';
end

num_non_nans = [];
for col = 1:size(amatrix,2)
    num_non_nans(col) = sum(~isnan(amatrix(:,col)));
end
num_non_nans(num_non_nans==0) = 1;

if strcmp(stdorsem, 'std')
astd=nanstd(amatrix); % to get std shading
end

if strcmp(stdorsem, 'sem')
astd=nanstd(amatrix)./ sqrt(num_non_nans); % to get sem shading
end

%added to handle nans in std
if sum(isnan(astd)) > 0
    print('Error equals NaN at some point...')
    astd(isnan(astd)) = 0;
end
if sum(isnan(amean)) > 0
    print('Mean equals NaN at some point...')
    astd(isnan(amean)) = [];
    F(isnan(amean)) = [];
    amean(isnan(amean)) = [];
end

if exist('alpha','var')==0 || isempty(alpha) 
    disp(size(F))
    fill_obj = fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor='k';
    disp(size(F))
else
    fill_obj = fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'facealpha',alpha,'linestyle','none');
%     patch([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor);
end

if ishold==0
    check=true; else check=false;
end

hold on;

plot_obj = plot(F,amean,'Color',acolor,'linewidth',1); %% change color or linewidth to adjust mean line

if check
    hold off;
end

end



