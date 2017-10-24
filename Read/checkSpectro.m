function checkSpectro(osuDataInput,osuDataTarget,Ts,Nidxs)

% This function is for visualizing the spectrogram around a rhythm points,
% where it can be showed which type of object is there.
%
%
% -----------------------------
% By Dongqi Han, OIST

P=4;
N=length(Ts);
N_t=128;
f=exp(linspace(log(20),log(10000),128));
% f=linspace(20,10000,128);
% f=linspace(1,128,128);
if nargin<4
    idxs=randperm(N-2*P-2,10)+(P+1);
else
    idxs=Nidxs;
end


for n=idxs
    
    figure
    subplot(3,1,1:2)
    tq=linspace(Ts(max(n-P,1)),Ts(min(n+P,length(Ts))),N_t);
    [TQ,FQ]=meshgrid(tq,f);
%     contourf(TQ,FQ,squeeze(osuDataInput(n,:,:)),30,'linestyle','none')
    contourf(squeeze(osuDataInput(n,:,:)),'linestyle','none')
%     pcolor(squeeze(osuDataInput(n,:,:)))
    title(['Around time t =',num2str(Ts(n)/1000),'s'])
    hold on
    
    subplot(3,1,3)
    
    
    for j=1:9
        [~,tp]=max(osuDataTarget(n-5+j,:));
        hold on
        if tp==1 %circle
            plot([j,j],[0.5,0.5],'r.','markersize',30)
        elseif tp==2 %sliderHead
            plot([j,j+0.5],[0.5,0.5],'b->','markersize',10)
            plot([j,j],[0,1],'b')
        elseif tp==3 %sliderEnd
            plot([j,j],[0,1],'b')
            plot([j-0.5,j],[0.5,0.5],'b->','markersize',10)
        end
    end
    
    xlim([1,9])
    ylim([0,1])
end

end