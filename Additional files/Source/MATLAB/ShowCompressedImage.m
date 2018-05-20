%lc
%clear all

filename = 'SDK_COMPRESSED_IMG.txt';
CSV = csvread(filename);

MAT = vec2mat(CSV,28,28);
IMG = mat2gray(MAT,[0 255]);
figure;
imshow(IMG);


%OVO TREBA DA SE URADI U HARDVERU
TEMP(1:784,1) = 255;

%Inverting values
for i=1:784
CSV2(i,1) = TEMP(i,1)-CSV(i,1);
end

%scaling
CSV2 = (CSV2/255);

%converting floating 0-1 value to fixed point in system S.4.11
i   = fi(CSV2,1,16,11);
i_h = hex(i);

%showing image after inverting values and scaling values
MAT2 = vec2mat(CSV2,28,28);
IMG2 = mat2gray(MAT2,[0 1]);
figure;
imshow(IMG2);


%Creating file[From here onwards]
numOfPictures = 1;
pictureResolution = 28*28;

%open file
FILE_BIN = fopen('cmpr_picture.h','w');

fprintf(FILE_BIN,'#ifndef SRC_CMPR_PICTURE_H_\n');
fprintf(FILE_BIN,'#define SRC_CMPR_PICTURE_H_\n');
fprintf(FILE_BIN,'\n');

fprintf(FILE_BIN,'u32 cmpr_picture[%d] = {',numOfPictures*pictureResolution);
for z = 1:(numOfPictures*pictureResolution)
    if(z == numOfPictures*pictureResolution)
        fprintf(FILE_BIN,'0x%s%s};',i_h(z,:),i_h(z,:));
    else
        fprintf(FILE_BIN,'0x%s%s,',i_h(z,:),i_h(z,:));
    end
    
    if(mod(z,28) == 0)
        fprintf(FILE_BIN,'\n\t\t\t\t\t\t');
    end
end

fprintf(FILE_BIN,'\n\n');

fprintf(FILE_BIN,'#endif\n');

fclose(FILE_BIN);