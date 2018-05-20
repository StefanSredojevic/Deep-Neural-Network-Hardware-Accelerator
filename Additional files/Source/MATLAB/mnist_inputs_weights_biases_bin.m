%Decimal floating point to binary fixed point
clear
clc

filename1 = 'weights_float.txt';
weights = csvread(filename1);
filename2 = 'inputs_float.txt';
inputs = csvread(filename2);
filename3 = 'biases_float.txt';
biases = csvread(filename3);

%convert weights and inputs to binary numbers in system 1.4.11
w   = fi(weights,1,16,11);%signed,16 bit word,11 bits for fraction
w_b = bin(w);

i   = fi(inputs,1,16,11);
i_b = bin(i);

b   = fi(biases,1,16,11);
b_b = bin(b);

%open file
FILE_BIN = fopen('mnist_inputs_weights_biases_bin.sv','w');

%writing binary values to file
fprintf(FILE_BIN,'logic [15:0] biases [0:41] = {     16''b%s,\t//%f\n',b_b(1,:),biases(1));
for z = 2:41
    fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s,\t//%f \n',b_b(z,:),biases(z));
end
fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s};\t//%f \n',b_b(42,:),biases(42));

fprintf(FILE_BIN,'\n\n');

fprintf(FILE_BIN,'logic [15:0] inputs [0:783] = {    16''b%s,\t//%f\n',i_b(1,:),inputs(1));
for z = 2:783
    fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s,\t//%f \n',i_b(z,:),inputs(z));
end
fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s};\t//%f \n',i_b(784,:),inputs(784));

fprintf(FILE_BIN,'\n\n');

fprintf(FILE_BIN,'logic [15:0] weights [0:12959] = { 16''b%s,\t//%f \n',w_b(1,:),weights(1));
for z = 2:12959
    fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s,\t//%f \n',w_b(z,:),weights(z));
end
fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s};\t//%f \n',w_b(784,:),weights(12960));

fclose(FILE_BIN);