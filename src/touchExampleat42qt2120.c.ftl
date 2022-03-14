/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    host_example.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>      // Defines NULL
#include <stdbool.h>     // Defines true
#include <stdlib.h>      // Defines EXIT_FAILURE
#include "definitions.h" // SYS function prototypes

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************

int touch_mainloop_example(void)
{
  /* Initialize all modules */
  SYS_Initialize(NULL);
    touchDeviceInit();
<#if ENABLE_TUNE_OPTION??>
<#if ENABLE_TUNE_OPTION == true>
  touchTuneInit();
</#if>
</#if>
  while (1)
  {

    touchDeviceProcess();
<#if ENABLE_TUNE_OPTION??>
<#if ENABLE_TUNE_OPTION == true>
    touchTuneProcess();
</#if>
</#if>
    /* If touch tune is enabled, then CHANGE pin may not be active as key status are read in tune continuously.
    In that case, refer to GUI to get the touch status */
    /* Read all status-bytes
     * if CHANGE pin is asserted */
<#if ENABLE_CHANGE_PIN??>
<#if ENABLE_CHANGE_PIN == true>
    if (CHANGE_PIN)
    {
      // read all status-bytes
      touchDeviceReadStatusData();
      // Update the touch status via LED
    }
</#if>
</#if>
  }

  /* Execution should not come here during normal operation */

  return (EXIT_FAILURE);
}

/*******************************************************************************
 End of File
*/
