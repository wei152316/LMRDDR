%��ʾ��׼�������
%����:nres:������׼�ı��γ���lm_gt: Լ�������ʵֵ
%�����error����ǵ����
function  error = show_error_curve(nres,lm_gt,refim,im)
n = size(nres,2); %��¼��׼�Ĵ���
error = zeros(n,1);
for i=1:n
    LM_new = gen_landmark(nres(i),refim,im,0,'refp',lm_gt(:,3:4));
    tmp = LM_new(:,1:2)-lm_gt(:,1:2);
    error(i) = mean(sqrt(tmp(:,1).^2+tmp(:,2).^2));
end