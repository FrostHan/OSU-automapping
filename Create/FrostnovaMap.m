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

diffname='FrOstNovA23';

Ts=getRhythmPoints(s);

N=length(Ts);

if size(y,1)<N
    y=[y;zeros(N-size(y,1),4)];
end

[~,type]=max(y(:,1:3),[],2);

counter=1;

%--------trace by chaotic equations--------

% DT1=400;
% DT2=10;
% 
% t_max=max(Ts);
% xC=henon(round(t_max/DT1)+1);
% xC=mapminmax(xC',20,480);
% yC=mackeyglass(round(t_max/DT2)+1);
% yC=mapminmax(yC',20,350);
% 
% figure
% plot(DT1:DT1:length(xC)*DT1,xC)
% hold on
% plot(DT2:DT2:length(yC)*DT2,yC)
% xlim([1000,3000])

for n=1:N
    
    [tf,n_itv]=judgeslider(type,n);
    
    if type(n)==1&&y(n,1)>threshold %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        counter=counter+1;
        
    elseif tf&&y(n,2)>threshold  %slider 
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'slider';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        
        osuObjCr(counter).interval = Ts(n+n_itv)-Ts(n);
        osuObjCr(counter).length = n_itv;
        type(n+n_itv)=3; %assign a slider end
        osuObjCr(counter).turns = 1;
        counter=counter+1;
        
    elseif type(n)==4||3 %empty or slider end
        
        
    else %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        
        counter=counter+1;
    end
    
end


try
    WriteOsuFile(s,osuObjCr,osuFolder,diffname)
catch ME
    disp(ME);
end

end


function [tf,n_itv]=judgeslider(type,n)

N=length(type);
n_itv=0;
tf=0;

if n>N||type(n)~=2
    tf=0;
else
    k=n+1;
    while k<N && type(k)~=3
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

% function x=ouProcess(t_max)
% 
% th = 1/500;
% mu = 250;
% sig = 10;
% 
% dt = 1;
% t = 0:t_max  ;        % Time vector
% x = zeros(1,length(t)); % Allocate output vector, set initial condition
% rng('shuffle');                 % Set random seed
% for i = 1:length(t)-1
%     x(i+1) = x(i)+th*(mu-x(i))*dt+sig*sqrt(dt)*randn;
% end
% 
% x = mapminmax(x,0,450);
% % figure;
% % plot(t,x);
% 
% end