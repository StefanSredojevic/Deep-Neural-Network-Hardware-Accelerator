%Decimal floating point to binary fixed point
clear
clc
filename = 'sigmoid.txt';
txt = csvread(filename);

WORD = 10;% Number of bits which is send like addres to LUT BRAM

a = fi(txt',0,WORD,WORD-1);
c = bin(a);

fileID = fopen('sigmoid_binary.txt','w');
formatSpec = '%s,\n';
for i = 1:(2^WORD)
    temp = c(i,:);
    fprintf(fileID,formatSpec,temp);
end
fclose(fileID);

%Sorting data
disp('Sorting');
fileID = fopen('sigmoid_binary_sorted.txt','w');
%formatSpec = '%d''b%s: data <= %d''b%s;\n';
formatSpec = 'ram[%d] = %d''b%s; \t';
j = 1;

%for i = 32769:65536
for  i = (((2^WORD)/2)+1) : (2^WORD)
    c_sorted(j,:) = c(i,:);
    j = j + 1;
end

%for i = 0:32767
for i = 0:(((2^WORD)/2)-1)
    %c_sorted(j,:) = c(32768-i,:);
    c_sorted(j,:) = c(((2^WORD)/2)-i,:);
    j = j + 1;
end

x = 1;

for i = 1:(2^WORD)
    temp                = c_sorted(i,:);
    bin                 = de2bi((i-1),WORD);
    bin_string          = mat2str(bin,WORD);
    %bin_string_full     = {bin_string(2),bin_string(4),bin_string(6),bin_string(8),bin_string(10),bin_string(12),bin_string(14),bin_string(16),bin_string(18),bin_string(20),bin_string(22),bin_string(24),bin_string(26),bin_string(28),bin_string(30),bin_string(32)};
    %bin_string_full should be all pair numbers, for WORD = 3 its 3 pair
    %numbers like 2 - 4 - 6 for WORD = 5 its 2 - 4 - 6 - 8 - 10 etc
    bin_string_full     = {bin_string(2),bin_string(4),bin_string(6),bin_string(8),bin_string(10),bin_string(12),bin_string(14),bin_string(16),bin_string(18),bin_string(20)};
    bin_string_joined   = strjoin(bin_string_full);
    bin_string_joined   = bin_string_joined(find(~isspace(bin_string_joined)));
    bin_string_joined   = fliplr(bin_string_joined);
    %fprintf(fileID,formatSpec,WORD,bin_string_joined,WORD,temp);
    fprintf(fileID,formatSpec,i-1,WORD,temp);
    if(x==4) 
        fprintf(fileID,'\n');
        x = 1;
    else
       x = x + 1; 
    end
    
end

fclose(fileID);