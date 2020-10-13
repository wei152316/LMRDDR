%���ܣ��ñ�ǵ�Լ����׼
%���룺LM����ǵ㣬X����ǰ�����λ��,lamda��ϵ�� okno:����Ŀ��
%�����y������ֵ��dy ����
%LM��ǰ�����Ǹ���ͼ������꣬�������ǲο�ͼ������� im-->refim
function [y,dy] = landmark(LM,X,okno,lamda,main)
% step1:compute B spline confidences Q
% step2:compute y
% step3:compute dy
weight = main.weight;
if nargin == 0
help(mfilename)
runminexample;return 
end
y = 0; %��ʼ��y
[mg,ng,~] = size(X);
[np,~] = size(LM);
tmp = (LM(:,3)-1)./okno;
px = floor(tmp);fx = tmp - px;%��ȡ������С������������
tmp = (LM(:,4)-1)./okno;
py = floor(tmp);fy = tmp - py;%��ȡ������С������������
ddx = zeros(mg,ng);
ddy = zeros(mg,ng); %���Ƶ��ϵĵ���
nx = ones(mg,ng); %��¼ÿ�����Ƶ���ӵĴ���
ny = ones(mg,ng);
for i = 1:np
    Fi = mirt2D_F(fx(i),fy(i));
    tmp = X(py(i)+1:py(i)+4,px(i)+1:px(i)+4,1);
    Cx = Fi*tmp(:);
    tmp = X(py(i)+1:py(i)+4,px(i)+1:px(i)+4,2);
    Cy = Fi*tmp(:);
    rx = LM(i,1)-Cx; ry = LM(i,2)-Cy;
    if sqrt(rx.^2+ry.^2) > -1
        if main.adaptive_weight ==1
            y = y + lamda.*weight(i).*sqrt(rx.^2+ry.^2); %Ŀ�꺯����ֵ
            ddx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = ddx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + lamda.*weight(i).*reshape(-2*rx*Fi',[4,4]);
            ddy(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = ddy(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + lamda.*weight(i).*reshape(-2*ry*Fi',[4,4]);
        else
            y = y + lamda.*sqrt(rx.^2+ry.^2); %Ŀ�꺯����ֵ
            ddx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = ddx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + lamda.*reshape(-2*rx*Fi',[4,4]);
            ddy(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = ddy(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + lamda.*reshape(-2*ry*Fi',[4,4]);   
        end
    end
%���Ƿ�ʹ���ݶȹ�һ��
    if main.norm == 1
        ny(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = ny(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + 1;
        nx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) = nx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) + 1;
    else
        ny(py(i)+1:py(i)+4,px(i)+1:px(i)+4) =  1;
        nx(py(i)+1:py(i)+4,px(i)+1:px(i)+4) =  1;
    end

end
dy = cat(3,ddx,ddy);

function Fi=mirt2D_F(ux,uy)
  
  B=[-1 3 -3 1;
    3 -6 3 0;
    -3 0 3 0;
    1 4 1 0]/6;

Tx=[ux.^3 ux.^2 ux 1];
Bx=Tx*B;

Ty=[uy.^3 uy.^2 uy 1];
By=Ty*B;

Fi=kron(Bx,By);

function runminexample
[x,y] = meshgrid(1-5:5:21,1-5:5:26);
X = cat(3,x,y);
LM = [1,2,3,4;5,6,7,8;9,10,11,12]; %���Ե㣬ǰ����Ϊ����ͼ�񣬺�����Ϊ�ο�ͼ��
lamda = 1;
main.okno = 5; %������Ϊ5;
[y,dy] = landmark(LM,X,main.okno,lamda);