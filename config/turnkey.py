import sys

try:
    #try required for pydoc server
    sys.path.append(Module.getPath() + "config")
except (NameError):
    pass

releaseVersion = "v1.1.0"
releaseYear    = "2024"
touchTurnkeyDB = {
'NO_DEVICE_SELECTED': {'interface': 'None', 'interruptPin': 'None'},
'MTCH2120': {'interface': 'i2c', 'interruptPin': True},
'AT42QT2120': {'interface': 'i2c', 'interruptPin': True},
'AT42QT1110': {'interface': 'spi', 'interruptPin': True}
}

masterFileList = { 'SOURCE':['touchI2C.c.ftl', 'touchSPI.c.ftl', 'touchUart.c.ftl','touchTune.c.ftl','touchTuneMTCH2120.c.ftl'],
                    'HEADER':['touchI2C.h', 'touchSPI.h', 'touchUart.h','touchTune.h','touchTuneMTCH2120.h','mtch2120_api_examples.h.ftl','mtch2120_host_example.h']
                    }

destinationFolder = "/touch_host_interface/"

possibleInterfaces = []

configName = ""

def destroyComponent(touch_turnkey):
    print ("Destroy touch module")

def finalizeComponent(touch_turnkey):
    """
    MHC reference :<http://confluence.microchip.com/display/MH/MHC+Python+Interface#MHCPythonInterface-voidfinalizeComponent(component,[index])>
    Arguments:
        :qtouchComponent : newly created module see module.loadModule()
    Returns:
        :none
    """
    autoComponentIDTable = []
    autoConnectTable = []
    res = Database.activateComponents(autoComponentIDTable)
    res = Database.connectDependencies(autoConnectTable)

def interruptPinOption(symbol, event):
    print(event)
    localComp = symbol.getComponent()
    devName = localComp.getSymbolByID("SELECT_TURNKEY_DEVICE").getValue()

    if devName=="MTCH2120":
        localSymbol1 = localComp.getSymbolByID("INT_PIN_WARNING")
        localSymbol2 = localComp.getSymbolByID("INT_PIN_NAME")
    else:
        localSymbol1 = localComp.getSymbolByID("CHANGE_PIN_WARNING")
        localSymbol2 = localComp.getSymbolByID("CHANGE_PIN_NAME")
    
    if event['value']:
        localSymbol1.setVisible(True)
        localSymbol2.setVisible(True)
    else:
        localSymbol1.setVisible(False)
        localSymbol2.setVisible(False)

def tuningOptionUpdate(symbol, event):
    print(event)
    localComp = symbol.getComponent()
    devName = localComp.getSymbolByID("SELECT_TURNKEY_DEVICE").getValue()
    localComp.setDependencyEnabled("Touch_Tune_UART", event['value'])

    if event['value']:

        if devName=="MTCH2120":
            localSymbol = localComp.getSymbolByID("HEADER_touchTune.h")
            localSymbol.setSourcePath("/src/touchTuneMTCH2120.h")
            localSymbol.setOutputName("touchTune.h")
            localSymbol.setEnabled(True)

        else:
            localSymbol = localComp.getSymbolByID("HEADER_touchTune.h")
            localSymbol.setSourcePath("/src/touchTune.h")
            localSymbol.setOutputName("touchTune.h")
            localSymbol.setEnabled(True)
            
        localSymbol = localComp.getSymbolByID("TUNE_SOURCE")
        localSymbol.setSourcePath("/src/touchTune"+devName+".c.ftl")
        localSymbol.setMarkup(True)
        localSymbol.setOutputName("touchTune.c")
        localSymbol.setEnabled(True)

    else:
        localSymbol = localComp.getSymbolByID("HEADER_touchTune.h")
        localSymbol.setEnabled(False)
        localSymbol = localComp.getSymbolByID("TUNE_SOURCE")
        localSymbol.setEnabled(False)

def processDeviceFiles(deviceName, localComp):

    localSymbol = localComp.getSymbolByID("TURNKEY_HEADER")
    localSymbol.setEnabled(False)
    localSymbol = localComp.getSymbolByID("TURNKEY_SOURCE")
    localSymbol.setEnabled(False)
    localSymbol = localComp.getSymbolByID("TURNKEY_COMMON_HEADER")
    localSymbol.setEnabled(False)

    localSymbol = localComp.getSymbolByID("ENABLE_INT_PIN")
    localSymbol.setVisible(False)
    localSymbol = localComp.getSymbolByID("INT_PIN_NAME")
    localSymbol.setVisible(False)
    localSymbol = localComp.getSymbolByID("INT_PIN_WARNING")
    localSymbol.setVisible(False)
    localSymbol = localComp.getSymbolByID("ENABLE_CHANGE_PIN")
    localSymbol.setVisible(False)
    localSymbol = localComp.getSymbolByID("CHANGE_PIN_NAME")
    localSymbol.setVisible(False)
    localSymbol = localComp.getSymbolByID("CHANGE_PIN_WARNING")
    localSymbol.setVisible(False)

    if deviceName != "NO_DEVICE_SELECTED".lower():

        if deviceName == "MTCH2120".lower():
            localSymbol = localComp.getSymbolByID("TURNKEY_HEADER")
            localSymbol.setSourcePath("/src/"+deviceName+".h.ftl")
            localSymbol.setOutputName(deviceName+".h")
            localSymbol.setEnabled(True)
            localSymbol.setMarkup(True)

            localSymbol1 = localComp.getSymbolByID("API_EXAMPLE")
            localSymbol1.setSourcePath("/src/mtch2120_api_examples.h.ftl")
            localSymbol1.setOutputName("mtch2120_api_examples.h")
            localSymbol1.setEnabled(True)
            localSymbol.setMarkup(True)

            localSymbol2 = localComp.getSymbolByID("HOST_EXAMPLE_HEADER")
            localSymbol2.setSourcePath("/src/mtch2120_host_example.h")
            localSymbol2.setOutputName("mtch2120_host_example.h")
            localSymbol2.setEnabled(True)
                   
        
        else:
            localSymbol = localComp.getSymbolByID("TURNKEY_HEADER")
            localSymbol.setSourcePath("/src/"+deviceName+".h")
            localSymbol.setOutputName(deviceName+".h")
            localSymbol.setEnabled(True)            

        localSymbol = localComp.getSymbolByID("TURNKEY_SOURCE")
        localSymbol.setSourcePath("/src/"+deviceName+".c.ftl")
        localSymbol.setOutputName(deviceName+".c")
        localSymbol.setEnabled(True)
        localSymbol.setMarkup(True)

        localSymbol = localComp.getSymbolByID("TOUCH_EXAMPLE")
        localSymbol.setSourcePath("/src/touchExample"+deviceName+".c.ftl")
        localSymbol.setOutputName(deviceName+"_host_example.c")
        localSymbol.setEnabled(True)
        localSymbol.setMarkup(True)

        localSymbol = localComp.getSymbolByID("TURNKEY_COMMON_HEADER")
        localSymbol.setOutputName("touch_host_driver.h")
        localSymbol.setEnabled(True)
    else:
        localSymbol = localComp.getSymbolByID("TURNKEY_HEADER")
        localSymbol.setEnabled(False)
        localSymbol = localComp.getSymbolByID("TURNKEY_SOURCE")
        localSymbol.setEnabled(False)
        localSymbol = localComp.getSymbolByID("TOUCH_EXAMPLE")
        localSymbol.setEnabled(False)
        localSymbol = localComp.getSymbolByID("TURNKEY_COMMON_HEADER")
        localSymbol.setEnabled(False)


    if deviceName == "MTCH2120".lower():
        localSymbol = localComp.getSymbolByID("ENABLE_INT_PIN")
        localSymbol.setEnabled(True)
        localSymbol.setVisible(True)
        localSymbol = localComp.getSymbolByID("INT_PIN_NAME")
        localSymbol.setVisible(True)
        localSymbol = localComp.getSymbolByID("INT_PIN_WARNING")
        localSymbol.setVisible(True)
    elif deviceName != "NO_DEVICE_SELECTED".lower():
        localSymbol = localComp.getSymbolByID("ENABLE_CHANGE_PIN")
        localSymbol.setEnabled(True)
        localSymbol = localComp.getSymbolByID("CHANGE_PIN_NAME")
        localSymbol.setVisible(True)
        localSymbol = localComp.getSymbolByID("CHANGE_PIN_WARNING")
        localSymbol.setVisible(True)

def deviceSelectCallback(symbol,event):
    tempdatabase = touchTurnkeyDB[symbol.getValue()]
    localComp = symbol.getComponent()
    print(tempdatabase)
    deviceName = event['value'].lower()
    for inter in ["i2c", "spi", "uart"]:
        if inter not in tempdatabase['interface']:
            localComp.setDependencyEnabled("Touch_"+inter, False)
        else:
            localComp.setDependencyEnabled("Touch_"+inter, True)
            if inter == "spi":
                localComp.getSymbolByID("SLAVE_SELECT_SPI_WARNING").setVisible(True)
 
    processDeviceFiles(deviceName, localComp)
    
    # localComp.setDependencyEnabled("Touch_i2c", False)
    # localComp.setDependencyEnabled("Touch_spi", False)
    # localComp.setDependencyEnabled("Touch_uart", False)

    # localComp.getSymbolByID("SLAVE_SELECT_SPI_WARNING").setVisible(False)

    # for inter in possibleInterfaces:
    #     if inter in tempdatabase['interface']:
    #         localComp.setDependencyEnabled("Touch_"+inter, True)
    #         if inter == "spi":
    #             localComp.getSymbolByID("SLAVE_SELECT_SPI_WARNING").setVisible(True)

    # processDeviceFiles(deviceName, localComp)

def processTurnkeyInterfaceFiles(interface, localComp):
    for item in masterFileList:
        currentItem = masterFileList[item]
        for keyval in currentItem:
            symbol = item+"_"+keyval
            if interface.lower() in keyval.lower():
                localSymbol = localComp.getSymbolByID(symbol)
                localSymbol.setEnabled(True)
             

def onAttachmentConnected(source,target):
    localComp = source["component"]
    targetID = target["id"]
    sourceID = source["id"]
    device = localComp.getSymbolByID("SELECT_TURNKEY_DEVICE").getValue()
    tempdatabase = touchTurnkeyDB[device]
    print(targetID, sourceID)
    interface = sourceID.replace("Touch_", "")
    processTurnkeyInterfaceFiles(interface, localComp)


    if sourceID != "Touch_Tune_UART":
        for inter in possibleInterfaces:
            if inter in tempdatabase['interface']:
                if inter.lower() not in sourceID:
                    localComp.setDependencyEnabled("Touch_"+inter, False)
        localSymbol4=localComp.getSymbolByID("ENABLE_SYSTICK_FUNCTIONS")
        localSymbol4.clearValue()
        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TURNKEY")
        localSymbol.clearValue()
        peripheralNode = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
        for index in range (0, len(peripheralNode.getChildren())):
            if (peripheralNode.getChildren()[index].getAttribute("name") == "I2C"): 
                if(peripheralNode.getChildren()[index].getAttribute("id") in ["01441"]):
                    localSymbol.setValue(targetID.upper().split("_")[0])
                    localSymbol4.setValue(False)
                    break
            else:
                localSymbol.setValue(targetID.upper())
                localSymbol4.setValue(True)
                
        
        localSymbol2 = localComp.getSymbolByID("TOUCH_INTERFACE_TURNKEY")
        localSymbol2.clearValue()
        localSymbol2.setValue(interface)
        if(localSymbol2.getValue() == "spi"):
             Database.setSymbolValue(localSymbol.getValue().split("_")[0].lower(), "SPI_CLOCK_PHASE", 1)
             Database.setSymbolValue(localSymbol.getValue().split("_")[0].lower(), "SPI_CLOCK_POLARITY", 1)

        localSymbol3 = localComp.getSymbolByID("TOUCH_SERCOM_ENUM_TURNKEY")
        localSymbol3.clearValue()
        for index in range (0, len(peripheralNode.getChildren())):
            if (peripheralNode.getChildren()[index].getAttribute("name") == "I2C"): 
                if(peripheralNode.getChildren()[index].getAttribute("id") in ["01441"]):
                    localSymbol3.setValue(targetID.upper().split("_")[1])
                    break
            else:
                localSymbol3.setValue(targetID.upper().replace((targetID.upper())[6],"",1))
                
    else:
        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TUNE")
        localSymbol.clearValue()
        peripheralNode = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
        for index in range (0, len(peripheralNode.getChildren())):
            if (peripheralNode.getChildren()[index].getAttribute("name") == "UART"): 
                if(peripheralNode.getChildren()[index].getAttribute("id") in ["02478"]):
                    localSymbol.setValue(targetID.upper().split("_")[0].replace("USART","UART"))
                    break
            else:
                localSymbol.setValue(targetID.upper().replace("UART","USART"))
                
        

def onAttachmentDisconnected(source,target):
    localComp = source["component"]
    targetID = target["id"]
    sourceID = source["id"]
    device = localComp.getSymbolByID("SELECT_TURNKEY_DEVICE").getValue()
    tempdatabase = touchTurnkeyDB[device]

    for inter in possibleInterfaces:
        if inter in tempdatabase['interface']:
            localComp.setDependencyEnabled("Touch_"+inter, True)

    if sourceID != "Touch_Tune_UART":
        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TURNKEY")
        localSymbol.clearValue()
        localSymbol = localComp.getSymbolByID("TOUCH_INTERFACE_TURNKEY")
        localSymbol.clearValue()
    else:
        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TUNE")
        localSymbol.clearValue()
        

def instantiateComponent(comp):
    # import sys;sys.path.append(r'C:\Programs\eclipse\plugins\org.python.pydev.core_8.3.0.202104101217\pysrc')
    # #import sys;sys.path.append(r'C:/Programs/Python/Python39/Scripts')
    # import pydevd;pydevd.settrace()
    """Start Point for instantiation of the touch Module. 
    MHC reference : <http://confluence.microchip.com/display/MH/MHC+Python+Interface#MHCPythonInterface-voidinstantiateComponent(component,[index])>
    Builds and populates tree view menu in MHC. 
    Determines target device and capabilities. 
    Configures all required submodules. 
    Triggers updates for touch sub modules with multiple groups:
        node, sensor, key, scroller, frequency hop, boost mode, driven shield
    Arguments:
        :qtouchComponent : newly created touchModule see module.loadModule()
    Returns:
        :none
    """
    print ("Entering initialise")

    # touchConfigurator = qtouchComponent.createMenuSymbol("TOUCH_CONFIGURATOR", None)

    configName = Variables.get("__CONFIGURATION_NAME")

    possibleDeviceList = []
    for dictItem in touchTurnkeyDB:
        possibleDeviceList.append(dictItem)
        thisDict = touchTurnkeyDB[dictItem]
        if thisDict['interface'] not in possibleInterfaces:
            if isinstance(thisDict['interface'], list):
                for i in thisDict['interface']:
                    possibleInterfaces.append(i)
            else:
                possibleInterfaces.append(thisDict['interface'])

    print(possibleInterfaces)

    possibleDeviceList = possibleDeviceList[::-1] # revert the list for proper display
    deviceSelect = comp.createComboSymbol("SELECT_TURNKEY_DEVICE", None, possibleDeviceList)
    deviceSelect.setLabel("Select Turnkey Device")
    deviceSelect.setDependencies(deviceSelectCallback,["SELECT_TURNKEY_DEVICE"])
    deviceSelect.setHelp("touch-host-config")

    interruptPinEnable = comp.createBooleanSymbol("ENABLE_INT_PIN", None)
    interruptPinEnable.setLabel("Enable INT Pin")
    interruptPinEnable.setDefaultValue(False)
    interruptPinEnable.setDependencies(interruptPinOption,["ENABLE_INT_PIN"])
    interruptPinEnable.setVisible(False)
    interruptPinEnable.setHelp("touch-host-config")

    interruptPinName = comp.createStringSymbol("INT_PIN_NAME", None)
    interruptPinName.setLabel("INTERRUPT Pin Name")
    interruptPinName.setDefaultValue("INT_PIN")
    interruptPinName.setVisible(False)
    interruptPinName.setHelp("touch-host-config")

    intPinWarning = comp.createCommentSymbol("INT_PIN_WARNING", None)
    intPinWarning.setLabel("Warning!!! Configure Interrupt Pin as input with Pull up enabled")
    intPinWarning.setVisible(False) 

    interruptPinEnable = comp.createBooleanSymbol("ENABLE_CHANGE_PIN", None)
    interruptPinEnable.setLabel("Enable CHANGE Pin")
    interruptPinEnable.setDefaultValue(False)
    interruptPinEnable.setDependencies(interruptPinOption,["ENABLE_CHANGE_PIN"])
    interruptPinEnable.setVisible(False)
    interruptPinEnable.setHelp("touch-host-config")

    interruptPinName = comp.createStringSymbol("CHANGE_PIN_NAME", None)
    interruptPinName.setLabel("CHANGE Pin Name")
    interruptPinName.setDefaultValue("CHANGE_PIN")
    interruptPinName.setVisible(False)
    interruptPinName.setHelp("touch-host-config")

    intPinWarning = comp.createCommentSymbol("CHANGE_PIN_WARNING", None)
    intPinWarning.setLabel("Warning!!! CHANGE PIN needs to be configured in Pin Manager")
    intPinWarning.setVisible(False)              
    
    
    tuneOption = comp.createBooleanSymbol("ENABLE_TUNE_OPTION", None)
    tuneOption.setLabel("Enable Tuning option")
    tuneOption.setDefaultValue(False)
    tuneOption.setDescription("The Data Visualizer allows touch sensor debug information to be relayed on the UART interface to Data Visualizer software tool. This setting should be enabled for initial sensor tuning and can be disabled later to avoid using USART and additionally save code memory. More information can be found in Microchip Developer Help page.")
    tuneOption.setDependencies(tuningOptionUpdate,["ENABLE_TUNE_OPTION"])
    tuneOption.setHelp("touch-host-config")

    turnkeyCommonHeader = comp.createFileSymbol("TURNKEY_COMMON_HEADER", None)
    turnkeyCommonHeader.setSourcePath("/src/touch_host_driver.h.ftl")
    turnkeyCommonHeader.setOutputName("touch_host_driver.h")
    turnkeyCommonHeader.setDestPath(destinationFolder)
    turnkeyCommonHeader.setProjectPath("config/" + configName + destinationFolder)
    turnkeyCommonHeader.setType("HEADER")
    turnkeyCommonHeader.setEnabled(False)
    turnkeyCommonHeader.setMarkup(True)

    turnkeyHeader = comp.createFileSymbol("TURNKEY_HEADER", None)
    turnkeyHeader.setDestPath(destinationFolder)
    turnkeyHeader.setProjectPath("config/" + configName + destinationFolder)
    turnkeyHeader.setType("HEADER")
    turnkeyHeader.setMarkup(False)
    turnkeyHeader.setEnabled(False)

    turnkeyHeader = comp.createFileSymbol("API_EXAMPLE", None)
    turnkeyHeader.setDestPath(destinationFolder)
    turnkeyHeader.setProjectPath("config/" + configName + destinationFolder)
    turnkeyHeader.setType("HEADER")
    turnkeyHeader.setMarkup(False)
    turnkeyHeader.setEnabled(False)

    turnkeyHeader = comp.createFileSymbol("HOST_EXAMPLE_HEADER", None)
    turnkeyHeader.setDestPath(destinationFolder)
    turnkeyHeader.setProjectPath("config/" + configName + destinationFolder)
    turnkeyHeader.setType("HEADER")
    turnkeyHeader.setMarkup(False)
    turnkeyHeader.setEnabled(False)

    turnkeySrc = comp.createFileSymbol("TURNKEY_SOURCE", None)
    turnkeySrc.setDestPath(destinationFolder)
    turnkeySrc.setProjectPath("config/" + configName + destinationFolder)
    turnkeySrc.setType("SOURCE")
    turnkeySrc.setMarkup(False)
    turnkeySrc.setEnabled(False)

    turnkeyInterfaceSercomString = comp.createStringSymbol("TOUCH_SERCOM_TURNKEY", None)
    turnkeyInterfaceSercomString.setLabel("Sercom For Turnkey")
    turnkeyInterfaceSercomString.setReadOnly(True)
    turnkeyInterfaceSercomString.setVisible(False)
    turnkeyInterfaceSercomString.setDefaultValue("")

    turnkeyInterfaceSercom = comp.createStringSymbol("TOUCH_SERCOM_ENUM_TURNKEY", None)
    turnkeyInterfaceSercom.setLabel("Sercom Enum For Turnkey")
    turnkeyInterfaceSercom.setReadOnly(True)
    turnkeyInterfaceSercom.setVisible(False)
    turnkeyInterfaceSercom.setDefaultValue("")

    interruptPinEnable = comp.createBooleanSymbol("ENABLE_SYSTICK_FUNCTIONS", None)
    interruptPinEnable.setLabel("Enable Systick Functions")
    interruptPinEnable.setReadOnly(True)
    interruptPinEnable.setVisible(False)
    interruptPinEnable.setDefaultValue(True)

    turnkeyInterfaceString = comp.createStringSymbol("TOUCH_INTERFACE_TURNKEY", None)
    turnkeyInterfaceString.setLabel("Interface For Turnkey")
    turnkeyInterfaceString.setReadOnly(True)
    turnkeyInterfaceString.setVisible(False)
    turnkeyInterfaceString.setDefaultValue("")

    slaveselectSPIPinWarning = comp.createCommentSymbol("SLAVE_SELECT_SPI_WARNING", None)
    slaveselectSPIPinWarning.setLabel("Warning!!! Slave Select PIN for SPI needs to be configured as SPI_SS in Pin Manager")
    slaveselectSPIPinWarning.setVisible(False)
    
    tuneHeader = comp.createFileSymbol("TUNE_HEADER", None)
    tuneHeader.setDestPath(destinationFolder)
    tuneHeader.setProjectPath("config/" + configName + destinationFolder)
    tuneHeader.setType("HEADER")
    tuneHeader.setMarkup(False)
    tuneHeader.setEnabled(False)

    src = []
    for item in masterFileList:
        currentItem = masterFileList[item]
        for keyval in currentItem:
            symbol = item+"_"+keyval
            src.append(comp.createFileSymbol(symbol, None))
            src[len(src)-1].setDestPath(destinationFolder)
            src[len(src)-1].setSourcePath("/src/"+keyval)
            src[len(src)-1].setProjectPath("config/" + configName + destinationFolder)
            src[len(src)-1].setType(item)
            if keyval.__contains__('ftl'):
                src[len(src)-1].setMarkup(True)
            else:
                src[len(src)-1].setMarkup(False)
            src[len(src)-1].setEnabled(False)
            src[len(src)-1].setOutputName(keyval.replace(".ftl",""))

    print(src)

    tuneSrc = comp.createFileSymbol("TUNE_SOURCE", None)
    tuneSrc.setDestPath(destinationFolder)
    tuneSrc.setProjectPath("config/" + configName + destinationFolder)
    tuneSrc.setType("SOURCE")
    tuneSrc.setMarkup(False)
    tuneSrc.setEnabled(False)

    tuneString = comp.createStringSymbol("TOUCH_SERCOM_TUNE", None)
    tuneString.setLabel("Sercom For Tuning")
    tuneString.setReadOnly(True)
    tuneString.setVisible(False)
    tuneString.setDefaultValue("")

    touchExample = comp.createFileSymbol("TOUCH_EXAMPLE", None)
    touchExample.setDestPath(destinationFolder)
    touchExample.setProjectPath("config/" + configName + destinationFolder)
    touchExample.setType("SOURCE")
    touchExample.setMarkup(False)
    touchExample.setEnabled(False)

    touchSystemDefFile = comp.createFileSymbol("TOUCH_SYS_DEF", None)
    touchSystemDefFile.setType("STRING")
    touchSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    touchSystemDefFile.setSourcePath("/src/system/definitions.h.ftl")
    touchSystemDefFile.setMarkup(True)

    getreleaseVersion = comp.createStringSymbol("REL_VER", None)
    getreleaseVersion.setDefaultValue(releaseVersion)
    getreleaseVersion.setVisible(False)

    getreleaseYear = comp.createStringSymbol("REL_YEAR", None)
    getreleaseYear.setDefaultValue(releaseYear)
    getreleaseYear.setVisible(False)
