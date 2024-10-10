/*******************************************************************************
  MPLAB Harmony Touch Host Interface Release
  
  Company:
    Microchip Technology Inc.
  
  File Name:
    touchTune.h

  Summary:
    This file contains the source code for the MPLAB Harmony application.

  Description:
    This file contains the source code for the MPLAB Harmony application.  It 
    implements the logic of the application's state machine and it may call 
    API routines of other MPLAB Harmony modules in the system, such as drivers,
    system services, and middleware.  However, it does not call any of the
    system interfaces (such as the "Initialize" and "Tasks" functions) of any of
    the modules in the system or make any assumptions about when those functions
    are called.  That is the responsibility of the configuration-specific system
    files.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2022 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *******************************************************************************/
// DOM-IGNORE-END

#ifndef DATASTREAMER_H_
#define DATASTREAMER_H_

#include "touch_host_driver.h"


#define DEF_TOUCH_DATA_STREAMER_ENABLE 1u

#if DEF_TOUCH_DATA_STREAMER_ENABLE == 1U

#define DV_HEADER    0x55u
#define DV_FOOTER    0xAAu

#define UART_RX_BUF_LENGTH 60u

#define HEADER_AWAITING 0u
#define HEADER_RECEIVED 1u
#define DATA_AWAITING 2u
#define DATA_RECEIVED 3u


#define SEND_DEBUG_DATA		 0x8000u

#define ZERO 0x00u

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
	PROTOCOL_VERSION = 0x02		// 0x00000010b - lsb 5 bits - Minor version, msb first 3 bits - Major version
}ROW_5;


void touchTuneProcess(void);
void touchUartTxComplete(uintptr_t lTouchUart);
void touchUartRxComplete(uintptr_t lTouchUart);
void touchTuneNewDataAvailable(void);

void touchTuneInit(void);

#endif

#endif /* DATASTREAMER_H_ */