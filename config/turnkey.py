import sys

try:
    #try required for pydoc server
    sys.path.append(Module.getPath() + "config")
except (NameError):
    pass

releaseVersion = "v1.0.0"
releaseYear    = "2022"
touchTurnkeyDB = {
'NO_DEVICE_SELECTED': {'interface': 'None', 'interruptPin': 'None'},
'AT42QT2120': {'interface': 'i2c', 'interruptPin': True},
'AT42QT1110': {'interface': 'spi', 'interruptPin': True}
}

masterFileList = { 'SOURCE':['touchI2C.c.ftl', 'touchSPI.c.ftl', 'touchUart.c.ftl','touchTune.c.ftl'],
                    'HEADER':['touchI2C.h', 'touchSPI.h', 'touchUart.h','touchTune.h']
                    }

destinationFolder = "/touch_host_interface/"

possibleInterfaces = []

configName = ""

def destroyComponent(touch_turnkey):
    print "Destroy touch module"

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
    localComp1 = symbol.getComponent()
    devName = localComp1.getSymbolByID("SELECT_TURNKEY_DEVICE").getValue()
    localComp = symbol.getComponent()

    localComp.setDependencyEnabled("Touch_Tune_UART", event['value'])

    if event['value']:
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

    if deviceName != "NO_DEVICE_SELECTED".lower():
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

def deviceSelectCallback(symbol,event):
    tempdatabase = touchTurnkeyDB[symbol.getValue()]
    localComp = symbol.getComponent()
    print(tempdatabase)
    deviceName = event['value'].lower()
    
    localComp.setDependencyEnabled("Touch_i2c", False)
    localComp.setDependencyEnabled("Touch_spi", False)
    localComp.setDependencyEnabled("Touch_uart", False)

    for inter in possibleInterfaces:
        if inter in tempdatabase['interface']:
            localComp.setDependencyEnabled("Touch_"+inter, True)
            if inter == "spi":
                localComp.getSymbolByID("SLAVE_SELECT_SPI_WARNING").setVisible(True)

    processDeviceFiles(deviceName, localComp)

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
    Database.setSymbolValue("core", "systickEnable", True)

    if sourceID != "Touch_Tune_UART":
        for inter in possibleInterfaces:
            if inter in tempdatabase['interface']:
                if inter.lower() not in sourceID:
                    localComp.setDependencyEnabled("Touch_"+inter, False)

        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TURNKEY")
        localSymbol.clearValue()
        localSymbol.setValue(targetID.upper())
        localSymbol2 = localComp.getSymbolByID("TOUCH_INTERFACE_TURNKEY")
        localSymbol2.clearValue()
        localSymbol2.setValue(interface)
        if(localSymbol2.getValue() == "spi"):
             Database.setSymbolValue(localSymbol.getValue().split("_")[0].lower(), "SPI_CLOCK_PHASE", 1)
             Database.setSymbolValue(localSymbol.getValue().split("_")[0].lower(), "SPI_CLOCK_POLARITY", 1)
    else:
        localSymbol = localComp.getSymbolByID("TOUCH_SERCOM_TUNE")
        localSymbol.clearValue()
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

    interruptPinEnable = comp.createBooleanSymbol("ENABLE_CHANGE_PIN", None)
    interruptPinEnable.setLabel("Enable CHANGE Pin")
    interruptPinEnable.setDefaultValue(False)
    interruptPinEnable.setDependencies(interruptPinOption,["ENABLE_CHANGE_PIN"])

    interruptPinName = comp.createStringSymbol("CHANGE_PIN_NAME", None)
    interruptPinName.setLabel("CHANGE Pin Name")
    interruptPinName.setDefaultValue("CHANGE_PIN")
    interruptPinName.setVisible(False)

    intPinWarning = comp.createCommentSymbol("CHANGE_PIN_WARNING", None)
    intPinWarning.setLabel("Warning!!! CHANGE PIN needs to be configured in Pin Manager")
    intPinWarning.setVisible(False)

    tuneOption = comp.createBooleanSymbol("ENABLE_TUNE_OPTION", None)
    tuneOption.setLabel("Enable Tuning option")
    tuneOption.setDefaultValue(False)
    tuneOption.setDescription("The Data Visualizer allows touch sensor debug information to be relayed on the UART interface to Data Visualizer software tool. This setting should be enabled for initial sensor tuning and can be disabled later to avoid using USART and additionally save code memory. More information can be found in Microchip Developer Help page.")
    tuneOption.setDependencies(tuningOptionUpdate,["ENABLE_TUNE_OPTION"])

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
