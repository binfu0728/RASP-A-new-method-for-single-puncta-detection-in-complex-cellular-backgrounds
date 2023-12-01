clc;clear;addpath('lib_RADSpot')
[status,errmsg] = load.checkToolBox('image_toolbox');

%% load area threshold for diffraction-limited objects
try 
    areathres = load.loadJSON('areathres.json').areathres;
catch
    areathres = 30;
end

%% load steepness and integrated gradient from negative control image(s)
try 
    radiality = load.loadJSON('rad_neg.json');
    radiality = [radiality.steepness,radiality.integratedGrad];
catch
    radiality = [1 0]; %steepness = 1, integrated gradient = 0
end

%% spot detection
files = dir(fullfile('images','*.tif'));
names = fullfile({files.folder}',{files.name}');
[k1,k2] = core.createKernel(1.4,2); %create kernels for the image processing

for i = 1%1:length(names)
    img = double(load.Tifread(names{i}));
    rad_tmpt = zeros(size(img,3),2);
    for j = 1%:size(img,3)
        img_z = img(:,:,j);
        [img2,Gx,Gy] = core.calculateGradientField(img_z,k1);
        [dlMask,centroids,rdl,idxs] = core.smallFeatureKernel(img_z,false(size(img_z)),img2,Gx,Gy,k2,0.05,areathres,radiality);
        figure;imshow(img_z,[100 300]);hold on;
        figure;imshow(img_z,[100 300]);hold on;
        plot(centroids(:,1),centroids(:,2),'o','MarkerSize',10);
    end
end