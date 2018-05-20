%Decimal floating point to binary fixed point
clear
clc

filename1 = 'PICTURES_FLOAT.txt';
inputs = csvread(filename1);
filename2 = 'labels.txt';
labels = csvread(filename2);

i   = fi(inputs,1,16,11);
i_b = bin(i);
i_h = hex(i);

numOfPictures = 500;
pictureResolution = 28*28;

%open file
FILE_BIN = fopen('picture.h','w');

fprintf(FILE_BIN,'#ifndef SRC_PICTURE_H_\n');
fprintf(FILE_BIN,'#define SRC_PICTURE_H_\n');
fprintf(FILE_BIN,'\n');

fprintf(FILE_BIN,'u32 pictures[%d] = {',numOfPictures*pictureResolution);
for z = 1:(numOfPictures*pictureResolution)
    if(z == numOfPictures*pictureResolution)
        fprintf(FILE_BIN,'0x%s%s};',i_h(z,:),i_h(z,:));
    else
        fprintf(FILE_BIN,'0x%s%s,',i_h(z,:),i_h(z,:));
    end
    
    if(mod(z,5) == 0)
        fprintf(FILE_BIN,'\n\t\t\t\t\t\t');
    end
end

fprintf(FILE_BIN,'\n\n');

fprintf(FILE_BIN,'u32 labels[%d] = { ',numOfPictures);
for z = 1:numOfPictures
    if(z == numOfPictures)
        fprintf(FILE_BIN,'%d};',labels(z));
    else
        fprintf(FILE_BIN,'%d,',labels(z));
    end
    
    if(mod(z,10) == 0)
        fprintf(FILE_BIN,'\n\t\t\t\t\t');
    end
end

fprintf(FILE_BIN,'\n');
fprintf(FILE_BIN,'#endif\n');

fclose(FILE_BIN);