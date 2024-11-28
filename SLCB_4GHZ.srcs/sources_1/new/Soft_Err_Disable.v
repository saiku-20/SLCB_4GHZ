`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/12 11:34:17
// Design Name: 
// Module Name: Soft_Err_Disable
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


module Soft_Err_Disable #(
    parameter   BUS_WIDTH = 32
)(
    input                        CLK                 ,
    input                        clk200M             ,
    input                        RST                 ,
   
    input                        verify_start        ,
    input                        verify_end          ,
    output reg [BUS_WIDTH-1:0]   soft_err_num        ,
    
    input                       SOFT_ERR_I            ,
    input                       RX_SRC_RDY_N_I        ,
    output   reg [BUS_WIDTH-1:0]  RX_DATA_I             ,
    
    output                      FIFO_WR_EN_N            ,
    output   reg [BUS_WIDTH-1:0]    FIFO_WR_DATA
 );
 reg        [BUS_WIDTH-1:0]  cnt_num          ;
 reg                        cnt_state       ;
 reg                        cnt_en          ;
 
 reg                        soft_err_r      ;
 reg                        rx_src_rdy_n_r  ;
 
 always @(posedge CLK)begin
    if(RST)begin
        soft_err_r <= 1'b0;
    end
    else begin
        soft_err_r <= SOFT_ERR_I;
    end
 end
 
 always @(posedge CLK)begin
    if(RST)begin
        rx_src_rdy_n_r <= 1'b0;
        FIFO_WR_DATA <= {BUS_WIDTH{1'b0}};
    end
    else begin
        rx_src_rdy_n_r <= RX_SRC_RDY_N_I;
        FIFO_WR_DATA   <= RX_DATA_I;
    end
 end
 
 assign FIFO_WR_EN_N = rx_src_rdy_n_r || soft_err_r; 
 
 always @(posedge CLK)begin
    if(RST)begin
        cnt_state <= 1'b0;
        cnt_num     <= 32'h0;
    end
    else if(cnt_state == 0)begin
        if(cnt_en == 1)
            cnt_state <= 1'b1;
    end
    else if(cnt_state == 1)begin
        if(cnt_en == 0)begin
            soft_err_num <= cnt_num;
            cnt_num <= 32'h0;
            cnt_state <= 1'b0;
        end
    else if(soft_err_r == 1)
        cnt_num <= cnt_num + 1'b1;
    end
 end
 
 always @(posedge clk200M)
 begin
    if(RST)
        cnt_en <= 0;
    else if(verify_start)
        cnt_en <= 1;
    else if(verify_end)
        cnt_en <= 0;
 end
endmodule
