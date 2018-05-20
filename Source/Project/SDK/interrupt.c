#include "interrupt.h"
XScuGic INTCInst;
static XScuGic_Config *IntcConfig;
u32 counter[2] = {0,0};

void UART_Transmit__intr_Handler()
{
	//xil_printf("UART Transmit interrupt happend\n");
}

void UART_Receive_intr_Handler()
{
	//xil_printf("UART Receive interrupt happend\n");
}

void FIT0_Intr_Handler()
{
	//xil_printf("Timer interrupt happend\n");
	if(++counter[0] == ((2^32) - 1))
		counter[1]++;
}


int IntcInitFunction(u16 DeviceId, int *UARTInstancePtr, int *Fit0InstancePtr)
{
	int status;

	//Interrupt controller initialization
	IntcConfig = XScuGic_LookupConfig(DeviceId);
	if(IntcConfig == NULL) return XST_FAILURE;

	status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
	if(status != XST_SUCCESS) return XST_FAILURE;

	status = XScuGic_SelfTest(&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;

	//Call interrupt setup function
	status = InterruptSystemSetup(&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;


	status = XScuGic_Connect(&INTCInst,
							INTC_FIT0_INTERRUPT_ID,
							(Xil_ExceptionHandler)FIT0_Intr_Handler,
							(void*)&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;
	//TX Interrupt
	status = XScuGic_Connect(&INTCInst,
							INTC_UART_T_INTERRUPT_ID,
							(Xil_ExceptionHandler)UART_Transmit__intr_Handler,
							(void*)&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;
	//RX Interrupt
	status = XScuGic_Connect(&INTCInst,
							INTC_UART_R_INTERRUPT_ID,
							(Xil_ExceptionHandler)UART_Receive_intr_Handler,
							(void*)&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;

	XScuGic_SetPriTrigTypeByDistAddr(XPAR_PS7_SCUGIC_0_DIST_BASEADDR, INTC_FIT0_INTERRUPT_ID, 0x00, 0x3);
	XScuGic_SetPriTrigTypeByDistAddr(XPAR_PS7_SCUGIC_0_DIST_BASEADDR, INTC_UART_T_INTERRUPT_ID, 0x02, 0x3);
	XScuGic_SetPriTrigTypeByDistAddr(XPAR_PS7_SCUGIC_0_DIST_BASEADDR, INTC_UART_R_INTERRUPT_ID, 0x01, 0x3);

	XScuGic_Enable(&INTCInst, INTC_FIT0_INTERRUPT_ID);
	XScuGic_Enable(&INTCInst, INTC_UART_T_INTERRUPT_ID);
	XScuGic_Enable(&INTCInst, INTC_UART_R_INTERRUPT_ID);

	return XST_SUCCESS;
}

int InterruptSystemSetup(XScuGic *XScuGicInstancePtr)
{

	//Register GIC interrupt handler
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
								(Xil_ExceptionHandler)XScuGic_InterruptHandler,
								XScuGicInstancePtr);
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

u64 SystemTime()
{
	//Disable interrupts
	XScuGic_Disable(&INTCInst, INTC_FIT0_INTERRUPT_ID);
	XScuGic_Disable(&INTCInst, INTC_UART_T_INTERRUPT_ID);
	XScuGic_Disable(&INTCInst, INTC_UART_R_INTERRUPT_ID);
	//Calculate system time
	u64 system_time = ((2^32)*counter[1]) + counter[0];
	//Enable interrupts
	XScuGic_Enable(&INTCInst, INTC_FIT0_INTERRUPT_ID);
	XScuGic_Enable(&INTCInst, INTC_UART_T_INTERRUPT_ID);
	XScuGic_Enable(&INTCInst, INTC_UART_R_INTERRUPT_ID);
	return system_time;
}

void delay_ms(u64 delay)
{
	u64 temp_counter = SystemTime();
	while((SystemTime()-temp_counter) < delay);
}
