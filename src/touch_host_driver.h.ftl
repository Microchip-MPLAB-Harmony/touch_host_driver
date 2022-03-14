/* ************************************************************************** */
/** Descriptive File Name

  @Company
    Company Name

  @File Name
    filename.h

  @Summary
    Brief description of the file.

  @Description
    Describe the purpose of this file.
 */
/* ************************************************************************** */

#ifndef _TOUCH_HOST_DRIVER_H    /* Guard against multiple inclusion */
#define _TOUCH_HOST_DRIVER_H


/* ************************************************************************** */
/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */
/* ************************************************************************** */

/* This section lists the other files that are included in this file.
 */

/* TODO:  Include other files here if needed. */


/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include "definitions.h"
    
#define CIRCULAR_BUFFER_LEN (200u)

#if (CIRCULAR_BUFFER_LEN <= 255)
typedef uint8_t transferSize_t;
#else
typedef uint16_t transferSize_t;
#endif

typedef  void(*callbackTx_T)(void);
typedef  void(*callbackRx_T)(uint8_t);

#define SYS_TIME_RESOLUTION_MSEC 10u

    /* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _TOUCH_HOST_DRIVER_H */

/* *****************************************************************************
 End of File
 */
