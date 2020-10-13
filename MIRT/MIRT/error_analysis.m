load result_107_0.1_10_nonorm.mat
nonorm_res = nres;

load result_107_0.1_10_norm.mat
norm_res = nres;

nonorm_error = show_error_curve(nonorm_res,LM_ground_truth,refim,im);

norm_error = show_error_curve(norm_res,LM_ground_truth,refim,im);

x = 0.1:0.1:10;
plot(x,nonorm_error(2:end),'r-',x,norm_error(2:end),'g-');