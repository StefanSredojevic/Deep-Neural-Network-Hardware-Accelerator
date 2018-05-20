//This library contains most needed function for programming and testing mlp
#include <math.h>
#include "xparameters.h"
#include "xil_types.h"
#include "interrupt.h"
#include "mlp_coefficients.h"
#include "mlp_lib.h"

#if(0)						//Setting this if to '1' set system to Debug mode
	#define DPRINT(args...) xil_printf(args)
#else
	#define DPRINT(args...)
#endif

#define INTERUPT_EN 1		//Setting this value to '1' enables delays
#define CHECK_MLP_OUTPUTS 1	//Setting this value to '1' enables mlp outputs checking

#define DM_EN  1024			//For enabling data mover we need to put 11th bit to 1, 0 value is for disabling

#define NUMBER_OF_USED_NEURONS 	2
#define NUMBER_OF_INPUTS  		784
#define NUMBER_OF_HIDDEN1 		16
#define NUMBER_OF_HIDDEN2 		16
#define NUMBER_OF_OUTPUTS 		10
#define NUMBER_OF_BIASES  ((NUMBER_OF_HIDDEN1+NUMBER_OF_HIDDEN2+NUMBER_OF_OUTPUTS)/NUMBER_OF_USED_NEURONS)
#define NUMBER_OF_WEIGHTS ((NUMBER_OF_INPUTS*NUMBER_OF_HIDDEN1+NUMBER_OF_HIDDEN1*NUMBER_OF_HIDDEN2+NUMBER_OF_HIDDEN2*NUMBER_OF_OUTPUTS)/NUMBER_OF_USED_NEURONS)

//STORAGE FOR LAYERS
u32 firstHiddenLayerStorage  [NUMBER_OF_HIDDEN1];
u32 secondHiddenLayerStorage [NUMBER_OF_HIDDEN2];
u32 outputsStorage	  		 [NUMBER_OF_OUTPUTS];

u32 current_layer [3] = {NUMBER_OF_HIDDEN1,NUMBER_OF_HIDDEN2,NUMBER_OF_OUTPUTS};
u32 previous_layer[3] = {NUMBER_OF_INPUTS,NUMBER_OF_HIDDEN1,NUMBER_OF_HIDDEN2};

u32	*mlp_axil		= (u32*)XPAR_MLP_IP_0_BASEADDR;
u32 *datamover_mm2s = (u32*)XPAR_DATAMOVERH_IP_1_S00_AXI_BASEADDR;
u32 *datamover_s2mm = (u32*)XPAR_DATAMOVERH_IP_0_S00_AXI_BASEADDR;

u32 *curr_lay_ptr;
u32 *prev_lay_ptr;
u32 *biases_ptr;
u32 *inputs_ptr;
u32 *weights_ptr;
u32 *hidden1_ptr;
u32 *hidden2_ptr;
u32 *outputs_ptr;

int inputs_cnt,weights_cnt,biases_cnt;

void mlp_init()
{
	DPRINT("Mlp initialization...\n");
	curr_lay_ptr= current_layer;
	prev_lay_ptr= previous_layer;
	biases_ptr  = biases;
	inputs_ptr  = NULL;
	weights_ptr = weights;
	hidden1_ptr = firstHiddenLayerStorage;
	hidden2_ptr = secondHiddenLayerStorage;
	outputs_ptr = outputsStorage;
	inputs_cnt 	= 1;
	weights_cnt	= 1;
	biases_cnt 	= 1;
}

void mlp_set_inputs_ptr (u32 *ptr){inputs_ptr  = ptr;}

void send_mlp_command(u32 NN_DATA_RDY, u32 NN_EN)
{
	u32 command 	= ( (NN_DATA_RDY<<1) | NN_EN );
	*(mlp_axil+3) 	= command;
	if(INTERUPT_EN) delay_ms(1);
}

void s2mm_rst()//NOT USED
{
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+2) = 1<<11;	//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+2) = 0;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
}

void send_from_ddr(u32 *ddr_ptr,u32 num_of_nodes_to_send)
{
	u32 SADDR 			= (u32)ddr_ptr;
	u32 BytesToTransfer = 4 * num_of_nodes_to_send;

	DPRINT("BTT = %d \n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*(datamover_mm2s) 	= 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+1) = SADDR;						//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+2) = 0;							//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+2) = (u32)DM_EN;					//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_mm2s+2) = 0;							//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*(datamover_mm2s+3) & 1) == 0 )				//slv_reg3
	{
		if(INTERUPT_EN) delay_ms(1);
		DPRINT("Waiting Datamover to send command... \n");
	}

	if(INTERUPT_EN) delay_ms(1);
}

void send_to_ddr(u32 *whereToStoreIt, u8 numOfNodesToStore)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = 4 * numOfNodesToStore;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*(datamover_s2mm+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_s2mm+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_s2mm+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_s2mm+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*(datamover_s2mm+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*(datamover_s2mm+3) & 1) == 0 )	//slv_reg3
	{
		if(INTERUPT_EN) delay_ms(1);
		DPRINT("Waiting Datamover to send command... \n");
	}

	if(INTERUPT_EN) delay_ms(1);
}

void wait_mlp()
{
	while((*(mlp_axil+4) & 0x00000001) != 0)
	{
		if(INTERUPT_EN) delay_ms(1);
		DPRINT("Waiting MLP to finish... \n");
	}

}

void calc_layer(u32 *fromWhereToTakeInputs,u32 *whereToStoreOutputs)
{
	DPRINT("~~~~~Calculation of Layer values~~~~~\n");
	//Sending inputs
	DPRINT("SENDING INPUTS...[%d] \n",inputs_cnt);
	send_from_ddr(fromWhereToTakeInputs,*(prev_lay_ptr));
	inputs_ptr += *(prev_lay_ptr);
	inputs_cnt++;

	DPRINT("Iterations in this layer : %d \n",( *(curr_lay_ptr) / NUMBER_OF_USED_NEURONS ));
	for(int j=0;j<( *(curr_lay_ptr) / NUMBER_OF_USED_NEURONS );j++)
	{
		//Sending biases
		DPRINT("SENDING BIASES...[%d] \n",biases_cnt);
		send_from_ddr(biases_ptr,NUMBER_OF_USED_NEURONS/2);
		biases_ptr += NUMBER_OF_USED_NEURONS/2;
		biases_cnt++;

		//Sending weights
		DPRINT("SENDING WEIGHTS...[%d] \n",weights_cnt);
		send_from_ddr(weights_ptr,(*(prev_lay_ptr) * NUMBER_OF_USED_NEURONS)/2);
		weights_ptr += (*(prev_lay_ptr) * NUMBER_OF_USED_NEURONS / 2);
		weights_cnt++;
	}

	if(INTERUPT_EN) delay_ms(1);
	wait_mlp();

	//store outputs inside DDR
	send_to_ddr(whereToStoreOutputs, *(curr_lay_ptr) );
}

int mlp_send_picture()
{
	//u32 hidden_nodes_temp = ( ((u32)NUMBER_OF_HIDDEN2)<<8 | (u32)NUMBER_OF_HIDDEN1 ); //OK (Ironic)
	u32 hidden_nodes_temp = (u32)659472;
	int recognized_number = 0;
	u32 recognized_number_val;

	if(!inputs_ptr)
	{
		xil_printf("ERROR: inputs pointer is pointing to NULL\n");
		return -1;
	}

	DPRINT("Sending picture... \n");
	*(mlp_axil+0) = (u32)NUMBER_OF_INPUTS;	//Set number of input nodes
	if(INTERUPT_EN) delay_ms(1);
	*(mlp_axil+1) = hidden_nodes_temp;		//Set number of hidden nodes
	if(INTERUPT_EN) delay_ms(1);
	*(mlp_axil+2) = (u32)NUMBER_OF_OUTPUTS;	//Set number of output nodes
	if(INTERUPT_EN) delay_ms(1);

	send_mlp_command(1,1);					//Enable MLP Network and Enable DATA RDY

	if(INTERUPT_EN) delay_ms(1);

	DPRINT("\nNUMBER OF NODES IN PREVIOUS LAYER = %d\n",*(prev_lay_ptr));
	DPRINT("NUMBER OF NODES IN CURRENT  LAYER = %d\n\n",*(curr_lay_ptr));
	calc_layer(inputs_ptr,hidden1_ptr);
	prev_lay_ptr++;
	curr_lay_ptr++;
	calc_layer(hidden1_ptr,hidden2_ptr);
	prev_lay_ptr++;
	curr_lay_ptr++;
	calc_layer(hidden2_ptr,outputs_ptr);
	prev_lay_ptr++;
	curr_lay_ptr++;

	recognized_number_val = 0;

	for(int n=0;n<NUMBER_OF_OUTPUTS;n++)
	{
			if(outputsStorage[n] > recognized_number_val)
			{
				recognized_number_val 	= outputsStorage[n];
				recognized_number 		= n;
			}
	}

	send_mlp_command(0,0);

	if(CHECK_MLP_OUTPUTS)
	{
		for(int k=0;k<16;k++)
			printf("HIDDEN 1[%d] = %08X \n",k,(unsigned int)firstHiddenLayerStorage[k]);

		for(int k=0;k<16;k++)
				printf("HIDDEN 2[%d] = %08X \n",k,(unsigned int)secondHiddenLayerStorage[k]);

		for(int k=0;k<10;k++)
				printf("OUTPUT[%d] = %08X \n",k,(unsigned int)outputsStorage[k]);
	}

	return recognized_number;
}

