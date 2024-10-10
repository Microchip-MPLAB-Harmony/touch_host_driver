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

#ifndef AT42QT1110_H
#define AT42QT1110_H

#include "touch_host_driver.h"

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

/* QT1110 Sepcifics */

#define NO_OF_KEYS 11u
#define ENABLE_CRC
#define TRUE ((uint8_t)0x01u)
#define FALSE ((uint8_t)0x00u)

#define CMD_SEND_SETUPS 0x01u	  // Configures the device to receive setup data
#define CMD_CALIBRATE_ALL 0x03u	  // Calibrates all keys
#define CMD_RESET 0x04u			  // Resets the device
#define CMD_SLEEP 0x05u			  // Sleep Mode
#define CMD_STORE_EEPROM 0x0Au	  // Stores RAM Setups to EEPROM
#define CMD_RESTORE_EEPROM 0x0Bu	  // Copies EEPROM setups to RAM
#define CMD_ERASE_EEPROM 0x0Cu	  // Erase EEPROM setups
#define CMD_RECOVER_EEPROM 0x0Du	  // Restores last EEPROM settings after erase
#define CMD_SEND_FIRST_KEY 0xC0u	  // Returns the first detected key
#define CMD_SEND_ALL_KEYS 0xC1u	  // Returns all keys
#define CMD_DEVICE_STATUS 0xC2u	  // Returns the device status
#define CMD_EEPROM_CRC 0xC3u		  // Returns the EEPROM CRC
#define CMD_RAM_CRC 0xC4u		  // Returns RAM CRC
#define CMD_ERROR_KEYS 0xC5u		  // Returns the error keys
#define CMD_DETECT_STATES 0xC6u	  // Returns the detect output states
#define CMD_LAST_COMMAND 0xC7u	  // Returns the last command send
#define CMD_READ_SETUPS 0xC8u	  // Returns the Setup Data
#define CMD_DEVICE_ID 0xC9u		  // Returns the device ID
#define CMD_FIRMWARE_VERSION 0xCAu // Returns the Firmware version

#define CHIP_ID_ADDRESS 0u
#define FW_VERSION_ADDRESS 1u
#define DETECTION_STATUS_ADDRESS 2u
#define KEY_STATUS_LSB_ADDRESS 3u
#define KEY_STATUS_MSB_ADDRESS 4u
#define SLIDER_POSITION_ADDRESS 5u
#define CALIBRATE_ADDRESS 6u
#define RESET_ADDRESS 7u
#define LOW_POWER_MODE_ADDRESS 8u
#define TTD_ADDRESS 9u
#define ATD_ADDRESS 10u
#define DI_ADDRESS 11u
#define TRD_ADDRESS 12u
#define DHT_ADDRESS 13u
#define SLIDER_OPTIONS_ADDRESS 14u
#define CHARGE_TIME_ADDRESS 15u

#define KEY0_DETECT_THRESHOLD_ADDRESS 16u
#define KEY1_DETECT_THRESHOLD_ADDRESS 17u
#define KEY2_DETECT_THRESHOLD_ADDRESS 18u
#define KEY3_DETECT_THRESHOLD_ADDRESS 19u
#define KEY4_DETECT_THRESHOLD_ADDRESS 20u
#define KEY5_DETECT_THRESHOLD_ADDRESS 21u
#define KEY6_DETECT_THRESHOLD_ADDRESS 22u
#define KEY7_DETECT_THRESHOLD_ADDRESS 23u
#define KEY8_DETECT_THRESHOLD_ADDRESS 24u
#define KEY9_DETECT_THRESHOLD_ADDRESS 25u
#define KEY10_DETECT_THRESHOLD_ADDRESS 26u
#define KEY11_DETECT_THRESHOLD_ADDRESS 27u

#define KEY0_CONTROL_ADDRESS 28u
#define KEY1_CONTROL_ADDRESS 29u
#define KEY2_CONTROL_ADDRESS 30u
#define KEY3_CONTROL_ADDRESS 31u
#define KEY4_CONTROL_ADDRESS 32u
#define KEY5_CONTROL_ADDRESS 33u
#define KEY6_CONTROL_ADDRESS 34u
#define KEY7_CONTROL_ADDRESS 35u
#define KEY8_CONTROL_ADDRESS 36u
#define KEY9_CONTROL_ADDRESS 37u
#define KEY10_CONTROL_ADDRESS 38u
#define KEY11_CONTROL_ADDRESS 39u

#define KEY0_PULSE_SCALE_ADDRESS 40u
#define KEY1_PULSE_SCALE_ADDRESS 41u
#define KEY2_PULSE_SCALE_ADDRESS 42u
#define KEY3_PULSE_SCALE_ADDRESS 43u
#define KEY4_PULSE_SCALE_ADDRESS 44u
#define KEY5_PULSE_SCALE_ADDRESS 45u
#define KEY6_PULSE_SCALE_ADDRESS 46u
#define KEY7_PULSE_SCALE_ADDRESS 47u
#define KEY8_PULSE_SCALE_ADDRESS 48u
#define KEY9_PULSE_SCALE_ADDRESS 49u
#define KEY10_PULSE_SCALE_ADDRESS 50u
#define KEY11_PULSE_SCALE_ADDRESS 51u

#define KEY0_SIGNAL_ADDRESS 52u
#define KEY1_SIGNAL_ADDRESS 54u
#define KEY2_SIGNAL_ADDRESS 56u
#define KEY3_SIGNAL_ADDRESS 58u
#define KEY4_SIGNAL_ADDRESS 60u
#define KEY5_SIGNAL_ADDRESS 62u
#define KEY6_SIGNAL_ADDRESS 64u
#define KEY7_SIGNAL_ADDRESS 66u
#define KEY8_SIGNAL_ADDRESS 68u
#define KEY9_SIGNAL_ADDRESS 70u
#define KEY10_SIGNAL_ADDRESS 72u
#define KEY11_SIGNAL_ADDRESS 74u

#define REF_DATA0_ADDRESS 76u
#define REF_DATA1_ADDRESS 78u
#define REF_DATA2_ADDRESS 80u
#define REF_DATA3_ADDRESS 82u
#define REF_DATA4_ADDRESS 84u
#define REF_DATA5_ADDRESS 86u
#define REF_DATA6_ADDRESS 88u
#define REF_DATA7_ADDRESS 90u
#define REF_DATA8_ADDRESS 92u
#define REF_DATA9_ADDRESS 94u
#define REF_DATA10_ADDRESS 96u
#define REF_DATA11_ADDRESS 98u
typedef struct
{
	// Address 0: Device Mode
	unsigned int REPEAT_TIME : 4;
	unsigned int SYNC : 1;
	unsigned int SIG : 1;
	unsigned int MODE : 1;
	unsigned int KEY_AC : 1;

	// Address 1: Guard Key/ Comms Options
	unsigned int CRC : 1;
	unsigned int CHG : 1;
	unsigned int SPI_EN : 1;
	unsigned int GD_EN : 1;
	unsigned int GUARD_KEY : 4;

	// Address 2: Detect Integrator Limit(DIL)/Drift Hold time
	unsigned int DHT : 4;
	unsigned int DIL : 4;

	// Address 3: PTHR/PHYST
	unsigned int PHYST : 2;
	unsigned int PTHR : 6;

	// Address 4: PDRIFT
	unsigned int PDRIFT : 8;

	// Address 5: Positive recalibration delay
	unsigned int PRD : 8;

	// Address 6: Lower Burst Limit
	unsigned int LBL : 8;

	// Address 7-8: AKS Mask
	unsigned int AKS_8 : 1;
	unsigned int AKS_9 : 1;
	unsigned int AKS_10 : 1;
	unsigned int AKS_unused : 5;
	unsigned int AKS_0 : 1;
	unsigned int AKS_1 : 1;
	unsigned int AKS_2 : 1;
	unsigned int AKS_3 : 1;
	unsigned int AKS_4 : 1;
	unsigned int AKS_5 : 1;
	unsigned int AKS_6 : 1;
	unsigned int AKS_7 : 1;

	// Address 9-15: Detect0 - Detect6 PWM
	unsigned int OUT_DETECT0 : 4;
	unsigned int IN_DETECT0 : 4;
	unsigned int OUT_DETECT1 : 4;
	unsigned int IN_DETECT1 : 4;
	unsigned int OUT_DETECT2 : 4;
	unsigned int IN_DETECT2 : 4;
	unsigned int OUT_DETECT3 : 4;
	unsigned int IN_DETECT3 : 4;
	unsigned int OUT_DETECT4 : 4;
	unsigned int IN_DETECT4 : 4;
	unsigned int OUT_DETECT5 : 4;
	unsigned int IN_DETECT5 : 4;
	unsigned int OUT_DETECT6 : 4;
	unsigned int IN_DETECT6 : 4;

	// Address 16: LED Detect Hold Time
	unsigned int LED_DETECT_HOLD_TIME : 8;

	// Address 17: LED Fade/ Key to LED
	unsigned int LED_0 : 1;
	unsigned int LED_1 : 1;
	unsigned int LED_2 : 1;
	unsigned int LED_3 : 1;
	unsigned int LED_4 : 1;
	unsigned int LED_5 : 1;
	unsigned int LED_6 : 1;
	unsigned int FADE : 1;

	// Address 18: LED Latch
	unsigned int LATCH_0 : 1;
	unsigned int LATCH_1 : 1;
	unsigned int LATCH_2 : 1;
	unsigned int LATCH_3 : 1;
	unsigned int LATCH_4 : 1;
	unsigned int LATCH_5 : 1;
	unsigned int LATCH_6 : 1;
	unsigned int LED_Latch_unused : 1;

	// Address 19-29: NTHR / NHYST
	unsigned int KEY_0_NHYST : 2;
	unsigned int KEY_0_NTHR : 6;
	unsigned int KEY_1_NHYST : 2;
	unsigned int KEY_1_NTHR : 6;
	unsigned int KEY_2_NHYST : 2;
	unsigned int KEY_2_NTHR : 6;
	unsigned int KEY_3_NHYST : 2;
	unsigned int KEY_3_NTHR : 6;
	unsigned int KEY_4_NHYST : 2;
	unsigned int KEY_4_NTHR : 6;
	unsigned int KEY_5_NHYST : 2;
	unsigned int KEY_5_NTHR : 6;
	unsigned int KEY_6_NHYST : 2;
	unsigned int KEY_6_NTHR : 6;
	unsigned int KEY_7_NHYST : 2;
	unsigned int KEY_7_NTHR : 6;
	unsigned int KEY_8_NHYST : 2;
	unsigned int KEY_8_NTHR : 6;
	unsigned int KEY_9_NHYST : 2;
	unsigned int KEY_9_NTHR : 6;
	unsigned int KEY_10_NHYST : 2;
	unsigned int KEY_10_NTHR : 6;

	// Address 30: Extend Pulse Time
	unsigned int LOW_TIME : 4;
	unsigned int HIGH_TIME : 4;

	// Address 31-41: NDRIFT / NRD
	unsigned int KEY_0_NRD : 4;
	unsigned int KEY_0_NDRIFT : 4;
	unsigned int KEY_1_NRD : 4;
	unsigned int KEY_1_NDRIFT : 4;
	unsigned int KEY_2_NRD : 4;
	unsigned int KEY_2_NDRIFT : 4;
	unsigned int KEY_3_NRD : 4;
	unsigned int KEY_3_NDRIFT : 4;
	unsigned int KEY_4_NRD : 4;
	unsigned int KEY_4_NDRIFT : 4;
	unsigned int KEY_5_NRD : 4;
	unsigned int KEY_5_NDRIFT : 4;
	unsigned int KEY_6_NRD : 4;
	unsigned int KEY_6_NDRIFT : 4;
	unsigned int KEY_7_NRD : 4;
	unsigned int KEY_7_NDRIFT : 4;
	unsigned int KEY_8_NRD : 4;
	unsigned int KEY_8_NDRIFT : 4;
	unsigned int KEY_9_NRD : 4;
	unsigned int KEY_9_NDRIFT : 4;
	unsigned int KEY_10_NRD : 4;
	unsigned int KEY_10_NDRIFT : 4;

} SetupBlock;
/*============================================================================
External variables
============================================================================*/
extern SetupBlock setup_block;

/*============================================================================
Prototypes
============================================================================*/
uint8_t at42qt1110ComputeCRC(uint8_t crc, uint8_t data);
void resetCommunicationStatus(void);
uint8_t at42qt1110SendFirstKey(void);
uint16_t at42qt1110GetAllKeyStatus(void);
uint8_t at42qt1110GetDeviceStatus(void);
uint8_t at42qt1110SendEepromCrc(void);
uint8_t at42qt1110SendRamCrc(void);
void at42qt1110SendErrorKeys(uint8_t *buffer);
uint16_t at42qt1110GetSignal(uint8_t keyNum);
uint16_t at42qt1110GetReference(uint8_t keyNum);
uint8_t at42qt1110GetKeyStatus(uint8_t keyNum);
uint8_t at42qt1110GetDetectOutStates(void);
uint8_t at42qt1110GetLastCommand(void);
void at42qt1110ReadSetupBlock(uint8_t *readBuffer, uint8_t length);
uint8_t at42qt1110GetDeviceId(void);
uint8_t at42qt1110GetFwVersion(void);
void at42qt1110SentControlCommand(uint8_t command);
void at42qt1110CalibrateAll(void);
void at42qt1110Reset(void);
void at42qt1110Sleep(void);
void at42qt1110StoreEeprom(void);
void at42qt1110RestoreEeprom(void);
void at42qt1110EraseEeprom(void);
void at42qt1110RecoverEeprom(void);
void touchDeviceGetDebugData(void);

uint8_t at42qt1110ReportRequest(uint8_t command, uint8_t length, uint8_t *readBuffer);
uint8_t ReadSetupBlock(uint8_t ReadLength, uint8_t *ReadPtr);
uint8_t WriteSetupBlock(uint8_t WriteLength, uint8_t *WritePtr);
uint8_t ReadKeyStatus(uint8_t ReadLength, uint8_t *ReadPtr);
uint8_t ReadKeySignal(uint8_t ReadLength, uint8_t *ReadPtr);

typedef union
{
	struct
	{
		unsigned int repeat_time : 4;
		unsigned int sync : 1;
		unsigned int sig : 1;
		unsigned int mode : 1;
		unsigned int key_ac : 1;
	} bits;
	uint8_t reg;
} deviceMode_t;

typedef union
{
	struct
	{
		unsigned int crc : 1;
		unsigned int chg : 1;
		unsigned int spi_en : 1;
		unsigned int gd_en : 1;
		unsigned int guard_key : 4;
	} bits;
	uint8_t reg;
} guardCommsOption_t;

typedef union
{
	struct
	{
		unsigned int dht : 4;
		unsigned int dil : 4;
	} bits;
	uint8_t reg;
} dilDht_t;

typedef union
{
	struct
	{
		unsigned int physt : 2;
		unsigned int pthr : 6;
	} bits;
	uint8_t reg;
} pThespHyst_t;

typedef union
{
	struct
	{
		unsigned int aks_8 : 1;
		unsigned int aks_9 : 1;
		unsigned int aks_10 : 1;
		unsigned int reserved : 5;
		unsigned int aks_0 : 1;
		unsigned int aks_1 : 1;
		unsigned int aks_2 : 1;
		unsigned int aks_3 : 1;
		unsigned int aks_4 : 1;
		unsigned int aks_5 : 1;
		unsigned int aks_6 : 1;
		unsigned int aks_7 : 1;
	} bits;
	uint16_t reg;
} aks_t;

typedef union
{
	struct
	{
		unsigned int out_detect : 4;
		unsigned int in_detect : 4;
	} bits;
	uint8_t reg;
} detect_t;

typedef union
{
	struct
	{
		// Address 17: LED Fade/ Key to LED
		unsigned int led_0 : 1;
		unsigned int led_1 : 1;
		unsigned int led_2 : 1;
		unsigned int led_3 : 1;
		unsigned int led_4 : 1;
		unsigned int led_5 : 1;
		unsigned int led_6 : 1;
		unsigned int fade : 1;
	} bits;
	uint8_t reg;
} ledKeyFade_t;

typedef union
{
	struct
	{
		unsigned int latch_0 : 1;
		unsigned int latch_1 : 1;
		unsigned int latch_2 : 1;
		unsigned int latch_3 : 1;
		unsigned int latch_4 : 1;
		unsigned int latch_5 : 1;
		unsigned int latch_6 : 1;
		unsigned int led_latch_unused : 1;
	} bits;
	uint8_t reg;
} ledLatch_t;

typedef union
{
	struct
	{
		unsigned int keynhyst : 2;
		unsigned int keynthr : 6;
	} bits;
	uint8_t reg;
} nThesNhyst_t;

typedef union
{
	struct
	{
		unsigned int low_time : 4;
		unsigned int high_time : 4;
	} bits;
	uint8_t reg;
} extendedPulseTime_t;

typedef union
{
	struct
	{
		unsigned int key_nrd : 4;
		unsigned int key_ndrift : 4;
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
	uint16_t signal_at42qt;
	uint16_t reference_at42qt;
	int16_t delta_at42qt;
	uint8_t status_at42qt;
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

extern at42qt1110DebugData_t at42qt1110DebugData[NO_OF_KEYS];
extern CommunicationStatus_t communicationStatus;

#define TIME_BETWEEN_BYTES_USEC 200u
#define DEF_STARTUP_TIME 500u
// Device ID for AT42QT1110
#define CHIP_ID 0x57u
#define IDLE_STATUS_CODE 0x55u
#define NULL_BYTE 0x00u
#define CRC_OPTION 0x91u

#endif /* AT42QT1110_H */
/*******************************************************************************
 End of File
 */
