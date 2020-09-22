%分析图像的均值和标准差去除变化比较大的异常的点
function newLM = routlier(LM,a)
if nargin == 0
runminexample;
return;
end
r = LM(:,1:2) - LM(:,end-1:end);
value = sqrt(diag(r*r'));
lm_mean = mean(value);
lm_std = std(value);
index = value > lm_mean + a * lm_std;
newLM = LM;
while(sum(index))
    newLM = newLM(~index,1:end);
    value = value(~index);
    lm_mean = mean(value);
    lm_std = std(value);
    index = value > lm_mean + a * lm_std;
end
end

function runminexample()
clear all; close all;
load np.mat
newLM = badpoint(newLM);
newLM = routlier(newLM(:,3:end),3);
end