function net=bsnet2(layersizes)
% An multi-layer neural network for simulation of birdsong neurons.
% layersize: [layersize1,layersize2,...,layersizeN]
% version2
% Created by Dongqi Han,OIST

net = network;

%--------------------Network Properties------------------------
net.numInputs=1;
% net.inputs{1}.size=[size(X{1},1),size(X{1},2)];

net.numLayers=length(layersizes);

%----define connectivities---

net.inputConnect(1,:)=1; % only the first la    yer has input
net.outputConnect(net.numLayers)=1; % output only from the last layer

for n=1:net.numLayers
    net.biasConnect(n)=1; %every layer has  bias
end

for i=1:net.numLayers
    for j=1:net.numlayers
        if i==j+1
            net.layerConnect(i,j)=1; % one layer only connect to the next one
        end
    end
end

%----define layer properties------
for n=1:net.numLayers
    net.layers{n}.transferFcn='logsig';
    net.layers{n}.size=layersizes(n);  %number of neurons
end

net.layers{net.numLayers}.transferFcn='poslin'; %The last layer, linear
% net.layers{net.numLayers}.initFcn='initnw';

%----define functions--------
net.trainFcn='trainlm';
net.trainParam.lr = 0.01;  
net.trainParam.min_grad=0;
net.trainParam.epochs=10000;
net.trainParam.max_fail=16;
net.trainParam.goal=1e-5;

net.divideFcn='dividerand';
net.divideParam.trainRatio=0.4;
net.divideParam.valRatio=0.2;
net.divideParam.testRatio=0.4;
net.performFcn='mse';

net.plotFcns={'plotperform', 'plottrainstate', 'ploterrhist', 'plotroc'};


%----define input properties-----
net.inputs{:}.range=[0,1]; %the probability of firing 
net.inputs{:}.size=0;

%----define output properties-----
net.outputs{net.numLayers}.range=[0,1]; %the probability of firing 


% %----initialize IW,LW------
% for i=1:1
%     for j=1:1
%         net.IW{i,j}=rand(size(net.IW{i},1),size(net.IW{i},2));
%     end
% end



for i=2:net.numLayers
    j=i-1;
    
    net.LW{i,j}=rand(size(net.LW{i,j},1),size(net.LW{i,j},2));

end
%-----------------------------


end