
input=osuDataInput.input;
[input1,target1]=regularizeDataInputTarget(input,target);

for i=1:10
    net=bsnet2([45,5,1]);
    [net,tr]=train(net,input1,target1);
    NET{i}=net;
    TR{i}=tr;
end

for i = 1:10
    pf(i)=TR{i}.best_tperf;
end
   
[~,ind]=min(pf);
net=NET{ind};

Y=net(input1);
figure
plot(Y(180:190));
hold on
plot(target1(180:190));

figure
plot(round(Y(80:95)));
hold on
plot(target1(80:95));

figure
histogram(round(Y)-target1)