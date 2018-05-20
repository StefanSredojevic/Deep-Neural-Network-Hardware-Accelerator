%Decimal floating point to binary fixed point
clear
clc

%find random values for weights and inputs
rng(0,'twister');
a = -2;
b = 2;
rnd_weights = [b-a].*rand(784,1)+a;
rnd_inputs  = [b-a].*rand(784,1)+a;

%convert weights and inputs to binary numbers in system 1.4.11
w   = fi(rnd_weights,1,16,11);%signed,16 bit word,11 bits for fraction
w_b = bin(w);

i   = fi(rnd_inputs,1,16,11);
i_b = bin(i);

%open file
FILE_INT_I = fopen('rnd_inputs_int.dat','w');
FILE_INT_W = fopen('rnd_weights_int.dat','w');
FILE_BIN = fopen('rnd_weights_inputs_bin.sv','w');

%writing integer values to file
for z = 1:784
    if(z<784)
        fprintf(FILE_INT_I,'%f,\n',rnd_inputs(z));
    else
        fprintf(FILE_INT_I,'%f\n',rnd_inputs(z));
    end
end

for z = 1:784
    if(z<784)
        fprintf(FILE_INT_W,'%f,\n',rnd_weights(z));
    else
        fprintf(FILE_INT_W,'%f\n',rnd_weights(z));
    end
end

%writing binary values to file
fprintf(FILE_BIN,'logic [15:0] rnd_inputs [783:0] = {16''b%s,\t//%f\n',i_b(1,:),rnd_inputs(1));
for z = 2:783
    fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s,\t//%f \n',i_b(z,:),rnd_inputs(z));
end
fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s};\t//%f \n',i_b(784,:),rnd_inputs(784));

fprintf(FILE_BIN,'\n\n');

fprintf(FILE_BIN,'logic [15:0] rnd_weights [783:0] = {16''b%s,\t//%f \n',w_b(1,:),rnd_weights(1));
for z = 2:783
    fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s,\t//%f \n',w_b(z,:),rnd_weights(z));
end
fprintf(FILE_BIN,'\t\t\t\t\t\t\t\t   16''b%s};\t//%f \n',w_b(784,:),rnd_weights(784));

fclose(FILE_INT_I);
fclose(FILE_INT_W);
fclose(FILE_BIN);