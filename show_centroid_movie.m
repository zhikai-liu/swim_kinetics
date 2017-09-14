% T=load('170822_6dpf_2_20170822_032818_PM_20170822_032928_PM_tracking.mat');
v = VideoWriter('170822_6dpf_2_20170822_032818_PM_20170822_032928_PM_tracking.avi');
v.FrameRate=503/50;
open(v);
figure('units','normal','position',[0.3 0 0.4 1]);
for frame =70:150
    h(1).handle=subplot(3,1,1);
    imshow(imageStack(:,:,frame))
    hold on;
    plot([T.core(frame,1),T.core_max_dist(frame,1)],[T.core(frame,2),T.core_max_dist(frame,2)],'r*-')
    hold off;
    h(2).handle=subplot(3,1,2);
    imshow(T.BIM(:,:,frame))
    hold on;
    plot([T.core(frame,1),T.core_max_dist(frame,1)],[T.core(frame,2),T.core_max_dist(frame,2)],'r*-')
    hold off;
    h(3).handle=subplot(3,1,3);
    imshow(T.Ed_image(:,:,frame))
    hold on;
    plot([T.core(frame,1),T.core_max_dist(frame,1)],[T.core(frame,2),T.core_max_dist(frame,2)],'r*-')
    hold off;
    %samexaxis('ytac','join');
    for i=1:3
    set(h(i).handle,'Units','normal',...
     'position',[0.2,0.95-0.3*i,0.6,0.28],...
     'Visible','off')
    end
    each_frame=getframe(gcf);
    writeVideo(v,each_frame);
end 
close(v)