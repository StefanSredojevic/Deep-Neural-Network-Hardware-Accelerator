#include "uart.h"
#include "camCommands.h"
#include "camera_picture.h"

void setUartBaudRate(u16 baudRate)
{
	*((int*)UART_CONF) |= 0x00007FFF & baudRate;
}

void setTlast(u32 tlast)
{
	*((int*)UART) |= (0x0007FFFF & tlast);
}

void setStartTran(u16 numOfExpectiongReceiveData)
{
	*((int*)UART_CONF) |= 0x00008000;
	delay_ms(1);
	setTlast(numOfExpectiongReceiveData);
	*((int*)UART_CONF) &= 0xFFFF7FFF;
}

void setStopBits(char numOfStopBits)
{
	if(numOfStopBits == 1)
		*((int*)UART) &= 0xFFF7FFFF;
	else if(numOfStopBits == 2)
		*((int*)UART) |= 0x00080000;
}

void fifoWriteData(u8 data)
{
	*((int*)FIFO) = 0x00000000 | data;
	delay_ms(5);
	*((int*)FIFO) |= 0x00000100;
	delay_ms(5);
	*((int*)FIFO) &= 0xFFFFFEFF;
	delay_ms(5);
}

void initUart(u16 baudRate,char numOfStopBits)
{
	*((int*)UART) = 0x00000000;
	delay_ms(1);
	*((int*)UART_CONF) = 0x00000000;
	delay_ms(1);
	*((int*)FIFO) = 0x00000000;
	delay_ms(1);
	setUartBaudRate(baudRate);
	delay_ms(1);
	setStopBits(1);
	delay_ms(1);
}

char send_to_ddr_Camera_sync(u32 *whereToStoreIt, u8 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
    	CameraSync();
        setStartTran(12);
		if(INTERUPT_EN) delay_ms(10);
		DPRINT("Waiting Datamover to send command... \n");
	}
	CameraSetBaudRate();
	setUartBaudRate(40);
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
		return 0;
	else
		return -1;

	if(INTERUPT_EN) delay_ms(1);
}

char send_to_ddr_Camera_reset(u32 *whereToStoreIt, u8 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(2);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
		CameraReset();
        setStartTran(12);
		if(INTERUPT_EN) delay_ms(100);
		DPRINT("Waiting Datamover to send command... \n");
	}
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
		return 0;
	else
		return -1;

	if(INTERUPT_EN) delay_ms(2);
}

char send_to_ddr_Camera_ack(u32 *whereToStoreIt, u8 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(2);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(2);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
		CameraAck();
        setStartTran(12);
		if(INTERUPT_EN) delay_ms(100);
		DPRINT("Waiting Datamover to send command... \n");
	}
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
		return 0;
	else
		return -1;

	if(INTERUPT_EN) delay_ms(2);
}

char send_to_ddr_Camera_init(u32 *whereToStoreIt, u8 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
		CameraInit();
        setStartTran(12);
		if(INTERUPT_EN) delay_ms(10);
		DPRINT("Waiting Datamover to send command... \n");
	}
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
		return 0;
	else
		return -1;

	if(INTERUPT_EN) delay_ms(1);
}

char send_to_ddr_Get_picture(u32 *whereToStoreIt, u32 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);
	u8 red;
	u8 blue;
	u8 green;
	int z =0;


	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
		CameraGetPicture();
        setStartTran(38412);
		if(INTERUPT_EN) delay_ms(100);
		DPRINT("Waiting Datamover to send command... \n");
	}
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
	{
		for(int i=3;i<9603;i++)
		{
			red = (full_pic[i] >> 27) * 8;
			green = ((full_pic[i] >> 21) & 0x0000002F) * 4;
			blue = ((full_pic[i] >> 16) & 0x0000001F) * 8;
			cam_pic[z]   = 0x00000000 | (blue << 16) | (green << 8) | red;
			DPRINT("R1 = %08X\n",(unsigned int)((full_pic[i] >> 27) * 8));
			DPRINT("G1 = %08X\n",(unsigned int)(((full_pic[i] >> 21) & 0x0000002F) * 4));
			DPRINT("B1 = %08X\n",(unsigned int)(((full_pic[i] >> 16) & 0x0000001F) * 8));
			DPRINT("CP1= %08X\n",cam_pic[z]);
			red = ((full_pic[i] >> 11) & 0x0000001F) * 8;
			green = ((full_pic[i] >> 5) & 0x0000002F) * 4;
			blue = ((full_pic[i]) & 0x0000001F) * 8;
			cam_pic[z+1] = 0x00000000 | (blue << 16) | (green << 8) | red;
			DPRINT("R2 = %08X\n",(unsigned int)(((full_pic[i] >> 11) & 0x0000001F) * 8));
			DPRINT("G2 = %08X\n",(unsigned int)(((full_pic[i] >> 5) & 0x0000002F) * 4));
			DPRINT("B2 = %08X\n",(unsigned int)(((full_pic[i]) & 0x0000001F) * 8));
			DPRINT("CP2= %08X\n",cam_pic[z+1]);

			z+=2;
		}

		/*for(int z=0;z<19200;z++)
		{
			xil_printf("%d\n",(unsigned int)(cam_pic[z] & 0x000000FF));
			xil_printf("%d\n",(unsigned int)((cam_pic[z] & 0x0000FF00) >> 8));
			xil_printf("%d\n",(unsigned int)((cam_pic[z] & 0x00FF0000) >> 16));
		}*/

		return 0;
	}
	else
		return -1;

	if(INTERUPT_EN) delay_ms(1);
}

char send_to_ddr_Camera_setInitial(u32 *whereToStoreIt, u8 bytesToSend)
{
	u32 SADDR 			= (u32)whereToStoreIt;
	u32 BytesToTransfer = (u32)bytesToSend;

	DPRINT("BTT = %d \n\n",BytesToTransfer);
	DPRINT("SADDR = %d \n\n",SADDR);

	*((u32*)DATAMOVER_S2MM+0) = 1<<30 | 1<<23 | BytesToTransfer;//slv_reg0
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+1) = SADDR;			//slv_reg1
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = (u32)DM_EN;		//slv_reg2
	if(INTERUPT_EN) delay_ms(1);
	*((u32*)DATAMOVER_S2MM+2) = 0;				//slv_reg2
	if(INTERUPT_EN) delay_ms(1);

	//Checking are data from datamoverh sent
	while( (*((u32*)DATAMOVER_S2MM+3) & 1) == 0 )	//slv_reg3
	{
		CameraSetInit();
        setStartTran(12);
		if(INTERUPT_EN) delay_ms(10);
		DPRINT("Waiting Datamover to send command... \n");
	}
	if((full_pic[0] & 0xFFFF0000) == 0xAA0E0000)
		return 0;
	else
		return -1;

	if(INTERUPT_EN) delay_ms(1);
}
