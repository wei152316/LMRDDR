% É¾³ýÆ¥Åä»µµã
function LM = badpoint(LM)
if nargin == 0
    runminexample(); 
end
[m,~] = size(LM);
count = 1;
for i = 1:m
    if LM(count,1) == 0
        LM(count,:) = [];
        count = count - 1;
    end
    count = count + 1;
end
end
function runminexample()
load np.mat
badpoint(newLM);
end