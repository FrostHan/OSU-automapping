function [input2,target2,input4,target4]=regularizeDataInputTarget(input,target)

% This function is for kicking out some of the thythm points without
% objects, so that the number of inputs with a target 0,1 will have
% similar numbers

%---------------- generate 2D training data ------------------
idx0=find(target(:,4)==1);
idx1=find(target(:,4)==0);


input_tmp = input;
target_tmp = target;

if (length(idx0)>length(idx1))
    idxdelete=idx0(randperm(length(idx0),length(idx0)-length(idx1)));
    input_tmp(idxdelete,:,:)=[];
    target_tmp(idxdelete,:)=[]; 
end

input2=input_tmp;
target2=target_tmp;


%---------------- generate 4D training data ------------------

idxci=find(target(:,1)==1);
idxsh=find(target(:,2)==1);
idxse=find(target(:,3)==1);
idxep=find(target(:,4)==1);

min_num = min( [nnz(idxci), nnz(idxsh), nnz(idxse), nnz(idxep)] );


idx = ( [idxci(randperm(length(idxci),min_num));idxsh(randperm(length(idxsh),min_num));idxse(randperm(length(idxse),min_num));idxep(randperm(length(idxep),min_num)) ]);


input4=input(idx);
target4=target(idx,:);




end