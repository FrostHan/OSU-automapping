function Ts=getRhythmPoints(s)

% This is the function for generating the rhythm points where the hitObjects can be placed
% (white and red shot lines in the upper time line in osu! editor.)
%
% output: Ts-- a list of rhythm points.
% input: s-- beatmap structure, where s=osuFileRead(osufile);
% temporal unit all in milisecond
% By Dongqi Han, OIST

osuObj=osuObjectParser(s);

Ts=zeros(1e6,1);

j=1; %index for timing points
z=1;
startTiming=textscan(s.TimingPoints{1},'%f,%f,%f');
beatDivisor=str2double(s.Editor.BeatDivisor);

Ts(1)=startTiming{1};
t=Ts(1);
tmptp=textscan(s.TimingPoints{j},'%f,%f,%f');
lengthof1pai_next=tmptp{2};
isend=0;

while 1

    if Ts(z)>=tmptp{1} && ~isend  
        lengthof1pai=lengthof1pai_next;
        t=tmptp{1}+(lengthof1pai/beatDivisor);
        if j<length(s.TimingPoints)
            while 1
                j=j+1;
                if j>length(s.TimingPoints)
                    isend=1;
                    break;
                end
                tmptp=textscan(s.TimingPoints{j},'%f,%f,%f');
                if tmptp{2}>0
                    lengthof1pai_next=tmptp{2};
                    break;
                end
                
            end
        end
    end
    

    t=t+(lengthof1pai/beatDivisor);
    
    Ts(z+1)=round(t); 
    z=z+1;
 
    if t >= osuObj(end).timing
        break;
    end

end

idxdel=find(Ts<=0);
Ts(idxdel)=[];


end