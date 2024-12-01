`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 11:50:06
// Design Name: 
// Module Name: top_tb
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


module top_tb();
parameter CLK_50M_CYCLE = 20;
parameter RST_TIME = 5;
reg rst,clk_50;
wire SPI_RSTb,SPI_SCLK,SPI_CSb,SPI_SDO,SPI_SDI;
reg SPI_BUSYb;
always #(2.5) clk_50 = ~clk_50;//

initial begin
    clk_50 = 1'b0;
    rst = 1'b1;
    SPI_BUSYb = 1;
    #(CLK_50M_CYCLE*RST_TIME);
    rst = 1'b0;
    #(CLK_50M_CYCLE*10);
    //CHANNEL_UP = 1'b1;
    #200;
end
SLCB_TOP u_SLCB_TOP(
     .clk_50m		          (clk_50),
     .clk_25m_p               (),
     .clk_25m_n               (),
     .rst_n	                  (~rst),
                                
     .gt_refclk_p             (),
     .gt_refclk_n             (),
                                
     .gt_rx_databus_p         (),
     .gt_rx_databus_n         (),
     .gt_tx_databus_p         (),
     .gt_tx_databus_n         (),
                                
     .gt_rx_failbus_p         (),
     .gt_rx_failbus_n         (),
     .gt_tx_failbus_p         (),
     .gt_tx_failbus_n         (),
     .SPI_RSTb                (SPI_RSTb),
     .SPI_SCLK                (SPI_SCLK),
     .SPI_CSb                 (SPI_CSb),
     .SPI_SDO                 (SPI_SDO),
     .SPI_SDI                 (SPI_SDI),
     .SPI_BUSYb               (SPI_BUSYb),           
     .led                     ()
);
endmodule
