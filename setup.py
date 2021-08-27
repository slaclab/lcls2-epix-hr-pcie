from setuptools import setup

# use softlinks to make the various "board-support-package" submodules
# look like subpackages.  Then __init__.py will modify
# sys.path so that the correct "local" versions of surf etc. are
# picked up.  A better approach would be using relative imports
# in the submodules, but that's more work.  -cpo

setup(
    name = 'lcls2_epix_hr_pcie',
    description = 'LCLS II pgp package',
    packages = [
        'lcls2_epix_hr_pcie',
        'lcls2_epix_hr_pcie.axipcie',
        'lcls2_epix_hr_pcie.l2si_core',
        'lcls2_epix_hr_pcie.LclsTimingCore',
        'lcls2_epix_hr_pcie.lcls2_pgp_fw_lib.shared',
        'lcls2_epix_hr_pcie.lcls2_pgp_fw_lib',
        'lcls2_epix_hr_pcie.surf',
        'lcls2_epix_hr_pcie.surf.axi',
        'lcls2_epix_hr_pcie.surf.devices',
        'lcls2_epix_hr_pcie.surf.devices/analog_devices',
        'lcls2_epix_hr_pcie.surf.devices/cypress',
        'lcls2_epix_hr_pcie.surf.devices/intel',
        'lcls2_epix_hr_pcie.surf.devices/linear',
        'lcls2_epix_hr_pcie.surf.devices/microchip',
        'lcls2_epix_hr_pcie.surf.devices/micron',
        'lcls2_epix_hr_pcie.surf.devices/nxp',
        'lcls2_epix_hr_pcie.surf.devices/silabs',
        'lcls2_epix_hr_pcie.surf.devices/ti',
        'lcls2_epix_hr_pcie.surf.devices/transceivers',
        'lcls2_epix_hr_pcie.surf.dsp',
        'lcls2_epix_hr_pcie.surf.dsp/fixed',
        'lcls2_epix_hr_pcie.surf.ethernet',
        'lcls2_epix_hr_pcie.surf.ethernet/gige',
        'lcls2_epix_hr_pcie.surf.ethernet/mac',
        'lcls2_epix_hr_pcie.surf.ethernet/ten_gig',
        'lcls2_epix_hr_pcie.surf.ethernet/udp',
        'lcls2_epix_hr_pcie.surf.ethernet/xaui',
        'lcls2_epix_hr_pcie.surf.misc',
        'lcls2_epix_hr_pcie.surf.protocols',
        'lcls2_epix_hr_pcie.surf.protocols/batcher',
        'lcls2_epix_hr_pcie.surf.protocols/clink',
        'lcls2_epix_hr_pcie.surf.protocols/htsp',
        'lcls2_epix_hr_pcie.surf.protocols/i2c',
        'lcls2_epix_hr_pcie.surf.protocols/jesd204b',
        'lcls2_epix_hr_pcie.surf.protocols/pgp',
        'lcls2_epix_hr_pcie.surf.protocols/rssi',
        'lcls2_epix_hr_pcie.surf.protocols/ssi',
        'lcls2_epix_hr_pcie.surf.protocols/ssp',
        'lcls2_epix_hr_pcie.surf.xilinx',
    ],
    package_dir = {
        'lcls2_epix_hr_pcie': 'firmware/python/lcls2_epix_hr_pcie',
        'lcls2_epix_hr_pcie.surf': 'firmware/submodules/surf/python/surf',
        'lcls2_epix_hr_pcie.axipcie': 'firmware/submodules/axi-pcie-core/python/axipcie',
        'lcls2_epix_hr_pcie.LclsTimingCore': 'firmware/submodules/lcls-timing-core/python/LclsTimingCore',
        'lcls2_epix_hr_pcie.lcls2_pgp_fw_lib': 'firmware/submodules/lcls2-pgp-fw-lib/python/lcls2_pgp_fw_lib',
        'lcls2_epix_hr_pcie.l2si_core': 'firmware/submodules/l2si-core/python/l2si_core'
    }
)
