
[songdata,fs]=audioread(songfile);

ajiduration=0.01; %in second
Naji=50;

Nfft=fs*ajiduration*2;
[S,F,T]=spectrogram(songdata(:,1),Nfft,Nfft/2,Nfft,fs);

S2=log(abs(S));

data=sum(S2,1);
data=mapminmax(data,0,1);

idx = (-Naji/2):(Naji/2);


for m=10:(length(osuObj)-20)

    [~,Tind]=min(abs(1000*T-osuObj(m).timing));
    timepoints = Tind+idx;
    
    aji(m-9,:)=data(timepoints);
    
    
end

aji=aji/max(max(aji));

for m=10:(length(osuObj)-20)
    
    if strcmp('circle',osuObj(m).type)
        ren(m-9,1)=1; % circle
    else
        ren(m-9,1)=0; %slider or spinner
    end
    
end

