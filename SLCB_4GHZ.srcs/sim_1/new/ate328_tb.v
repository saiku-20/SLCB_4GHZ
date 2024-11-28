`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/03 19:45:40
// Design Name: 
// Module Name: ate328_tb
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


module ate328_tb;
reg clk_200;
reg rst; 

reg    CHANNEL_UP;

reg _write,_read,_pe_rst;
wire read_done,write_done;
wire reset_done;
reg [28:0] send_date;
wire [28:0] recive_date;
wire SPI_RSTb,SPI_SCLK,SPI_CSb,SPI_SDI;
reg SPI_SDO;
reg _SPI_BUSYb;

reg user_clk_out;
reg [28:0] readDate;

parameter CLK_200M_CYCLE = 5;
parameter USER_CLK_CYCLE = 20;
parameter RST_TIME = 5;
always #(2.5) clk_200 = ~clk_200;//
always #(USER_CLK_CYCLE/2)user_clk_out = ~user_clk_out;

integer i;
// ������λ�ź�
initial begin
    #(500)
    #(USER_CLK_CYCLE*65);
     _SPI_BUSYb = 1'b0;
    #(USER_CLK_CYCLE*20);
     _SPI_BUSYb = 1'b1;
end
initial begin
    i=0;
    _write = 0;
    _read  = 0;
    _pe_rst =0;
    SPI_SDO = 0;
    readDate = 29'h1_a_b_c_d_e_f_5;
    _SPI_BUSYb = 1'b1;
    clk_200 = 1'b1;
    user_clk_out = 1'b1;
   // CHANNEL_UP = 1'b0;
    rst = 1'b1;
    #(USER_CLK_CYCLE*RST_TIME);
    rst = 1'b0;
    #(USER_CLK_CYCLE*10);
    //CHANNEL_UP = 1'b1;
    #200;

    send_date = 29'b0001_1010_0101_1_1010_0101_1010_0101;
    #1;
    _write = 1;
    _pe_rst = 0;
    _read = 0;
    #(CLK_200M_CYCLE);
    _write = 0;
     //#(10000*CLK_200M_CYCLE);
     //#(2000);
     
     @(posedge write_done)
        @(negedge write_done)
            send_date = 29'b0010_1010_0101_1_1010_0101_1010_0101;
            #1;
            _write = 1;
            _pe_rst = 0;
            _read = 0;
            #(CLK_200M_CYCLE);
            _write = 0;
    @(posedge write_done)
        @(negedge write_done)
            send_date = 29'b0100_1010_0101_1_1010_0101_1010_0101;
            #1;
            _write = 1;
            _pe_rst = 0;
            _read = 0;
            #(CLK_200M_CYCLE);
            _write = 0;
    @(posedge write_done)
        @(negedge write_done)
            send_date = 29'b1000_1010_0101_0_1010_0101_1010_0101;
            #1;
            _write = 0;
            _pe_rst = 0;
            _read = 1;
            #(CLK_200M_CYCLE);
            _read = 0;
            wait(SPI_CSb == 0);
            while(!SPI_CSb)begin
                i = i + 1;
                @(posedge SPI_SCLK)
                    SPI_SDO =0;
                    //readDate = {readDate[27:0],1'b0}; 
            end
            wait(SPI_CSb == 0);
            
            while(!SPI_CSb)begin
                i = i + 1;
                @(posedge SPI_SCLK)
                    #1;
                    SPI_SDO = readDate[28];
                    readDate = {readDate[27:0],1'b0}; 
            end
        //#(2000);   
        @(posedge read_done)    
        @(negedge read_done)
            #201;
            _pe_rst = 1;
            #(CLK_200M_CYCLE);
            _pe_rst = 0;
            #(USER_CLK_CYCLE*65);
              _SPI_BUSYb = 1'b0;
             #(USER_CLK_CYCLE*20);
              _SPI_BUSYb = 1'b1;
    #(2000);
     $stop; 
     
end
//initial begin
//    #20;
//    pc_data = 29'b1111_1010_0101_1100_0011_1010_0101_1;
//    _write = 1;
//    #(CLK_200M_CYCLE);
//    _write = 0;
//     #(10000*CLK_200M_CYCLE);
//     $stop; 
//end

SLCB_ADATE328_SPI u_slcb_adate328_spi(
    .clk_200    (clk_200),
    .rst        (rst),

    .i_write     (_write),
    .i_read      (_read),
    .i_pe_rst    (_pe_rst), 

    .o_read_done      (read_done),
    .o_write_done     (write_done), 
    .o_reset_done     (reset_done),
    .i_send_data      (send_date),
    .o_recive_data    (recive_date),

    .O_SPI_RSTb  (SPI_RSTb),
    .O_SPI_SCLK  (SPI_SCLK),
    .O_SPI_CSb   (SPI_CSb),
    .I_SPI_SDO   (SPI_SDO),
    .O_SPI_SDI   (SPI_SDI),

    .I_SPI_BUSYb (_SPI_BUSYb)
);
endmodule
