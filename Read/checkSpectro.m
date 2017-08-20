function checkSpectro(Ts,osuDataInput,osuDataTarget)

% This function is for visualizing the spectrogram around a rhythm points,
% where it can be showed which type of object is there.
%
%
% -----------------------------
% By Dongqi Han, OIST

N=length(Ts);

idxs=randperm(N-10,30)+5;

for i=idxs
    
    figure
    subplot(3,1,1:2)
    contourf(squeeze(osuDataInput(i,:,:)),'linestyle','none')
    hold on
    
    subplot(3,1,3)
    
    
    for j=1:9
        [~,tp]=max(osuDataTarget(i-5+j,:));
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
    
    xlim([0.9,9.1])
    ylim([0,1])
end

end