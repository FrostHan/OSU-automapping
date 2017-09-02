

% dir=...
%     'E:\Program Files (x86)\osu!\Songs\39325 SHIKI - Pure Ruby\';
% osufilename=[dir,...
%     'SHIKI - Pure Ruby (tsuka) [Another].osu'];
% songfile=[dir,...
%     'Pure Ruby.mp3'];

% 
% dir=...
%     '/Users/dongqihan/Downloads/opsu/Songs/';
% osufilename=[dir,...
%     'IOSYS - Power of Dream (Night Fever Refix) (Kite) [Power of Stream].osu'];
% songfile=[dir,...
%     '11. Power of Dream Refix.mp3'];
% 

% dir=...
%     '/Users/dongqihan/Documents/MATLAB/OSU/FrOstNovaV2.0/osufiles/';
% osufilename=[dir,...
%     'Daisuke Achiwa - BASARA (100pa-) [BASARA].osu'];
% songfile=[dir,...
%     'BASARA.mp3'];

% 
% 
% dir=...
%     '/Users/dongqihan/Downloads/opsu/Songs/155118 Drop - Granat/';
% osufilename=[dir,...
%     'Drop - Granat (Lan wings) [Extra].osu'];
% songfile=[dir,...
%     '7.VII. Granat.mp3'];
% % % 
dir=...
    'C:\Users\hdqhd\AppData\Local\osu!\Songs\13019 Daisuke Achiwa - BASARA\';

osufilename=[dir,...
    'Daisuke Achiwa - BASARA (100pa-) [BASARA].osu'];
songfile=[dir,...
    'BASARA.mp3'];

s=osuFileRead(osufilename);
Ts=getRhythmPoints(s);
osuObj=osuObjectParser(s);
osuDataInput = getOsuDataInput(s,songfile);
osuDataTarget = getOsuDataTarget(s);

target=osuDataTarget;
input=osuDataInput;
[input1,target1]=regularizeDataInputTarget(input,target);


% 
% clear NET
% clear TR
% M=3;
% for i=1:M
%     net=osunet2([33,33,1]);
%     [net,tr]=train(net,input1,target1);
%     NET{i}=net;
%     TR{i}=tr;
% end
% 
% pf=zeros(M,1);
% for i = 1:M
%     pf(i)=TR{i}.best_tperf;
% end
%    
% [~,ind]=min(pf);
% net=NET{ind};
% 
% Y=net(input1);
% figure
% plot(Y(180:190),'r');
% hold on
% plot(target1(180:190),'b');
% 
% figure
% plot(round(Y(80:95)),'r');
% hold on
% plot(target1(80:95),'b');
% 
% figure
% hist(round(Y)-target1)
% 
% osuObjCr=FrostnovaMap(s,input,net,dir,0.5);
% 
% 
% 
