%判断给定目录下是否存在DCE文件
%输入：dcm文件路径
%输出：dce文件路径，是否存在dce文件flag
function [dce_path,isexistdce] = ifexistdcedata(full_path)
if nargin == 0
    test()
    return;
end
filedir = dir(full_path);
isexistdce = 0;dce_path = [];
l = length(filedir);
for i = 1:l
    file_path = strcat(full_path,'\',filedir(i).name,'\IM*');
    num_img = length(dir(file_path));
    if num_img == 1800
        X = sprintf('dce image is %s found',filedir(i).name);
        dce_path = file_path;
        isexistdce = 1;
        break;
    else
        isexistdce = 0; 
    end
end
end

function test()
    dcm_path = 'D:\dataset\anonymized_DICOM\000004';
    [dce,fdce] = ifexistdcedata(dcm_path);
    disp(dce);
    disp(fdce);
end