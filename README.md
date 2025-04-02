# lcls2-epix-hr-pcie
[DOE Code](https://www.osti.gov/doecode/biblio/77593)

<!--- ######################################################## -->

# Clone the GIT repository

Install git large filesystems (git-lfs) in your .gitconfig (1-time step per unix environment)
```bash
$ git lfs install
```
Clone the git repo with git-lfs enabled
```bash
$ git clone --recursive https://github.com/slaclab/lcls2-epix-hr-pcie.git
```

<!--- ######################################################## -->

# SLAC PGP GEN4 PCIe Fiber mapping

```
QSFP[0][0] = PGP.Lane[0].VC[3:0]
QSFP[0][1] = PGP.Lane[1].VC[3:0]
QSFP[0][2] = PGP.Lane[2].VC[3:0]
QSFP[0][3] = PGP.Lane[3].VC[3:0]
QSFP[1][0] = LCLS-I  Timing Receiver
QSFP[1][1] = LCLS-II Timing Receiver
QSFP[1][2] = Unused QSFP Link
QSFP[1][3] = Unused QSFP Link
SFP = Unused SFP Link
```

<!--- ######################################################## -->

# KCU1500 PCIe Fiber mapping

```
QSFP[0][0] = PGP.Lane[0].VC[3:0]
QSFP[0][1] = PGP.Lane[1].VC[3:0]
QSFP[0][2] = PGP.Lane[2].VC[3:0]
QSFP[0][3] = PGP.Lane[3].VC[3:0]
QSFP[1][0] = LCLS-I  Timing Receiver
QSFP[1][1] = LCLS-II Timing Receiver
QSFP[1][2] = Unused QSFP Link
QSFP[1][3] = Unused QSFP Link
```

<!--- ######################################################## -->

# PGP Virtual Channel Mapping

```
PGP.Lane[0].VC[0] = SRPv3 (register access)
PGP.Lane[0].VC[1] = Camera Image (streaming data)
PGP.Lane[0].VC[2] = PseudoScope (streaming data)
PGP.Lane[0].VC[3] = Slow ADC Monitoring (streaming data)

PGP.Lane[3:1].VC[0] = Unused
PGP.Lane[3:1].VC[1] = Camera Image (streaming data)
PGP.Lane[3:1].VC[2] = Unused
PGP.Lane[3:1].VC[3] = Unused
```

<!--- ######################################################## -->

# DMA channel mapping

```
DMA[lane].DEST[0] = SRPv3 (PGP.Lane[0].VC[0])
DMA[lane].DEST[1] = Event Builder Batcher (super-frame)
DMA[lane].DEST[1].DEST[0] = XPM Trigger Message (sub-frame)
DMA[lane].DEST[1].DEST[1] = XPM Transition Message (sub-frame)
DMA[lane].DEST[1].DEST[2] = XPM Timing Message (sub-frame)
DMA[lane].DEST[1].DEST[3] = PGP.Lane[0] Camera Image (sub-frame)
DMA[lane].DEST[1].DEST[4] = PGP.Lane[1] Camera Image (sub-frame)
DMA[lane].DEST[1].DEST[5] = PGP.Lane[2] Camera Image (sub-frame)
DMA[lane].DEST[1].DEST[6] = PGP.Lane[3] Camera Image (sub-frame)
DMA[lane].DEST[2] = PseudoScope (PGP.Lane[0].VC[2])
DMA[lane].DEST[3] = Slow ADC Monitoring (PGP.Lane[0].VC[3])
DMA[lane].DEST[255:4] = Unused
```

<!--- ######################################################## -->

# How to build the PCIe firmware

1) Setup Xilinx licensing
```
$ source lcls2-epix-hr-pcie/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd lcls2-epix-hr-pcie/firmware/targets/SlacPgpCardG4/Lcls2EpixHrSlacPgpCardG4Pgp4_6Gbps/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ######################################################## -->

# How to load the driver

```
# Confirm that you have the board the computer with VID=1a4a ("SLAC") and PID=2030 ("AXI Stream DAQ")
$ lspci -nn | grep SLAC
04:00.0 Signal processing controller [1180]: SLAC National Accelerator Lab TID-AIR AXI Stream DAQ PCIe card [1a4a:2030]

# Clone the driver github repo:
$ git clone --recursive https://github.com/slaclab/aes-stream-drivers

# Go to the driver directory
$ cd aes-stream-drivers/data_dev/driver/

# Build the driver
$ make

# Load the driver
$ sudo /sbin/insmod ./datadev.ko cfgSize=0x50000 cfgRxCount=256 cfgTxCount=16

# Give appropriate group/permissions
$ sudo chmod 666 /dev/datadev*

# Check for the loaded device
$ cat /proc/datadev0

```

<!--- ######################################################## -->

# How to install the Rogue With miniforge

> https://slaclab.github.io/rogue/installing/miniforge.html

<!--- ######################################################## -->

# XPM Triggering Documentation

https://docs.google.com/document/d/1B_sIkk9Fxsw2EjOBpGVFpfCCWoIiOJoVGTrkTshZfew/edit?usp=sharing

<!--- ######################################################## -->

# How to reprogram the PCIe firmware via Rogue software

1) Setup the rogue environment
```
$ cd lcls2-epix-hr-pcie/software
$ source setup_env_slac.sh
```

2) Run the PCIe firmware update script:
```
$ python scripts/updatePcieFpga.py --path <PATH_TO_IMAGE_DIR>
```
where <PATH_TO_IMAGE_DIR> is path to image directory (example: ../firmware/targets/ClinkKcu1500Pgp2b/images/)

3) Reboot the computer
```
sudo reboot
```

<!--- ######################################################## -->

# How to run the Rogue GUI

1) Setup the rogue environment
```
$ cd lcls2-epix-hr-pcie/software
$ source setup_env_slac.sh
```

2) Lauch the GUI:
```
$ python scripts/devGui --pgp4 IS_PGP4_BOOL
```

# Example of starting up KCU1500 with PGP4 and stand alone mode (locally generated timing)
```
$ python scripts/devGui.py --pcieBoardType Kcu1500 --yamlFileLclsII config/defaults_LCLS-II.yml --standAloneMode 1
Then execute the StartRun() command to start the triggering
```

<!--- ######################################################## -->

