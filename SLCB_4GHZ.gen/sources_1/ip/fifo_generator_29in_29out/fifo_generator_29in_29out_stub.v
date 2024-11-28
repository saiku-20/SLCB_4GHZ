// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Tue Oct 29 09:00:43 2024
// Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {e:/FPGA
//               Project/SLCB_4GHZ/SLCB_4GHZ.gen/sources_1/ip/fifo_generator_29in_29out/fifo_generator_29in_29out_stub.v}
// Design      : fifo_generator_29in_29out
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffv900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module fifo_generator_29in_29out(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[28:0],wr_en,rd_en,dout[28:0],full,empty,data_count[10:0]" */;
  input clk;
  input srst;
  input [28:0]din;
  input wr_en;
  input rd_en;
  output [28:0]dout;
  output full;
  output empty;
  output [10:0]data_count;
endmodule
