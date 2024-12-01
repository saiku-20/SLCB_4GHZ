`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/31 23:23:38
// Design Name: 
// Module Name: AD7616_SoftwareParallel
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

//unfinish
/*
`define clk_div_num 3;
//base on 200mhz
`define RESETb_WAIT          300000;   //1.5ms
`define DEVICE_SETUP_Partial 20;       //100ns
`define DEVICE_SETUP_Full    4000000;  //20ms
`define DEVICE_SETUP_Full_1  4300000;  //20ms
`define RESETb_LOW_Partial   60; //300ns
`define RESETb_LOW_Full      400; //2us
module AD7616_SoftwareParallel(
    input           clk      ,
    input           rst         ,
    
    input           i_ad_full_rst,
    input           i_ad_partial_rst,


    //output          O_HW_RNGSEL       ,// 
    //output  [2:0]   O_OS          ,    //over sample
    output          O_RSTSETb       ,
    output          O_REF_SEL        ,
    output          O_SER_PARb       ,
    output          O_RDb           ,
    output          O_WRb           ,
    output          CONVERT         ,    
    input           I_AD_BUSY        
           
    
    );
    
reg ad_full_rst,ad_partial_rst;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        ad_full_rst     <=      1'b0;
        ad_partial_rst  <=      1'b0;
    end
    else begin
        ad_full_rst     <=      i_ad_full_rst;
        ad_partial_rst  <=      i_ad_partial_rst;
    end
end
// clk div
//generaate 5mhz wait for clk_operate_complete == 1
reg clk_operate_complete;
reg device_clk_edge;
reg [15:0]  frq_div_cnt;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        clk_operate_complete <= 1'b1;
    end
    else if(~clk_operate_complete)begin
        if(o_read_done|o_write_done|o_reset_done)
            clk_operate_complete <= 1'b1;
        else if(frq_div_cnt == pe_frq_div_nums) begin//0->3 == 4??200mhz??4??
            frq_div_cnt <= 16'h0;
            device_clk_edge <= 1'b1;
        end
        else begin
            frq_div_cnt <= frq_div_cnt + 1'd1;
            device_clk_edge <= 1'b0;
        end
    end
    //else if(write|read|pe_rst)
    else if(write|ext_read|pe_rst)
        begin
            clk_operate_complete <= 1'b0;
            frq_div_cnt <= frq_div_cnt + 1'd1; 
            device_clk_edge <= 1'b0;
        end
    else begin
        frq_div_cnt <= 16'h0;
        device_clk_edge <= 1'b0;
        clk_operate_complete <= 1'b1;
    end
end
//resetb
localparam  INIT_RST        = 0,
            INIT_RST_WAIT   = 1,
            PARTIAL_RST     = 1,
            FULL_RST        = 2,
            FINISH          = 3;
reg [4:0] rst_state;
reg ad_init_rst;
reg rst_cnt_zero;
reg rst_operate_complete;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        rst_operate_complete    <= 1'b1;
        O_RSTSETb               <= 1'b0;
        ad_init_rst             <= 1'b1;
        rst_cnt_zero            <= 1'b0;
        O_SER_PARb              <= 1'b0;

    end
    else if((ad_init_rst | ad_full_rst | ad_partial_rst)&rst_operate_complete)begin
        rst_state   <=  ad_init_rst ? INIT_RST : 
                        ad_partial_rst ? PARATIAL_RST :
                        ad_full_rst ? FULL_RST : FINISH;
        rst_operate_complete    <= 1'b0;
        O_RSTSETb               <= 1'b0;
    end
    else if(!rst_operate_complete)begin
        case(rst_state) 
            INIT_RST:begin 
                O_RSTSETb <= (rst_cnt == RESETb_WAIT)? 1'b1: 1'b0;
                O_SER_PARb <= 1'b0;
                rst_state <= INIT_RST_WAIT; end
            INIT_RST_WAIT:begin 
                
             end
            PARATIAL_RST:begin 
                
             end
            FULL_RST:begin 
                
             end
            PARATIAL_RST:begin 

             end

            PARATIAL_RST:begin  end

        endcase
    end
end
reg  [23:0]   rst_cnt;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        rst_cnt     <=  24'd0;
    end
    else if(rst_operate_complete)begin
        rst_cnt     <= 24'd0;
    end
    else
        rst_cnt     <= rst_cnt + 1'd1;

end
endmodule
*/