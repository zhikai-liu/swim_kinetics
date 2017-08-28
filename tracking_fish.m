filename_h='170822_6dpf';
f_tif = dir([filename_h '*.tif']);
for j=11:length(f_tif)
    fname=f_tif(j).name;
    %% reading images from file
    info=imfinfo(fname);
    numberOfImages = length(info);
    imageStack = zeros(info(1).Height,info(1).Width,numberOfImages,'uint8');
    for k = 1:numberOfImages
        currentImage = imread(fname, k, 'Info', info);
        imageStack(:,:,k) = currentImage;
    end 
    [Ed_image,BIM,area_ErIM,area_BIM,core,core_max_dist]=fish_tracking(imageStack,numberOfImages,fname);
    scale_pixels_mm=1000/10.5;
    fps=503;
    save([fname(1:end-4) '_tracking.mat'],'Ed_image','BIM','area_ErIM','area_BIM','core','core_max_dist')
    [kinetics,swim_episodes]=manuv_para_calc(core,core_max_dist,numberOfImages,scale_pixels_mm,fps,fname);
    save([fname(1:end-4) '_kinetics.mat'],'kinetics','swim_episodes')
end