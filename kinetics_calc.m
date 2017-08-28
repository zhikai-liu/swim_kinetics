filename_h='170822_6dpf';
f_tif = dir([filename_h '*.tif']);
for j=1:length(f_tif)
    fname=f_tif(j).name;
    %% reading images info from file
    info=imfinfo(fname);
    numberOfImages = length(info);
    scale_pixels_mm=1000/10.5;
    fps=503;
    S=load([fname(1:end-4) '_tracking.mat'],'core','core_max_dist');
    [kinetics,swim_episodes]=manuv_para_calc(S.core,S.core_max_dist,numberOfImages,scale_pixels_mm,fps,fname);
    save([fname(1:end-4) '_kinetics.mat'],'kinetics','swim_episodes')
end