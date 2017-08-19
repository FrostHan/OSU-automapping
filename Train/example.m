

% dir=...
%     'E:\Program Files (x86)\osu!\Songs\39325 SHIKI - Pure Ruby\';
% osufilename=[dir,...
%     'SHIKI - Pure Ruby (tsuka) [Another].osu'];
% songfile=[dir,...
%     'Pure Ruby.mp3'];


% dir=...
%     'E:\Program Files (x86)\osu!\Songs\27152 IOSYS - Power of Dream (Night Fever Refix)\';
% osufilename=[dir,...
%     'IOSYS - Power of Dream (Night Fever Refix) (Kite) [Power of Stream].osu'];
% songfile=[dir,...
%     '11. Power of Dream Refix.mp3'];


dir=...
    '/Users/dongqihan/Documents/MATLAB/OSU/FrOstNovaV1.00/osufiles/';
osufilename=[dir,...
    'SakiZ - osu!memories (DeRandom Otaku) [Happy Memories].osu'];
songfile=[dir,...
    'audio.mp3'];

% 
% dir=...
%     'E:\Program Files (x86)\osu!\Songs\155118 Drop - Granat\';
% osufilename=[dir,...
%     'Drop - Granat (Lan wings) [Extra].osu'];
% songfile=[dir,...
%     '7.VII. Granat.mp3'];
% % 
% dir=...
%     'E:\Program Files (x86)\osu!\Songs\13019 Daisuke Achiwa - BASARA\';
% 
% osufilename=[dir,...
%     'Daisuke Achiwa - BASARA (100pa-) [BASARA].osu'];
% songfile=[dir,...
%     'BASARA.mp3'];

s=osuFileRead(osufilename);
Ts=getRhythmPoints(s);
osuObj=osuObjectParser(s);
osuDataInput = getOsuDataInput(Ts,songfile);
osuDataTarget = getOsuDataTarget(Ts,osuObj);

target=osuDataTarget.isCircle+osuDataTarget.isSliderHead+osuDataTarget.isSliderEnd;
input=osuDataInput.input;
[input1,target1]=regularizeDataInputTarget(input,target);

clear NET
clear TR
M=3;
for i=1:M
    net=bsnet2([33,33,1]);
    [net,tr]=train(net,input1,target1);
    NET{i}=net;
    TR{i}=tr;
end

pf=zeros(M,1);
for i = 1:M
    pf(i)=TR{i}.best_tperf;
end
   
[~,ind]=min(pf);
net=NET{ind};

Y=net(input1);
figure
plot(Y(180:190),'r');
hold on
plot(target1(180:190),'b');

figure
plot(round(Y(80:95)),'r');
hold on
plot(target1(80:95),'b');

figure
hist(round(Y)-target1)

osuObjCr=FrostnovaMap(s,input,net,dir,0.5);



