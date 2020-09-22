%% 读取log文件中的结果,并画图
clear all; close all
fid = fopen('result.log');
if fid
    num = 1;
    while feof(fid) ~=1
       tline = fgetl(fid);
       if num == 1
       title = tline;
       end
       if(contains(tline,'number'))
           p = strfind(tline,'=');
           result(1,num) = str2double(tline(p+1:end));
       end
       if(contains(tline,'after'))
           p = strfind(tline,'=');
           result(2,num) = str2double(tline(p+1:end));
           num = num+1;
       end
       if(contains(tline,'ssd'))
           p = strfind(tline,'=');
           result(3,1) = str2double(tline(p+1:end));
       end
       if(contains(tline,'MI'))
           p = strfind(tline,'=');
           result(3,2) = str2double(tline(p+1:end));
       end
       if(contains(tline,'before'))
           p = strfind(tline,'=');
           result(3,3) = str2double(tline(p+1:end));
       end
    end
else
    error('没有相应文件');
end
r = ones(1,size(result(1,6:end),2));
figure, 
plot(result(1,6:end),result(2,6:end),result(1,6:end),r.*result(3,1),result(1,6:end),r.*result(3,2),result(1,6:end),r.*result(3,3));
xlabel('number of landmarks');
ylabel('mean error');