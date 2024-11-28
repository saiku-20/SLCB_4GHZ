`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/31 23:23:38
// Design Name: 
// Module Name: AD7616_HardwareParallel
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

// we don't need to get sample for the same time


module AD7616_HardwareParallel(
    input           clk             ,
    input           rst             ,
    
    input           i_start_conv    ,
    input           i_ad_full_rst   ,
    input           i_ad_partial_rst,
    input    [7:0]  i_ad_channelsel ,


    output           o_read_done     ,
    output   [255:0] o_conv_ab       ,

    //output          O_HW_RNGSEL       ,// 
    //output  [2:0]   O_OS          ,    //over sample
    output   reg       O_RSTSETb       ,
    output   reg       O_SER_PARb      ,
    output   reg       O_REFSEL        ,
    output   reg       O_SEQEN         ,
    //output          O_CRCEN       ,
    //output  [2:0]   O_OS          ,
    //output          O_SER1Wb      ,
    output  reg [1:0]   O_HW_RNGSEL     ,

    output reg         O_CONVST       ,
     input             I_AD_BUSY       ,
    output reg [2:0]   O_CHSEL         ,
    output reg         O_BURST         ,
    output reg         O_RDb           ,
    //output          O_WRb         ,
    output reg         O_CSb           ,
    input  [15:0]      IO_DB           
         
);

localparam clk_div_num          = 3        ; 
localparam CYCLE                = 8'd200      ; //1us
localparam CONV_HIGH            = 8'd12       ; //60ns
localparam CS_SETUP             = 8'd4        ; //20ns

localparam RESETb_WAIT          =  24'd300000;   //1.5ms
localparam WRITE_Partial        =  8'd15;       //75ns
localparam WRITE_FULL           =  24'd50000;    //250us
localparam RDb_SETUP            =  8'd3;        //15ns
localparam DOUT_SETUP           =  8'd6;        //30ns flaxible time,adjustable
localparam RDb_LOW              =  8'd8;         //40ns
localparam RDb_HIGH             =  8'd9;         //45ns
localparam RDb_HOLD             =  8'd3;         //15ns
localparam DOUT_3STATE          =  8'd3;         //15ns
localparam DEVICE_SETUP_Partial =  8'd20;       //100ns
localparam DEVICE_SETUP_Full    =  24'd3100000;  //15.5ms
localparam RESETb_LOW_Partial   =  8'd60; //300ns
localparam RESETb_LOW_Full      =  24'd400; //2us

//
reg         ad_full_rst,ad_partial_rst,ad_busy;
reg [7:0]   ad_channelsel;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        ad_full_rst     <=      1'b0;
        ad_partial_rst  <=      1'b0;
        ad_channelsel   <=      8'b0;
        ad_busy         <=      1'b0;
    end
    else begin
        ad_full_rst     <=      i_ad_full_rst;
        ad_partial_rst  <=      i_ad_partial_rst;
        ad_channelsel   <=      i_ad_channelsel;
        ad_busy         <=      I_AD_BUSY;
    end
end

//save A B part channal to fifo
reg        read_cmd_rst,read_cmd_frm;
reg        read_one_done,read_pair_done;
reg [31:0] conv_ab_data;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        read_one_done        <= 1'b0;
        conv_ab_data         <= 32'b0;
        read_pair_done       <= 1'b0;
    end
    else if(read_cmd_rst | read_cmd_frm | !read_one_done)begin
        conv_ab_data   <= {16'b0,IO_DB};
        read_one_done  <= 1'b1;
        read_pair_done <= 1'b0;
    end
    else if(read_cmd_rst | read_cmd_frm | read_one_done)begin
        conv_ab_data <= {conv_ab_data[15:0],IO_DB};
        read_one_done <= 1'b0;
        read_pair_done <= 1'b1;
    end
    else begin
        read_pair_done <= 1'b0;
    end
end

reg       ad_fifo_full;
reg       ad_fifo_empty;
reg [9:0] ad_fifo_count;
fifo_generator_32in_256out u_fifo_generator_32in_256out (
  .clk(clk),                      // input wire clk
  .srst(rst),                    // input wire srst
  .din(conv_ab_data),                      // input wire [31 : 0] din
  .wr_en(read_pair_done),         // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(dout),                    // output wire [255 : 0] dout
  .full(ad_fifo_full),                    // output wire full
  .empty(ad_fifo_empty),                  // output wire empty
  .wr_data_count(ad_fifo_count)  // output wire [9 : 0] wr_data_count
);

reg rst_operate_complete;
reg cmd_operate_complete;
//8 pair channels lun xun
reg [7:0] chsel_shift;
reg shift_valid;
DECODE_8_3 u_DECODE_8_3(clk,(chsel_shift & ad_channelsel),shift_valid,O_CHSEL);
always@(posedge clk or posedge rst)begin
    if(rst)begin
        chsel_shift             <= 8'b0000_0001;
        shift_valid              <= 1'b0;
    end
    else if(chsel_shift == 8'b0)begin
        //chsel_shift <= ;
        chsel_shift     <= (i_start_conv) ? 8'b0000_0001 : 8'b0; 
        shift_valid      <= 1'b0;
    end
    else if((|(chsel_shift & ad_channelsel))&read_pair_done)begin 
        chsel_shift     <= {chsel_shift[7:0],1'b0};
        shift_valid      <= 1'b0;
    end
    else if((|(chsel_shift & ad_channelsel))&(!read_pair_done))begin
        shift_valid      <= 1'b1;
        chsel_shift <= chsel_shift;
    end
    else
        shift_valid      <= 1'b0;
        chsel_shift <= {chsel_shift[7:0],1'b0};
end

reg       RDb_rst, RDb_frm;
reg       CSb_rst, CSb_frm;
//reg [2:0] CHSEL_rst, CHSEL_frm;
always@(posedge clk)begin
    //O_CHSEL  <= CHSEL_rst | CHSEL_frm; 
    O_CSb    <= CSb_rst | CSb_frm;    
    O_RDb    <= RDb_rst | RDb_frm;    
end

localparam  CONV_START    = 0,
            CONV_END      = 1,
            CONV_BUSY     = 2,
            ACQ_WAIT1     = 3,
            ACQ_CONVA     = 4,
            ACQ_WAIT2     = 5,
            ACQ_CONVB     = 6,
            ACQ_WAIT3     = 7,
            CONV_FINISH   = 8;

//convert clk cnt
reg [4:0] conv_state;
reg [7:0] conv_clk_cnt;
reg [7:0] conv_clk_cnt_temp;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        O_CONVST <= 1'b0;
        conv_clk_cnt_temp <= 8'd0;
        cmd_operate_complete <= 1'b1;
    end
    else if(rst_operate_complete & (!cmd_operate_complete) & shift_valid)begin
        case(conv_state)
            CONV_START:begin 
                O_CONVST  <= 1'b1;
                CSb_frm    <= 1'b1;
                RDb_frm    <= 1'b1;
                conv_state <= CONV_END;
            end
            CONV_END:begin 
                O_CONVST  <= (conv_clk_cnt == CONV_HIGH) ? 1'b0 : O_CONVST;
                conv_state <= (ad_busy & (!O_CONVST)) ? CONV_BUSY : conv_state;
            end
            CONV_BUSY:begin 
                conv_state <= (ad_busy == 1'b0) ? ACQ_WAIT1 : conv_state;
                conv_clk_cnt_temp <= (ad_busy == 1'b0) ? conv_clk_cnt : 8'd0;
            end
            ACQ_WAIT1:begin
                CSb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP) ? 1'b0 : CSb_frm);
                RDb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP) ? 1'b0 : RDb_frm);
                conv_state      <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP) ? ACQ_CONVA : conv_state);
            end
            ACQ_CONVA:begin 
                RDb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW) ? 1'b1 : RDb_frm);
                read_cmd_frm    <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + 1) ? 1'b1 : 1'b0);
                CSb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD) ? 1'b1 : CSb_rst);
                conv_state      <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD) ? ACQ_WAIT2 : conv_state);
            end
            ACQ_WAIT2:begin 
                CSb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD + RDb_HOLD) ? 1'b0 : CSb_frm);
                RDb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH) ? 1'b0 : RDb_frm);
                conv_state      <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP) ? ACQ_CONVA : conv_state);
            end
            ACQ_CONVB:begin 
                RDb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW)) ? 1'b1 : RDb_rst;
                read_cmd_frm    <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + 1)) ? 1'b1 : 1'b0;
                CSb_frm         <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + RDb_HOLD)) ? 1'b1 : CSb_rst;
                conv_state      <= (conv_clk_cnt == (conv_clk_cnt_temp + CS_SETUP + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + RDb_HOLD + DOUT_3STATE)) ? ACQ_WAIT3 : conv_state;
            end
            ACQ_WAIT3:begin
                conv_state      <= (conv_clk_cnt == CYCLE) ? CONV_FINISH : conv_state;
            end
            CONV_FINISH:begin
                cmd_operate_complete <= 1'b1;
            end
            default:begin cmd_operate_complete <= 1'b1; end 
            //IDLE:begin  end
        endcase
    end
end
reg conv_time_out;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        conv_clk_cnt <= 8'd0;
        conv_time_out <= 1'b0;
    end
    else if(!rst_operate_complete | cmd_operate_complete)
        conv_clk_cnt <= 8'd0;
    else if(conv_clk_cnt == 8'd201)begin
        conv_clk_cnt <= 8'd0;
        conv_time_out <= 1'b1;
    end
    else
        conv_clk_cnt <= conv_clk_cnt + 1'd1;
end
//need:add a busy counter at CONV_BUSY state

//resetb
localparam  INIT_RST        = 0,
            INIT_RST_WAIT1  = 1,
            INIT_RST_READA  = 2,
            INIT_RST_WAIT2  = 3,
            INIT_RST_READB  = 4,
            RST_FINISH      = 5,
            PARTIAL_RST     = 6,
            FULL_RST        = 7,
            FINISH          = 8;
reg [4:0] rst_state;    


reg  [23:0]   rst_cnt;
reg ad_init_rst;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        rst_operate_complete    <= 1'b1;
        O_RSTSETb               <= 1'b0;
        ad_init_rst             <= 1'b1;
        O_SER_PARb              <= 1'b0;
        //CHSEL_rst               <= 3'b000;
        CSb_rst                 <= 1'b1;
        RDb_rst                 <= 1'b1;
        
        O_HW_RNGSEL             <= 2'b11; //range set
        O_REFSEL                <= 1'b1;
        O_SEQEN                 <= 1'b0;
    end
    else if((ad_init_rst | ad_full_rst | ad_partial_rst) & rst_operate_complete)begin
        rst_state   <=  ad_init_rst ? INIT_RST : 
                        ad_partial_rst ? PARTIAL_RST :
                        ad_full_rst ? FULL_RST : FINISH;
        rst_operate_complete    <= 1'b0;
        O_RSTSETb               <= 1'b0;
    end
    else if(!rst_operate_complete & shift_valid)begin
        case(rst_state) 
            INIT_RST:begin 
                O_SER_PARb <= 1'b0; //choose parail
                //CHSEL_rst  <= O_CHSEL; //c8 AB
                CSb_rst    <= 1'b1;
                O_REFSEL   <= 1'b1; //ref inside
                O_SEQEN    <= 1'b0; //sequence disable
                O_HW_RNGSEL<= 2'b11; //+-10v
                O_RSTSETb  <= (rst_cnt == RESETb_WAIT) ? 1'b1: O_RSTSETb;
                rst_state  <= (rst_cnt == RESETb_WAIT) ? INIT_RST_WAIT1 : rst_state; end
            INIT_RST_WAIT1:begin 
                CSb_rst <=  (rst_cnt == (RESETb_WAIT + WRITE_FULL)) ? 1'b0 : CSb_rst;
                RDb_rst <=  (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP)) ? 1'b0 : RDb_rst;
                rst_state <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP)) ? INIT_RST_READA : rst_state;
            end
            INIT_RST_READA:begin
                RDb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW)) ? 1'b1 : RDb_rst;
                read_cmd_rst    <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + 1)) ? 1'b1 : 1'b0;
                CSb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD)) ? 1'b1 : CSb_rst;
                rst_state       <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD)) ? INIT_RST_WAIT2 : rst_state;
            end
            INIT_RST_WAIT2:begin
                CSb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HOLD + RDb_HOLD))? 1'b0 : CSb_rst;  //TWO RDb_HOLD as high of CSb
                RDb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH))? 1'b0 : RDb_rst;
                rst_state       <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP))? INIT_RST_READB : rst_state;
            end
            INIT_RST_READB:begin
                RDb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW)) ? 1'b1 : RDb_rst;
                read_cmd_rst    <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + 1)) ? 1'b1 : 1'b0;
                CSb_rst         <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + RDb_HOLD)) ? 1'b1 : CSb_rst;
                rst_state       <= (rst_cnt == (RESETb_WAIT + WRITE_FULL + RDb_SETUP + DOUT_SETUP + RDb_LOW + RDb_HIGH + DOUT_SETUP + RDb_LOW + RDb_HOLD + DEVICE_SETUP_Full)) ? RST_FINISH : rst_state;
            end                                                                                                                                 
            PARTIAL_RST:begin 
                 //wait for complete
                 //CHSEL_rst  <= 
                 CSb_rst    <= 1'b1;
                 O_RSTSETb  <= (rst_cnt == RESETb_LOW_Partial) ? 1'b1 : O_RSTSETb;
                 rst_state  <= (rst_cnt == RESETb_LOW_Partial + WRITE_Partial) ? RST_FINISH : rst_state;
            end
            FULL_RST:begin 
                
            end
            RST_FINISH:begin rst_operate_complete <= 1'b1; end
            default:begin rst_operate_complete <= 1'b1; end
        endcase
    end
end
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
//
//reg  [] 
//always@(posedge clk or posedge rst)begin
//    if(rst)begin
//        
//    end
//    else if( & rst_operate_complete)begin
//        
//    end
//end
endmodule
