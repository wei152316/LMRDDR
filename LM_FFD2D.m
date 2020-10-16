%landmark based ffd registration
function LM_FFD2D(load_name,save_loc,ref_slice)
    if nargin == 0
        runminexample();
        return;
    end
    header = nhdr_nrrd_read('seg_1610.nrrd',1);
    img_dir = dir(load_name);
    l = 60; thrc = 20;
    image_name = strcat(load_name(1:end-6),'im.nrrd');
    tmpdata = nrrdread(image_name);
    data = tmpdata;
    refim = data(:,:,ref_slice);
    header.data = permute(refim,[2,1,3]);
    header.type = 'double';
    save_name = strcat(save_loc,'refim.nrrd');
    if ~isdir(save_loc)
        mkdir(save_loc);
    end
    nhdr_nrrd_write(save_name,header,1);

    for i = 1:l %find landmark correspondences
        im{i} = data(:,:,i);
%         [im1{i},wc{i}] = prereg(refim,im{i});
        wc{i} = [0;0;0];
        [newLM_ro{i},newLM{i}] =  match_point(refim,im{i},wc{i},0.1,4,13,thrc);
    end
    
    lambda = 0.1; % 
    for i = 1:l %perform lm-based registration
        weight = calc_weight(newLM_ro{i});
        [res_MsLRM{i},newim] =  lm_reg2D(refim,im{i},lambda,newLM_ro{i},weight);
        newim(isnan(newim))=0;
        newim3D(:,:,i) = newim; 
    end
    header.sizes = [240,240,l];
    header.data = permute(newim3D,[2,1,3]);
    save_name = strcat(save_loc,'newim.nrrd');
    nhdr_nrrd_write(save_name,header,1);
    res = res_MsLRM;
    name = strcat(save_loc,'res.mat');
    save(name,'res','newLM_ro','newLM');
end

function runminexample()
    dbstop if error
%     clear all; close all;
    addpath(genpath('mslrm/'));
    load_name = strcat('P0032_layer=14/data/*.nrrd');
    save_loc = strcat('P0032_layer=14/lc_ffd_result-ref=8\');
    layer = 14;
    ref_slice = 8;
    LM_FFD2D(load_name,save_loc,ref_slice);
end