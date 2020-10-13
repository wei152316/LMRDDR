%显示配准误差曲线
%输入:nres:所有配准的变形场，lm_gt: 约束点的真实值
%输出：error：标记点的误差；
function  error = show_error_curve(nres,lm_gt,refim,im)
n = size(nres,2); %记录配准的次数
error = zeros(n,1);
for i=1:n
    LM_new = gen_landmark(nres(i),refim,im,0,'refp',lm_gt(:,3:4));
    tmp = LM_new(:,1:2)-lm_gt(:,1:2);
    error(i) = mean(sqrt(tmp(:,1).^2+tmp(:,2).^2));
end