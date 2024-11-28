`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/13 08:25:43
// Design Name: 
// Module Name: aurora_64b66b_FIFO_CTL
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
module aurora_64b66b_TX_Fifo_64in_64out(
    input           RESET           ,
    input           CLK             ,
    
    input           CAP_EN          ,
    input  [63:0]   IN_CAP_DATA     ,
    
    output  [0:63]   TX_D           ,
    output     reg  TX_SRC_RDY_N    ,
    input           TX_DST_RDY_N    ,
    
    input           USER_CLK        ,
    input           CHANNEL_UP
 ) ;
 
 wire reset_c;
 wire dly_data_xfer;
 reg [4:0] channel_up_cnt;
 wire W_tx_fifo_empty, W_tx_fifo_alempty;
 
 wire full_o;
 wire almost_full_o;
 wire wr_rst_busy;
 wire rd_rst_busy;
 wire [10:0] wr_data_count;
 wire [10:0] rd_data_count;
 
 
 always @(posedge USER_CLK)begin
    if(RESET)
        channel_up_cnt <= `DLY 5'd0;
    else if(CHANNEL_UP)
        if(&channel_up_cnt)
            channel_up_cnt <= `DLY channel_up_cnt;
        else
            channel_up_cnt <= `DLY channel_up_cnt + 1'b1;
    else
        channel_up_cnt <= `DLY 5'd0;
 end
 
 assign dly_data_xfer = (&channel_up_cnt);
 //channel up��ʱ�ȶ�һ��ʱ��
 assign reset_c = RESET || !dly_data_xfer;
 
 always @(posedge USER_CLK)begin
    if(reset_c)begin
        TX_SRC_RDY_N <= `DLY 1'b1;
    end
    else if(~W_tx_fifo_empty)begin
        TX_SRC_RDY_N <= `DLY ~TX_SRC_RDY_N;
    end
    else begin
        TX_SRC_RDY_N <= `DLY 1'b1;
    end
 end
 //1024 Version
 /*
 fifo_generator_64in_64out u_fifo_tx (
  .rst(reset_c),                    // input wire rst
  .wr_clk(CLK),              // input wire wr_clk
  .rd_clk(USER_CLK),              // input wire rd_clk
  .din(IN_CAP_DATA),                    // input wire [63 : 0] din
  .wr_en(CAP_EN),                // input wire wr_en
  .rd_en(~TX_SRC_RDY_N & ~TX_DST_RDY_N),                // input wire rd_en
  .dout(TX_D),                  // output wire [63 : 0] dout
  .full(full_o ),                  // output wire full
  .almost_full(almost_full_o ),    // output wire almost_full
  .empty(W_tx_fifo_empty),                // output wire empty
  .almost_empty(W_tx_fifo_alempty),  // output wire almost_empty
  .rd_data_count(rd_data_count),  // output wire [10 : 0] rd_data_count
  .wr_data_count(wr_data_count),  // output wire [10 : 0] wr_data_count
  .wr_rst_busy(wr_rst_busy),    // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)    // output wire rd_rst_busy
);*/
//128 Version
fifo_generator_64in_64out_D128 u_fifo_generator_64in_64out_D128 (
  .rst(reset_c),                    // input wire rst
  .wr_clk(CLK),              // input wire wr_clk
  .rd_clk(USER_CLK),              // input wire rd_clk
  .din(IN_CAP_DATA),                    // input wire [63 : 0] din
  .wr_en(CAP_EN),                // input wire wr_en
  .rd_en(~TX_SRC_RDY_N & ~TX_DST_RDY_N),                // input wire rd_en
  .dout(TX_D),                  // output wire [63 : 0] dout
  .full(full_o),                  // output wire full
  .almost_full(almost_full_o),    // output wire almost_full
  .empty(W_tx_fifo_empty),                // output wire empty
  .almost_empty(W_tx_fifo_alempty),  // output wire almost_empty
  .wr_rst_busy(wr_rst_busy),    // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)    // output wire rd_rst_busy
);

endmodule 

module aurora_64b66b_RX_Fifo_64in_64out(
    input           RESET           ,
    input           CLK             ,
    
    output          EMPTY           ,
    output          ALEMPTY         ,
    input           RD_DATA_EN      ,
    output  [63:0]  O_CAP_DATA      ,
    
    input   [0:63]  RX_D            ,
    input           RX_SRC_RDY_N    ,
    
    input           USER_CLK        ,
    input           CHANNEL_UP
    
    );
    
    reg [4:0]   channel_up_cnt      ;
    reg [0:63]        RX_D_SLACK    ;
    reg          RX_SRC_RDY_N_SLACK ;
    
    wire        dly_data_xfer       ;
    wire        reset_c             ;
    wire        data_valid_c        ;
    
    wire full_o;
    wire almost_full_o;
    wire wr_rst_busy;
    wire rd_rst_busy;
    wire [10:0] wr_data_count;
    wire [10:0] rd_data_count;
    //����һ��
    always @(posedge USER_CLK)begin
        RX_D_SLACK          <=    `DLY  RX_D;
        RX_SRC_RDY_N_SLACK  <=    `DLY  RX_SRC_RDY_N;
    end
    
    assign data_valid_c = (!RX_SRC_RDY_N_SLACK) & CHANNEL_UP;
    //channelup����һ��ʱ����˳����?
    always @(posedge USER_CLK)begin
     if(RESET)
         channel_up_cnt  <=  5'd0;
     else if(CHANNEL_UP)
         if(&channel_up_cnt)
             channel_up_cnt <= channel_up_cnt;
         else
             channel_up_cnt <= channel_up_cnt + 1'b1;
     else
         channel_up_cnt <= 5'd0;
    end
    
    assign dly_data_xfer = (&channel_up_cnt);
    assign reset_c = RESET || !dly_data_xfer;
//����fifo�������Լ�
fifo_generator_64in_64out u_fifo_rx (
  .rst(reset_c),                    // input wire rst
  .wr_clk(USER_CLK),              // input wire wr_clk
  .rd_clk(CLK),              // input wire rd_clk
  .din(RX_D_SLACK),                    // input wire [63 : 0] din
  .wr_en(data_valid_c),                // input wire wr_en
  .rd_en(RD_DATA_EN),                // input wire rd_en
  .dout(O_CAP_DATA),                  // output wire [63 : 0] dout
  .full(full_o),                  // output wire full
  .almost_full(almost_full_o),    // output wire almost_full
  .empty(EMPTY),                // output wire empty
  .almost_empty(ALEMPTY),  // output wire almost_empty
  .rd_data_count(rd_data_count),  // output wire [10 : 0] rd_data_count
  .wr_data_count(wr_data_count),  // output wire [10 : 0] wr_data_count
  .wr_rst_busy(wr_rst_busy),    // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)    // output wire rd_rst_busy
);
  
   
endmodule
