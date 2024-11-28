-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Wed Sep 25 18:46:52 2024
-- Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {e:/FPGA
--               Project/SLCB_4GHZ/aurora_64b66b_Master_ex/aurora_64b66b_Master_ex.gen/sources_1/ip/aurora_64b66b_reg_slice_0/aurora_64b66b_reg_slice_0_stub.vhdl}
-- Design      : aurora_64b66b_reg_slice_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffv900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aurora_64b66b_reg_slice_0 is
  Port ( 
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_tlast : out STD_LOGIC
  );

end aurora_64b66b_reg_slice_0;

architecture stub of aurora_64b66b_reg_slice_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[63:0],s_axis_tkeep[7:0],s_axis_tlast,m_axis_tvalid,m_axis_tready,m_axis_tdata[63:0],m_axis_tkeep[7:0],m_axis_tlast";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axis_register_slice_v1_1_22_axis_register_slice,Vivado 2020.2";
begin
end;
