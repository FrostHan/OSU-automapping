function CreateMaps(threshold)

resultDir='D:\OSU\SongMat\Create\';

matList=dir(resultDir);


matList=matList(3:length(matList));


for i=1:length(matList)
    if strcmp(matList(i).name(1:2),'y_')
        load([resultDir,matList(i).name],'y')
        inputMatFileName=matList(i).name;
        inputMatFileName(3:end)
        load([resultDir,inputMatFileName(3:end)],'s','osuFolder')
        y(1:10,:)
        s.Metadata
        FrostnovaMap(s,y,osuFolder,threshold);
    end
end

end