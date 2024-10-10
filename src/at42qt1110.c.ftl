/*******************************************************************************
  MPLAB Harmony Touch Host Interface ${REL_VER} Release

  Company:
    Microchip Technology Inc.

  File Name:
    at42qt1110.c

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
 * Copyright (C) ${REL_YEAR} Microchip Technology Inc. and its subsidiaries.
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "at42qt1110.h"
#include "touchSPI.h"
#include "touchTune.h"

/*============================================================================
Global variable definitions
============================================================================*/
// Setup block structure
SetupBlock setup_block;

at42qt1110DebugData_t at42qt1110DebugData[NO_OF_KEYS];

static volatile uint8_t at42qt1110TransmitInProgress;
static volatile uint8_t at42qt1110DataReceived;

#define NUM_OF_TRY 5u

CommunicationStatus_t communicationStatus;

uint8_t at42qt1110ComputeCRC(uint8_t crc, uint8_t data)
{
  uint8_t index;
  uint8_t fb;
  index = 8u;

  do
  {
    fb = (crc ^ data) & 0x01u;
    data >>= 1u;
    crc >>= 1u;
    if (fb != 0u)
    {
      crc ^= 0x8cu;
    }
    index--;
  } while (index > 0u);

  return crc;
}

void resetCommunicationStatus(void)
{
  communicationStatus.crcError = 0u;
  communicationStatus.error = 0u;
  communicationStatus.errorCommand = 0u;
  communicationStatus.initError = 0u;
  communicationStatus.readStatus = 0u;
  communicationStatus.writeStatus = 0u;
}

uint8_t at42qt1110SendFirstKey(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_SEND_FIRST_KEY, 1u, &retVar);
  return retVar;
}

uint16_t at42qt1110GetAllKeyStatus(void)
{
  uint16_t allKeyStatus = 0u;
  // Read detection status of all keys
  (void)at42qt1110ReportRequest(CMD_SEND_ALL_KEYS, 2u, (uint8_t *)&allKeyStatus);
  return allKeyStatus;
}

uint8_t at42qt1110GetDeviceStatus(void)
{
  uint8_t status = 0u;
  (void)at42qt1110ReportRequest(CMD_DEVICE_STATUS, 1u, &status);
  return status;
}

uint8_t at42qt1110SendEepromCrc(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_EEPROM_CRC, 1u, &retVar);
  return retVar;
}

uint8_t at42qt1110SendRamCrc(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_RAM_CRC, 1u, &retVar);
  return retVar;
}

void at42qt1110SendErrorKeys(uint8_t *buffer)
{
  (void)at42qt1110ReportRequest(CMD_ERROR_KEYS, 2u, buffer);
}

uint16_t at42qt1110GetSignal(uint8_t keyNum)
{
  uint16_t signalValue = 0u;
  uint8_t cmd = (0x20u | keyNum);
  (void)at42qt1110ReportRequest(cmd, 2, (uint8_t *)&signalValue);

  return (signalValue >> (uint16_t)8u);
}

uint16_t at42qt1110GetReference(uint8_t keyNum)
{
  uint16_t refValue = 0u;
  (void)at42qt1110ReportRequest(0x40u | keyNum, 2, (uint8_t *)&refValue);

  return (refValue >> (uint16_t)8u);
}

uint8_t at42qt1110GetKeyStatus(uint8_t keyNum)
{
  uint8_t status = 0u;
  (void)at42qt1110ReportRequest(0x80u | keyNum, 1u, &status);
  return status;
}

uint8_t at42qt1110GetDetectOutStates(void)
{
  uint8_t status = 0u;
  (void)at42qt1110ReportRequest(CMD_DETECT_STATES, 1u, &status);
  return status;
}

uint8_t at42qt1110GetLastCommand(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_LAST_COMMAND, 1u, &retVar);
  return retVar;
}

void at42qt1110ReadSetupBlock(uint8_t *readBuffer, uint8_t length)
{
  // Read setup block
  (void)at42qt1110ReportRequest(CMD_READ_SETUPS, length, readBuffer);
}

uint8_t at42qt1110GetDeviceId(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_DEVICE_ID, 1u, &retVar);
  return retVar;
}

uint8_t at42qt1110GetFwVersion(void)
{
  uint8_t retVar = 0u;
  (void)at42qt1110ReportRequest(CMD_FIRMWARE_VERSION, 1u, &retVar);
  return retVar;
}

void at42qt1110SentControlCommand(uint8_t command)
{
  uint8_t data, try = 0u;
  touchSPIActivateSS();
  do
  {
    try++;
    // send Command to read device ID
    data = touchSPIExchangeData(command);
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  } while ((data != IDLE_STATUS_CODE) && (try < NUM_OF_TRY));
  if (try >= NUM_OF_TRY)
  {
    communicationStatus.error = 1u;
    communicationStatus.errorCommand = command;
  }
  touchSPIDeactivateSS();
}

void at42qt1110CalibrateAll(void)
{
  at42qt1110SentControlCommand(CMD_CALIBRATE_ALL);
  touchSPIDelayUsec(200u); // wait for 200usec
}

void at42qt1110Reset(void)
{
  at42qt1110SentControlCommand(CMD_RESET);
  touchSPIDelayUsec(200000u); // wait for 200msec
}

void at42qt1110Sleep(void)
{
  at42qt1110SentControlCommand(CMD_SLEEP);
}

void at42qt1110StoreEeprom(void)
{
  at42qt1110SentControlCommand(CMD_STORE_EEPROM);
  touchSPIDelayUsec(200000u); // wait for 200msec
}

void at42qt1110RestoreEeprom(void)
{
  at42qt1110SentControlCommand(CMD_RESTORE_EEPROM);
  touchSPIDelayUsec(200000u); // wait for 200msec
}

void at42qt1110EraseEeprom(void)
{
  at42qt1110SentControlCommand(CMD_ERASE_EEPROM);
  touchSPIDelayUsec(50000u); // wait for 50msec
}

void at42qt1110RecoverEeprom(void)
{
  at42qt1110SentControlCommand(CMD_RECOVER_EEPROM);
  touchSPIDelayUsec(50000u); // wait for 50msec
}

void touchDeviceGetDebugData(void)
{
  for (uint8_t cnt = 0u; cnt < NO_OF_KEYS; cnt++)
  {
    at42qt1110DebugData[cnt].signal_at42qt = at42qt1110GetSignal(cnt);
    at42qt1110DebugData[cnt].reference_at42qt = at42qt1110GetReference(cnt);
    at42qt1110DebugData[cnt].delta_at42qt = (int16_t)at42qt1110DebugData[cnt].reference_at42qt;
    at42qt1110DebugData[cnt].delta_at42qt -= (int16_t)at42qt1110DebugData[cnt].signal_at42qt;
    at42qt1110DebugData[cnt].status_at42qt = at42qt1110GetKeyStatus(cnt);
  }
}

void touchDeviceProcess(void)
{
  static uint8_t init = 0u;
  if (init == 0u)
  {
    init = 1u;
    touchDeviceInit();
<#if ENABLE_TUNE_OPTION??>
<#if ENABLE_TUNE_OPTION == true>
    touchTuneInit();
</#if>
</#if>
  }
  touchDeviceGetDebugData();
<#if ENABLE_TUNE_OPTION??>
<#if ENABLE_TUNE_OPTION == true>
  touchTuneNewDataAvailable();
</#if>
</#if>
}

void touchDeviceRxCompleteCallback(uint8_t data)
{
  at42qt1110DataReceived = 1u;
}

void touchDeviceTxCompleteCallback(void)
{
  at42qt1110TransmitInProgress = 0u;
}

void touchDeviceInit(void)
{
  SYSTICK_TimerStart();
  touchSPIInit(touchDeviceTxCompleteCallback, touchDeviceRxCompleteCallback);
  SYSTICK_DelayMs(DEF_STARTUP_TIME);
  uint8_t data, try = 0u;
  do
  {
    try++;
    // send Command to read device ID
    data = touchSPIExchangeData(CMD_DEVICE_ID);
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  } while ((data != CHIP_ID) && (try < NUM_OF_TRY));
  if (try >= NUM_OF_TRY)
  {
    communicationStatus.initError = 1u;
  }

#ifdef ENABLE_CRC
  /*
  CRC option is disabled on power cycle unless CRC enable
  setting is written in EEPROM. In this example taken the
  condition as CRC option disabled(default) on power cycle */

  do
  {
    try++;
    // Send Command
    data = touchSPIExchangeData(CRC_OPTION);
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
    ;
  } while ((data != IDLE_STATUS_CODE) && (try < NUM_OF_TRY));
  if (try >= NUM_OF_TRY)
  {
    communicationStatus.crcError = 1u;
  }
  // Send data byte (CRC Enabled byte)
  (void)touchSPIExchangeData(0x01u);

  /* leave a minimum delay between bytes
   * before sending next command */
  touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);

#endif
}
uint8_t ReadSetupBlock(uint8_t ReadLength, uint8_t *ReadPtr)
{
  // Read setup block
  return (at42qt1110ReportRequest(CMD_READ_SETUPS, ReadLength, ReadPtr));
}
uint8_t WriteSetupBlock(uint8_t WriteLength, uint8_t *WritePtr)
{
  uint8_t result = 1u, try = 0u;
  uint8_t data;
#ifdef ENABLE_CRC
  uint8_t CrcValue = 0u;
#endif

  do
  {
    try++;
    // Send Setup Command
    data = touchSPIExchangeData(CMD_SEND_SETUPS);
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  } while ((data != IDLE_STATUS_CODE) && (try < NUM_OF_TRY));
  if (try >= NUM_OF_TRY)
  {
    communicationStatus.writeStatus = 1u;
  };

#ifdef ENABLE_CRC
  // calculate CRC
  CrcValue = at42qt1110ComputeCRC(CrcValue, CMD_SEND_SETUPS);
#endif

  // Send data byte by byte
  for (uint8_t i = 0u; i < WriteLength; i++)
  {
    data = touchSPIExchangeData(*WritePtr);

#ifdef ENABLE_CRC
    // calculate CRC
    CrcValue = at42qt1110ComputeCRC(CrcValue, *WritePtr);
#endif
    // Increment write data pointer
    WritePtr++;

    // Delay needed between multi-byte communications
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  }

#ifdef ENABLE_CRC
  // send CRC byte
  data = touchSPIExchangeData(CrcValue);

  // verify the received CRC
  if (data != CrcValue)
  {
    result = 0u;
  }
#endif

  return result;
}
uint8_t ReadKeyStatus(uint8_t ReadLength, uint8_t *ReadPtr)
{
  // Read detection status of all keys
  return (at42qt1110ReportRequest(CMD_SEND_ALL_KEYS, ReadLength, ReadPtr));
}
uint8_t ReadKeySignal(uint8_t ReadLength, uint8_t *ReadPtr)
{
  // Read detection status of all keys
  return (at42qt1110ReportRequest(0x21, ReadLength, ReadPtr));
}

uint8_t at42qt1110ReportRequest(uint8_t command, uint8_t length, uint8_t *readBuffer)
{
  uint8_t result = 1U;
  uint8_t data, try = 0u;
#ifdef ENABLE_CRC
  uint8_t CrcValue;
#endif

  do
  {
    try++;
    // Send Command
    data = touchSPIExchangeData(command);
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  } while ((data != IDLE_STATUS_CODE) && (try < NUM_OF_TRY));
  if (try >= NUM_OF_TRY)
  {
    communicationStatus.readStatus = 1u;
  };

#ifdef ENABLE_CRC
  // init crc value
  CrcValue = 0u;

  // calculate CRC
  CrcValue = at42qt1110ComputeCRC(CrcValue, command);

  // send command byte CRC and read CRC byte send from QT device
  data = touchSPIExchangeData(CrcValue);

  // verify the received CRC
  if (data != CrcValue)
  {
    // Command failed! return
    return 0U;
  }

  touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);

  // init crc value
  CrcValue = 0u;
#endif

  // read the bytes
  for (uint8_t i = 0u; i < length; i++)
  {
    *readBuffer = touchSPIExchangeData(NULL_BYTE);
#ifdef ENABLE_CRC
    CrcValue = at42qt1110ComputeCRC(CrcValue, *readBuffer);
#endif
    // increment the data pointer
    readBuffer++;
    touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
  }

#ifdef ENABLE_CRC
  // read the CRC byte
  data = touchSPIExchangeData(NULL_BYTE);

  // verify the received CRC
  if (data != CrcValue)
  {
    result = 0U;
  }
  /* The below delay is required if two consecutive
   * commands are executed (This function ReportRequest()
   * is called consecutively
   */
  touchSPIDelayUsec(TIME_BETWEEN_BYTES_USEC);
#endif

  return result;
}

/*******************************************************************************
 End of File
 */
