/*
 * mlp_lib.h
 *
 *  Created on: Apr 9, 2018
 *      Author: Stefan
 */

#ifndef SRC_MLP_LIB_H_
#define SRC_MLP_LIB_H_

//initiate pointers to data
void mlp_init();
//set inputs pointer to some position
void mlp_set_inputs_ptr (u32 *ptr);
//sends data from ddr to mlp as stream data
void send_from_ddr(u32 *ddr_ptr,u32 num_of_nodes_to_send);
//sends data from mlp to ddr as stream data
void send_to_ddr(u32 *whereToStoreIt, u8 numOfNodesInCurrentLayer);
//sends command for mlp
void send_mlp_command(u32 NN_DATA_RDY, u32 NN_EN);
//waits until mlp finish calculations
void wait_mlp();
//sends one whole picture
int mlp_send_picture();
//calculate layer
void calc_layer(u32 *fromWhereToTakeInputs,u32 *whereToStoreOutputs);
//resets s2mm datamover if output ports of datamoverh are connected to datamover
void s2mm_rst();

#endif /* SRC_MLP_LIB_H_ */
