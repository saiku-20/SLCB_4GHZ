`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/12 16:27:56
// Design Name: 
// Module Name: SLCB_DataBus_Check
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


module SLCB_DataBus_Check(
    input       CLK_IN,
    input       RESET,
    
    input       DATA_WR,
    input[63:0] DATA_IN,
    
    input       DATA_RD,
    output[63:0]DATA_OUT
    );
    
    //收到写信号，则缓存写数据
    //收到读信号，输出缓存数据
    
    reg [63:0] data_temp;
    
always @(posedge CLK_IN)begin
    if(RESET)begin
        data_temp <= 64'b0;
    end
    else begin
        if(DATA_WR)begin
            data_temp  <=  DATA_IN;
        end
        else begin
            data_temp  <=  data_temp;
        end       
     end
end

assign DATA_OUT[63:0] = (DATA_RD == 1'b1) ? data_temp:64'hz;
endmodule
