`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/17 20:01:53
// Design Name: 
// Module Name: SLCB_SPI_offline_Debug
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
//每32位放29位寄存器数据，一帧64位 {3'b000,29'bX}

module SLCB_SPI_offline_Debug(
    input                   clk     ,
    input                   rst     ,
    output     reg          o_write          ,
    output     reg          o_read           ,
    output     reg          o_pe_rst         , 
    input                   i_read_done          ,
    input                   i_write_done         ,
    input                   i_reset_done         ,
    output   reg    [28:0]  o_send_data          ,
    input        [28:0]     i_recive_data        ,
    input                   I_SPI_BUSYb
    );
    parameter CH = 4'b0001;
    parameter ADDR = 8'h01;
    parameter DATA = 16'hfff2;
    localparam  IDLE = 0,
                RESET = 1,
                RESET_WAIT = 2,
                WRITE_DATA = 3,
                WRITE_DATA_WAIT = 4,
                READ_DATA       = 5,
                READ_DATA_WAIT  = 6,
                FINISH          = 7;
    reg [3:0] state; 
 //写死
    reg [27:0] clk_reg_cnt; //将近1s一个周期
    //reg [5:0] clk_reg_cnt; 
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            clk_reg_cnt <= 28'd0;
        end
        else if(&clk_reg_cnt || state == FINISH)
            clk_reg_cnt <= 28'd0;
        else
            clk_reg_cnt  =  clk_reg_cnt + 1'd1;
    end
    reg o_pe_rst_r;
    reg o_write_r;
    reg o_read_r;
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:begin
                    if(&clk_reg_cnt)begin//开始spi功能验证
                        state <= RESET;
                    end end
                RESET:begin
                    if((~o_pe_rst_r)&&(o_pe_rst))
                        state <= RESET_WAIT;
                    else
                        state <= state;end
                RESET_WAIT:begin
                    if(i_reset_done)
                        state <= WRITE_DATA;
                    else
                        state <= state;end
                WRITE_DATA:begin
                    if((~o_write_r)&&(o_write))
                        state <= WRITE_DATA_WAIT;
                    else
                        state <= state;end
                WRITE_DATA_WAIT:begin
                    if(i_write_done)
                        state <= READ_DATA;
                    else
                        state <= state;end   
                READ_DATA:begin 
                    if((~o_read_r)&&(o_read))
                        state <= READ_DATA_WAIT;
                    else
                        state <= state;end
                READ_DATA_WAIT:begin
                    if(i_read_done)begin
                        state <= FINISH;end
                    else
                        state <= state;end   
                 default:begin state <= 4'd0;end
            endcase
        end
    end
    
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            o_write     <=  1'b0;
            o_write_r   <=  1'b0;
            o_read      <=  1'b0;
            o_read_r    <=  1'b0;
            o_pe_rst    <=  1'b0;
            o_pe_rst_r  <=  1'b0;
        end
        else
            case(state)
                IDLE:begin  end
                RESET:begin 
                    o_pe_rst <=  o_pe_rst ? 1'b0 : 1'b1;
                    o_pe_rst_r <= o_pe_rst;end
                RESET_WAIT:begin 
                    o_send_data <= {CH,ADDR,1'b1,DATA};
                end
                WRITE_DATA:begin
                    o_write <= o_write ? 1'b0:1'b1;
                    o_write_r <= o_write;
                end
                WRITE_DATA_WAIT:begin
                    o_send_data <= {CH,ADDR,1'b0,DATA};
                end
                READ_DATA:begin
                    o_read <= o_read ? 1'b0:1'b1;
                    o_read_r <= o_read;
                end
                READ_DATA_WAIT:begin
                    
                end
                default:begin o_pe_rst <= 1'b0;o_read <= 1'b0;o_write <= 1'b0;end
            endcase
    end
endmodule
