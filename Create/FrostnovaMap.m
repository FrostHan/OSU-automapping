function osuObjCr=FrostnovaMap(s,y,osuFolder,threshold)

% This is the function to create a beatmap (mapping) by the trained network
% and input data
% ----------------Input----------------
% s: osu structure
% y: result from tensorflow
% dir: directory of the song
% threshold: threshold for placing a object (higher threshold, more objects)
% ----------------Output---------------
%
% osuObj created by the inputs

Ts=getRhythmPoints(s);

counter=1;
[~,type]=max(y,[],2);
N=length(Ts);

for n=1:N
    
    [tf,n_itv]=judgeslider(type,n);
    
    if type(n)==1 %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/500));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/500));
        counter=counter+1;
        
    elseif tf  %slider 
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'slider';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/500));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/500));
        osuObjCr(counter).interval = Ts(n+n_itv)-Ts(n);
        osuObjCr(counter).length = n_itv;
        type(n+n_itv)=3; %assign a slider end
        osuObjCr(counter).turns = 1;
        counter=counter+1;
        
    elseif type(n)==4||3 %empty or slider end
        
        
    else %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/500));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/500));
        counter=counter+1;
    end
    
end

diffname='FrOstNovA2';
WriteOsuFile(s,osuObjCr,osuFolder,diffname)

end


function [tf,n_itv]=judgeslider(type,n)

N=length(type);
n_itv=0;
tf=0;

if n>N||type(n)~=2
    tf=0;
else
    k=n+1;
    while k<N||type(k)~=3
        if type(k)==1||type(k)==2
            tf=0;
            break;
        elseif type(k)==3
            tf=1;
            break;
        end
        k=k+1;
    end
end

if tf==1
    n_itv=k-n;
end

end
