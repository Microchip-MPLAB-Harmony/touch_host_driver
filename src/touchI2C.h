/*******************************************************************************
  MPLAB Harmony Touch Host Interface Release

  Company:
    Microchip Technology Inc.

  File Name:
    touchI2C.h

  Summary:
    This header file provides prototypes and definitions for the application.

  Description:
    This header file provides function prototypes and data type definitions for
    the application.  Some of these are required by the system (such as the
    "APP_Initialize" and "APP_Tasks" prototypes) and some of them are only used
    internally by the application (such as the "APP_STATES" definition).  Both
    are defined here for convenience.
*******************************************************************************/

//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

/**
 * @file touchI2C.h
 * @brief This file contains header for touch I2C communication functions
 * @copyright Copyright (c) 2021 Microchip Technology Inc. and its subsidiaries.
 * 
 */

#ifndef TOUCH_I2C_H
#define TOUCH_I2C_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "touch_host_driver.h"

/**
 * @brief initialization function to register uesr level callback and to configure
 * I2C settings.
 * 
 * @param txCallback user level callback function to indicate tx complete
 * @param rxCallback user level callback function to indicate rx complete
 */
void touchI2cInit(callbackTx_T txCallback, callbackRx_T rxCallback);
/**
 * @brief Set the slave address from/to which the data must be read/write
 * 
 * @param slaveAddr I2C Slave address
 */
void touchI2cSetSlaveAddress(uint8_t slaveAddrTemp);
/**
 * @brief Set the memroy address from/to which the data must be read/write
 * 
 * @param memAddr address of the memory
 */
void touchI2cSetMemoryAddrss(uint8_t memAddr);
/**
 * @brief This function writes one byte of data. This is a blocking code.
 * Before calling this function, the memory address and slave address 
 * to which this data to be written must be set using touchI2cSetMemoryAddrss() and touchI2cSetSlaveAddress() 
 * for the very first byte.
 * The memory address is increased later on in this function.
 * 
 * Usage: \n 
 * touchI2cSetSlaveAddress(0x25); \n 
 * touchI2cSetMemoryAddrss(0x10); Memory address is 0x10 \n 
 * for(uint8_t cnt = 0; cnt < 10; cnt ++) touchI2cWriteByte(buffer[cnt]);
 * 
 */
void touchI2cWriteByte(uint8_t data);
/**
 * @brief This function reads one byte of data. This is a blocking code.
 * Before calling this function, the memory address and slave address 
 * to which this data to be written must be set using touchI2cSetMemoryAddrss() and touchI2cSetSlaveAddress() 
 * for the very first byte.
 * The memory address is increased later on in this function.
 * 
 * Usage: \n 
 * touchI2cSetSlaveAddress(0x25); \n 
 * touchI2cSetMemoryAddrss(0x10); Memory address is 0x10 \n 
 * for(uint8_t cnt = 0; cnt < 10; cnt ++) buffer[cnt] = touchI2cReadByte();
 * 
 * @return uint8_t returns read data
 */
uint8_t touchI2cReadByte(void);
/**
 * @brief This function send data "len" number of data from address "memAddr".
 * It sends write command with first address being memAddr. 
 * This is a non-blocking code.
 * The completion is indicated by txCallback function registered in touchI2cInit 
 * 
 * Usage: \n 
 * touchI2cSendDataToAddress(0x25, 0x10, &buffer[0], 10);
 * 
 * @param slaveAddr slave address
 * @param memAddr memory address to which data must be written
 * @param dataptr pointer from which data must be written
 * @param len length of data that must be written
 */
void touchI2cSendDataToAddress(uint8_t slaveAddr, uint8_t memAddr, uint8_t *dataptr, transferSize_t len);
/**
 * @brief This function receives data "len" number of data from address "memAddr".
 * First it sents a I2C write command with data as "memAddr"
 * Second it sends I2C read command for length defined by "len"
 * This is a non-blocking code.
 * The completion is indicated by rxCallback function registered in touchI2cInit 
 * 
 * Usage: \n 
 * touchI2cReceiveDataFromAddress(0x25, 0x10, &buffer[0], 10);
 * 
 * @param slaveAddr slave address
 * @param memAddr memory address from which data must be read
 * @param dataptr pointer to which data must be read
 * @param len length of data that must be read
 */
void touchI2cReceiveDataFromAddress(uint8_t slaveAddr, uint8_t memAddr, uint8_t *dataptr, transferSize_t len);


/**
 * @brief This function send data "len" number of data from address "memAddr".
 * It sends write command with first address being memAddr. 
 * This is a non-blocking code.
 * The completion is indicated by txCallback function registered in touchI2cInit 
 * 
 * Usage: \n 
 * touchI2cSendDataTo_16bit_Address(0x25, 0x10, &buffer[0], 10);
 * 
 * @param slaveAddr slave address
 * @param memAddr memory address to which data must be written
 * @param dataptr pointer from which data must be written
 * @param len length of data that must be written
 */
void touchI2cSendDataTo_16bit_Address(uint8_t slaveAddr, uint16_t memAddr, const uint8_t *dataptr, transferSize_t len);
/**
 * @brief This function receives data "len" number of data from address "memAddr".
 * First it sents a I2C write command with data as "memAddr"
 * Second it sends I2C read command for length defined by "len"
 * This is a non-blocking code.
 * The completion is indicated by rxCallback function registered in touchI2cInit 
 * 
 * Usage: \n 
 * touchI2cReceiveDataFrom_16bit_Address(0x25, 0x10, &buffer[0], 10);
 * 
 * @param slaveAddr slave address
 * @param memAddr memory address from which data must be read
 * @param dataptr pointer to which data must be read
 * @param len length of data that must be read
 */
void touchI2cReceiveDataFrom_16bit_Address(uint8_t slaveAddr, uint16_t memAddr, uint8_t *dataptr, transferSize_t len);

#endif /* _touchI2C_H */
/*******************************************************************************
 End of File
 */

