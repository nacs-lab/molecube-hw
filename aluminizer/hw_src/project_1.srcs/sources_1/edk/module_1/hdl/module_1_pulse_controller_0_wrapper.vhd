-------------------------------------------------------------------------------
-- module_1_pulse_controller_0_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library pulse_controller_v4_00_b;
use pulse_controller_v4_00_b.all;

entity module_1_pulse_controller_0_wrapper is
  port (
    S_AXI_ACLK : in std_logic;
    S_AXI_ARESETN : in std_logic;
    S_AXI_AWADDR : in std_logic_vector(31 downto 0);
    S_AXI_AWVALID : in std_logic;
    S_AXI_WDATA : in std_logic_vector(31 downto 0);
    S_AXI_WSTRB : in std_logic_vector(3 downto 0);
    S_AXI_WVALID : in std_logic;
    S_AXI_BREADY : in std_logic;
    S_AXI_ARADDR : in std_logic_vector(31 downto 0);
    S_AXI_ARVALID : in std_logic;
    S_AXI_RREADY : in std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA : out std_logic_vector(31 downto 0);
    S_AXI_RRESP : out std_logic_vector(1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_WREADY : out std_logic;
    S_AXI_BRESP : out std_logic_vector(1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_AWREADY : out std_logic;
    pulse_io : out std_logic_vector(31 downto 0);
    dds_addr : out std_logic_vector(6 downto 0);
    dds_control : out std_logic_vector(3 downto 0);
    dds_addr2 : out std_logic_vector(6 downto 0);
    dds_control2 : out std_logic_vector(3 downto 0);
    dds_cs : out std_logic_vector(21 downto 0);
    counter_in : in std_logic_vector(0 to 0);
    sync_in : in std_logic;
    clock_out : out std_logic;
    dds_data_I : in std_logic_vector(15 downto 0);
    dds_data_O : out std_logic_vector(15 downto 0);
    dds_data_T : out std_logic;
    dds_data2_I : in std_logic_vector(15 downto 0);
    dds_data2_O : out std_logic_vector(15 downto 0);
    dds_data2_T : out std_logic
  );
end module_1_pulse_controller_0_wrapper;

architecture STRUCTURE of module_1_pulse_controller_0_wrapper is

  component pulse_controller is
    generic (
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_S_AXI_ADDR_WIDTH : INTEGER;
      C_S_AXI_MIN_SIZE : std_logic_vector;
      C_USE_WSTRB : INTEGER;
      C_DPHASE_TIMEOUT : INTEGER;
      C_BASEADDR : std_logic_vector;
      C_HIGHADDR : std_logic_vector;
      C_FAMILY : STRING;
      C_NUM_REG : INTEGER;
      C_NUM_MEM : INTEGER;
      C_SLV_AWIDTH : INTEGER;
      C_SLV_DWIDTH : INTEGER;
      U_PULSE_WIDTH : INTEGER;
      N_DDS : INTEGER;
      U_DDS_DATA_WIDTH : INTEGER;
      U_DDS_ADDR_WIDTH : INTEGER;
      U_DDS_CTRL_WIDTH : INTEGER;
      N_COUNTER : INTEGER
    );
    port (
      S_AXI_ACLK : in std_logic;
      S_AXI_ARESETN : in std_logic;
      S_AXI_AWADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_AWVALID : in std_logic;
      S_AXI_WDATA : in std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_WSTRB : in std_logic_vector(((C_S_AXI_DATA_WIDTH/8)-1) downto 0);
      S_AXI_WVALID : in std_logic;
      S_AXI_BREADY : in std_logic;
      S_AXI_ARADDR : in std_logic_vector((C_S_AXI_ADDR_WIDTH-1) downto 0);
      S_AXI_ARVALID : in std_logic;
      S_AXI_RREADY : in std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA : out std_logic_vector((C_S_AXI_DATA_WIDTH-1) downto 0);
      S_AXI_RRESP : out std_logic_vector(1 downto 0);
      S_AXI_RVALID : out std_logic;
      S_AXI_WREADY : out std_logic;
      S_AXI_BRESP : out std_logic_vector(1 downto 0);
      S_AXI_BVALID : out std_logic;
      S_AXI_AWREADY : out std_logic;
      pulse_io : out std_logic_vector((U_PULSE_WIDTH-1) downto 0);
      dds_addr : out std_logic_vector((U_DDS_ADDR_WIDTH-1) downto 0);
      dds_control : out std_logic_vector((U_DDS_CTRL_WIDTH-1) downto 0);
      dds_addr2 : out std_logic_vector((U_DDS_ADDR_WIDTH-1) downto 0);
      dds_control2 : out std_logic_vector((U_DDS_CTRL_WIDTH-1) downto 0);
      dds_cs : out std_logic_vector((N_DDS-1) downto 0);
      counter_in : in std_logic_vector((N_COUNTER-1) to 0);
      sync_in : in std_logic;
      clock_out : out std_logic;
      dds_data_I : in std_logic_vector((U_DDS_DATA_WIDTH-1) downto 0);
      dds_data_O : out std_logic_vector((U_DDS_DATA_WIDTH-1) downto 0);
      dds_data_T : out std_logic;
      dds_data2_I : in std_logic_vector((U_DDS_DATA_WIDTH-1) downto 0);
      dds_data2_O : out std_logic_vector((U_DDS_DATA_WIDTH-1) downto 0);
      dds_data2_T : out std_logic
    );
  end component;

begin

  pulse_controller_0 : pulse_controller
    generic map (
      C_S_AXI_DATA_WIDTH => 32,
      C_S_AXI_ADDR_WIDTH => 32,
      C_S_AXI_MIN_SIZE => X"000001ff",
      C_USE_WSTRB => 0,
      C_DPHASE_TIMEOUT => 0,
      C_BASEADDR => X"73000000",
      C_HIGHADDR => X"7300ffff",
      C_FAMILY => "zynq",
      C_NUM_REG => 1,
      C_NUM_MEM => 1,
      C_SLV_AWIDTH => 32,
      C_SLV_DWIDTH => 32,
      U_PULSE_WIDTH => 32,
      N_DDS => 22,
      U_DDS_DATA_WIDTH => 16,
      U_DDS_ADDR_WIDTH => 7,
      U_DDS_CTRL_WIDTH => 4,
      N_COUNTER => 1
    )
    port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR => S_AXI_AWADDR,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      pulse_io => pulse_io,
      dds_addr => dds_addr,
      dds_control => dds_control,
      dds_addr2 => dds_addr2,
      dds_control2 => dds_control2,
      dds_cs => dds_cs,
      counter_in => counter_in,
      sync_in => sync_in,
      clock_out => clock_out,
      dds_data_I => dds_data_I,
      dds_data_O => dds_data_O,
      dds_data_T => dds_data_T,
      dds_data2_I => dds_data2_I,
      dds_data2_O => dds_data2_O,
      dds_data2_T => dds_data2_T
    );

end architecture STRUCTURE;

