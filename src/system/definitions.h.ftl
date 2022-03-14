<#if SELECT_TURNKEY_DEVICE == "AT42QT1110">
#include "touch_host_interface/at42qt1110.h"
<#elseif SELECT_TURNKEY_DEVICE == "AT42QT2120">
#include "touch_host_interface/at42qt2120.h"
</#if>
<#if ENABLE_TUNE_OPTION??>
<#if ENABLE_TUNE_OPTION == true>
#include "touch_host_interface/touchTune.h"
</#if>
</#if>