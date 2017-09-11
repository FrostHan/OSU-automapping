
% s=osuFileRead(osufilename);
% Ts=getRhythmPoints(s);
% osuObj=osuObjectParser(s);
% osuDataInput = getOsuDataInput(s,songfile);
% osuDataTarget = getOsuDataTarget(s);
% 
% target=osuDataTarget;
% input=osuDataInput;
% [input1,target1]=regularizeDataInputTarget(input,target);
% 

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
% Skip to content


osuSongDir='D:\Program Files (x86)\osu!\Songs\';

songList=dir(osuSongDir);

savefolder='D:\OSU\SongMat\';

beatmapSetRange=[600000,615717];

for osuFolderIdx=8000:length(songList)
    
    % Redirect to osufile folder.
    % Find *.osu in the folder
    
    %   OsuFolderStrcut structure is shown as follows
    %        name: '1 Kenji Ninuma - DISCO PRINCE'
    %      folder: 'C:\Users\Agony\AppData\Local\osu!\Songs'
    %        date: '08-8??-2017 10:29:39'
    %       bytes: 0
    %       isdir: 1
    %     datenum: 7.3692e+05
    
    osuFolderStruct=songList(osuFolderIdx);
    saveMatName=strcat(savefolder,osuFolderStruct.name,'.mat');
    osuFolder=strcat(osuSongDir,osuFolderStruct.name,'\');
    osuFileListStruct=dir(strcat(osuFolder,'*.osu'));
    
    %   osuFileListStruct(i) structure is shown as follows:
    %        name: 'Kenji Ninuma - DISCO??PRINCE (peppy) [Normal].osu'
    %      folder: 'C:\Users\Agony\AppData\Local\osu!\Songs\1 Kenji Ninuma - DISCO PRINCE'
    %        date: '08-8??-2017 10:36:04'
    %       bytes: 6697
    %       isdir: 0
    %     datenum: 7.3692e+05
    
    %   If there is no *.osu in the folder, jump to next folder
    
    if isempty(osuFileListStruct)
        continue
    else
        % Trying to find the largest file
        tempSaveBytes=0;
        tempSaveIdx=-1;
        for i=1:length(osuFileListStruct)
            if osuFileListStruct(i).bytes>tempSaveBytes
                tempSaveBytes=osuFileListStruct(i).bytes;%这行你没加
                tempSaveIdx=i;
            end
        end
    end
    
    % Here we get the directory and filename of the osu file
    
    osufilename=strcat(osuFolder,osuFileListStruct(tempSaveIdx).name);
    try
        s=osuFileRead(osufilename);
    catch ME
        ME
        disp(osuFolder)
        disp(strcat(osuFileListStruct(tempSaveIdx).name,' cannot be processed'));
        fclose all;
        
    end
    try
        BeatmapSetID=str2double(s.Metadata.BeatmapSetID);        
    catch
        try
           name=osuFolderStruct.name;
           BeatmapSetID=textscan(osuFolderStruct.name,'%d ');
           BeatmapSetID=BeatmapSetID{1}(1);
        catch
            continue
        end
    end
    try
        if BeatmapSetID==-1
            continue
        elseif BeatmapSetID<beatmapSetRange(1) || BeatmapSetID>beatmapSetRange(2)
            continue
        end
    catch
        continue
    end
    
    try
        
        % Commented at 2017.8.27 by Agony.
        % osufilename=[dir,...
        %     'Daisuke Achiwa - BASARA (100pa-) [BASARA].osu'];
        % songfile=[dir,...
        %     'BASARA.mp3'];
        
        
        disp(['Operating osufile: ',osuFolderStruct.name, '. Progress: ',num2str(osuFolderIdx-2),...
            ' of ',num2str(length(songList)-2)])
        % songfilename and directory is get at here
        songfilename=s.General.AudioFilename;
        songfile=strcat(osuFolder,songfilename);
        
        Ts=getRhythmPoints(s);
        osuObj=osuObjectParser(s);
        osuDataInput = getOsuDataInput(s,songfile);
        osuDataTarget = getOsuDataTarget(s);
        
        target=osuDataTarget;
        input=osuDataInput;
        [input1,target1]=regularizeDataInputTarget(input,target);        
        save(saveMatName,'s','Ts','input','input1','target1','osuFolder');
        disp('sucess!')
    catch
        
        disp('Process Abort!!')
    end
    
end
