/*******************************************************************************
  MPLAB Harmony Application Header File

  Company:
    Microchip Technology Inc.

  File Name:
    at42qt2120.h

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
 * Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
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

#ifndef _AT42QT2120_H
#define _AT42QT2120_H

#include "touch_host_driver.h"

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

/* QT2120 Sepcifics */

#define NO_OF_KEYS 12u

#define SLAVE_DEVICE_ADDRESS 0x1C

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

typedef union
{
  struct
  {
    uint8_t scale : 4;
    uint8_t pulse : 4;
  } bits;
  uint8_t reg;
} pulseScale_t;

typedef union
{
  struct
  {
    uint8_t en : 1;
    uint8_t gpo : 1;
    uint8_t aks : 2;
    uint8_t guard : 1;
    uint8_t reserved : 3;
  } bits;
  uint8_t reg;
} keyControl_t;

typedef struct
{
  uint8_t chip_id;
  uint8_t firmware_version;
  uint8_t detection_status;
  uint16_t key_status;
  uint8_t slider_position;
} qt2120StatusRegister;

typedef struct
{
  uint16_t key_signal[NO_OF_KEYS];
  uint16_t ref_data[NO_OF_KEYS];
} qt2120DebugDataRegister;

typedef struct
{
  uint8_t lowPowerMode;
  uint8_t towardsTouchDrift;
  uint8_t awayFromTouchDrift;
  uint8_t detectIntegrator;
  uint8_t touchRecalDelay;
  uint8_t driftHoldTime;
  uint8_t slider_options;
  uint8_t charge_time;
  uint8_t key_detect_threshold[NO_OF_KEYS];
  keyControl_t key_control[NO_OF_KEYS];
  pulseScale_t pulseScale[NO_OF_KEYS];
} qt2120ConfigRegisters;

#define getChipIDAddress() 0
#define getConfigStartAddress() LOW_POWER_MODE_ADDRESS
#define getDebugDataStartAddress() KEY0_SIGNAL_ADDRESS
#define getDeviceExpectedChipID() 0x3E
typedef qt2120ConfigRegisters configurationDataT;
typedef qt2120DebugDataRegister debugDataT;
typedef qt2120StatusRegister statusDataT;

/* General */
typedef enum
{
  STATE_INVALID,
  READ_DEBUG_DATA_FROM_TOUCH,
  READ_STATUS_DATA_FROM_TOUCH,
  SEND_DATA_TO_PC
} touchI2CState_t;

typedef struct tagCommunicationStatus_t
{
  uint8_t initError;
  uint8_t ConfigDataError;
  uint8_t DebugDataError;
  uint8_t StatusDataError;
} CommunicationStatus_t;

void touchDeviceInit(void);
void touchDeviceProcess(void);
void touchDeviceRxCompleteCallback(uint8_t data);
void touchDeviceTxCompleteCallback(void);

extern volatile uint8_t timeToRead;

#endif /* _AT42QT2120_H */
/*******************************************************************************
 End of File
 */
