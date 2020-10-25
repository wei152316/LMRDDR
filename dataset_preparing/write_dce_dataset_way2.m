%将dcm图像保存为nrrd图像
%输入：dce文件路径,保存路径,nrrd_header
%输出：void
function write_dce_dataset_way2(dce_path,patient_name,header)
if nargin == 0
    test()
    return;
end
addpath(genpath('D:\code\paper2\nrrd_read_write_rensonnet\nrrd_read_write_rensonnet'))
imagedir = dir(dce_path);
n = size(imagedir,1);
position = zeros(n,1);
trigger_time = zeros(n,1);
sorted_time = zeros(n,1);
for i = 1:n
    full_name = strcat(dce_path(1:end-3),imagedir(i).name);
    imageinfo = dicominfo(full_name);
    tmp = imagedir(i).name;
    image_sequence{i} = tmp;
    position(i) = imageinfo.ImagePositionPatient(3);
    trigger_time(i) = imageinfo.TriggerTime;
end
tmp = 1:n;
[sorted_position,order] = sort(position,1,'ascend');
sorted_time(tmp) = trigger_time(order);
sorted_image(tmp) = image_sequence(order);

for i = 1:30%30层 排序
        time = sorted_time((i-1)*60+1:(i-1)*60+60);
        [tmp,order]=sort(time,1,'ascend');
        sorted_time((i-1)*60+1:(i-1)*60+60) = tmp;
        tmp = sorted_image((i-1)*60+1:(i-1)*60+60);
        sorted_image((i-1)*60+1:(i-1)*60+60) = tmp(order);
        tmp = sorted_position((i-1)*60+1:(i-1)*60+60);
        sorted_position((i-1)*60+1:(i-1)*60+60) = tmp(order);
end
clear position trigger_time
%读取图像
for i = 1:30 %层数
    save_name = strcat('dce2d\p',patient_name,'_l_',num2str(i),'.nrrd');
    header.type = 'uint16';
    header.sizes = [240,240,60];
    header.data = uint16(zeros(header.sizes));
    for j = 1:60 %图像数
        fullname = strcat(dce_path(1:end-3),sorted_image{(i-1)*60+j});
        image = dicomread(fullname);
        header.data(:,:,j) = permute(image,[2,1]);
    end
    nhdr_nrrd_write(save_name,header,1);
end
end

function test()
header = nhdr_nrrd_read('seg_1610.nrrd',1);
save_dir = strcat('dce2d');
if ~isdir(save_dir)
    mkdir(save_dir);
end
dce_path = 'D:\dataset\anonymized_DICOM\000004\1501\IM*';
write_dce_dataset_way2(dce_path,'0004',header);
end
