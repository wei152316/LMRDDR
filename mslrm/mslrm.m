% input:
%refim: reference image
%im:    moving image
%LM:	candidate landmark points r extracted on reference image
%wc:    pre-registration parameter
%edge:  the trade off parameter in the modified NGF
%num_scale: number of scales in MsLRM 
%scale_factor: scale factor in MsLRM
% p: the size of block in MsLRM
% thrc: threshold in the first step in outlier removal.

%output:
%newLM: the resulting landmark points
%newLM_ro: the resulting landmark points after outlier removal

function [newLM_ro,newLM] =  mslrm(refim,im,LM,wc,edge,scale,blocksize,thrc)
    
    %multiscale local rigid matching
    [newLM,hiswc] = mslocal_rigid(im,refim,LM,num_scale,scale_factor,thrc,'edge',edge,'p',[blocksize,blocksize],'dispimage',0,'w0',wc);
    %outlier removal
    newLM = badpoint(newLM);
    tmp = newLM;
	%2rd step
    R = vision.internal.detector.HarrisResp(im,newLM);
    tmp = newLM(R>0.0000,:);
    newLM_ro = routlier(tmp(:,1:end),3);
end