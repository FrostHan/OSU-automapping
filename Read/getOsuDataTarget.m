function osuDataTarget = getOsuDataTarget(Ts,osuObj)

% This function is for generating the targets to the neural network, as a
% formatized data of the the beatmap created by humans.
% 
% Specially designed for convolution NN "FrostNova" Ver1
% -----------Input------------ 
% Ts: the rhythm poitns of the song, Ts=Ts=getRhythmPoints(s), where s
% is the osu structure.
% osuObj: the objects of the map, osuObj=osuObjectParser(s);
% -----------Output------------
% osuDataTarget:
% 
% -----------------------
% By Dongqi Han, OIST

n=1; %drop the first and last timing points.

osuDataTarget.isCircle=zeros(1,length(Ts)-2);
osuDataTarget.isSliderHead=zeros(1,length(Ts)-2);
osuDataTarget.isSliderEnd=zeros(1,length(Ts)-2);
osuDataTarget.isSpinnerHead=zeros(1,length(Ts)-2,1);
osuDataTarget.isSpinnerEnd=zeros(1,length(Ts)-2,1);
osuDataTarget.timing=zeros(1,length(Ts)-2,1);

z0=1;
while osuObj(z0).timing<Ts(1)
    z0=z0+1;
end
    
for z=z0:length(osuObj) 
    
    
    while n<length(Ts)-1&&abs(osuObj(z).timing-Ts(n))>3
        n=n+1;
    end
    
    if n>=length(Ts)-1
        break;
    end
    
    if n>1
        switch osuObj(z).type
            case 'circle'
                osuDataTarget.isCircle(n)=1;
            case 'slider'
                osuDataTarget.isSliderHead(n)=1;
            case 'spinner'
                osuDataTarget.isSpinner(n)=1;
        end
        osuDataTarget.timing(n)=osuObj(z).timing;
    end
    
    
    n=n+1;
    
    
end




end


