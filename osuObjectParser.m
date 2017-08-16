function osuObj=osuObjectParser(s)

% This is the function for interpreting the HitObject strings in osufile.
%
% output: osuObj-- a list of structures contain the information of the object.
% input: s-- beatmap structure, where s=osuFileRead(osufile);
% temporal unit all in milisecond
% By Dongqi Han, OIST




N=length(s.HitObjects);

osuObj=struct('x',cell(N,1),'y',cell(N,1),'timing',cell(N,1),'interval',cell(N,1),'turns',cell(N,1),'currentBPM',cell(N,1),'type',[]);

SliderMultiplier=str2double(s.Difficulty.SliderMultiplier);
InheritedTiming=100;
j=1; %index for timing points
tmptp=textscan(s.TimingPoints{1},'%f,%f,%d');
BPMnow=60000/abs(tmptp{2});


for i = 1:N
    tmp = textscan(s.HitObjects{i},'%f,%f,%f,%f,%f,%f');
    osuObj(i).x=tmp{1};
    osuObj(i).y=tmp{2};
    osuObj(i).timing=tmp{3};
    osuObj(i).interval=0; % only for slider and spinner
    osuObj(i).turns=0; %only for slider
    
    
    while 1

        tmptp=textscan(s.TimingPoints{j},'%f,%f,%f');
        
        if j+1<length(s.TimingPoints)&&tmptp{1}<tmp{3}
            if tmptp{2}>=0
                BPMnow=60000/tmptp{2};
            else
                InheritedTiming=abs(tmptp{2});
                beats=tmptp{3};
            end
            j=j+1;
        else
            break
        end

        
    end
    
    
    osuObj(i).currentBPM=BPMnow;
    osuObj(i).inheritedTiming=InheritedTiming;
    
%-----------------------slider------------------------
    if isempty(tmp{6}) 
        osuObj(i).type='slider';
        [C,pos] = textscan(s.HitObjects{i},'%f,%f,%f,%f,%f,%c|%f:%f');
        pos1=0;
        while ~isempty(C{1})
            pos=pos+pos1;
            [C,pos1] = textscan(s.HitObjects{i}(pos+1:end),'|%f:%f');
        end
        tmp2 = textscan (s.HitObjects{i}(pos+1:end),',%f,%f,%f');
        osuObj(i).turns=tmp2{1};
        
        SliderLength=tmp2{2};
        
        %slider time length (interval)
        osuObj(i).interval=SliderLength*InheritedTiming/SliderMultiplier/10000*(60000/osuObj(i).currentBPM);

%-----------------------spinner------------------------
    elseif tmp{6}>10 %spinner
        osuObj(i).type='spinner';
        osuObj(i).interval=tmp{6}-osuObj(i).timing;
        
        
%-----------------------circle------------------------

    else %circle
        osuObj(i).type='circle';
    end
    
    
end


    
    

end