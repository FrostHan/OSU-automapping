function osuObjCr=FrostnovaMap(s,y,osuFolder,threshold,diffname,slider_2_circle_ratio) 

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


if nargin<6
    slider_2_circle_ratio = 0.08;
end

if nargin<5
    diffname='FrOstNovA';
end

Ts=getRhythmPoints(s);

N=length(Ts);

%----------to make some uncertainty when judgeing slider or circle-------
y(:,1) = y(:,1) - 0.05 + 0.1*rand(size(y,1),1);
y(:,2) = y(:,2) - 0.05 + 0.1*rand(size(y,1),1) + slider_2_circle_ratio;
y(:,3) = y(:,3) - 0.05 + 0.1*rand(size(y,1),1) + slider_2_circle_ratio;
y(:,4) = y(:,4) > (1 - threshold) ; 
%------------------------------------------------------------------------

[~,type]=max(y(:,1:4),[],2);

counter=1; % object counter

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
n=1;
while n<=N
    
    [tf,n_itv]=judgeslider(y,n);
    
    if tf&&y(n,2)>threshold  %slider 
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'slider';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        
        osuObjCr(counter).interval = Ts(n+n_itv)-Ts(n);
        osuObjCr(counter).length = n_itv;
        y(n+n_itv,1)=0; %assign a slider end
        y(n+n_itv,2)=0;
        y(n+n_itv,3)=0;
        y(n+n_itv,4)=1;
        osuObjCr(counter).turns = 1;
        counter=counter+1;
        n=n+n_itv+1;
    
    elseif y(n,1)>threshold %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        counter=counter+1;
        n=n+1;        
    elseif max(y(n,1:3))<threshold %empty 
        n=n+1;
        
    else %circle
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(250+200*cos(Ts(n)/400));
        osuObjCr(counter).y = round(200+150*sin(Ts(n)/400));

%         osuObjCr(counter).x = round(xC(round(Ts(n)/DT1)+1));
%         osuObjCr(counter).y = round(yC(round(Ts(n)/DT2)+1));
        
        counter=counter+1;
        n=n+1;
    end
    
end


try
    WriteOsuFile(s,osuObjCr,osuFolder,diffname)
catch ME
    disp(ME);
end

end


function [tf,n_itv]=judgeslider(y,n)

[~,type]=max(y(:,1:4),[],2);

N=length(type);
n_itv=0;
tf=0;

if n>N
    tf=0;
else
    k=n+1;
    while k<N 
        if type(k)~=4 && y(n,2)+y(k,3)<y(n,1)+y(k,1)
            tf=0;
            break;
        elseif type(k)~=4 && y(n,2)+y(k,3)>y(n,1)+y(k,1)
            tf=1;
            break;
        end
        k=k+1;
    end
end

if tf==1
    n_itv = k-n;
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