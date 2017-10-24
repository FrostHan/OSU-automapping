function [input,TS,TQ,FQ] = getOsuDataInput(s,songfile)

% This function is for generating the inputs to the neural network, as a
% formatized data of the songfile.
% 
% Specially designed for convolution NN "FrostNova" Ver1
% -----------Input------------ 
% Ts: the rhythm poitns of the song, Ts=Ts=getRhythmPoints(s), where s
% is the osu structure.
% songfile: the path of the music file.
% -----------Output------------
% osuDataInput: A Tensor of input for TENSORFLOW, each data set contains
% the matrix of spectrogram around a rhythm point.
% 
% -----------------------
% By Dongqi Han, OIST

t_reso = 50; % temporal resolution estimation(in milisecond) 
N_t = 128; % divide 
P = 4;
fq=exp(linspace(log(20),log(10000),128)); %range of frequency
% fq=linspace(20,10000,128);

%----------- read data -------------
[data0,fs]=audioread(songfile);
data1=data0(:,1); %left channel
data2=data0(:,2); %right channel

Nfft=round(fs/(1000/(t_reso))); 
window=hann(Nfft); 
noverlap=floor(length(window)*0.9);

[S1,~,~]=spectrogram(data1,window,noverlap,Nfft,fs);

S1 = log(1+abs(S1));
S1 = S1 / max(max(S1)); %normalize

[S2,f,t]=spectrogram(data2,window,noverlap,Nfft,fs);


% offset=length(window)/Nfft/2*t_reso;
% t=linspace(offset,length(data1)/fs*1000-offset,size(S2,2)); % ms

t=t*1000;

S2 = log(1+abs(S2));
S2 = S2 / max(max(S2)); %normalize

S=(S1+S2)/2;



Ts=getRhythmPoints(s);


osuDataInput=zeros(length(Ts),length(fq),N_t,'gpuArray'); %Input Tensor



% for n=1:length(Ts) %drop the first and last timing points.
%     
%     tq(1:N_t+1)=linspace(Ts(n-1),Ts(n),N_t+1);
%     tq(N_t+1:2*N_t+1)=linspace(Ts(n),Ts(n+1),N_t+1);
% 
%     tmp=interp1(T,S_t,tq);
%     
%     osuDataInput(n,n-1)=tmp/max(tmp);
%     
% end



%-------------------------------Find the decode offset--------------------
interval = Ts(2)-Ts(1);
St = sum(S,1); %sum up all frequency parts

tried_offsets = 0:round(interval/0.6);

LTs = length(Ts);

g = 3;
while g<LTs&&((Ts(g)-Ts(g-1))-(Ts(g-1)-Ts(g-2)))<=1
    g = g + 1; % find the end of first fixed-interval part of the song
end



i=0;

% target =  getOsuDataTarget(s);
% Tcircle = Ts(find(target(:,1)==1)); % timing of circles

for tried_offset =  tried_offsets
    i = i+1;
    tqt = Ts(1:2:(floor(g/2)*2-1)) + tried_offset;
%     tqt = Tcircle + tried_offset;
    s_tmp = interp1(t,St,tqt');
    tmp(i) = sum(s_tmp) ;
end 

[~,idx] = max(tmp);
decode_offset = tried_offsets(idx);
disp(['decode_offset = ',num2str(decode_offset)])

%-------------------------------------------------------------------------

[TS,~]=meshgrid(Ts,f); 
[T,F]=meshgrid(t,f);

Sg=gpuArray(S);
Tg=gpuArray(T);
Fg=gpuArray(F);

for n=1:length(Ts)-P
    if n<P+1
        tq=linspace(Ts(n)-P*interval,Ts(min(n+P,LTs)),N_t) + decode_offset ;
    else
        tq=linspace(Ts(max(n-P,1)),Ts(min(n+P,LTs)),N_t) + decode_offset ;% This decode offset is due to matlab audioread 
    end
    [TQ,FQ]=meshgrid(tq,fq);
    TQg=gpuArray(TQ);
    FQg=gpuArray(FQ);
    
    osuDataInput(n,:,:)=interp2(Tg,Fg,Sg,TQg,FQg);
    osuDataInput(n,:,:)=osuDataInput(n,:,:)/max(max(osuDataInput(n,:,:)));
%     if mod(n,500)==1
%         n
%     end
end

input=gather(osuDataInput);

end