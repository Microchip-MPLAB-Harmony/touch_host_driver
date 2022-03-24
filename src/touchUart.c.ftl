/*******************************************************************************
  MPLAB Harmony Touch Host Interface ${REL_VER} Release

  @Company
    Microchip Technology Inc.

  @File Name
    TouchUart.c

  @Summary
    This file contains the source code for the touch Uart application.

  @Description
    Provides the two way datastreamer protocol implementation, transmission of
          module data to data visualizer software using UART port.

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

#include "touchUart.h"
// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

#if TOUCH_INTERFACE == UART_INTERFACE

uintptr_t touchUart;
/**
 * @brief UART Tx complete call back function
 * 
 */
callbackTx_T txCompleteCallback;
/**
 * @brief UART Rx complete call back function
 * 
 */
callbackRx_T rxCompleteCallback;

/**
 * @brief Rx Data
 * 
 */
static volatile uint8_t rxData;

/**
 * @brief UART Tx complete call back function.
 * If user callback is not NULL, call the user registered callback function
 * 
 */
void touchUartTxComplete(uintptr_t touchUart) {
    if(txCompleteCallback != NULL){
        txCompleteCallback();
    }
}

/**
 * @brief UART Rx complete call back function.
 * If user callback is not NULL, call the user registered callback function
 * 
 */
void touchUartRxComplete(uintptr_t touchUart){
    if(rxCompleteCallback != NULL){
        rxCompleteCallback(rxData);
    }
    ${TOUCH_SERCOM_TURNKEY}_USART_Read((void *) &rxData,1);
}

/**
 * @brief initialization function to register uesr level callback and to configure
 * UART serttings.
 * 
 * @param txCallback user level callback function to indicate tx complete
 * @param rxCallback user level callback function to indicate rx complete
 */
void touchUartInit(callbackTx_T txCallback, callbackRx_T rxCallback) {
    
    txCompleteCallback = txCallback;
    rxCompleteCallback = rxCallback;
    
    USART_SERIAL_SETUP serailsetup;
    serailsetup.baudRate = TOUCH_UART_baudRate;
    serailsetup.parity = TOUCH_UART_parity;
    serailsetup.stopBits = TOUCH_UART_stopBits;
    serailsetup.dataWidth = TOUCH_UART_dataWidth;
    
    ${TOUCH_SERCOM_TURNKEY}_USART_SerialSetup(&serailsetup, ${TOUCH_SERCOM_TURNKEY}_USART_FrequencyGet());
    
    
    ${TOUCH_SERCOM_TURNKEY}_USART_ReadCallbackRegister(touchUartRxComplete, touchUart);
    ${TOUCH_SERCOM_TURNKEY}_USART_WriteCallbackRegister(touchUartTxComplete, touchUart);
    
    ${TOUCH_SERCOM_TURNKEY}_USART_Read((void *) &rxData,1);
}

/**
 * @brief Transmit data through UART
 * 
 * @param buffer data buffer pointer
 * @param len length of data buffer
 */
void touchUartSendData(uint8_t *buffer, transferSize_t len){
    
    ${TOUCH_SERCOM_TURNKEY}_USART_Write((void *) buffer, len);
}

/*******************************************************************************
 End of File
 */
#endif

