#include "uart.h"

void CameraInit()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x01);
	//Parameter 1 (dummy parameter always 00)
	fifoWriteData(0x00);
	//Parameter 2 "Image Format" --> 16-bit Colour (RAW, 565(RGB))
	fifoWriteData(0x06);
	//Parameter 3 "Raw Resolution" --> 160 x 120
	fifoWriteData(0x03);
	//Parameter 4 "JPEG Resolution" in our case dummy parameter
	fifoWriteData(0x00);
}

void CameraGetPicture()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x04);
	//Parameter 1 "Pitcure Type" -- > RAW Picture Mode
	fifoWriteData(0x02);
	//Parameter 2 dummy parameter
	fifoWriteData(0x00);
	//Parameter 3 dummy parameter
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraSnapshot()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x05);
	//Parameter 1 "Snapshot type" --> Uncompressed Picture (RAW)
	fifoWriteData(0x01);
	//Parameter 2 "Skip Frame(Low Byte)" -->
	fifoWriteData(0x00);
	//Parameter 3 "Skip Frame(High Byte)" -->
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraSetPackage()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x06);
	//Parameter 1 fixed value
	fifoWriteData(0x08);
	//Parameter 2 "Package Size(Low Byte)" -->
	fifoWriteData(0x00);
	//Parameter 3 "Package Size(High Byte)" -->
	fifoWriteData(0x02);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraSetBaudRate()
{
	//Set to 1228800 bits/s
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x07);
	//Parameter 1 "First Divider"
	fifoWriteData(0x02);
	//Parameter 2 "Second Divider"
	fifoWriteData(0x00);
	//Parameter 3 dummy parameter
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraReset()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x08);
	//Parameter 1 "HARD RESET"
	fifoWriteData(0x00);
	//Parameter 2 dummy parameter
	fifoWriteData(0x00);
	//Parameter 3 dummy parameter
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}


void CameraSync()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x0D);
	//Parameter 1 dummy parameter
	fifoWriteData(0x00);
	//Parameter 2 dummy parameter
	fifoWriteData(0x00);
	//Parameter 3 dummy parameter
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraAck()
{
	//Set to 1228800 bits/s
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x0E);
	//Parameter 1 "First Divider"
	fifoWriteData(0x0A);
	//Parameter 2 "Second Divider"
	fifoWriteData(0x00);
	//Parameter 3 dummy parameter
	fifoWriteData(0x00);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}

void CameraSetInit()
{
	 //Send ID Number
	fifoWriteData(0xAA);
	fifoWriteData(0x14);
	//Parameter 1 Contrast
	fifoWriteData(0x04);
	//Parameter 2 Brightness
	fifoWriteData(0x04);
	//Parameter 3 Exposure
	fifoWriteData(0x04);
	//Parameter 4 dummy parameter
	fifoWriteData(0x00);
}
