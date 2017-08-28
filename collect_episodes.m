filename_h='170822_6dpf';
f_tif = dir([filename_h '*_kinetics.mat']);
swim_epi_all=[];

%% Design a low pass filter
nfilt=34;
Fst=25;
Fs=503;
d=designfilt('lowpassfir','FilterOrder',nfilt,'CutoffFrequency',Fst,'SampleRate',Fs);
%grpdelay(d,N,Fs);
delay = mean(grpdelay(d));

for j=1:length(f_tif)
    fname=f_tif(j).name;
    %% reading images info from file
    S=load(fname);
%     for i=1:size(S.swim_episodes,2)
%         swim_epi_all=[swim_epi_all,filter(d,S.swim_episodes(:,i))];
%     end
    swim_epi_all=[swim_epi_all,S.swim_episodes];
end
av_vel=mean(swim_epi_all,2);
g=9.8;
fps=503;
av_accel=diff(av_vel)*fps;
lp_av_vel=filter(d,av_vel);
lp_av_accel=diff(lp_av_vel)*fps;
xt=[1:length(av_vel)-delay]/fps;

figure;
hold on;
for i=1:size(swim_epi_all,2)
plot(xt,swim_epi_all(1:end-delay,i), 'Color', [0.7 0.7 0.7])
end
plot(xt,av_vel(1:end-delay),'k','LineWidth',2)
plot(xt,lp_av_vel(1+delay:end),'r--','LineWidth',2)
% plot(lp1_av,'k')
% plot(lp2_av,'g')
plot(xt(1:end-1),av_accel(1:end-delay)/g,'k','LineWidth',1)
plot(xt(1:end-1),lp_av_accel(1+delay:end)/g,'r--','LineWidth',1);
ylabel('m/s or g')
xlabel('seconds')
hold off;
T=table;
T.accel=lp_av_accel;
vel=lp_av_vel(1:end-1);
T.vel=vel;
writetable(T,'average_kinetics.csv');
save('average_kinetics.mat','vel','lp_av_accel');