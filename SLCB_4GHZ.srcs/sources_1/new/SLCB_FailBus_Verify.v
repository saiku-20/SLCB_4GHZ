`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 19:30:33
// Design Name: 
// Module Name: SLCB_FailBus_verify
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


module SLCB_FailBus_Verify(
    input           RESET,
    input           CLK_IN,
    
    input           wr_FailBus_Check_en,
    input           rd_FailBus_Check_en,
    input   [63:0]  pc_wr_Check_data,
    output  [63:0]  pc_rd_Check_data,
    
    output  reg          FailBus_txfifo_en,
    output  reg  [63:0]  FailBus_txfifo_data,
    output  reg          FailBus_rxfifo_en,
    input  [63:0]        FailBus_rxfifo_data,
    
    input           FailBus_rxfifo_empty
    );
always@(posedge CLK_IN)begin//发送校验数据
    if(RESET)begin
        FailBus_txfifo_en   <=  1'b0;
        FailBus_txfifo_data <=  64'h0;
    end
    else if(wr_FailBus_Check_en <= 1'b1)begin
        FailBus_txfifo_en <= 1'b1;
        FailBus_txfifo_data <= pc_wr_Check_data;
    end
    else begin
        FailBus_txfifo_en   <= 1'b0;
        FailBus_txfifo_data <= 64'h0;
    end
end

always@(posedge CLK_IN)begin //接收校验数据
    if(RESET)begin
        FailBus_rxfifo_en   <= 1'b0;
    end
    else if(~FailBus_rxfifo_empty & ~FailBus_rxfifo_en)begin
        FailBus_rxfifo_en  <=  1'b1;
    end
    else begin
        FailBus_rxfifo_en  <= 1'b0;
    end
end
assign pc_rd_Check_data = rd_FailBus_Check_en ? FailBus_rxfifo_data : 64'hz;
endmodule
