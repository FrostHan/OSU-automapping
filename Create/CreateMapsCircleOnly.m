function CreateMapsCircleOnly(threshold,diffname)

resultDir='C:\OSU\SongMat\Create\';

matList=dir(resultDir);


matList=matList(3:length(matList));


for i=1:length(matList)
    if strcmp(matList(i).name(1:3),'y2_')
        load([resultDir,matList(i).name],'y2')
        y=zeros(size(y2,1),4);
        y(:,1)=y2(:,1);
        y(:,4)=y2(:,2);
        inputMatFileName=matList(i).name;
        inputMatFileName(4:end)
        load([resultDir,inputMatFileName(4:end)],'s','osuFolder')
        s.Metadata
        FrostnovaMap(s,y,osuFolder,threshold,diffname);
    end
end

end