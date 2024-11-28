-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Thu Oct 24 14:35:16 2024
-- Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top fifo_generator_64in_64out_D128_1 -prefix
--               fifo_generator_64in_64out_D128_1_ fifo_generator_64in_64out_D128_stub.vhdl
-- Design      : fifo_generator_64in_64out_D128
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffv900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_generator_64in_64out_D128_1 is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end fifo_generator_64in_64out_D128_1;

architecture stub of fifo_generator_64in_64out_D128_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[63:0],wr_en,rd_en,dout[63:0],full,empty,data_count[7:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_5,Vivado 2020.2";
begin
end;
