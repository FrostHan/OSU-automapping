function [Ts,InheritedTimings]=getRhythmPoints(s)

% This is the function for generating the rhythm points where the hitObjects can be placed
% (white and red shot lines in the upper time line in osu! editor.)
%
% output: Ts-- a list of rhythm points.
% input: s-- beatmap structure, where s=osuFileRead(osufile);
% temporal unit all in milisecond
% By Dongqi Han, OIST

osuObj=osuObjectParser(s);

Ts=zeros(1e6,1);
InheritedTimings=zeros(1e6,1);

q=1; %index 
j=1; %index 
z=1; %index 
startTiming=textscan(s.TimingPoints{1},'%f,%f,%f');
beatDivisor=str2double(s.Editor.BeatDivisor);

Ts(1)=startTiming{1};
InheritedTimings(1)=100;
InheritedTiming=100;


t=Ts(1);
tmptp=textscan(s.TimingPoints{j},'%f,%f,%f');
lengthof1pai_next=tmptp{2};
lengthof1pai=lengthof1pai_next;
isend=0;


tmptp1=textscan(s.TimingPoints{q},'%f,%f,%f');


while 1
    
    while q<=length(s.TimingPoints)

        tmptp1=textscan(s.TimingPoints{q},'%f,%f,%f');
        
        if q<=length(s.TimingPoints)&&tmptp1{1}<Ts(z)
            if tmptp1{2}>=0
                BPMnow=60000/tmptp1{2};
            else
                InheritedTiming=abs(tmptp1{2});
                beats=tmptp1{3};
            end
            q=q+1;
        else
            break
        end
        
       
    end
    
    
    if Ts(z)>=tmptp{1} && ~isend  
        lengthof1pai=lengthof1pai_next;
%         t=tmptp{1}+(lengthof1pai/beatDivisor);
%         %我曹就是这一行困扰了我一万年，为什么我当初这么SB会加上这么一行！！！！
        if j<=length(s.TimingPoints)
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
    InheritedTimings(z+1)=InheritedTiming;

    z=z+1;
    
    
    if t >= osuObj(end).timing
        break;
    end

end

idxdel=find(Ts<=0);
Ts(idxdel)=[];
InheritedTimings(idxdel)=[];

end