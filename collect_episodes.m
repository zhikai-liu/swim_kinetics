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

%% reading swimming kinetics data from file
for j=1:length(f_tif)
    fname=f_tif(j).name;
    S=load(fname);
%     for i=1:size(S.swim_episodes,2)
%         swim_epi_all=[swim_epi_all,filter(d,S.swim_episodes(:,i))];
%     end
    swim_epi_all=[swim_epi_all,S.swim_episodes];
end

%% average all the episodes and apply the low-pass filter, calculate velocity and acceleration
av_vel=mean(swim_epi_all,2);
g=9.8;
fps=503;
av_accel=diff(av_vel)*fps;
lp_av_vel=filter(d,av_vel);
lp_av_accel=diff(lp_av_vel)*fps;
xt=[1:length(av_vel)-delay]/fps;

%% fourier frequency analysis for av_accel
Y_av_accel=fft(av_accel);
Y_lp_av_accel=fft(lp_av_accel);
L=length(Y_av_accel);
P2_nlp=abs(Y_av_accel/L);
P1_nlp = P2_nlp(1:L/2+1);
P1_nlp(2:end-1) = 2*P1_nlp(2:end-1);
P2_lp=abs(Y_lp_av_accel/L);
P1_lp = P2_lp(1:L/2+1);
P1_lp(2:end-1) = 2*P1_lp(2:end-1);
f = Fs*(0:(L/2))/L;
figure('Units','Normal',...
    'Position',[0.3 0 0.4 0.7]);
hold on;
plot(f,P1_nlp,'LineWidth',3,'Color','k') 
plot(f,P1_lp,'LineWidth',3,'Color','r')
% plot([8 8],[0 0.1],'k:','LineWidth',3)
% text(7,-0.0028,'8','FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k')
title('Fast Fourier Transform Spectrum of Acceleration','FontSize',20,'FontWeight','bold')
xlim([0 80])
xticks(0:10:80)
xlabel('Hz')
ylabel('|P1(f)|')
A=gca;
set(A,'box','off')
set(A.XAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
set(A.YAxis,'FontSize',20,'FontWeight','bold','LineWidth',3,'Color','k');
print('swim_frequency_spectrum.svg','-dsvg');

%% plot the results
figure('Units','Normal',...
    'Position',[0 0 1 1]);
h(1).handle=subplot(2,1,1);
hold on;
vel_zoom=2;
for i=1:size(swim_epi_all,2)
plot(xt,swim_epi_all(1:end-delay,i)*vel_zoom, 'Color', [0.7 0.7 0.7],'LineWidth',2)
end
plot(xt,av_vel(1:end-delay)*vel_zoom,'k','LineWidth',6)
plot(xt,lp_av_vel(1+delay:end)*vel_zoom,'r','LineWidth',6)
% plot(lp1_av,'k')
% plot(lp2_av,'g')
plot(xt(1:end-1),av_accel(1:end-delay)/g,'k:','LineWidth',6)
plot(xt(1:end-1),lp_av_accel(1+delay:end)/g,'r:','LineWidth',6);
xlim([xt(1) xt(end)])
ylim([-0.05 0.1])
ylabel('m/s or g')
xlabel('seconds')
hold off;
h(2).handle=subplot(2,1,2);
plot([0;0], [0;1],'-k',[0;1], [0;0],'-k','LineWidth',4);
hold on;
plot([0.2;0.6], [1;1],'-k',[0.2;0.6], [0.7;0.7],'k:','LineWidth',4);
hold off;
xlim([0 1]);
ylim([0 1]);
%%Set axis into appropriate parameters for printing
XLIM=xt(end)-xt(1);
YLIM=0.1+0.05;
g_x_l=0.4;
g_y_l=0.8;
g_y_scale=0.02;
x_scale=0.05;
scale_x_l=g_x_l/XLIM*x_scale;
scale_y_l=g_y_l/YLIM*g_y_scale;
set(h(1).handle,'Units','normal',...
                     'position',[0.3,0.1,g_x_l,g_y_l],...
                     'Visible','off')
set(h(2).handle,'Units','normal',...
                     'position',[0.7,0.1,scale_x_l,scale_y_l],...
                     'Visible','off')
text(0.65,1,[num2str(g_y_scale/vel_zoom) 'm/s'],'fontsize',20,'fontweight','bold')
%             g_scale=round(2*1.5*Stim_amp/YAxis_h(2)*0.06,2);
text(0.65,0.7,[num2str(g_y_scale) 'g'],'fontsize',20,'fontweight','bold')
%             x_scale=round(S_period_sec/XAxis_l(1)*0.035,2);
text(1.1,0,[num2str(x_scale*1000) 'ms'],'fontsize',20,'fontweight','bold')

print('Swim_kinetics_plus_lowpass','-dsvg')

% %% save results into mat and csv files
% T=table;
% T.accel=lp_av_accel;
% vel=lp_av_vel(1:end-1);
% T.vel=vel;
% writetable(T,'average_kinetics.csv');
% save('average_kinetics.mat','vel','lp_av_accel');