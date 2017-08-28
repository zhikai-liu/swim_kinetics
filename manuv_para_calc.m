function [kinetics,swim_episodes]=manuv_para_calc(core,core_max_dist,numberOfImages,scale_pixels_mm,fps,fname)
range=1:numberOfImages-12;
core_anter=core-core_max_dist;

% %% Design a low pass filter
% nfilt=34;
% Fst=25;
% Fs=503;
% d=designfilt('lowpassfir','FilterOrder',nfilt,'CutoffFrequency',Fst,'SampleRate',Fs);
% %grpdelay(d,N,Fs);
% delay = mean(grpdelay(d));
% sm_core=[filter(d,core(:,1)),filter(d,core(:,2))];

%% smoothing data
sm_core=core;
for i=1:5
sm_core=[smooth(sm_core(:,1),3),smooth(sm_core(:,2),3)];
end

%% calculate the projection on anterior axis and lateral axis
core_diff=diff(sm_core);
dot_proj=core_diff(:,1).*core_anter(1:end-1,1)+core_diff(:,2).*core_anter(1:end-1,2);
% norm_core_diff=sqrt(sum(core_diff.^2,2));
norm_core_anter=sqrt(sum(core_anter.^2,2));
dist_proj_anter=dot_proj./norm_core_anter(1:end-1);
% cos_proj=dist_proj_anter./norm_core_diff;
% angle_proj_anter=acos(cos_proj);
dist_proj_later=(core_diff(:,1).*core_anter(1:end-1,2)-core_diff(:,2).*core_anter(1:end-1,1))./norm_core_anter(1:end-1);
% angle_proj_later=asin(dist_proj_later./norm_core_diff);
cum_anter_dist=cumsum(dist_proj_anter);
cum_later_dist=cumsum(dist_proj_later);
% man_angle=atan(core_anter(:,2)./core_anter(:,1));
% swim_angle=atan(core_diff(:,2)./core_diff(:,1));
% for i=1:length(swim_angle)
%     if swim_angle(i)<-1
%        swim_angle(i)=swim_angle(i)+pi;
%     end
% end

%% convert to real scale and calculate velocity and acceleration
kinetics=struct();
kinetics.cum_anter_dist_mm=cum_anter_dist./scale_pixels_mm; 
kinetics.cum_later_dist_mm=cum_later_dist./scale_pixels_mm; 
kinetics.swim_anter_vel=diff(kinetics.cum_anter_dist_mm).*fps./1000;
kinetics.swim_later_vel=diff(kinetics.cum_later_dist_mm).*fps./1000;
kinetics.swim_anter_accel=diff(kinetics.swim_anter_vel).*fps;
kinetics.swim_later_accel=diff(kinetics.swim_later_vel).*fps;


%% calculate the start of each swimming episode
A_thre=0.5;
V_thre=0.01;
accel_thre=kinetics.swim_anter_accel-A_thre;
crossing_ = accel_thre(1:end-1).*accel_thre(2:end)<0;
start_index=find(crossing_.*(accel_thre(1:end-1)>0)); 
gap_index=diff(start_index)>0.2*fps;
gap_index=[1;gap_index];
start_index=start_index(gap_index~=0 & start_index<numberOfImages-200 & start_index>51);
swim_episodes=[];
for i=1:length(start_index)
    if any(kinetics.swim_anter_vel(start_index(i):start_index(i)+50)>V_thre)
        swim_episodes=[swim_episodes,kinetics.swim_anter_vel(start_index(i)-50:start_index(i)+199)];
    end
end
%% plot figures
%{
figure;
title([fname ' Swim Episodes overlay'])
hold on;
for i=1:length(start_index)
    plot(swim_episodes(i,:))
end
% av_episode=mean(swim_episodes,1);
% plot(av_episode,'b');
% plot(diff(av_episode).*50,'r')
hold off

time=range./fps;
% figure;
% plot(smooth(man_angle).*180./pi,'b')
% hold on;
% %plot(angle_proj_anter,'r')
% plot(angle_proj_later.*180./pi,'r')
% %plot(diff(smooth(man_angle)),'r')
% hold off;
figure;
%plot(swim_dist,'k');
subplot(3,1,1)
plot(time,kinetics.cum_anter_dist_mm(range),'b');
hold on;
%plot(time,kinetics.cum_later_dist_mm(range),'r');
hold off;
ylabel('cum dist, mm')
subplot(3,1,2)
plot(time,kinetics.swim_anter_vel(range),'b');
hold on;
%plot(time,kinetics.swim_later_vel(range),'r');
hold off;
ylabel('velocity, m/s')
subplot(3,1,3)
plot(time,kinetics.swim_anter_accel(range),'b');
hold on;
% plot(time,kinetics.swim_later_accel(range),'r');
%plot(time,accel_thre(range),'r');
hold off;
ylabel('accel, m/s^2')
samexaxis('ytac','join','yld',1,'Box','off')
title([fname ' kinetics'])
%}
end