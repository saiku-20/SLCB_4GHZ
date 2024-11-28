`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 13:25:36
// Design Name: 
// Module Name: AD_SPI
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

//(frame1 frame2)
//output_brust 8

module SLCB_ADATE328_SPI #(
     // Parameters for timing configuration
    parameter PE_FRAME_NUMS = 29,          // Number of bits per frame
    parameter PE_FRQ_DIV_NUMS = 4,         // Clock divider ratio
    // Timing parameters
    parameter RST_CLK_NUM = 14500,         // Reset clock cycles (MIN = 14171)
    parameter CLK_3US_NUM = 3000/(PE_FRQ_DIV_NUMS*5) // 3us timing requirement
)(
    // Clock and reset
    input                 clk         ,
    input                 rst             ,
    
    //input                ADATE328_ctrl   ,
    input                 i_write          ,
    //input                 i_read           ,
    input                 i_pe_rst         ,
    // Status outputs
    output  reg          o_read_done       ,
    output  reg          o_write_done      ,
    output  reg          o_reset_done      ,
    output  reg          o_reset_fail       ,
    // Data interface
    input        [28:0]  i_send_data        ,
    output  reg  [28:0]  o_recive_data     ,
    // SPI interface
    output  reg          O_SPI_RSTb       ,
    output  reg          O_SPI_SCLK       ,
    output  reg          O_SPI_CSb        ,
    input                I_SPI_SDO        ,
    output  reg          O_SPI_SDI        ,

    input               I_SPI_BUSYb 
    );
// Command states
localparam [1:0] 
    WRITE = 2'b01,
    READ  = 2'b10,
    EXT_READ = 2'b11;

// Internal registers for clock generation
reg                     clk_operate_complete;
reg                     cmd_operate_complete;
reg         [2:0]       frq_div_cnt;
reg                     device_clk_edge;
reg                     device_clk;

// Data handling registers
reg         [28:0]      send_combine_data;
reg         [28:0]      recive_data_temp;
reg                     read_done_r;
reg                     write, pe_rst, ext_read;

// SPI control registers
reg                     busyb_clk;
reg                     device_csb;
reg                     data_to_device;
reg                     data_from_device;
reg                     SPI_BUSYb;
reg                     SPI_RSTb;

// Counters and state machines
reg         [5:0]       send_data_cnt;
reg         [7:0]       clk_cnt;
reg         [7:0]       clk_cnt_temp;
reg         [2:0]       pe_rst_state;
reg         [1:0]       cmd_state;
reg         [3:0]       state;

// Output assignments
always @(posedge clk or posedge rst) begin
    if (rst) begin
        O_SPI_SCLK <= 1'b0;
        O_SPI_CSb <= 1'b1;
        O_SPI_SDI <= 1'b0;
        O_SPI_RSTb <= 1'b1;
    end
    else begin
        O_SPI_SCLK <= device_clk || busyb_clk;
        O_SPI_CSb <= device_csb;
        O_SPI_SDI <= data_to_device;
        O_SPI_RSTb <= SPI_RSTb;
    end
end

//generaate 5mhz wait for clk_operate_complete == 1
always@(posedge clk or posedge rst)begin
    if(rst)begin
        clk_operate_complete <= 1'b1;
        frq_div_cnt <= 3'd0;
        device_clk_edge <= 1'b0;
    end
    else if(~clk_operate_complete)begin
        if(o_read_done || o_write_done || o_reset_done)
            clk_operate_complete <= 1'b1;
        else if(frq_div_cnt == PE_FRQ_DIV_NUMS-1) begin//0->3 == 4??200mhz??4??
            frq_div_cnt <= 3'd0;
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

reg             pe_rst_complete;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        //device_clk_end <= 1'b0;
        cmd_operate_complete <= 1'b1;
        pe_rst_complete <= 1'b1;
        pe_rst_state <= 3'd0;
        o_reset_fail <= 1'b0;
        o_reset_done <= 1'b0;
        
        cmd_state <= 2'b0;
        state     <= 4'd0;
        device_clk <= 1'b0;
        device_csb   <= 1'b1;
        data_to_device <= 1'b0;
        
        o_read_done        <= 1'b0;
        recive_data_temp <= 29'b0;
        o_recive_data      <= 29'b0;
        read_done_r       <= 1'b0;
        o_write_done        <= 1'b0;
        clk_cnt      <= 8'd0;
        clk_cnt_temp <= 8'd0;
        send_combine_data <= 29'd0;
    end
    else if((write || ext_read || pe_rst) && clk_operate_complete)begin
        cmd_operate_complete    <= 1'b0;
        pe_rst_complete         <= pe_rst ? 1'b0:1'b1;
        pe_rst_state            <= 3'd0;
        ext_read                <= 1'b0;
        cmd_state               <= write ? ((!i_send_data[16]) ? READ : WRITE) : (ext_read ? EXT_READ:2'b0);
        //cmd_state               <= write ? WRITE:(ext_read ? EXT_READ:2'b0); //(!i_send_data[16])? 
        //cmd_state               <= write ? WRITE : (read ? READ:(ext_read ? EXT_READ:2'b0));
        clk_cnt                 <= 8'd0;
        //read_clk_cnt            <= 7'd0;
        send_data_cnt           <= 5'd0;
        send_combine_data       <= (write) ? i_send_data : 29'd0;
        //send_combine_data       <= (write||read) ? i_send_data : 29'd0;
    end
    else if(read_done_r && cmd_operate_complete && !(&clk_cnt))
        clk_cnt <= clk_cnt + 1'd1;
    else if(read_done_r && cmd_operate_complete && (&clk_cnt))begin
        ext_read <= 1'b1;
        clk_cnt <= 8'd0;
    end
    else if(~pe_rst_complete)begin
        case(pe_rst_state)
            3'd0:if(device_clk_edge&&(clk_cnt != 3))begin  //rst????????
                    device_clk <= busyb_clk ? 1'b0:~device_clk; 
                    clk_cnt    <= busyb_clk ? clk_cnt : (clk_cnt + 1'd1);
                    SPI_RSTb <= 1'b0;
                    clk_cnt <= clk_cnt + 1'd1;end
                 else if(device_clk_edge&&(clk_cnt == 3))begin //reset ???edge?
                    device_clk <= ~device_clk;
                    clk_cnt <= 8'd0;
                    pe_rst_state <= 3'd1;end
                 else pe_rst_state <= pe_rst_state;
            3'd1:if(device_clk_edge)begin //???busy??????
                    SPI_RSTb <= 1'b1;
                    device_clk <= ~device_clk;
                    pe_rst_state <= 3'd2;end
                 else pe_rst_state <= pe_rst_state;
            3'd2:if(device_clk_edge&&(!SPI_BUSYb))begin//????????rst???????
                    SPI_RSTb <= 1'b1;
                    device_clk <= ~device_clk;
                    clk_cnt <= clk_cnt + 1'd1;end
                 else if(device_clk_edge&&SPI_BUSYb)begin
                    SPI_RSTb <= 1'b1;
                    device_clk <= ~device_clk;
                    clk_cnt_temp <= clk_cnt;clk_cnt <= 8'd0;
                    pe_rst_state <= 3'd3;end
                 else pe_rst_state <= pe_rst_state;
            3'd3:if(device_clk_edge&&(clk_cnt != CLK_3US_NUM))begin
                    device_clk <= ~device_clk;
                    clk_cnt <= clk_cnt + 1'd1;end
                 else if(device_clk_edge&&(clk_cnt == CLK_3US_NUM))begin
                    device_clk <= ~device_clk;
                    clk_cnt <= 8'd0;
                    if(|clk_cnt_temp == 1'b0)begin
                        o_reset_fail <= 1'b1;end
                    else begin    
                        o_reset_done  <=  1'b1;end
                    pe_rst_state <= 3'd4;end
                 else pe_rst_state <= pe_rst_state;
            default: begin device_clk <= 1'b0;SPI_RSTb <= 2'b1; pe_rst_complete <= 1'b1;
                    o_reset_done <= 1'b0;o_reset_fail <= 1'b0;
                    clk_cnt_temp <= 8'd0;cmd_operate_complete <= 1'b1;pe_rst_state <= 3'd0; end
        endcase
    end
    else if(~cmd_operate_complete & pe_rst_complete)begin
        case(state)
           4'd0:begin 
                 if(device_clk_edge&&(clk_cnt != 3)) begin 
                   device_clk <= busyb_clk ? 1'b0:~device_clk; 
                   clk_cnt    <= busyb_clk ? clk_cnt : (clk_cnt + 1'd1);
                   device_csb <= 1'b1; data_to_device <= 1'b0; end
                else if(device_clk_edge&&(clk_cnt == 3)) begin
                   device_clk <=2'd0;
                   device_csb <= 1'b0;
                   clk_cnt <= 8'd0;
                   state <= 4'd1;
                   data_to_device <= send_combine_data[28];
                   send_combine_data <= {send_combine_data[27:0],1'b0};end
                else state <= state;end
           4'd1:begin if(device_clk_edge)begin
                   device_clk <= 1'b1;
                   send_data_cnt <= send_data_cnt + 1'd1;
                   state <= 4'd2;end
                else state <= state;end
           4'd2:if(device_clk_edge&(send_data_cnt != PE_FRAME_NUMS))begin 
                   device_clk <= 1'b0;
                   recive_data_temp[PE_FRAME_NUMS - send_data_cnt] <= data_from_device;
                   data_to_device <= send_combine_data[28];
                   send_combine_data <= {send_combine_data[27:0],1'b0};
                   state <= 4'd1;end
                else if(device_clk_edge&(send_data_cnt == PE_FRAME_NUMS))begin
                   device_clk <= 1'b0;
                   device_csb <= 1'b1;
                   data_to_device <= 1'b0;
                   recive_data_temp[0] <= data_from_device; // ???????��
                   send_data_cnt <= 5'd0;
                   state <= 4'd3;end   
               else state <= state;      
           4'd3:if(device_clk_edge&(clk_cnt != 5))begin
                   device_clk <= ~device_clk;
                   clk_cnt <= clk_cnt + 1'd1;
                   o_recive_data <= recive_data_temp;
                   device_csb <= 1'b1;end
                else if(device_clk_edge&(clk_cnt == 5)) begin
                   device_clk <= 1'b0;
                   clk_cnt <= 8'd0;
                   case(cmd_state)
                       WRITE: begin
                           o_write_done <= 1'b1;
                           o_read_done <= read_done_r;                          
                           state <= 4'd5;
                       end
                       READ: begin
                           o_write_done <= 1'b1;
                           read_done_r <= 1'b1; 
                           o_read_done <= read_done_r;
                           state <= 4'd4;
                       end
                       EXT_READ:begin
                           o_read_done <= read_done_r;
                           state <= 4'd5;end
                       default: begin o_read_done <= 1'b0;o_write_done <= 1'b0;end
                       endcase
                   end
                else state <= state;
           4'd4:begin device_clk <= 1'b0;
                          device_csb <= 1'b1;
                          cmd_operate_complete <= 1'b1; 
                          o_read_done <= 1'b0;o_write_done <= 1'b0;state <= 4'd0;end
           4'd5: begin device_clk <= 1'b0; 
                          device_csb <= 1'b1;
                          cmd_operate_complete <= 1'b1; 
                          o_write_done <= 1'b0;o_read_done <= 1'b0;read_done_r <= 1'b0;state <= 4'd0;end
           default:begin device_clk <= 1'b0;
                          device_csb <= 1'b1;
                          state <= 4'd0; end
           endcase
      end
end

reg SPI_BUSYb_r;
// Busy detection logic with improved timing
always @(posedge clk or posedge rst) begin
    if (rst) begin
        SPI_BUSYb_r <= 1'b1;
    end
    else if (device_clk_edge) begin
        SPI_BUSYb_r <= I_SPI_BUSYb;
    end
end

 reg [24:0] busyb_clk_cnt_temp;
 reg [24:0] busyb_clk_cnt;
 reg busyb_flag;

localparam BUSY_IDLE = 2'b00;
localparam BUSY_ACTIVE = 2'b01;
localparam BUSY_COMPLETE = 2'b10;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        busyb_clk <= 1'b0;
        busyb_flag <= 1'b0;
        busyb_clk_cnt <= 25'd0;
        busyb_clk_cnt_temp <= 25'd0;
    end 
    else if (device_clk_edge) begin
        case ({SPI_BUSYb_r, SPI_BUSYb})
            2'b10:   // BUSY active (1->0)
                begin
                    busyb_clk <= device_clk ? 1'b0 : 1'b1;
                    busyb_flag <= 1'b0;
                    busyb_clk_cnt <= 25'd0;
                    busyb_clk_cnt_temp <= 25'd0;
                end
                
            2'b01:   // BUSY release (0->1)
                begin
                    busyb_clk <= 1'b0;
                    busyb_flag <= 1'b1;
                    busyb_clk_cnt_temp <= busyb_clk_cnt;
                    busyb_clk_cnt <= 25'd0;
                end
                
            2'b11:   // BUSY keep high
                begin
                    busyb_clk <= 1'b0;
                    busyb_flag <= 1'b0;
                    busyb_clk_cnt <= 25'd0;
                end
                
            2'b00:   // BUSY keep low
                begin
                    busyb_clk <= ~busyb_clk;
                    busyb_flag <= 1'b0;
                    busyb_clk_cnt <= busyb_clk_cnt + 1'd1;
                end
        endcase
    end
end
ila_2  u_ila_2(
	.clk(clk), // input wire clk


	.probe0(busyb_clk_cnt_temp), // input wire [24:0]  probe0  
	.probe1(busyb_flag) // input wire [0:0]  probe1
);
endmodule
