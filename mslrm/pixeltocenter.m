%��ͼ�����ص�ת����centergrid
%���� x �ֲ�������꣬������*������
% omega:����ͼ��Χ
% p :��*��
% m: ͼ��Ĵ�С ��*��
function xc = pixeltocenter(x,omega,m,p)
if nargin  == 0
    runminexample();
    return
end
dim = length(omega)/2;
tt = reshape(x,p(2),p(1),dim);
tx = tt(:,:,1);ty = tt(:,:,2);
px = tx(1,:); py = ty(:,1)';
h  = (omega(2:2:end)-omega(1:2:end))./m;
xi = @(i) linspace(omega(2*i-1)+h(i)/2,omega(2*i)-h(i)/2,m(i))';     % cell centers
px = (px-0.5)*h(2) + 0; py = (py-0.5)*h(1) + 0;
cx = repmat(py',1,p(1));cy = repmat(px,p(2),1);
xc = [reshape(cx,[],1);reshape(cy,[],1)];
end
function runminexample()
[a,b] = meshgrid(3:7,4:6);
x = [reshape(a,[],1);reshape(b,[],1)];
%��������������
m = [10,10];omega = [0,1,0,2];
p = [5,3];
xc = pixeltocenter(x,omega,m,p);
end