function [input1,target1]=regularizeDataInputTarget(input,target)

% This function is for kicking out some of the thythm points without
% objects, so that the number of inputs with a target 0,1 will have
% similar numbers


idx0=find(target==0);
idx1=find(target==1);

if (length(idx0)>length(idx1))
    idxdelete=idx0(randperm(length(idx0),length(idx0)-length(idx1)));


    input(:,idxdelete)=[];
    target(:,idxdelete)=[];
    
end

input1=input;
target1=target;

end