clc;clear;addpath('lib_RADSpot')
[status,errmsg] = load.checkToolBox('image_toolbox');
areathres = 1000;
radiality = [0.968 36]; %predetermined steepness and integrated gradient, can be maunally changed until all spots in the image are detected

%% spot detection
files = dir(fullfile('area_threshold','*.tif'));
names = fullfile({files.folder}',{files.name}');
[k1,k2] = core.createKernel(1.4,2); %create kernels for the image processing

areas = []; %area for diffraction-limited spots in px

for i = 1:length(names)
    img = double(load.Tifread(names{i}));
    rad_tmpt = zeros(size(img,3),2);
    for j = 1:size(img,3)
        img_z = img(:,:,j);
        [img2,Gx,Gy] = core.calculateGradientField(img_z,k1);
        [dlMask,centroids,rdl,idxs] = core.smallFeatureKernel(img_z,false(size(img_z)),img2,Gx,Gy,k2,0.05,areathres,radiality);
        % figure;imshow(img_z,[]);hold on;
        % figure;imshow(img_z,[]);hold on;
        % plot(centroids(:,1),centroids(:,2),'o','MarkerSize',10);
        t = regionprops(dlMask,'Area');
        areas = [areas,t.Area];
    end
end

areas = struct('areathres',ceil(prctile(areas,95)));
load.saveJSON(areas,'areathres.json');