#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Camera link gateway', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import os
import sys
import argparse
import importlib
import rogue
import pyrogue
import pyrogue.pydm

if __name__ == "__main__":

#################################################################

    # Set the argument parser
    parser = argparse.ArgumentParser()

    # Convert str to bool
    argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

    # Add arguments
    parser.add_argument(
        "--dev",
        type     = str,
        required = False,
        default  = '/dev/datadev_0',
        help     = "path to device",
    )

    parser.add_argument(
        "--pgp4",
        type     = argBool,
        required = False,
        default  = True, # Default: PGPv4
        help     = "true = PGPv4, false = PGP2b",
    )

    parser.add_argument(
        "--enLclsI",
        type     = argBool,
        required = False,
        default  = True, # Default: Enable LCLS-I hardware registers
        help     = "Enable LCLS-I hardware registers",
    )

    parser.add_argument(
        "--enLclsII",
        type     = argBool,
        required = False,
        default  = True, # Default: Enable LCLS-II hardware registers
        help     = "Enable LCLS-II hardware registers",
    )

    parser.add_argument(
        "--yamlFileLclsI",
        type     = str,
        required = False,
        default  = None, # Default: None = bypassing YAML load
        help     = "Sets the default LCLS-I YAML configuration file to be loaded at the root.start()",
    )

    parser.add_argument(
        "--yamlFileLclsII",
        type     = str,
        required = False,
        default  = None, # Default: None = bypassing YAML load
        help     = "Sets the default LCLS-II YAML configuration file to be loaded at the root.start()",
    )

    parser.add_argument(
        "--startupMode",
        type     = argBool,
        required = False,
        default  = True, # Default: True = LCLS-II timing mode
        help     = "False = LCLS-I timing mode, True = LCLS-II timing mode",
    )

    parser.add_argument(
        "--standAloneMode",
        type     = argBool,
        required = False,
        default  = False, # Default: False = using fiber timing
        help     = "False = using fiber timing, True = locally generated timing",
    )

    parser.add_argument(
        "--pollEn",
        type     = argBool,
        required = False,
        default  = True,
        help     = "Enable auto-polling",
    )

    parser.add_argument(
        "--initRead",
        type     = argBool,
        required = False,
        default  = True,
        help     = "Enable read all variables at start",
    )

    parser.add_argument(
        "--serverPort",
        type     = int,
        required = False,
        default  = 9099,
        help     = "Zeromq server port",
    )

    parser.add_argument(
        "--releaseZip",
        type     = str,
        required = False,
        default  = None,
        help     = "Sets the default YAML configuration file to be loaded at the root.start()",
    )

    parser.add_argument(
        "--guiType",
        type     = str,
        required = False,
        default  = 'PyDM',
        help     = "Sets the GUI type (PyDM or PyQt)",
    )

    parser.add_argument(
        "--pcieBoardType",
        type     = str,
        required = False,
        default  = None,
        help     = "define the type of PCIe card, used to select I2C mapping. Options: [none or SlacPgpCardG4 or Kcu1500]",
    )


    # Get the arguments
    args = parser.parse_args()

    #################################################################

    # First see if submodule packages are already in the python path
    try:
        import axi_pcie_core
        import lcls2_pgp_fw_lib
        import lcls_timing_core
        import l2si_core
        import surf

    # Otherwise assume it is relative in a standard development directory structure
    except:

        # Check for release zip file path
        if args.releaseZip is not None:
            pyrogue.addLibraryPath(args.releaseZip + '/python')
        else:
            import setupLibPaths

    # Load the cameralink-gateway package
    import lcls2_epix_hr_pcie

    #################################################################

    with lcls2_epix_hr_pcie.DevRoot(
            dev            = args.dev,
            pollEn         = args.pollEn,
            initRead       = args.initRead,
            pgp4           = args.pgp4,
            enLclsI        = (args.enLclsII or not args.startupMode),
            enLclsII       = (args.enLclsII or args.startupMode),
            yamlFileLclsI  = args.yamlFileLclsI,
            yamlFileLclsII = args.yamlFileLclsII,
            startupMode    = args.startupMode,
            standAloneMode = args.standAloneMode,
            pcieBoardType  = args.pcieBoardType,
            serverPort = args.serverPort
        ) as root:

        ######################
        # Development PyDM GUI
        ######################
        if (args.guiType == 'PyDM'):
            print("Starting PyDM")
            pyrogue.pydm.runPyDM(
                serverList  = root.zmqServer.address,
                sizeX=700,
                sizeY=800,
            )

        #################
        # Legacy PyQT GUI
        #################
        elif (args.guiType == 'PyQt'):
            print('Not supported anymore')

        ####################
        # Undefined GUI type
        ####################
        else:
            raise ValueError("Invalid GUI type (%s)" % (args.guiType) )

    #################################################################
