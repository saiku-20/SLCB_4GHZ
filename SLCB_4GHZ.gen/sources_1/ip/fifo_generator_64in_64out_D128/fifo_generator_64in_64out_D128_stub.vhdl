-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Tue Oct 29 09:38:00 2024
-- Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {e:/FPGA
--               Project/SLCB_4GHZ/SLCB_4GHZ.gen/sources_1/ip/fifo_generator_64in_64out_D128/fifo_generator_64in_64out_D128_stub.vhdl}
-- Design      : fifo_generator_64in_64out_D128
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffv900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_generator_64in_64out_D128 is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    full : out STD_LOGIC;
    almost_full : out STD_LOGIC;
    empty : out STD_LOGIC;
    almost_empty : out STD_LOGIC;
    wr_rst_busy : out STD_LOGIC;
    rd_rst_busy : out STD_LOGIC
  );

end fifo_generator_64in_64out_D128;

architecture stub of fifo_generator_64in_64out_D128 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[63:0],wr_en,rd_en,dout[63:0],full,almost_full,empty,almost_empty,wr_rst_busy,rd_rst_busy";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_5,Vivado 2020.2";
begin
end;
