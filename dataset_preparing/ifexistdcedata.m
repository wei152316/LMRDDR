%�жϸ���Ŀ¼���Ƿ����DCE�ļ�
%���룺dcm�ļ�·��
%�����dce�ļ�·�����Ƿ����dce�ļ�flag
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