#ifndef SRC_UART_H_
#define SRC_UART_H_

#if(0)						//Setting this if to '1' set system to Debug mode
	#define DPRINT(args...) xil_printf(args)
#else
	#define DPRINT(args...)
#endif

#include "xparameters.h"
#include "xil_cache.h"
#include "interrupt.h"

#define INTERUPT_EN 1		//Setting this value to '1' enables delays
#define DM_EN  1024			//For enabling data mover we need to put 11th bit to 1, 0 value is for disabling
#define UART XPAR_UART_AXI_V1_0_0_BASEADDR + 0x00000000
#define UART_CONF XPAR_UART_AXI_V1_0_0_BASEADDR + 0x00000001
#define FIFO XPAR_UART_AXI_V1_0_0_BASEADDR + 0x00000002
#define STATUS XPAR_UART_AXI_V1_0_0_BASEADDR + 0x00000003
#define DATAMOVER_S2MM XPAR_DATAMOVERH_IP_2_S00_AXI_BASEADDR

void setUartBaudRate(u16 baudRate);
void setTlast(u32 tlast);
void setStartTran(u16 numOfExpectiongReceiveData);
void setStopBits(char numOfStopBits);
void fifoWriteData(u8 data);
char send_to_ddr_Camera_sync(u32 *whereToStoreIt, u8 bytesToSend);
char send_to_ddr_Camera_init(u32 *whereToStoreIt, u8 bytesToSend);
char send_to_ddr_Camera_ack(u32 *whereToStoreIt, u8 bytesToSend);
char send_to_ddr_Camera_reset(u32 *whereToStoreIt, u8 bytesToSend);
char send_to_ddr_Camera_setInitial(u32 *whereToStoreIt, u8 bytesToSend);
void initUart(u16 baudRate,char numOfStopBits);
char send_to_ddr_Get_picture(u32 *whereToStoreIt, u32 bytesToSend);

#endif /* SRC_UART_H_ */
