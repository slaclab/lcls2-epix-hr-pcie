export TARGET_DIRS  = $(PWD)/targets/XilinxC1100/Lcls2EpixHrXilinxC1100Pgp4_6Gbps \
                      $(PWD)/targets/XilinxC1100/Lcls2EpixHrXilinxC1100Pgp4_10Gbps \
                      $(PWD)/targets/XilinxKcu1500/Lcls2EpixHrXilinxKcu1500Pgp4_6Gbps \
                      $(PWD)/targets/XilinxKcu1500/Lcls2EpixHrXilinxKcu1500Pgp4_10Gbps

.PHONY: all build clean

# Default
all: build

# Check variables
test:
	@echo TARGET_DIRS:
	@echo -e "$(foreach ARG,$(TARGET_DIRS),\t$(ARG)\n)"

# Clean all firmware builds
clean:
	for i in $(TARGET_DIRS); do \
      cd $$i; make clean; \
   done

# Build targets
build:
	for i in $(TARGET_DIRS); do \
      echo $$i; cd $$i; make clean; rm -rf images; make; \
   done
