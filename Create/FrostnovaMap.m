function osuObjCr=FrostnovaMap(s,Ts,input,net,threshold)



output=net(input);

counter=1;

for n=2:length(Ts)-1
    
    if output(n-1)>threshold
        osuObjCr(counter).timing= Ts(n);
        osuObjCr(counter).type = 'circle';
        osuObjCr(counter).x = round(rand(1,1)*100+200);
        osuObjCr(counter).y = round(rand(1,1)*100+150);
        counter=counter+1;
    end
    
end

dir='/Users/dongqihan/Downloads/opsu/Songs/13019 Daisuke Achiwa - BASARA/';
diffname='FrOstNovA';
WriteOsuFile(s,osuObjCr,dir,diffname)

end