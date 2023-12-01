clc;clear;addpath('lib_RADSpot')
[status,errmsg] = load.checkToolBox('image_toolbox');

%% load area threshold for diffraction-limited objects
try 
    areathres = load.loadJSON('areathres.json').areathres;
catch
    areathres = 30;
end

%% determine steepness and integrated gradient based on the negative control image(s)
files = dir(fullfile('negative_control','*.tif'));
names = fullfile({files.folder}',{files.name}');
acceptedRatio = 0.2; %how much false positives accepted in each dimension, in percentage
[k1,k2] = core.createKernel(1.4,2); %create kernels for the image processing

rad_neg = zeros(length(names),2);

for i = 1:length(names)
    img = double(load.Tifread(names{i}));
    rad_tmpt = zeros(size(img,3),2);
    for j = 1:size(img,3)
        img_z = img(:,:,j);
        [img2,Gx,Gy] = core.calculateGradientField(img_z,k1);
        [~,~,radiality] = core.smallFeatureKernel(img_z,false(size(img_z)),img2,Gx,Gy,k2,0.05,areathres,[0 0 0]);
        rad_tmpt(j,:) = [prctile(radiality(:,1),acceptedRatio),prctile(radiality(:,2),100-acceptedRatio)];
    end
    rad_neg = mean(rad_tmpt,1);
end

rad_neg = struct('steepness',rad_neg(1),'integratedGrad',rad_neg(2));
load.saveJSON(rad_neg,'rad_neg.json');
