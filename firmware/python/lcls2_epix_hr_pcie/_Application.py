#-----------------------------------------------------------------------------
# This file is part of the 'lcls2-epix-hr-pcie'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'lcls2-epix-hr-pcie', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

import surf.protocols.batcher as batcher

class Application(pr.Device):
    def __init__(   self,
            name        = "Application",
            description = "Application Container",
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        ###################################################
        # SLAVE[INDEX=0][TDEST=0] = XPM Trigger Message
        # SLAVE[INDEX=0][TDEST=1] = XPM Event Transition Message
        # SLAVE[INDEX=1][TDEST=2] = XPM Timing Message
        # SLAVE[INDEX=2][TDEST=3] = PGP.Lane[0].CameraImage
        # SLAVE[INDEX=3][TDEST=4] = PGP.Lane[1].CameraImage
        # SLAVE[INDEX=4][TDEST=5] = PGP.Lane[2].CameraImage
        # SLAVE[INDEX=5][TDEST=6] = PGP.Lane[3].CameraImage
        ###################################################
        self.add(batcher.AxiStreamBatcherEventBuilder(
            name         = 'EventBuilder',
            offset       = 0x0,
            numberSlaves = 6, # Total number of slave indexes (not necessarily same as TDEST)
            tickUnit     = '156.25MHz',
            expand       = True,
        ))
