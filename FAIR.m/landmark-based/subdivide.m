function [wOpt,Mn] = subdivide(wOpt,Mn,flag)
    if flag == 1 %coarse to fine
        X = permute(reshape(wOpt,[Mn,2]),[2,1,3]);
        [mg,ng,tmp]=size(X);
        x=squeeze(X(:,:,1,:));
        y=squeeze(X(:,:,2,:));
        xnew=zeros(mg, 2*ng-1, 1);
        ynew=zeros(mg, 2*ng-1, 1);
        xfill=(x(:,1:end-1,:)+x(:,2:end,:))/2;
        yfill=(y(:,1:end-1,:)+y(:,2:end,:))/2;
        for i=1:ng-1 %inter on the x axis first
            xnew(:,2*i-1:2*i,:)=cat(2,x(:,i,:), xfill(:,i,:)); 
            ynew(:,2*i-1:2*i,:)=cat(2,y(:,i,:), yfill(:,i,:)); 
        end
        xnew(:,end,:) = x(:,end,:);
        ynew(:,end,:) = y(:,end,:);
        
        x = xnew;y = ynew;
        xfill = (x(1:end-1,:,:)+x(2:end,:,:))/2;
        yfill = (y(1:end-1,:,:)+y(2:end,:,:))/2;
        xnew=zeros(2*mg-1, 2*ng-1, 1);
        ynew=zeros(2*mg-1, 2*ng-1, 1);
        for i=1:mg-1 %inter on the x axis first
            xnew(2*i-1:2*i,:,:)=cat(1,x(i,:,:), xfill(i,:,:)); 
            ynew(2*i-1:2*i,:,:)=cat(1,y(i,:,:), yfill(i,:,:)); 
        end
        
        xnew(end,:,:) = x(end,:,:);
        ynew(end,:,:) = y(end,:,:);
        
        xnew = xnew';ynew = ynew';
        wOpt=cat(4, xnew, ynew);
        wOpt=permute(wOpt,[1 2 4 3]);
        Mn = size(wOpt(:,:,1));
        wOpt = wOpt(:);
    end
end