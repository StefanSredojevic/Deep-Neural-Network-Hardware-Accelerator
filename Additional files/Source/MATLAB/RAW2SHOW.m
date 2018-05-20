clc
clear all

row=120;  col=160;
%fin=fopen('CAM_IMG_RAW.bmp','r');
%I=fread(fin, col*row*3,'uint8=>uint8'); %// Read in as a single byte stream

I(1:160,1:120,1:3) = 0;
I = cast(I,'uint8');

fid = fopen('CAM_IMG_RAW.bmp');
tline = fgetl(fid);
for j = 1:120
    for i = 1:160
        for k = 1:3
            temp = str2num(tline);
            I(i,j,k) = temp;
            tline = fgetl(fid);
        end
    end
end
fclose(fid);

I = reshape(I, [col row 3]); %// Reshape so that it's a 3D matrix - Note that this is column major
Ifinal = flipdim(imrotate(I, -90),2); % // The clever transpose
imshow(Ifinal);