%��ԭʼDCE������ѡȡDCE-MRIͼ�񣬲���ÿ��slice���2d+t����άnrrdͼ��%
%���룺dcm�ļ�Ŀ¼
%�����void
close all; clear all
root_path = 'D:\dataset\anonymized_DICOM\0*';
root_dir = dir(root_path);
num_case = length(root_dir);
mri_path = [];
save_file = 'foldertopatientdce2d.txt';
fid = fopen(save_file,'w');
header = nhdr_nrrd_read('seg_1610.nrrd',1);
save_dir = strcat('dce2d');
if ~isdir(save_dir)
    mkdir(save_dir);
end
for i = 1:num_case
    tmp_path = strcat(root_dir(i).folder,'\',root_dir(i).name);
    if isdir(tmp_path)
        mri_path = tmp_path;
    else
        mri_path = [];
        continue;
    end
    
    %�ж��Ƿ���dcm�ļ���
    if ~isempty(mri_path)
         [dce_path,isexistdce] = ifexistdcedata(mri_path);
    else
        continue;
    end
    
    if isexistdce == 1
        %�������ݿ��ļ���
        patient_name = root_dir(i).name;
        %�������DCE�ļ��У��洢dce�ļ�
        write_dce_dataset_way2(dce_path,patient_name,header);
        fprintf(fid,'folder=%d, patient=%s\n', i, root_dir(i).name);
    else
        continue
    end
end
fclose(fid);