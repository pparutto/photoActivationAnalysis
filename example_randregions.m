% -------
%% Example script for getting signal rise in randomly destributed ROIs on an image
% This is intended to be used in cell mode in matlab
% hit ctrl-enter (or equivalent) to run one chunk of code at a time
% You will need to supply 2 tif stacks: one before photoactivation, one
% after (or just one concatenated stack + knowledge of what frame
% corresponds to the start of photoactivation)
% -------


% Modify these parameters for your own file organization

% the directory where images are stored
dirname = '/mnt/data/photoactivation_data/data/1_SH-SY5Y_ER_PA_GFP_RTN4_KO/1_WT/190226_SH-SY5Y_PA_GFP_Rtn4_KO_WT_ROI1/';

% the name of the tif file containing images before photoactivation
prefile = 'C3-FRAP001_pre.tif';
% the name of the tif file containing images during photoactivation
PAfile = 'C3-FRAP001_bleach.tif';

% now load the images 
% rawimgs has the raw images (replace with ~ to save memory by not keeping
% these)
% imgs has them run through a basic local median denoising filter
% imgs is a 3D matrix of size (height x width x frames)
% startPA is the frame number at which the photoactivation starts
[imgs,startPA,rawimgs] = loadImages(dirname,prefile,PAfile);

nimg = size(imgs,3);
imgsize = [size(imgs,1) size(imgs,2)];
%% view the images to make sure everything loaded correctly
implay(imgs)

%% Manually select the  photoactivated region
% click and drag to select the photoactivated region
% you can resize or draw the circle afterward as needed
figure(1)
tmp = imgs(:,:,startPA+5);
imshow(tmp, [0 max(tmp(:))]);

actROI = drawcircle(gca,'Color','y');
actcent = actROI.Center;
actrad = actROI.Radius;

%% Manually select an ROI defining the entire cellular region of interst
% this needs to be a single polygonal region
% click around to define the polygon. Right-click to finish. 
% then adjust control points as needed
% you can also adjust the photoactivated region ROI if desired
% (keep in mind this image is the end of the photoactivated period).
figure(1)
tmp = imgs(:,:,end);
imshow(tmp, [0 max(tmp(:))]);
cellROI = drawpolygon(gca);
celloutline = cellROI.Position;

actROI = drawcircle(gca,'Center',actcent,'Radius',actrad,'Color','y');
actcent = actROI.Center;
actrad = actROI.Radius;


%% Generate random local ROIs within the overall cellular region, for tracking signal
% the ROIs are sorted by distance from activated region
% their position can be adjusted afterwards
nreg = 100; % number of regions to generate
regrad = 10; % radius of circular regions (in px)
% maximum allowed distance from activation center (in px)
% can set to inf if any distance within the cellular region is ok
maxdist = 100; 

figure(2)
[regROIs, cellROI, regdist] = getRandomROIs(imgs(:,:,end),nreg,regrad,celloutline,actcent,maxdist);
regcent = reshape([regROIs.Center],2,length(regROIs))';
%% Get brightness over time for each region

% update region centers and distances in case any got adjusted manually
regcent = reshape([regROIs.Center],2,length(regROIs))';
regdist = sqrt(sum((regcent - actcent).^2,2))

regionTraces = getRegionTraces(imgs,regROIs);

%% plot the time traces for a few regions
% color matches the region color in the previous figure
figure(3)
tvals = 1:size(imgs,3)
for rc = 1:5:nreg
    plot(tvals,regionTraces(rc,:),'Color',regROIs(rc).Color,'LineWidth',2)
    text(tvals(end),regionTraces(rc,end),sprintf('%d',rc),'Color',regROIs(rc).Color,'FontSize',16)
    hold all
end
xlabel('time (frames)')
ylabel('intensity per unit area')
hold off