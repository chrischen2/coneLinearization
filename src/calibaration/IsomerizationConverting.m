% main
clearvars; close all;

%% load the source spectrum
[fileS,pathS]=uigetfile('/Users/chrischen/Library/CloudStorage/Dropbox/research/resources/spectrums/sources/*.txt','multiselect','on');
for i=1:length(fileS)
    prSpec.(regexprep(fileS{i},'.txt',''))=dlmread([pathS fileS{i}]);
    receptor.(regexprep(fileS{i},'.txt','')).values= prSpec.(regexprep(fileS{i},'.txt',''))(:,2);
    receptor.(regexprep(fileS{i},'.txt','')).wavelengths= prSpec.(regexprep(fileS{i},'.txt',''))(:,1)*(10^-9);
end

%% load the device spectrum
[file,path]=uigetfile('/Users/chrischen/Library/CloudStorage/Dropbox/research/resources/spectrums/rigs/*.txt','multiselect','on');
%
if iscell(file) % in case only one spectrum is selected
    for i=1:length(file)
        devSpec.(regexprep(file{i},'.txt',''))=dlmread([path file{i}]);
    end
else
    devSpec.(regexprep(file,'.txt',''))=dlmread([path file]);
end
devNames=fieldnames(devSpec);
prNames=fieldnames(prSpec);

for i=1:length(devNames)
    device.(devNames{i}).values=interp1(devSpec.(devNames{i})(:,1),devSpec.(devNames{i})(:,2),prSpec.(prNames{1})(:,1));
    device.(devNames{i}).wavelengths=prSpec.(prNames{1})(:,1)*(10^-9);
end

%% visualize the spectrum for OLED
figure; hold all;
plot(receptor.l_cone_spectrum.wavelengths*10^9,receptor.l_cone_spectrum.values,'r','linewidth',2); 
plot(receptor.m_cone_spectrum.wavelengths*10^9,receptor.m_cone_spectrum.values,'g','linewidth',2); 
plot(receptor.s_cone_spectrum.wavelengths*10^9,receptor.s_cone_spectrum.values,'b','linewidth',2); 
plot(device.microdisplay_below_red_spectrum.wavelengths*10^9,device.microdisplay_below_red_spectrum.values,'--r','linewidth',2); 
plot(device.microdisplay_below_green_spectrum.wavelengths*10^9,device.microdisplay_below_green_spectrum.values,'--g','linewidth',2); 
plot(device.microdisplay_below_blue_spectrum.wavelengths*10^9,device.microdisplay_below_blue_spectrum.values,'--b','linewidth',2); 
legend('L Cone','M Cone','S Cone', 'Oled Red','Oled Green','Oled Blue');

%% compute the isomerization per watts for the spectrum loaded above
% collecting area: l/m/s cones in primate  0.37, stimuli from below or 0.6
% stimulate from above, that is 1 and 1 for rods
% in mouse, collecting area is 0.2 for M/S cones from below, and 1 from
% above.  for rod, that value is 0.5 and 0.87 respectively.
chl=3;
prChl=3;
collectingArea= 0.37;
calibrationValue=17.77; % in nW
calibrationDiameter=500;  % in uM
fprintf('%s\n', ['device ' devNames{chl}  ' ' 'pr ', ' ' prNames{prChl}]);
output = convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.(devNames{chl}), prSpec.(prNames{prChl}), collectingArea, {}, {});
fprintf('%s %d\n','Isomerization is ', output);


% in the case of OLED spectrum 
% get the transform matrix from RGB to LMS isom
collectingArea= 0.37;
calibrationValue=17.77; % in nW
calibrationDiameter=500;  % in uM
delta.rl=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_red_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.gl=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_green_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.bl=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_blue_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});

delta.rm=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_red_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.gm=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_green_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.bm=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_blue_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});

delta.rs=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_red_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});
delta.gs=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_green_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});
delta.bs=convisom(1, 'intensity', calibrationValue/(pi*(calibrationDiameter/2)^2),devSpec.microdisplay_below_blue_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});

rgbToLms=[delta.rl delta.gl delta.bl; delta.rm delta.gm delta.bm;  delta.rs delta.gs delta.bs]
lmsToRgb= inv(rgbToLms);

%% in the case of RBU LED on shared 2P rig
clc; close all;
collectingArea= 0.37; 
figure; hold all;
plot(receptor.l_cone_spectrum.wavelengths*10^9,receptor.l_cone_spectrum.values,'r','linewidth',2); 
plot(receptor.m_cone_spectrum.wavelengths*10^9,receptor.m_cone_spectrum.values,'g','linewidth',2); 
plot(receptor.rod_spectrum.wavelengths*10^9,receptor.rod_spectrum.values,'b','linewidth',2); 
plot(device.red_led_spectrum.wavelengths*10^9,device.red_led_spectrum.values,'--r','linewidth',2); 
plot(device.blue_led_spectrum.wavelengths*10^9,device.blue_led_spectrum.values,'--b','linewidth',2); 
plot(device.uv_led_spectrum.wavelengths*10^9,device.uv_led_spectrum.values,'--p','linewidth',2); 
legend('L Cone','M Cone','rod', 'Red LED','Blue LED','UV LED');


delta.rl=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.bl=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.ul=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});

delta.rm=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.bm=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.um=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});

delta.rr=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});
delta.br=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});
delta.ur=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});
rbuToLmr=[delta.rl delta.bl delta.ul; delta.rm delta.bm delta.um;  delta.rr delta.br delta.ur];
lmrToRbu= inv(rbuToLmr);


% % visualize the linear mapping 
% [x, y]= meshgrid(0:0.05:1, 0:0.05:1);
% lIsom=delta.rl.*x+delta.bl.*y;
% mIsom=delta.rm.*x+delta.bm.*y;
% figure; 
% s1=surf(x,y,lIsom,'FaceAlpha',0.8); hold all; s2=surf(x,y,mIsom,'FaceAlpha',0.7); colorbar;
% s1.EdgeColor = 'none'; s2.EdgeColor = 'none';
% 
% figure; scatter(lIsom(:), mIsom(:));   xlabel('L cone Isom'); ylabel('M cone Isom');
%% in the case of RGU LED on shared old Slice
clc; close all; clear delta
ndf=2.3;
collectingArea= 0.37/(10^ndf); 
figure; hold all;
plot(receptor.l_cone_spectrum.wavelengths*10^9,receptor.l_cone_spectrum.values,'r','linewidth',2); 
plot(receptor.m_cone_spectrum.wavelengths*10^9,receptor.m_cone_spectrum.values,'g','linewidth',2); 
plot(receptor.rod_spectrum.wavelengths*10^9,receptor.rod_spectrum.values,'b','linewidth',2); 
plot(device.red_led_spectrum.wavelengths*10^9,device.red_led_spectrum.values,'--r','linewidth',2); 
plot(device.green_led_spectrum.wavelengths*10^9,device.green_led_spectrum.values,'--g','linewidth',2); 
plot(device.uv_led_spectrum.wavelengths*10^9,device.uv_led_spectrum.values,'--p','linewidth',2); 
legend('L Cone','M Cone','rod', 'Red LED','Green LED','UV LED');


delta.rl=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.gl=convisom(1, 'intensity', 0.00631565324269389,devSpec.green_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.ul=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});

delta.rm=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.gm=convisom(1, 'intensity', 0.00631565324269389,devSpec.green_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.um=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});

delta.rr=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});
delta.gr=convisom(1, 'intensity', 0.00631565324269389,devSpec.green_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});
delta.ur=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.rod_spectrum, collectingArea, {}, {});

rguToLmr=[delta.rl delta.gl delta.ul; delta.rm delta.gm delta.um; delta.rr delta.gr delta.ur]
lmrToRgu= inv(rguToLmr);


% visualize the linear mapping 
[x, y]= meshgrid(0:0.05:1, 0:0.05:1);
lIsom=delta.rl.*x+delta.gl.*y;
mIsom=delta.rm.*x+delta.gm.*y;
figure; 
s1=surf(x,y,lIsom,'FaceAlpha',0.8); hold all; s2=surf(x,y,mIsom,'FaceAlpha',0.7); colorbar;
s1.EdgeColor = 'none'; s2.EdgeColor = 'none';

figure; scatter(lIsom(:), mIsom(:));   xlabel('L cone Isom'); ylabel('M cone Isom');
%%  compute the range of L,M for given iso-luminance 
close all; clc; clear contrast
totalLum=0.5*(delta.rm+delta.rl+delta.gm+delta.gl); 
[l, m]= meshgrid(linspace(0,delta.rl+delta.gl,200), linspace(0, delta.rm+delta.gm,200));
line1=find((m*delta.gl-l*delta.gm)<0);
line2=find((m*delta.rl-l*delta.rm)>0);
line3=find(((m-delta.gm)*delta.rl-delta.rm*(l-delta.gl))<0);
line4=find(((m-delta.rm)*delta.gl-delta.gm*(l-delta.rl))>0);
index=intersect(intersect(line1,line2), intersect(line3,line4));
crossIndex= intersect(find(abs(l+m-totalLum)/totalLum< .002),index);
cl=l(crossIndex); cm=m(crossIndex);
l=l(index); m=m(index);
figure; scatter(l,m); hold all; scatter(cl,cm); xlabel('L cone Isom'); ylabel('M cone Isom');
% get the cross section for the unity line x+y=mean lumi


totalLum=linspace(0.01,1,100)*(delta.rm+delta.rl+delta.gm+delta.gl); 
[l, m]= meshgrid(linspace(0,delta.rl+delta.gl,5000), linspace(0, delta.rm+delta.gm,5000));
line1=find((m*delta.gl-l*delta.gm)<0);
line2=find((m*delta.rl-l*delta.rm)>0);
line3=find(((m-delta.gm)*delta.rl-delta.rm*(l-delta.gl))<0);
line4=find(((m-delta.rm)*delta.gl-delta.gm*(l-delta.rl))>0);
index=intersect(intersect(line1,line2), intersect(line3,line4));
for i=1:length(totalLum) 
    crossIndex= intersect(find(abs(l+m-totalLum(i))/totalLum(i)< .01),index);
    cl=l(crossIndex); cm=m(crossIndex);
    % L/M contrast 
    contrast.lowBnd(i)= (min(cl)-max(cm))/(min(cl)+max(cm));
    contrast.upBnd(i)= (max(cl)-min(cm))/(max(cl)+min(cm));

end
% plot the range 
f=figure;  hold all;
plot(totalLum, contrast.lowBnd,'linewidth',2); 
plot(totalLum,contrast.upBnd,'linewidth',2);
xlabel('Total Luminance in Isom/cone/s');
ylabel(' Contrast bounds  (L-M)/(L+M)');
%% generate the Red and Green Gun series
close all; clc;
tempFreq=6; totalLumContrast=0.9; lmContrast=0.65;  % defined as (L-M)/(L+M)
preTime=1000; stimTime=2000; tailTime=1000; sampleRate=1000;
lumSteps=[2000, 8000];  
totalLum=lumSteps(1)*ones(1, preTime+stimTime+tailTime); totalLum(preTime:preTime+stimTime)=lumSteps(2);
x=(1:numel(totalLum))/sampleRate;
totalLum=totalLum.*(1+totalLumContrast*sin(2*pi*tempFreq*x));
% totalLum(preTime+stimTime+1:end)=totalLum(1:preTime);
lIsom=totalLum*(1+lmContrast)/2;
mIsom=totalLum*(1-lmContrast)/2;
rgIntensity= lmToRg*[lIsom; mIsom];
figure; subplot(2,1,1);
plot(x, totalLum,'k');
hold all;  plot(x, lIsom,'r'); plot(x, mIsom,'g'); legend('total Lum','L cone isom','M cone Isom'); legend boxoff;
subplot(2,1,2); 
plot(x, rgIntensity(1,:),'r'); hold all;  plot(x, rgIntensity(2,:),'g'); hold off; 
legend('red gun','green gun');
%% case for lightcrafter in confocal 
clc; close all;
collectingArea= 0.37; 
figure; hold all;
plot(receptor.l_cone_spectrum.wavelengths*10^9,receptor.l_cone_spectrum.values,'r','linewidth',2); 
plot(receptor.m_cone_spectrum.wavelengths*10^9,receptor.m_cone_spectrum.values,'g','linewidth',2); 
plot(receptor.s_cone_spectrum.wavelengths*10^9,receptor.s_cone_spectrum.values,'b','linewidth',2); 
plot(device.red_led_spectrum.wavelengths*10^9,device.red_led_spectrum.values,'--r','linewidth',2); 
plot(device.blue_led_spectrum.wavelengths*10^9,device.blue_led_spectrum.values,'--b','linewidth',2); 
plot(device.uv_led_spectrum.wavelengths*10^9,device.uv_led_spectrum.values,'--p','linewidth',2); 
legend('L Cone','M Cone','S Cone', 'Red LED','Blue LED','UV LED');


delta.rl=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.bl=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});
delta.ul=convisom(1, 'intensity', 0.0167133750446899,devSpec.red_led_spectrum, ...,
    prSpec.l_cone_spectrum, collectingArea, {}, {});

delta.rm=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.bm=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});
delta.um=convisom(1, 'intensity', 0.00631565324269389,devSpec.blue_led_spectrum, ...,
    prSpec.m_cone_spectrum, collectingArea, {}, {});

delta.rs=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});
delta.bs=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});
delta.us=convisom(1, 'intensity', 0.00412057864005028,devSpec.uv_led_spectrum, ...,
    prSpec.s_cone_spectrum, collectingArea, {}, {});
rbuToLms=[delta.rl delta.bl delta.ul; delta.rm delta.bm delta.um;  delta.rs delta.bs delta.us];
lmsToRbu= inv(rbuToLms);
