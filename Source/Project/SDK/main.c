/*
 * Take what you need
#include <stdio.h>
#include "xil_printf.h"
#include "camera_picture.h"
*/
#include <stdio.h>
#include <xgpio.h>
#include "platform.h"
#include "xil_types.h"
#include "interrupt.h"
#include "mlp_lib.h"
#include "compression.h"
#include "cmpr_picture.h"
#include "camCommands.h"
#include "uart.h"
#include "camera_picture.h"

XGpio inout;
u32 *SW_RST = (u32*)XPAR_SW_RESET_IP_0_S00_AXI_BASEADDR;
u32 *MATRIX = (u32*)XPAR_LED_MATRIX_IP_0_BASEADDR;

int main()
{
	printf("Program starts...\n");
	int number 	= 0;
	int status 	= 0;
	int button_data = 0;
	int button_data_prev = 0;

    init_platform();
    Xil_DCacheDisable();

    XGpio_Initialize(&inout, XPAR_AXI_GPIO_0_DEVICE_ID);	//initialize input XGpio variable

    XGpio_SetDataDirection(&inout,  1, 0xF);			//set first channel tristate buffer to input

    status = IntcInitFunction(INTC_DEVICE_ID,NULL,NULL);
    if(status == XST_FAILURE)
    {
    	xil_printf("interrupt initialization problem!\n");
    	return -1;
    }
    initUart(434,2);
    setTlast(12);
    while(1)
    {
    	button_data = XGpio_DiscreteRead(&inout, 1);
    	if(((button_data & 0x1) == 0x1) && ((button_data_prev & 0x1) == 0x0))
    	{
    		xil_printf("USAO\n");
    		*SW_RST = (u32)0;
    		delay_ms(200);
    		*SW_RST = (u32)1;
    		delay_ms(200);
    	    initUart(434,2);
    	    setTlast(12);
    	    delay_ms(2);
			while( send_to_ddr_Camera_setInitial(full_pic,12) == -1);
			xil_printf("SET INIT VELUES\n");
			while(send_to_ddr_Camera_sync(full_pic,12) == -1);
			xil_printf("CAMERA WAKED UP\n");
			while(send_to_ddr_Camera_init(full_pic,12) == -1);
			xil_printf("CAMERA INIT\n");
			send_to_ddr_Get_picture(full_pic, 38412);
			xil_printf("GOT IMAGE\n");

			*SW_RST = (u32)0;
			delay_ms(2);
			*SW_RST = (u32)1;

			img_cmpr(160,120,112,112,4);

			mlp_init();
			//mlp_set_inputs_ptr(&(cmpr_pic[0]));
			mlp_set_inputs_ptr(&(cmpr_pic[0]));
			number = mlp_send_picture();
			printf("Number = %d\n",(int)number);
			(*MATRIX) = (0x00000010 | (number & 0x0000000F));
    	}
    	button_data_prev = button_data;

    }

    cleanup_platform();
    return 0;
}
