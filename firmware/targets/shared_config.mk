# Define Firmware Version: v1.4.0.0
export PRJ_VERSION = 0x01040000

#Use PGP4 Timing
export INCLUDE_PGP4_6G = 1

# Define release
ifndef RELEASE
export RELEASE = lcls2_epix_hr_pcie
endif
