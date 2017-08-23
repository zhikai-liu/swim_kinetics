T=load('170822_6dpf_2_20170822_032818_PM_20170822_032928_PM_tracking.mat');
[x, y, t]=size(imageStack);
figure;
for frame =920:925
    imshow(T.BIM(:,:,frame))
    hold on;
    plot([T.core(frame,1),T.core_max_dist(frame,1)],[T.core(frame,2),T.core_max_dist(frame,2)],'r*-')
    %plot(core(frame,1),core(frame,2),'r*')
    %plot(tri(frame,:,1),tri(frame,:,2),'b*')
    pause(1);
    hold off;
end 