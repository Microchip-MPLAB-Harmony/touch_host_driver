"""
MHC Python Interface documentation website <http://confluence.microchip.com/display/MH/MHC+Python+Interface>
"""

def loadModule():
    peripheralNode = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals")
    for index in range (0, len(peripheralNode.getChildren())):
        if (peripheralNode.getChildren()[index].getAttribute("name") == "SERCOM"): 
            if(peripheralNode.getChildren()[index].getAttribute("id") in ["U2201"]):
                touchTurnkeyComponent = Module.CreateComponent("touch_turnkey", "Touch Host Interface", "/Touch Turnkey/", "config/turnkey.py")
                touchTurnkeyComponent.setDisplayType("Touch Host Interface")
                touchTurnkeyComponent.addDependency("Touch_uart", "UART", None, False, False)
                touchTurnkeyComponent.setDependencyEnabled("Touch_uart", False)
                touchTurnkeyComponent.addDependency("Touch_spi", "SPI", None, False, False)
                touchTurnkeyComponent.setDependencyEnabled("Touch_spi", False)
                touchTurnkeyComponent.addDependency("Touch_i2c", "I2C", None, False, False)
                touchTurnkeyComponent.setDependencyEnabled("Touch_i2c", False)
                touchTurnkeyComponent.addDependency("Touch_Tune_UART", "UART", "UART (Tune)", False, False)
                touchTurnkeyComponent.setDependencyEnabled("Touch_Tune_UART", False)
    