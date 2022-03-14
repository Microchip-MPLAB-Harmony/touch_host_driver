

#ifndef DATASTREAMER_H_
#define DATASTREAMER_H_

#include "touch_host_driver.h"


#define DEF_TOUCH_DATA_STREAMER_ENABLE 1u

#if DEF_TOUCH_DATA_STREAMER_ENABLE == 1U

#define DV_HEADER    0x55 
#define DV_FOOTER    0xAA 

#define UART_RX_BUF_LENGTH 60

#define HEADER_AWAITING 0
#define HEADER_RECEIVED 1
#define DATA_AWAITING 2
#define DATA_RECEIVED 3


#define SEND_DEBUG_DATA		 0x8000

#define ZERO 0x00  

typedef enum
{
	CONFIG_INFO =  0x00,
	SENSOR_INDIVIDUAL_CONFIG_ID ,
	SENSOR_COMMON_CONFIG_ID
}FRAME_ID_VALUES;

typedef enum
{
	PC_REQUEST_CONFIG_DATA_FROM_MCU		= 0x01,		// sw read PC_REQUEST_CONFIG_DATA_FROM_MCU
	PC_SEND_CONFIG_DATA_TO_MCU			= 0x02,		// sw write	PC_SEND_CONFIG_DATA_TO_MCU
	MCU_SEND_TUNE_DATA_TO_PC			= 0x03,		// send debug data MCU_SEND_TUNE_DATA_TO_PC
	MCU_RESPOND_CONFIG_DATA_TO_PC		= 0x04 		// sw read MCU_RESPOND_CONFIG_DATA_TO_PC
}TYPE_ID_VALUES;



typedef enum
{
	AT42QT1110			   = 0x61,
	AT42QT2120			   = 0x62,

}DEVICE_TYPE;

typedef enum
{
	KEYS_MODULE               = 0x01,
    ERROR                     = 0x02,
    KEY_DEBUG_DATA_ID		  = 0x80
}DEBUG_CONFIG_FRAME_ID;

typedef enum
{
	SELF_CAP = 0x00,
	MUTUAL_CAP = 0x01
}ACQ_METHOD;

typedef enum
{
	PROTOCOL_VERSION = 0x40		// 0x01000000b - lsb 5 bits - Minor version, msb first 3 bits - Major version
}ROW_5;


void touchTuneProcess(void);
void touchUartRxComplete(uintptr_t touchUart);
void touchUartTxComplete(uintptr_t touchUart);
void touchTuneNewDataAvailable(void);
extern volatile uint16_t command_flags;

void touchTuneInit(void);

#endif

#endif /* DATASTREAMER_H_ */