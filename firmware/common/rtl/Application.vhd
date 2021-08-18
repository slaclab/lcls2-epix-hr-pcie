-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- This file is part of 'lcls2-epix-hr-pcie'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'lcls2-epix-hr-pcie', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

entity Application is
   generic (
      TPD_G             : time             := 1 ns;
      AXI_BASE_ADDR_G   : slv(31 downto 0) := x"00C0_0000";
      DMA_AXIS_CONFIG_G : AxiStreamConfigType);
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk              : in  sl;
      axilRst              : in  sl;
      axilReadMaster       : in  AxiLiteReadMasterType;
      axilReadSlave        : out AxiLiteReadSlaveType;
      axilWriteMaster      : in  AxiLiteWriteMasterType;
      axilWriteSlave       : out AxiLiteWriteSlaveType;
      -- PGP Streams (axilClk domain)
      pgpIbMasters         : out AxiStreamMasterArray(3 downto 0);
      pgpIbSlaves          : in  AxiStreamSlaveArray(3 downto 0);
      pgpObMasters         : in  AxiStreamQuadMasterArray(3 downto 0);
      pgpObSlaves          : out AxiStreamQuadSlaveArray(3 downto 0);
      -- Trigger Event streams (axilClk domain)
      eventTrigMsgMaster   : in  AxiStreamMasterType;
      eventTrigMsgSlave    : out AxiStreamSlaveType;
      eventTimingMsgMaster : in  AxiStreamMasterType;
      eventTimingMsgSlave  : out AxiStreamSlaveType;
      -- DMA Interface (dmaClk domain)
      dmaClk               : in  sl;
      dmaRst               : in  sl;
      dmaIbMaster          : out AxiStreamMasterType;
      dmaIbSlave           : in  AxiStreamSlaveType;
      dmaObMaster          : in  AxiStreamMasterType;
      dmaObSlave           : out AxiStreamSlaveType);
end Application;

architecture mapping of Application is

   signal dataMasters : AxiStreamQuadMasterType;
   signal dataSlaves  : AxiStreamQuadSlaveType;

   signal eventMaster : AxiStreamMasterType;
   signal eventSlave  : AxiStreamSlaveType;

   signal appObMasters : AxiStreamQuadMasterType;
   signal appObSlaves  : AxiStreamQuadSlaveType;

   signal appObMaster : AxiStreamMasterType;
   signal appObSlave  : AxiStreamSlaveType;

begin

   --------------------
   -- Application Lanes
   --------------------
   GEN_VEC :
   for i in 3 downto 0 generate

      U_ImageBuffer : entity surf.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            INT_PIPE_STAGES_G   => 1,
            PIPE_STAGES_G       => 1,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 1,
            -- FIFO configurations
            MEMORY_TYPE_G       => "block",
            GEN_SYNC_FIFO_G     => true,
            INT_WIDTH_SELECT_G  => "CUSTOM",
            INT_DATA_WIDTH_G    => 8,   -- 64-bit
            FIFO_ADDR_WIDTH_G   => 9,   -- 512 sample = 2^9
            CASCADE_SIZE_G      => 16,  -- 2^9 x 64-bit x 16 cascade = 524kb buffer
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
            MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
         port map (
            -- Slave Port
            sAxisClk    => axilClk,
            sAxisRst    => axilRst,
            sAxisMaster => pgpObMasters(i)(1),  -- VC[1]
            sAxisSlave  => pgpObSlaves(i)(1),   -- VC[1]
            -- Master Port
            mAxisClk    => axilClk,
            mAxisRst    => axilRst,
            mAxisMaster => dataMasters(i),
            mAxisSlave  => dataSlaves(i));

      BASE_LANE : if (i = 0) generate

         -----------------------
         -- DMA to HW ASYNC FIFO
         -----------------------
         U_DMA_to_HW : entity surf.AxiStreamFifoV2
            generic map (
               -- General Configurations
               TPD_G               => TPD_G,
               INT_PIPE_STAGES_G   => 1,
               PIPE_STAGES_G       => 0,
               SLAVE_READY_EN_G    => true,
               VALID_THOLD_G       => 1,
               -- FIFO configurations
               MEMORY_TYPE_G       => "block",
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               -- AXI Stream Port Configurations
               SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
               MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
            port map (
               -- Slave Port
               sAxisClk    => dmaClk,
               sAxisRst    => dmaRst,
               sAxisMaster => dmaObMaster,
               sAxisSlave  => dmaObSlave,
               -- Master Port
               mAxisClk    => axilClk,
               mAxisRst    => axilRst,
               mAxisMaster => pgpIbMasters(0),
               mAxisSlave  => pgpIbSlaves(0));

         --------------
         -- VC[0] Paths
         --------------
         appObMasters(0)   <= pgpObMasters(0)(0);
         pgpObSlaves(0)(0) <= appObSlaves(0);

         --------------
         -- VC[2] Paths
         --------------
         appObMasters(2)   <= pgpObMasters(0)(2);
         pgpObSlaves(0)(2) <= appObSlaves(2);

         --------------
         -- VC[3] Paths
         --------------
         appObMasters(3)   <= pgpObMasters(0)(3);
         pgpObSlaves(0)(3) <= appObSlaves(3);

      end generate;

      EXTENDED_LANE : if (i /= 0) generate

         ----------------------------
         -- Terminated unused streams
         ----------------------------
         pgpIbMasters(i)   <= AXI_STREAM_MASTER_INIT_C;
         pgpObSlaves(i)(0) <= AXI_STREAM_SLAVE_FORCE_C;
         pgpObSlaves(i)(2) <= AXI_STREAM_SLAVE_FORCE_C;
         pgpObSlaves(i)(3) <= AXI_STREAM_SLAVE_FORCE_C;

      end generate;

   end generate GEN_VEC;

   ----------------------------------
   -- Event Builder
   ----------------------------------
   U_EventBuilder : entity surf.AxiStreamBatcherEventBuilder
      generic map (
         TPD_G          => TPD_G,
         NUM_SLAVES_G   => 6,
         MODE_G         => "ROUTED",
         TDEST_ROUTES_G => (
            0           => "0000000-",  -- Trig on 0x0, Event on 0x1
            1           => x"02",       -- Map Timing          to TDEST 0x2
            2           => x"03",       -- Map PGP[Lane0][VC1] to TDEST 0x3
            3           => x"04",       -- Map PGP[Lane1][VC1] to TDEST 0x4
            4           => x"05",       -- Map PGP[Lane2][VC1] to TDEST 0x5
            5           => x"06"),      -- Map PGP[Lane3][VC1] to TDEST 0x6
         TRANS_TDEST_G  => X"01",
         AXIS_CONFIG_G  => DMA_AXIS_CONFIG_G)
      port map (
         -- Clock and Reset
         axisClk         => axilClk,
         axisRst         => axilRst,
         -- AXI-Lite Interface (axisClk domain)
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- AXIS Inbound Master Interfaces
         sAxisMasters(0) => eventTrigMsgMaster,
         sAxisMasters(1) => eventTimingMsgMaster,
         sAxisMasters(2) => dataMasters(0),
         sAxisMasters(3) => dataMasters(1),
         sAxisMasters(4) => dataMasters(2),
         sAxisMasters(5) => dataMasters(3),
         -- AXIS Inbound Slave Interfaces
         sAxisSlaves(0)  => eventTrigMsgSlave,
         sAxisSlaves(1)  => eventTimingMsgSlave,
         sAxisSlaves(2)  => dataSlaves(0),
         sAxisSlaves(3)  => dataSlaves(1),
         sAxisSlaves(4)  => dataSlaves(2),
         sAxisSlaves(5)  => dataSlaves(3),
         -- AXIS Outbound Interfaces
         mAxisMaster     => eventMaster,
         mAxisSlave      => eventSlave);

   -------------------------------------
   -- Burst FIFO before interleaving MUX
   -------------------------------------
   U_FIFO : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 128,  -- Hold until enough to burst into the interleaving MUX
         VALID_BURST_MODE_G  => true,
         -- FIFO configurations
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => axilClk,
         sAxisRst    => axilRst,
         sAxisMaster => eventMaster,
         sAxisSlave  => eventSlave,
         -- Master Port
         mAxisClk    => axilClk,
         mAxisRst    => axilRst,
         mAxisMaster => appObMasters(1),
         mAxisSlave  => appObSlaves(1));

   -----------------
   -- AXI Stream MUX
   -----------------
   U_Mux : entity surf.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => 4,
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => true,
         ILEAVE_REARB_G       => 128,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Inbound Ports
         sAxisMasters => appObMasters,
         sAxisSlaves  => appObSlaves,
         -- Outbound Port
         mAxisMaster  => appObMaster,
         mAxisSlave   => appObSlave);

   -----------------------
   -- App to DMA ASYNC FIFO
   -----------------------
   U_APP_to_DMA : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => DMA_AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => axilClk,
         sAxisRst    => axilRst,
         sAxisMaster => appObMaster,
         sAxisSlave  => appObSlave,
         -- Master Port
         mAxisClk    => dmaClk,
         mAxisRst    => dmaRst,
         mAxisMaster => dmaIbMaster,
         mAxisSlave  => dmaIbSlave);

end mapping;
