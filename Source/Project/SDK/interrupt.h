#ifndef SRC_INTERRUPT_C_
#define SRC_INTERRUPT_C_

#include "xscugic.h"
#include "uart.h"

#define INTC_DEVICE_ID XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INTC_FIT0_INTERRUPT_ID XPAR_FABRIC_FIT_TIMER_0_INTERRUPT_INTR
#define INTC_UART_T_INTERRUPT_ID 62U
#define INTC_UART_R_INTERRUPT_ID 63U

void UART_Receive_intr_Handler();
void UART_Transmit__intr_Handler();
void FIT0_Intr_Handler();
int InterruptSystemSetup(XScuGic *XScuGicInstancePtr);
int IntcInitFunction(u16 DeviceId, int *UARTInstancePtr, int *Fit0InstancePtr);
u64 SystemTime();
void delay_ms(u64 delay);
char dataAvaliableSemaphore(char command);

#endif /* SRC_INTERRUPT_C_ */
