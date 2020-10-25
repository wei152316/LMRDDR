close all; clear all
dataset_path = 'dce2d/p*';
new_data_path = 'dce';
patient_dir = dir(dataset_path);
num_patients = length(patient_dir);

%new_image_dir
if ~isdir(new_data_path)
    mkdir(new_data_path);
    mkdir(strcat(new_data_path,'/pre_contrast'));
    mkdir(strcat(new_data_path,'/wash_in'));
    mkdir(strcat(new_data_path,'/wash_out'));
    xlswrite('dce/info.xlsx',{'name','pre','wash-in'},1,'A1');
end
t = 1;
for i = 31:num_patients
    sprintf('patient_name:%s',patient_dir(i).name)
    if t == 1 || ~strcmp(pre_patient_name, patient_dir(i).name(1:7))
        pre_index = input('pre_contrast:'); %new_patient
        max_index = input('max_enhancement:');
        pre_patient_name = patient_dir(i).name(1:7);
        xlswrite('dce/info.xlsx',{pre_patient_name,pre_index,max_index},1,'A3');
    end
    k1 = strfind(patient_dir(i).name,'l_');
    k2 = strfind(patient_dir(i).name,'.nrrd');
    l = str2double(patient_dir(i).name(k1+2:k2-1));
    if l >13 
        srcfile_path = strcat('dce2d\',patient_dir(i).name);
        img_head = nhdr_nrrd_read(srcfile_path, 1);
        pre_head = img_head;
        pre_head.data = img_head.data(:,:,1:pre_index);
        pre_head.sizes = [pre_head.sizes(1), pre_head.sizes(2), pre_index];
        dst_file = strcat('dce/pre_contrast/',patient_dir(i).name);
        nhdr_nrrd_write(dst_file,pre_head,1);

        washin_head = img_head;
        washin_head.data = img_head.data(:,:,pre_index+1:max_index);
        washin_head.sizes = [pre_head.sizes(1), pre_head.sizes(2), max_index-pre_index];
        dst_file = strcat('dce/wash_in/',patient_dir(i).name);
        nhdr_nrrd_write(dst_file,washin_head,1);

        washout_head = img_head;
        washout_head.data = img_head.data(:,:,max_index+1:end);
        washout_head.sizes = [pre_head.sizes(1), pre_head.sizes(2), 60-max_index];
        dst_file = strcat('dce/wash_out/',patient_dir(i).name);
        nhdr_nrrd_write(dst_file,washout_head,1);
    end
    t = t+1;
end