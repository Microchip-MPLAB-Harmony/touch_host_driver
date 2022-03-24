/*******************************************************************************
  MPLAB Harmony Touch Host Interface Release

  Company:
	Microchip Technology Inc.

  File Name:
	at42qt1110.h

  Summary:
	This header file provides prototypes and definitions for the application.

  Description:
	This header file provides function prototypes and data type definitions for
	the application.  Some of these are required by the system (such as the
	"APP_Initialize" and "APP_Tasks" prototypes) and some of them are only used
	internally by the application (such as the "APP_STATES" definition).  Both
	are defined here for convenience.
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

#ifndef _AT42QT1110_H
#define _AT42QT1110_H

#include "touch_host_driver.h"

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

/* QT1110 Sepcifics */

#define NO_OF_KEYS 11u
#define ENABLE_CRC
#define TRUE ((uint8_t)0x01)
#define FALSE ((uint8_t)0x00)

#define CMD_SEND_SETUPS 0x01	  // Configures the device to receive setup data
#define CMD_CALIBRATE_ALL 0x03	  // Calibrates all keys
#define CMD_RESET 0x04			  // Resets the device
#define CMD_SLEEP 0x05			  // Sleep Mode
#define CMD_STORE_EEPROM 0x0A	  // Stores RAM Setups to EEPROM
#define CMD_RESTORE_EEPROM 0x0B	  // Copies EEPROM setups to RAM
#define CMD_ERASE_EEPROM 0x0C	  // Erase EEPROM setups
#define CMD_RECOVER_EEPROM 0x0D	  // Restores last EEPROM settings after erase
#define CMD_SEND_FIRST_KEY 0xC0	  // Returns the first detected key
#define CMD_SEND_ALL_KEYS 0xC1	  // Returns all keys
#define CMD_DEVICE_STATUS 0xC2	  // Returns the device status
#define CMD_EEPROM_CRC 0xC3		  // Returns the EEPROM CRC
#define CMD_RAM_CRC 0xC4		  // Returns RAM CRC
#define CMD_ERROR_KEYS 0xC5		  // Returns the error keys
#define CMD_DETECT_STATES 0xC6	  // Returns the detect output states
#define CMD_LAST_COMMAND 0xC7	  // Returns the last command send
#define CMD_READ_SETUPS 0xC8	  // Returns the Setup Data
#define CMD_DEVICE_ID 0xC9		  // Returns the device ID
#define CMD_FIRMWARE_VERSION 0xCA // Returns the Firmware version

#define CHIP_ID_ADDRESS 0
#define FW_VERSION_ADDRESS 1
#define DETECTION_STATUS_ADDRESS 2
#define KEY_STATUS_LSB_ADDRESS 3
#define KEY_STATUS_MSB_ADDRESS 4
#define SLIDER_POSITION_ADDRESS 5
#define CALIBRATE_ADDRESS 6
#define RESET_ADDRESS 7
#define LOW_POWER_MODE_ADDRESS 8
#define TTD_ADDRESS 9
#define ATD_ADDRESS 10
#define DI_ADDRESS 11
#define TRD_ADDRESS 12
#define DHT_ADDRESS 13
#define SLIDER_OPTIONS_ADDRESS 14
#define CHARGE_TIME_ADDRESS 15

#define KEY0_DETECT_THRESHOLD_ADDRESS 16
#define KEY1_DETECT_THRESHOLD_ADDRESS 17
#define KEY2_DETECT_THRESHOLD_ADDRESS 18
#define KEY3_DETECT_THRESHOLD_ADDRESS 19
#define KEY4_DETECT_THRESHOLD_ADDRESS 20
#define KEY5_DETECT_THRESHOLD_ADDRESS 21
#define KEY6_DETECT_THRESHOLD_ADDRESS 22
#define KEY7_DETECT_THRESHOLD_ADDRESS 23
#define KEY8_DETECT_THRESHOLD_ADDRESS 24
#define KEY9_DETECT_THRESHOLD_ADDRESS 25
#define KEY10_DETECT_THRESHOLD_ADDRESS 26
#define KEY11_DETECT_THRESHOLD_ADDRESS 27

#define KEY0_CONTROL_ADDRESS 28
#define KEY1_CONTROL_ADDRESS 29
#define KEY2_CONTROL_ADDRESS 30
#define KEY3_CONTROL_ADDRESS 31
#define KEY4_CONTROL_ADDRESS 32
#define KEY5_CONTROL_ADDRESS 33
#define KEY6_CONTROL_ADDRESS 34
#define KEY7_CONTROL_ADDRESS 35
#define KEY8_CONTROL_ADDRESS 36
#define KEY9_CONTROL_ADDRESS 37
#define KEY10_CONTROL_ADDRESS 38
#define KEY11_CONTROL_ADDRESS 39

#define KEY0_PULSE_SCALE_ADDRESS 40
#define KEY1_PULSE_SCALE_ADDRESS 41
#define KEY2_PULSE_SCALE_ADDRESS 42
#define KEY3_PULSE_SCALE_ADDRESS 43
#define KEY4_PULSE_SCALE_ADDRESS 44
#define KEY5_PULSE_SCALE_ADDRESS 45
#define KEY6_PULSE_SCALE_ADDRESS 46
#define KEY7_PULSE_SCALE_ADDRESS 47
#define KEY8_PULSE_SCALE_ADDRESS 48
#define KEY9_PULSE_SCALE_ADDRESS 49
#define KEY10_PULSE_SCALE_ADDRESS 50
#define KEY11_PULSE_SCALE_ADDRESS 51

#define KEY0_SIGNAL_ADDRESS 52
#define KEY1_SIGNAL_ADDRESS 54
#define KEY2_SIGNAL_ADDRESS 56
#define KEY3_SIGNAL_ADDRESS 58
#define KEY4_SIGNAL_ADDRESS 60
#define KEY5_SIGNAL_ADDRESS 62
#define KEY6_SIGNAL_ADDRESS 64
#define KEY7_SIGNAL_ADDRESS 66
#define KEY8_SIGNAL_ADDRESS 68
#define KEY9_SIGNAL_ADDRESS 70
#define KEY10_SIGNAL_ADDRESS 72
#define KEY11_SIGNAL_ADDRESS 74

#define REF_DATA0_ADDRESS 76
#define REF_DATA1_ADDRESS 78
#define REF_DATA2_ADDRESS 80
#define REF_DATA3_ADDRESS 82
#define REF_DATA4_ADDRESS 84
#define REF_DATA5_ADDRESS 86
#define REF_DATA6_ADDRESS 88
#define REF_DATA7_ADDRESS 90
#define REF_DATA8_ADDRESS 92
#define REF_DATA9_ADDRESS 94
#define REF_DATA10_ADDRESS 96
#define REF_DATA11_ADDRESS 98
typedef struct
{
	// Address 0: Device Mode
	uint8_t REPEAT_TIME : 4;
	uint8_t SYNC : 1;
	uint8_t SIG : 1;
	uint8_t MODE : 1;
	uint8_t KEY_AC : 1;

	// Address 1: Guard Key/ Comms Options
	uint8_t CRC : 1;
	uint8_t CHG : 1;
	uint8_t SPI_EN : 1;
	uint8_t GD_EN : 1;
	uint8_t GUARD_KEY : 4;

	// Address 2: Detect Integrator Limit(DIL)/Drift Hold time
	uint8_t DHT : 4;
	uint8_t DIL : 4;

	// Address 3: PTHR/PHYST
	uint8_t PHYST : 2;
	uint8_t PTHR : 6;

	// Address 4: PDRIFT
	uint8_t PDRIFT : 8;

	// Address 5: Positive recalibration delay
	uint8_t PRD : 8;

	// Address 6: Lower Burst Limit
	uint8_t LBL : 8;

	// Address 7-8: AKS Mask
	uint8_t AKS_8 : 1;
	uint8_t AKS_9 : 1;
	uint8_t AKS_10 : 1;
	uint8_t AKS_unused : 5;
	uint8_t AKS_0 : 1;
	uint8_t AKS_1 : 1;
	uint8_t AKS_2 : 1;
	uint8_t AKS_3 : 1;
	uint8_t AKS_4 : 1;
	uint8_t AKS_5 : 1;
	uint8_t AKS_6 : 1;
	uint8_t AKS_7 : 1;

	// Address 9-15: Detect0 - Detect6 PWM
	uint8_t OUT_DETECT0 : 4;
	uint8_t IN_DETECT0 : 4;
	uint8_t OUT_DETECT1 : 4;
	uint8_t IN_DETECT1 : 4;
	uint8_t OUT_DETECT2 : 4;
	uint8_t IN_DETECT2 : 4;
	uint8_t OUT_DETECT3 : 4;
	uint8_t IN_DETECT3 : 4;
	uint8_t OUT_DETECT4 : 4;
	uint8_t IN_DETECT4 : 4;
	uint8_t OUT_DETECT5 : 4;
	uint8_t IN_DETECT5 : 4;
	uint8_t OUT_DETECT6 : 4;
	uint8_t IN_DETECT6 : 4;

	// Address 16: LED Detect Hold Time
	uint8_t LED_DETECT_HOLD_TIME : 8;

	// Address 17: LED Fade/ Key to LED
	uint8_t LED_0 : 1;
	uint8_t LED_1 : 1;
	uint8_t LED_2 : 1;
	uint8_t LED_3 : 1;
	uint8_t LED_4 : 1;
	uint8_t LED_5 : 1;
	uint8_t LED_6 : 1;
	uint8_t FADE : 1;

	// Address 18: LED Latch
	uint8_t LATCH_0 : 1;
	uint8_t LATCH_1 : 1;
	uint8_t LATCH_2 : 1;
	uint8_t LATCH_3 : 1;
	uint8_t LATCH_4 : 1;
	uint8_t LATCH_5 : 1;
	uint8_t LATCH_6 : 1;
	uint8_t LED_Latch_unused : 1;

	// Address 19-29: NTHR / NHYST
	uint8_t KEY_0_NHYST : 2;
	uint8_t KEY_0_NTHR : 6;
	uint8_t KEY_1_NHYST : 2;
	uint8_t KEY_1_NTHR : 6;
	uint8_t KEY_2_NHYST : 2;
	uint8_t KEY_2_NTHR : 6;
	uint8_t KEY_3_NHYST : 2;
	uint8_t KEY_3_NTHR : 6;
	uint8_t KEY_4_NHYST : 2;
	uint8_t KEY_4_NTHR : 6;
	uint8_t KEY_5_NHYST : 2;
	uint8_t KEY_5_NTHR : 6;
	uint8_t KEY_6_NHYST : 2;
	uint8_t KEY_6_NTHR : 6;
	uint8_t KEY_7_NHYST : 2;
	uint8_t KEY_7_NTHR : 6;
	uint8_t KEY_8_NHYST : 2;
	uint8_t KEY_8_NTHR : 6;
	uint8_t KEY_9_NHYST : 2;
	uint8_t KEY_9_NTHR : 6;
	uint8_t KEY_10_NHYST : 2;
	uint8_t KEY_10_NTHR : 6;

	// Address 30: Extend Pulse Time
	uint8_t LOW_TIME : 4;
	uint8_t HIGH_TIME : 4;

	// Address 31-41: NDRIFT / NRD
	uint8_t KEY_0_NRD : 4;
	uint8_t KEY_0_NDRIFT : 4;
	uint8_t KEY_1_NRD : 4;
	uint8_t KEY_1_NDRIFT : 4;
	uint8_t KEY_2_NRD : 4;
	uint8_t KEY_2_NDRIFT : 4;
	uint8_t KEY_3_NRD : 4;
	uint8_t KEY_3_NDRIFT : 4;
	uint8_t KEY_4_NRD : 4;
	uint8_t KEY_4_NDRIFT : 4;
	uint8_t KEY_5_NRD : 4;
	uint8_t KEY_5_NDRIFT : 4;
	uint8_t KEY_6_NRD : 4;
	uint8_t KEY_6_NDRIFT : 4;
	uint8_t KEY_7_NRD : 4;
	uint8_t KEY_7_NDRIFT : 4;
	uint8_t KEY_8_NRD : 4;
	uint8_t KEY_8_NDRIFT : 4;
	uint8_t KEY_9_NRD : 4;
	uint8_t KEY_9_NDRIFT : 4;
	uint8_t KEY_10_NRD : 4;
	uint8_t KEY_10_NDRIFT : 4;

} SetupBlock;
/*============================================================================
External variables
============================================================================*/
extern SetupBlock setup_block;
extern uint8_t QtStatus[2];
extern uint8_t signal[NO_OF_KEYS];
extern uint8_t reference[NO_OF_KEYS];
extern uint8_t CRC_en;

/*============================================================================
Prototypes
============================================================================*/
void GetCommsReady(void);
uint8_t ControlCommand(uint8_t Command);
uint8_t at42qt1110ReportRequest(uint8_t command, uint8_t length, uint8_t *readBuffer);
uint8_t SetInstruction(uint8_t Command, uint8_t SetData);
uint8_t GetInstruction(uint8_t Command, uint8_t *ReadPtr);
void InitQtInterface(void);
uint8_t ReadSetupBlock(uint8_t ReadLength, uint8_t *ReadPtr);
uint8_t WriteSetupBlock(uint8_t WriteLength, uint8_t *WritePtr);
uint8_t ReadKeyStatus(uint8_t ReadLength, uint8_t *ReadPtr);
uint8_t ReadKeySignal(uint8_t ReadLength, uint8_t *ReadPtr);
void ResetQT(void);

typedef union
{
	struct
	{
		uint8_t repeat_time : 4;
		uint8_t sync : 1;
		uint8_t sig : 1;
		uint8_t mode : 1;
		uint8_t key_ac : 1;
	} bits;
	uint8_t reg;
} deviceMode_t;

typedef union
{
	struct
	{
		uint8_t crc : 1;
		uint8_t chg : 1;
		uint8_t spi_en : 1;
		uint8_t gd_en : 1;
		uint8_t guard_key : 4;
	} bits;
	uint8_t reg;
} guardCommsOption_t;

typedef union
{
	struct
	{
		uint8_t dht : 4;
		uint8_t dil : 4;
	} bits;
	uint8_t reg;
} dilDht_t;

typedef union
{
	struct
	{
		uint8_t physt : 2;
		uint8_t pthr : 6;
	} bits;
	uint8_t reg;
} pThespHyst_t;

typedef union
{
	struct
	{
		uint8_t aks_8 : 1;
		uint8_t aks_9 : 1;
		uint8_t aks_10 : 1;
		uint8_t reserved : 5;
		uint8_t aks_0 : 1;
		uint8_t aks_1 : 1;
		uint8_t aks_2 : 1;
		uint8_t aks_3 : 1;
		uint8_t aks_4 : 1;
		uint8_t aks_5 : 1;
		uint8_t aks_6 : 1;
		uint8_t aks_7 : 1;
	} bits;
	uint16_t reg;
} aks_t;

typedef union
{
	struct
	{
		uint8_t out_detect : 4;
		uint8_t in_detect : 4;
	} bits;
	uint8_t reg;
} detect_t;

typedef union
{
	struct
	{
		// Address 17: LED Fade/ Key to LED
		uint8_t led_0 : 1;
		uint8_t led_1 : 1;
		uint8_t led_2 : 1;
		uint8_t led_3 : 1;
		uint8_t led_4 : 1;
		uint8_t led_5 : 1;
		uint8_t led_6 : 1;
		uint8_t fade : 1;
	} bits;
	uint8_t reg;
} ledKeyFade_t;

typedef union
{
	struct
	{
		uint8_t latch_0 : 1;
		uint8_t latch_1 : 1;
		uint8_t latch_2 : 1;
		uint8_t latch_3 : 1;
		uint8_t latch_4 : 1;
		uint8_t latch_5 : 1;
		uint8_t latch_6 : 1;
		uint8_t led_latch_unused : 1;
	} bits;
	uint8_t reg;
} ledLatch_t;

typedef union
{
	struct
	{
		uint8_t keynhyst : 2;
		uint8_t keynthr : 6;
	} bits;
	uint8_t reg;
} nThesNhyst_t;

typedef union
{
	struct
	{
		uint8_t low_time : 4;
		uint8_t high_time : 4;
	} bits;
	uint8_t reg;
} extendedPulseTime_t;

typedef union
{
	struct
	{
		uint8_t key_nrd : 4;
		uint8_t key_ndrift : 4;
	} bits;
	uint8_t reg;
} nDriftNRD_t;

typedef struct
{
	deviceMode_t deviceMode;
	guardCommsOption_t guardCommsOption;
	dilDht_t dilDth;
	pThespHyst_t pThespHyst;
	uint8_t positiveDriftComp;
	uint8_t positiveRecalibDelay;
	uint8_t lowerBustLength;
	aks_t aks;
	detect_t detect[7];
	ledKeyFade_t ledKeyFade;
	ledLatch_t ledLatch;
	nThesNhyst_t nThesNhyst[NO_OF_KEYS];
	extendedPulseTime_t extendedPulseTime;
	nDriftNRD_t nDriftNRD[NO_OF_KEYS];
} at42qt1110ConfigRegisters_t;

typedef struct tagat42qt1110DebugData_t
{
	uint16_t signal;
	uint16_t reference;
	int16_t delta;
	uint8_t status;
} at42qt1110DebugData_t;

typedef struct tagCommunicationStatus_t
{
	uint8_t error;
	uint8_t initError;
	uint8_t crcError;
	uint8_t errorCommand;
	uint8_t readStatus;
	uint8_t writeStatus;
} CommunicationStatus_t;

#define getChipIDAddress() 0
#define getConfigStartAddress() LOW_POWER_MODE_ADDRESS
#define getDebugDataStartAddress() KEY0_SIGNAL_ADDRESS
#define getDeviceExpectedChipID() 0x3E
// typedef qt2120StatusRegister statusDataT;

/* General */
typedef enum
{
	STATE_INVALID,
	READ_DEBUG_DATA_FROM_TOUCH,
	READ_STATUS_DATA_FROM_TOUCH,
	SEND_DATA_TO_PC
} touchI2CState_t;

void touchDeviceInit(void);
void touchDeviceProcess(void);
void touchDeviceRxCompleteCallback(uint8_t data);
void touchDeviceTxCompleteCallback(void);

extern volatile uint8_t timeToRead;

#define TIME_BETWEEN_BYTES_USEC 200
#define DEF_STARTUP_TIME 500
// Device ID for AT42QT1110
#define CHIP_ID 0x57
#define IDLE_STATUS_CODE 0x55
#define NULL_BYTE 0x00
#define CRC_OPTION 0x91

#endif /* _AT42QT1110_H */
/*******************************************************************************
 End of File
 */
