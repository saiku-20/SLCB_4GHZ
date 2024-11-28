`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 19:10:43
// Design Name: 
// Module Name: Version_Read
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

module SLCB_Version_Read(
         input       RESET,
         input       CLK_IN,
         input       VERSION_RD,
         input       FPGA_ID_RD,
         output  [15:0] FPGA_VER_ID_DATA
    );
    //V.a.b.c  <==> 0x0abc
    localparam      PAR_VERSION     =    16'h0100;
    localparam      PAR_FPGA_ID     =    16'h0325;
    
    reg     [15:0]      fpga_version_data;
    reg     [15:0]      fpga_id_data;
    
    always @(posedge    CLK_IN)begin
        if(RESET==1'b1)begin
            fpga_version_data   <= 16'b0;
        end
        else begin
            fpga_version_data   <= PAR_VERSION;
        end
    end
    
    always @(posedge    CLK_IN)begin
        if(RESET == 1'b1)begin
            fpga_id_data  <=  16'b0;
        end
        else begin
            fpga_id_data  <=  PAR_FPGA_ID;
        end
    end
endmodule
