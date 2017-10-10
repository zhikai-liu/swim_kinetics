%T=load('170822_6dpf_2_20170822_032818_PM_20170822_032928_PM_tracking.mat');
framge_range=[910,925,950,980];
range_core=910:980;
x_range=1:718;
y_range=1:909;
figure('units','normal','position',[0.3 0 0.5 0.7]);
BIM_sum=max(max(max(T.BIM(x_range,y_range,framge_range(1)).*20,T.BIM(x_range,y_range,framge_range(2)).*40),T.BIM(x_range,y_range,framge_range(3)).*60),T.BIM(x_range,y_range,framge_range(4)).*80);
BIM_sum=80-BIM_sum;
imshow(mat2gray(BIM_sum));
hold on;
plot(T.core(range_core,1),T.core(range_core,2),'r.-','MarkerSize',5)
hold off;
print('swim_overlay.jpg','-r300','-djpeg')