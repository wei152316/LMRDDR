function f = calcrc(T,R)
    n  = sqrt(length(T));
    Tm = reshape(T,[n,n]);
    Rm = reshape(R,[n,n]);
    rbig=Tm-Rm;
    [y,x]=find_imagebox(rbig); r=rbig(y,x);
    r(isnan(r))=nanmean(r(:));

    Qr=mirt_dctn(r);
    Li=Qr.^2+0.05;
    f=0.5*sum(log(Li(:)/0.05));
end

function [y,x]=find_imagebox(im)
[i,j]=find(~isnan(im)); 
n=0; % border size
y=min(i)+n:max(i)-n;
x=min(j)+n:max(j)-n;
end