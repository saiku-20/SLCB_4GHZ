// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Tue Oct 29 09:38:00 2024
// Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {e:/FPGA
//               Project/SLCB_4GHZ/SLCB_4GHZ.gen/sources_1/ip/fifo_generator_64in_64out_D128/fifo_generator_64in_64out_D128_stub.v}
// Design      : fifo_generator_64in_64out_D128
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffv900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module fifo_generator_64in_64out_D128(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  almost_full, empty, almost_empty, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[63:0],wr_en,rd_en,dout[63:0],full,almost_full,empty,almost_empty,wr_rst_busy,rd_rst_busy" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [63:0]dout;
  output full;
  output almost_full;
  output empty;
  output almost_empty;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
