`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/12 11:17:25
// Design Name: 
// Module Name: aurora_Process
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aurora_Process#
(
    parameter            DATA_WIDTH         = 64 // DATA bus width
)
( 
    input                      RESET,
    input                      CLK,
                               //tx data from user ram
    input                      CAP_EN          ,
    input  [63:0]              IN_CAP_DATA     ,
                               //tx data to aurora
    output [0:(DATA_WIDTH-1)]  s_axi_tx_tdata,
    output                     s_axi_tx_tvalid,
    input                      s_axi_tx_tready,
                               //rx data to user ram
    output                     EMPTY           ,
    output                     ALEMPTY         ,
    input                      RD_DATA_EN      ,
    output  [63:0]             O_CAP_DATA      ,
                               //rx data from aurora
    input                      m_axi_rx_tvalid    ,
    input   [0:63]             m_axi_rx_tdata            ,

    input                      USER_CLK        ,
    input                      CHANNEL_UP
);
    //TX
wire  [0:63]  tx_d_i;
wire          tx_src_rdy_n_i;
wire          tx_dst_rdy_n_i;
aurora_64b66b_TX_Fifo_64in_64out 
u_aurora_64b66b_TX_Fifo_64in_64out(
   .RESET        (RESET),
   .CLK          (CLK),

   .CAP_EN       (CAP_EN),
   .IN_CAP_DATA  (IN_CAP_DATA),

   .TX_D         (tx_d_i),
   .TX_SRC_RDY_N (tx_src_rdy_n_i),
   .TX_DST_RDY_N (tx_dst_rdy_n_i),

   .USER_CLK     (USER_CLK),
   .CHANNEL_UP   (CHANNEL_UP)
 ) ;
  
aurora_64b66b_LL_TO_AXI #
     (
        .DATA_WIDTH(64),
        .STRB_WIDTH(8),
        .USE_4_NFC (0),
        .REM_WIDTH (3)
     )
     frame_gen_ll_to_axi_data
     (
      // LocalLink input Interface
      .LL_IP_DATA(tx_d_i),
      .LL_IP_SOF_N(),
      .LL_IP_EOF_N(),
      .LL_IP_REM(),
      .LL_IP_SRC_RDY_N(tx_src_rdy_n_i),
      .LL_OP_DST_RDY_N(tx_dst_rdy_n_i),

      // AXI4-S output signals
      .AXI4_S_OP_TVALID(s_axi_tx_tvalid),
      .AXI4_S_OP_TDATA(s_axi_tx_tdata),
      .AXI4_S_OP_TKEEP(),
      .AXI4_S_OP_TLAST(),
      .AXI4_S_IP_TREADY(s_axi_tx_tready)
     );
     
     //rx
     wire [0:63] rx_d_i;
     wire        rx_src_rdy_n_i;
     
    aurora_64b66b_RX_Fifo_64in_64out 
    u_aurora_64b66b_RX_Fifo_64in_64out(
    .RESET        (RESET) ,
    .CLK          (CLK) ,
                  
    .EMPTY        (EMPTY) ,
    .ALEMPTY      (ALEMPTY) ,
    .RD_DATA_EN   (RD_DATA_EN) ,
    .O_CAP_DATA   (O_CAP_DATA) ,
                  
    .RX_D         (rx_d_i) ,
    .RX_SRC_RDY_N   (rx_src_rdy_n_i) ,
                  
    .USER_CLK     (USER_CLK) ,
    .CHANNEL_UP   (CHANNEL_UP)  
    
    );
     
 aurora_64b66b_AXI_TO_LL#
   (
        .DATA_WIDTH(64),
        .STRB_WIDTH(8),
        .ISUFC(0),
        .REM_WIDTH (3)
     )
   frame_chk_axi_to_ll_data
   (
        // AXI4-S input signals
        .AXI4_S_IP_TX_TVALID(m_axi_rx_tvalid),
        .AXI4_S_IP_TX_TREADY(),
        .AXI4_S_IP_TX_TDATA(m_axi_rx_tdata),
        .AXI4_S_IP_TX_TKEEP(8'd0),
        .AXI4_S_IP_TX_TLAST(1'b0),

        // LocalLink output Interface
        .LL_OP_DATA(rx_d_i),
        .LL_OP_SOF_N(),
        .LL_OP_EOF_N() ,
        .LL_OP_REM() ,
        .LL_OP_SRC_RDY_N(rx_src_rdy_n_i),
        .LL_IP_DST_RDY_N(1'b0),

        // System Interface
        .USER_CLK(USER_CLK),
        .RESET(RESET),
        .CHANNEL_UP(CHANNEL_UP)
   ); 
   
endmodule
