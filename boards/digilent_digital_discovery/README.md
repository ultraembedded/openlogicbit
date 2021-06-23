# Digilent Digital Discovery

The Digilent Digital Discovery is a 24-channel digital logic analyzer that comes with some free but proprietary software called WaveForms.

The device does not have persistent flash storage for FPGA bitstreams, so one must be loaded each time the power is applied.

## Loading bitstreams
```
# Acquire openFPGALoader from https://github.com/trabucayre/openFPGALoader

# Load the open-logic-bit gateware onto the device
sudo openFPGALoader -c digilent_ad prebuilt/fpga.bit
```

## Disclaimer
I have used the Digilent Digital Discovery reference manual schematics, and a bit of reverse engineering to guess the clock and FTDI connections.  
Nothing should be persistently changed on the device, but use at your own risk - it works well for me, but if some magic smoke should escape, do not blame me, etc...