%Decimal floating point to binary fixed point
clear
clc

%uncomment if you need this conversion
%fid = fopen('BIASES BINARY.txt');
%switched = 0;
%FILE_BIN = fopen('BIASES HEX.txt','w');

%uncomment if you need this conversion
fid = fopen('INPUTS BINARY.txt');
switched = 1;
FILE_BIN = fopen('INPUTS HEX.txt','w');

%uncomment if you need this conversion
%fid = fopen('WEIGHTS BINARY.txt');
%switched = 0;
%FILE_BIN = fopen('WEIGHTS HEX.txt','w');

if(switched==0)
    tline0 = fgetl(fid);
    tline1 = fgetl(fid);

    i = 2;

    while ischar(tline0)
        %num         = bin2dec(tline)
        %hexString   = dec2hex(num);
        text0 = sprintf('%0*X', ceil(length(tline0)/4), bin2dec(tline0));
        text1 = sprintf('%0*X', ceil(length(tline1)/4), bin2dec(tline1));
        fprintf(FILE_BIN,'0x%s%s,',text1,text0);%ide ovako kontra

        if(i==6)
            fprintf(FILE_BIN,'\n');
            i=1;
        end

        i = i +1;
        tline0 = fgetl(fid);
        tline1 = fgetl(fid);
    end
else
    tline0 = fgetl(fid);
    
    i = 2;

    while ischar(tline0)
        %num         = bin2dec(tline)
        %hexString   = dec2hex(num);
        text0 = sprintf('%0*X', ceil(length(tline0)/4), bin2dec(tline0));
        fprintf(FILE_BIN,'0x%s%s,',text0,text0);

        if(i==6)
            fprintf(FILE_BIN,'\n');
            i=1;
        end

        i = i +1;
        tline0 = fgetl(fid);
    end
end
fclose(FILE_BIN);