close all; clear all
dataset_path = 'dce2d/p*';
new_data_path = 'dce';
patient_dir = dir(dataset_path);
num_patients = length(patient_dir);
if ~isdir(new_data_path)
    mkdir(new_data_path);
end

for i = 1:num_patients
    sprintf('patient_name:%s',patient_dir(i).name)
    p_path = strcat(new_data_path,'/','p',num2str(i));
    if ~isdir(p_path)
        mkdir(p_path);
        mkdir(strcat(p_path,'/pre_contrast'));
        mkdir(strcat(p_path,'/wash_in'));
        mkdir(strcat(p_path,'/wash_out'));
    end
    pre_index = input('pre_contrast:');
    max_index = input('max_enhancement:');
    for l = 1:30
        for t = 1:60
            if t < pre_index +1
                dst_file = strcat('dce/p',num2str(i),'/pre_contrast/l_',num2str(l),'t_',num2str(t),'.nrrd');
            elseif t < max_index +1
                dst_file = strcat('dce/p',num2str(i),'/wash_in/l_',num2str(l),'t_',num2str(t),'.nrrd');
            else
                dst_file = strcat('dce/p',num2str(i),'/wash_out/l_',num2str(l),'t_',num2str(t),'.nrrd');
            end
            src_file = strcat('dce2d/p',num2str(i),'/l_',num2str(l),'t_',num2str(t),'.nrrd');          
            copyfile(src_file,dst_file);       
        end
    end
end