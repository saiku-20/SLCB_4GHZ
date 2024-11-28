// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed Sep 25 18:47:40 2024
// Host        : DESKTOP-LJPGHQG running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {e:/FPGA
//               Project/SLCB_4GHZ/aurora_64b66b_Master_ex/aurora_64b66b_Master_ex.gen/sources_1/ip/aurora_64b66b_reg_slice_2/aurora_64b66b_reg_slice_2_stub.v}
// Design      : aurora_64b66b_reg_slice_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffv900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axis_register_slice_v1_1_22_axis_register_slice,Vivado 2020.2" *)
module aurora_64b66b_reg_slice_2(aclk, aresetn, s_axis_tvalid, s_axis_tready, 
  s_axis_tdata, s_axis_tuser, m_axis_tvalid, m_axis_tready, m_axis_tdata, m_axis_tuser)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_tvalid,s_axis_tready,s_axis_tdata[63:0],s_axis_tuser[4:0],m_axis_tvalid,m_axis_tready,m_axis_tdata[63:0],m_axis_tuser[4:0]" */;
  input aclk;
  input aresetn;
  input s_axis_tvalid;
  output s_axis_tready;
  input [63:0]s_axis_tdata;
  input [4:0]s_axis_tuser;
  output m_axis_tvalid;
  input m_axis_tready;
  output [63:0]m_axis_tdata;
  output [4:0]m_axis_tuser;
endmodule
