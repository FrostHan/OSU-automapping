function CreateMaps(threshold,diffname)

resultDir='C:\OSU\SongMat\Create\';

matList=dir(resultDir);


matList=matList(3:length(matList));


for i=1:length(matList)
    if strcmp(matList(i).name(1:2),'y_')
        load([resultDir,matList(i).name],'y2','y4')
        y = zeros(size(y2,1),4);
        y(:,1) = y2(:,1) + (y4(:,1)-0.5);
        y(:,2) = y2(:,1) + (y4(:,2)-0.5);
        y(:,2) = y2(:,1) + (y4(:,3)-0.5);
        y(:,4) = y2(:,2);
        inputMatFileName=matList(i).name;
        disp(inputMatFileName(3:end))
        load([resultDir,inputMatFileName(3:end)],'s','osuFolder')
        s.Metadata
        FrostnovaMap(s,y,osuFolder,threshold,diffname);
    end
end

end