function osuObjCr=FrostnovaMap(s,input,net,dir,threshold)

% This is the function to create a beatmap (mapping) by the trained network
% and input data
% ----------------Input----------------
% s: osu structure
% dir: directory of the song
% threshold: threshold for placing a object (higher threshold, more objects)
% ----------------Output---------------
%
%

Ts=getRhythmPoints(s);

output=net(input);

counter=1;

for n=2:length(Ts)-1
    
    if output(n-1)>threshold
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/500));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/500));
        counter=counter+1;
    end
    
end

diffname='FrOstNovA';
WriteOsuFile(s,osuObjCr,dir,diffname)

end










function WriteOsuFile(s,osuObjCr,dir,diffname)

% Write a .osu file
% ------------------
% By Dongqi Han, OIST


filename=[s.Metadata.Artist,' - ',s.Metadata.Title,' (',s.Metadata.Creator,')'];
SliderMultiplier=0.18;
% timedistance=(60/(BPM*BeatDivisor))*1000;
AR=9;
OD=7;
CS=4;
HP=6;

osufp=fopen([dir,filename,' [',diffname,'].osu'],'w');

% try 

fprintf(osufp,'%s\r\n\r\n','osu file format v14');


% -------General-------
fprintf(osufp,'%s\r\n','[General]');
fprintf(osufp,'%s','AudioFilename: ');
fprintf(osufp,'%s\r\n',s.General.AudioFilename);
fprintf(osufp,'%s\r\n',['AudioLeadIn: ',s.General.AudioLeadIn]);
fprintf(osufp,'%s\r\n',['PreviewTime: ',s.General.PreviewTime]);
fprintf(osufp,'%s\r\n',['Countdown: ',s.General.Countdown]);
fprintf(osufp,'%s\r\n','SampleSet: Soft');
fprintf(osufp,'%s\r\n',['StackLeniency: ',s.General.StackLeniency]);
fprintf(osufp,'%s\r\n','Mode: 0');
fprintf(osufp,'%s\r\n',['LetterboxInBreaks: ',s.General.LetterboxInBreaks]);
fprintf(osufp,'%s\r\n\r\n','WidescreenStoryboard: 0');


% ------Editor--------
fprintf(osufp,'%s\r\n','[Editor]');
fprintf(osufp,'%s\r\n','DistanceSpacing: 1');
fprintf(osufp,'%s\r\n',['BeatDivisor: ',s.Editor.BeatDivisor]);
fprintf(osufp,'%s\r\n','GridSize: 4');
fprintf(osufp,'%s\r\n\r\n','TimelineZoom: 1');


% ------Metadata--------
fprintf(osufp,'%s\r\n','[Metadata]');
fprintf(osufp,'%s','Title:');
fprintf(osufp,'%s\r\n',s.Metadata.Title);
if exist('s.Metadata.ArtistUnicode','var')
    fprintf(osufp,'%s','TitleUnicode: ');
    fprintf(osufp,'%s\r\n',s.Metadata.TitleUnicode);
end
fprintf(osufp,'%s\r\n',['Artist: ',s.Metadata.Artist]);
if exist('s.Metadata.ArtistUnicode','var')
    fprintf(osufp,'%s\r\n',['ArtistUnicode: ',s.Metadata.ArtistUnicode]);
end
fprintf(osufp,'%s\r\n',['Creator: ',s.Metadata.Creator]);
fprintf(osufp,'%s\r\n',['Version: ',num2str(diffname)]);
fprintf(osufp,'%s\r\n',['Source: ',s.Metadata.Source]);
fprintf(osufp,'%s\r\n',['Tags: ',s.Metadata.Tags]);
fprintf(osufp,'%s\r\n','BeatmapID:-1');
fprintf(osufp,'%s\r\n\r\n','BeatmapSetID:-1');


% ------Difficulty-------
fprintf(osufp,'%s\r\n','[Difficulty]');
fprintf(osufp,'%s\r\n',['HPDrainRate:',num2str(HP)]);
fprintf(osufp,'%s\r\n',['CircleSize:',num2str(CS)]);
fprintf(osufp,'%s\r\n',['OverallDifficulty:',num2str(OD)]);
fprintf(osufp,'%s\r\n',['ApproachRate:',num2str(AR)]);
fprintf(osufp,'%s\r\n',['SliderMultiplier:',num2str(SliderMultiplier)]);
fprintf(osufp,'%s\r\n\r\n','SliderTickRate:1');

% ------Events----------
fprintf(osufp,'%s\r\n','[Events]');
% for i=1:length(s.Events)
%     fprintf(osufp,'%s\r\n',s.Events{i});
% end
fprintf(osufp,'%s\r\n',s.Events{1});
fprintf(osufp,'\r\n');

% ------Timing points--------
fprintf(osufp,'%s\r\n','[TimingPoints]');
for i=1:length(s.TimingPoints)
    fprintf(osufp,'%s\r\n',s.TimingPoints{i});
end
fprintf(osufp,'\r\n');

% ------HitObjects-----------
fprintf(osufp,'%s\r\n','[HitObjects]');


for k = 1:length(osuObjCr)

     if strcmp(osuObjCr(k).type,'circle') || strcmp(osuObjCr(k).type,'slider' )

        fprintf(osufp,['%d,%d,',int2str(osuObjCr(k).timing),',1,2\r\n'],osuObjCr(k).x,osuObjCr(k).y);

     end

end

fclose(osufp);
% catch
%     fclose(osufp);
% end

% for k=1:length(osuObjCr)
%     
% if osuObjCr(k).type=='circle'
% 
%             fprintf(osufp,['%d,%d,',int2str(osuObjCr.time(k)),',1,0,0:0:0:0:\r\n'],osuObjCr.position(k,1),osuObjCr.position(k,2));
% 
% end
% 
% if osuObjCr(k).type=='slider'
%             m=0;
%             while m==0||osuObjCr.type(k+m)==0
%                 m=m+1;
%                 if  k+m-1==length(osuObjCr.type)%end of song
%                     fprintf(osufp,['%d,%d,',int2str(osuObjCr.time(k)),',1,0,0:0:0:0:\r\n'],osuObjCr.position(k,1),osuObjCr.position(k,2));
%                 elseif osuObjCr.type(k+m)==3 %a slidertail matches sliderhead
%                     sliderlength=round((osuObjCr.time(k+m)-osuObjCr.time(k))/(BeatDivisor*timedistance)*100*SliderMultiplier);
%                     a=osuObjCr.position(k,1);
%                     b=osuObjCr.position(k,2);
%                     osuObjCr.type(k+m)=4;
%                     fprintf(osufp,['%d,%d,',int2str(osuObjCr.time(k)),',2,0,L|%d:%d,1,%f\r\n'],a,b,a+sliderlength,b,sliderlength);
%                 elseif  osuObjCr.type(k+m)==2||osuObjCr.type(k+m)==1 %sliderhead doesn't match a slidertail
%                     sliderlength=round((osuObjCr.time(k+m-1)-osuObjCr.time(k))/(BeatDivisor*timedistance)*100*SliderMultiplier);
%                     a=osuObjCr.position(k,1);
%                     b=osuObjCr.position(k,2);
%                     fprintf(osufp,['%d,%d,',int2str(osuObjCr.time(k)),',2,0,L|%d:%d,1,%f\r\n'],a,b,a+sliderlength,b,sliderlength);
%                 end
%             end
% end
% 
% if osuObjCr(k).type==3
%             fprintf(osufp,['%d,%d,',int2str(osuObjCr.time(k)),',1,0,0:0:0:0:\r\n'],round(400*rand(1,1)),round(300*rand(1,1)));
% end
% 
% 
% end
% 
% 



end