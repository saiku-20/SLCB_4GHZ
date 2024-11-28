`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/31 23:23:38
// Design Name: 
// Module Name: AD7616_SoftwareSerial
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


`define Simulation 1'b1

// AD7616 软件串行接口模块 / AD7616 Software Serial Interface Module
module AD7616_SoftwareSerial(
    // 时钟和复位信号 / Clock and reset signals
    input               clk,                // 系统时钟 / System clock
    input               rst,                // 复位信号 / Reset signal

    // 控制信号 / Control signals 
    input               i_ad_start_conv,    // 开始转换信号 / Start conversion signal
    input               i_ad_read_reg,      // 读寄存器信号 / Read register signal
    input               i_ad_full_rst,      // 完全复位信号 / Full reset signal
    input               i_ad_partial_rst,   // 部分复位信号 / Partial reset signal
    input    [15:0]     i_ad_channelsel,   // 通道选择信号 / Channel selection signal
    
    input    [11:0]     i_ad_sample_nums,  // 采样数量 / Number of samples
    
    // 状态输出 / Status outputs
    output     reg      o_conv_done,        // 转换完成标志 / Conversion done flag
    output     reg      o_rst_done,         // 复位完成标志 / Reset done flag
    
    // FIFO接口 / FIFO interface
    output              o_ad_fifo_empty,    // FIFO空标志 / FIFO empty flag
    input               i_ad_fifo_read,     // FIFO读使能 / FIFO read enable
    output   [63:0]     o_ad_fifo_dout,    // FIFO数据输出 / FIFO data output
        
    output   reg        O_RSTSETb,         // 复位控制信号 / Reset control signal
    output   reg        O_SER_PARb,        // 串/并行选择信号 / Serial/Parallel selection
    output   reg        O_REFSEL,          // 参考电压选择 / Reference voltage selection
    output   reg        O_SER1Wb,          // 串行接口模式选择 / Serial interface mode selection
    output   reg        O_CONVST,          // 转换启动信号 / Conversion start signal
    input               I_AD_BUSY,         // AD忙标志 / AD busy flag
    output   reg        O_CSb,             // 片选信号 / Chip select signal
    output   reg        O_SCLK,            // 串行时钟 / Serial clock
    output   reg        O_SDI,             // 串行数据输入 / Serial data input
    input               I_SDOA,            // 串行数据输出A / Serial data output A
    input               I_SDOB,            // 串行数据输出B / Serial data output B
    //output reg [2:0]   O_CHSEL            ,
    //output reg         O_BURST            ,
    //output reg         O_RDb              ,
    //output             O_WRb              ,
    //input  [15:0]      IO_DB              , 
        
    // 配置参数输入 / Configuration parameter inputs
    input               i_BURSTEN,         // 突发模式使能 / Burst mode enable
    input               i_SEQEN,           // 序列器使能 / Sequencer enable
    input      [2:0]    i_OS,             // 过采样率设置 / Oversampling rate setting
    input               i_STATUSE,         // 状态使能 / Status enable
    input               i_CRCEN,           // CRC使能 / CRC enable
    input      [7:0]    i_ChannelSelBA,   // 通道选择BA / Channel selection BA
    input      [15:0]   i_InRangeA,       // A通道输入范围 / Input range for channel A
    input      [15:0]   i_InRangeB,       // B通道输入范围 / Input range for channel B
    input      [127:0]  i_ASEL,           // A通道序列选择 / Channel A sequence selection
    input      [127:0]  i_BSEL,           // B通道序列选择 / Channel B sequence selection
    input      [31:0]   i_SSREN           // 序列栈寄存器使能 / Sequence stack register enable
);  
parameter pe_frq_div_nums = 4;
parameter Reserved = 1'b1;
parameter RD = 1'b0;
parameter WR = 1'b1;
integer i,j;

localparam clk_div_num          = 3;
localparam CYCLE                = `Simulation ? 8'd20    : 8'd200;      //1us
localparam CONV_HIGH            = 8'd6;                                 //60ns  T = 10NS
localparam CS_SETUP             = 8'd4;                                 //20ns
localparam RESETb_WAIT          = `Simulation ? 24'd300   : 24'd300000; //1.5ms
localparam WRITE_Partial        = 8'd15;                                //75ns
localparam WRITE_FULL           = `Simulation ? 24'd50    : 24'd50000;  //250us         

localparam RDb_SETUP            = 8'd3;                                 //15ns
localparam DOUT_SETUP           = 8'd6;                                 //30ns
localparam RDb_LOW              = 8'd8;                                 //40ns
localparam RDb_HIGH             = 8'd9;                                 //45ns
localparam RDb_HOLD             = 8'd3;                                 //15ns
localparam DOUT_3STATE          = 8'd3;                                 //15ns
localparam DEVICE_SETUP_Partial = 8'd20;                                //100ns
localparam DEVICE_SETUP_Full    = 24'd3100000;//15.5ms
localparam RESETb_LOW_Partial   = 8'd60;                                //300ns
localparam RESETb_LOW_Full      = `Simulation ? 24'd40    : 24'd400;    //2us

`ifdef Simulation reg [20*20:1] state_ascii; `endif 

reg               r_BURSTEN;
reg               r_SEQEN;
reg        [2:0]  r_OS;
reg               r_STATUSE;
reg               r_CRCEN;
reg        [7:0]  r_ChannelSelBA;
reg        [15:0]  r_InRangeA;
reg        [15:0]  r_InRangeB;
reg        [127:0] r_ASEL;
reg        [127:0] r_BSEL;
reg        [31:0]  r_SSREN; 

//convert state
localparam [4:0]    IDLE                = 5'd0,
                    CONFIG_START        = 5'd1,
                    CONVST_START        = 5'd2,
                    CONVST_WAIT         = 5'd3,
                    TRANSMIT_LOW        = 5'd4,
                    TRANSMIT_HIGH       = 5'd5,
                    FRAME_DONE          = 5'd6,
                    DATA_RELOAD         = 5'd7,
                    TRANSMIT_FINISH     = 5'd8,
                    CONV_FINISH         = 5'd9;
//reg stete
localparam [4:0]    RegConfigInitial    = 5'd1,
                    ChannelSelectReg    = 5'd2,     
                    InputRangeRegA1     = 5'd3,     
                    InputRangeRegA2     = 5'd4,     
                    InputRangeRegB1     = 5'd5,     
                    InputRangeRegB2     = 5'd6,     
                    SequencerStack      = 5'd7,     
                    SetChannelReg       = 5'd8,
                    OneFrameRead        = 5'd9,
                    RegOptFinish        = 5'd10;     
//rst config
localparam  [4:0]   INIT_RST            = 5'd1,
                    INIT_RST_WRITE      = 5'd2,
                    INIT_RST_WAIT       = 5'd3,
                    PARTIAL_RST         = 5'd4,
                    FULL_RST            = 5'd5,
                    RST_FINISH          = 5'd6;
//channel generate
reg         chTransfer;
reg         chTransfer_done;
reg [7:0]   BitShift;
reg [3:0]   ChannelA [7:0];
reg [3:0]   ChannelB [7:0];
reg [3:0]   channelA_ID;
reg [3:0]   channelB_ID;
reg [15:0]  i_ad_channelsel_temp1;
reg [15:0]  i_ad_channelsel_temp2;

reg [15:0]  frq_div_cnt;      //
reg         device_clk_edge;         //

reg         clk_operate_complete;
reg         reg_operate_complete;
reg         cmd_operate_complete;
reg         rst_operate_complete;

reg [4:0]   reg_state;
reg         reg_config_flag;
reg [15:0]  data_to_spi;
reg [6:0]   SeqStackNum;
reg [5:0]   SeqStackAddr;

reg [4:0]   cmd_state;
reg [7:0]   clk_cnt;
reg [3:0]   data_cnt;

reg [4:0]   rst_state;
reg [23:0]  rst_cnt;
reg         timeout_rst;

reg         channel_data_valid,channel_valid_1,channel_valid_2;

reg [11:0] sampleNums;
reg [11:0] sample_cnt;
reg [3:0] channel_cnt;
reg [4:0] channel_cnt_max; //

//save A B part channal to fifo
reg [31:0] channel_Result [15:0];     //具体位宽多少合适
reg [15:0] data_from_spiA;   //
reg [15:0] data_from_spiB;   //
reg [3:0]  ResultA_cnt;
reg [3:0]  ResultB_cnt;
reg        SDOA,SDOB;

reg [3:0]  channelA_ID_r;
reg [3:0]  channelB_ID_r;
reg [4:0]  channel_totle_nums; 
reg        ad_init_rst,ad_full_rst,ad_partial_rst;
reg        AD_BUSY,AD_BUSY_R;
reg        start_conv;
reg        clk_start,clk_end;   

always @(posedge clk or posedge rst) begin
    if (rst) begin
        r_BURSTEN      <= 1'b0;
        r_SEQEN        <= 1'b0;
        r_OS           <= 3'b0;
        r_STATUSE      <= 1'b0;
        r_CRCEN        <= 1'b0;     
        r_ChannelSelBA <= 8'h11;
        r_InRangeA     <= 16'b00_00_00_00_00_00_00_00;   //0X0
        r_InRangeB     <= 16'b00_00_00_00_00_00_00_00;
        r_ASEL         <= 128'h01234567_01234567_01234567_01234567;
        r_BSEL         <= 128'h01234567_01234567_01234567_01234567;
        r_SSREN        <= 32'b00000001_00000000_00000000_00000000;
    end
    else begin
        r_BURSTEN      <= i_BURSTEN;
        r_SEQEN        <= i_SEQEN;
        r_OS           <= i_OS;
        r_STATUSE      <= i_STATUSE;
        r_CRCEN        <= i_CRCEN;     
        r_ChannelSelBA <= i_ChannelSelBA;
        r_InRangeA     <= i_InRangeA;
        r_InRangeB     <= i_InRangeB;
        r_ASEL         <= i_ASEL;
        r_BSEL         <= i_BSEL;
        r_SSREN        <= i_SSREN;
    end
end


always@(posedge clk or posedge rst)begin
    if(rst)begin
        ad_full_rst     <=      1'b0;
        ad_partial_rst  <=      1'b0;
        SDOA            <=      1'b0;
        SDOB            <=      1'b0;
        AD_BUSY         <=      1'b0;
        AD_BUSY_R       <=      1'b0;

        start_conv      <=      1'b0;
    end
    else begin
        ad_full_rst     <=      i_ad_full_rst;
        ad_partial_rst  <=      i_ad_partial_rst;
        SDOA            <=      I_SDOA;
        SDOB            <=      I_SDOB;
        AD_BUSY_R       <=      I_AD_BUSY;
        AD_BUSY         <=      AD_BUSY_R;

        start_conv      <=      i_ad_start_conv;
        clk_start       <= o_conv_done | o_rst_done;
        clk_end         <= start_conv | ad_init_rst | ad_partial_rst | ad_full_rst;
    end
end

//clk granenter
always@(posedge clk or posedge rst)begin
    if(rst)begin
        clk_operate_complete <= 1'b1;
        frq_div_cnt <= 16'd0;
    end
    else if(~clk_operate_complete)begin
        if(clk_start)
            clk_operate_complete <= 1'b1;
        else if(frq_div_cnt == pe_frq_div_nums-1) begin//0->3 == 4??200mhz??4??
            frq_div_cnt <= 16'h0;
            device_clk_edge <= 1'b1;
        end
        else begin
            frq_div_cnt <= frq_div_cnt + 1'd1;
            device_clk_edge <= 1'b0;
        end
    end
    else if(clk_end)
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

//channel generate
always@(posedge clk or posedge rst)begin
    if(rst)begin
        i_ad_channelsel_temp2 <= 16'b0;
        BitShift <= 8'b1000_0000;
        for(i = 0; i < 8; i = i + 1) begin
            ChannelA[i] <= 4'b0;
            ChannelB[i] <= 4'b0;
        end
        channelA_ID <= 4'd0;
        channelB_ID <= 4'd0;
        chTransfer_done <= 1'b0;
    end
    else if((BitShift == 8'b0) & (chTransfer == 1'b1) & (|(channelA_ID|channelB_ID)))begin
        BitShift <= 8'b1000_0000;
        i_ad_channelsel_temp2 <= i_ad_channelsel_temp1;
        chTransfer_done <= 1'b1;
    end
    else if((chTransfer == 1'b1) & (chTransfer_done == 1'b0)) begin
        ChannelA[channelA_ID] <= |(i_ad_channelsel_temp1[15:8] & BitShift) ? channelA_ID : 4'h0;                                 
        channelA_ID <= |(i_ad_channelsel_temp1[15:8] & BitShift) ? channelA_ID + 1'd1 : channelA_ID;
        ChannelB[channelB_ID] <= |(i_ad_channelsel_temp1[ 7:0] & BitShift) ? channelB_ID : 4'h0;
        channelB_ID <= |(i_ad_channelsel_temp1[ 7:0] & BitShift) ? channelB_ID + 1'd1 : channelB_ID;
        BitShift <= {1'b0,BitShift[7:1]};
    end    
    else if(chTransfer == 1'b0)begin
        BitShift <= 8'b1000_0000;
        for(i = 0; i < 8; i = i + 1) begin
            ChannelA[i] <= 4'b0;
            ChannelB[i] <= 4'b0;
        end
        channelA_ID <= 4'd0;
        channelB_ID <= 4'd0;
        chTransfer_done <= 1'b0;
    end
    else
        chTransfer_done <= chTransfer_done;
end
//
always@(posedge clk or posedge rst)begin
    if(rst)begin
        chTransfer <= 1'b0;
        i_ad_channelsel_temp1 <= 16'b0;
    end
    else if((i_ad_channelsel != i_ad_channelsel_temp1) & (chTransfer == 1'b0))begin
        chTransfer <= 1'b1;
        i_ad_channelsel_temp1 <= i_ad_channelsel;
    end
    else if((i_ad_channelsel != i_ad_channelsel_temp1) & (chTransfer == 1'b1))begin
        chTransfer <= 1'b0;
    end
    else
        chTransfer  <= chTransfer;
end

//convert state manager
reg channel_config_flag;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        channel_config_flag <= 1'b0;
    end
    else if(start_conv & chTransfer_done & rst_operate_complete)begin
        channel_config_flag <= 1'b1;
    end
    else
        channel_config_flag <= 1'b0;
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        for(j = 0; j < 16; j = j + 1) begin
            channel_Result[j] <= 32'b0;
        end
        ResultA_cnt <= 4'd0;
        ResultB_cnt <= 4'd0;
        channelA_ID_r <= 4'd0;
        channelB_ID_r <= 4'd0;
    end
    //channel config
    else if(channel_config_flag) begin
        for(j = 0; j < 16; j = j + 1) begin
            channel_Result[j] <= 32'b0;
        end
        channelA_ID_r <= channelA_ID; //save channelA_ID
        channelB_ID_r <= channelB_ID;
        ResultA_cnt <= 4'd0;
        ResultB_cnt <= 4'd0;
    end
    //channel data valid:要等待一个周期来转换
    else if((cmd_state == FRAME_DONE) & channel_data_valid & rst_operate_complete & device_clk_edge)begin
      // Channel A processing
      if(ResultA_cnt == channel_cnt_max) begin
          // Reset counter and start accumulating from beginning if within valid channel range
          if(4'd0 < channelA_ID_r) begin
              channel_Result[4'd0] <= channel_Result[4'd0] + data_from_spiA;
          end
          ResultA_cnt <= 4'd1;
      end
      else if(ResultA_cnt < channel_cnt_max) begin
          // Only accumulate if within valid channel range
          if(ResultA_cnt < channelA_ID_r) begin
              channel_Result[ResultA_cnt] <= channel_Result[ResultA_cnt] + data_from_spiA;
          end
          ResultA_cnt <= ResultA_cnt + 1'd1;
      end
      
      // Channel B processing  
      if(ResultB_cnt == channel_cnt_max) begin
          // Reset counter and start accumulating from beginning if within valid channel range
          if(4'd0 < channelB_ID_r) begin
              channel_Result[channelA_ID_r] <= channel_Result[channelA_ID_r] + data_from_spiB;
          end
          ResultB_cnt <= 4'd1;
      end
      else if(ResultB_cnt < channel_cnt_max) begin
          // Only accumulate if within valid channel range
          if(ResultB_cnt < channelB_ID_r) begin
              channel_Result[ResultB_cnt + channelA_ID_r] <= channel_Result[ResultB_cnt + channelA_ID_r] + data_from_spiB;
          end
          ResultB_cnt <= ResultB_cnt + 1'd1;
      end
    end
    else begin
        
    end
end

reg             ad_fifo_read_en;           
wire  [63:0]    ad_fifo_dout; 
wire             ad_fifo_full;
wire             ad_fifo_empty;
reg     [9:0]   ad_fifo_count;
reg             fifo_rst,fifo_wr_en;
reg     [511:0] fifo_din_reg;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        fifo_rst        <=      1'b0;
        fifo_din_reg    <=      512'd0;
    end
    else begin
        fifo_rst        <= start_conv|ad_partial_rst|ad_full_rst;
        fifo_wr_en      <= o_conv_done;      
        fifo_din_reg <= {channel_Result[15], channel_Result[14], channel_Result[13], 
                        channel_Result[12], channel_Result[11], channel_Result[10],
                        channel_Result[9],  channel_Result[8],  channel_Result[7],
                        channel_Result[6],  channel_Result[5],  channel_Result[4],
                        channel_Result[3],  channel_Result[2],  channel_Result[1],
                        channel_Result[0]};
    end
end 
fifo_generator_512in_64out u_fifo_generator_512in_64out (
  .clk(clk),      // input wire clk
  .srst(fifo_rst),    // input wire srst
  .din(fifo_din_reg),      // input wire [511 : 0] din
  .wr_en(fifo_wr_en),  // input wire wr_en
  .rd_en(ad_fifo_read_en),  // input wire rd_en
  .dout(ad_fifo_dout),    // output wire [63 : 0] dout
  .full(ad_fifo_full),    // output wire full
  .empty(ad_fifo_empty)  // output wire empty
);
//save and genarate data
//regiester operate
always@(posedge clk or posedge rst)begin
    if(rst)begin
        reg_state <= IDLE;
        data_to_spi <= 16'b0;
        reg_operate_complete <= 1'b1;
        SeqStackNum <= 7'd0;
        SeqStackAddr <= 6'h20;
        sample_cnt <= 12'd0;
        channel_cnt_max <= 5'd0;
        channel_totle_nums <= 5'd0;
    end
    else if((reg_config_flag | channel_config_flag) & reg_operate_complete)begin
        reg_state <= reg_config_flag ? RegConfigInitial : 
                     channel_config_flag  ? SetChannelReg : RegOptFinish;
        reg_operate_complete <= 1'b0;
        sampleNums <= i_ad_sample_nums - 1'd1;
        sample_cnt <= 12'd0;
        channel_cnt <= 4'b0;
        channel_totle_nums <= channelA_ID + channelB_ID;
        channel_cnt_max <= (channelA_ID > channelB_ID) ? (channelA_ID) : (channelB_ID);
    end
    else if(!reg_operate_complete & device_clk_edge & (cmd_state == DATA_RELOAD || cmd_state == TRANSMIT_FINISH))begin
        case(reg_state)
            //reset regiest
            IDLE:begin `ifdef Simulation state_ascii = "IDLE"; `endif
                reg_operate_complete <= 1'b1;
            end
            RegConfigInitial:begin `ifdef Simulation state_ascii <= "RegConfigInitial"; `endif  
                SeqStackNum <= 5'd0; SeqStackAddr <= 6'h20;
                data_to_spi <= {WR,6'h02,Reserved,1'b0,r_BURSTEN,r_SEQEN,r_OS,r_STATUSE,r_CRCEN};reg_state <= reg_state + 1'd1;end
            ChannelSelectReg:begin `ifdef Simulation state_ascii <= "ChannelSelectReg"; `endif
                data_to_spi <= {WR,6'h03,Reserved,r_ChannelSelBA};reg_state <= reg_state + 1'd1;end
            InputRangeRegA1:begin `ifdef Simulation state_ascii <= "InputRangeRegA1"; `endif
                data_to_spi <= {WR,6'h04,Reserved,r_InRangeA[7:6],r_InRangeA[5:4],r_InRangeA[3:2],r_InRangeA[1:0]};reg_state <= reg_state + 1'd1;end
            InputRangeRegA2:begin `ifdef Simulation state_ascii <= "InputRangeRegA2"; `endif
                data_to_spi <= {WR,6'h05,Reserved,r_InRangeA[15:14],r_InRangeA[13:12],r_InRangeA[11:10],r_InRangeA[9:8]};reg_state <= reg_state + 1'd1;end
            InputRangeRegB1:begin `ifdef Simulation state_ascii <= "InputRangeRegB1"; `endif
                data_to_spi <= {WR,6'h06,Reserved,r_InRangeB[7:6],r_InRangeB[5:4],r_InRangeB[3:2],r_InRangeB[1:0]};reg_state <= reg_state + 1'd1;end
            InputRangeRegB2:begin `ifdef Simulation state_ascii <= "InputRangeRegB2"; `endif    
                data_to_spi <= {WR,6'h07,Reserved,r_InRangeB[15:14],r_InRangeB[13:12],r_InRangeB[11:10],r_InRangeB[9:8]};reg_state <= reg_state + 1'd1;end
            SequencerStack:begin `ifdef Simulation state_ascii <= "SequencerStack"; `endif          
                data_to_spi <= {WR,SeqStackAddr,r_SSREN[31-SeqStackNum],
                                r_ASEL[127-(SeqStackNum<<2) -: 4],  //从最高位开始向下取4位
                                r_BSEL[127-(SeqStackNum<<2) -: 4]}; // <
                SeqStackNum <= SeqStackNum + 1'd1;SeqStackAddr <= SeqStackAddr + 1'b1;
                reg_state <= (SeqStackNum >= 6'd31) ? RegOptFinish : reg_state;end
            //set channel
            SetChannelReg:begin `ifdef Simulation state_ascii <= "SetChannelReg"; `endif
                data_to_spi <= {WR,6'h03,Reserved,ChannelA[channel_cnt],ChannelB[channel_cnt]};
                if(channel_cnt < channel_cnt_max)begin
                    channel_cnt <= channel_cnt + 4'd1;
                end
                else if(channel_cnt >= channel_cnt_max)begin
                    channel_cnt <= 4'd1;
                    sample_cnt <= sample_cnt + 1'd1;
                    reg_state <= (sample_cnt >= sampleNums) ? OneFrameRead: SetChannelReg;
                end end
            //finish
            OneFrameRead:begin `ifdef Simulation state_ascii <= "OneFrameRead"; `endif  
                data_to_spi <= 16'b0;channel_cnt <= 4'd0;sample_cnt <= 12'd0;
                reg_state <= RegOptFinish;end
            RegOptFinish:begin `ifdef Simulation state_ascii <= "RegOptFinish"; `endif
                data_to_spi <= 16'd0; reg_operate_complete <= 1'b1;reg_state <= IDLE;end
            default:begin data_to_spi <= 16'd0; reg_operate_complete <= 1'b1;reg_state <= IDLE;end
        endcase
    end
end
//cmd operate
always@(posedge clk or posedge rst)begin
    if(rst)begin
        O_CSb <= 1'b1;
        O_SDI <= 1'b1;
        O_SCLK <= 1'b1;
        O_CONVST <= 1'b0;
        cmd_state <= 5'd0;
        data_cnt <= 4'd15;
        clk_cnt  <= 8'd0;
        channel_data_valid <= 1'b0;
        channel_valid_1 <= 1'b0;
        channel_valid_2 <= 1'b0;
        cmd_operate_complete <= 1'b1;
    end
    else if((reg_config_flag | channel_config_flag) & cmd_operate_complete)begin
        cmd_state <= DATA_RELOAD;
        O_CSb <= 1'b1;
        O_CONVST <= 1'b0;
        data_cnt <= 4'd15;
        clk_cnt <= 8'd0;
        channel_data_valid <= 1'b0;
        channel_valid_1 <= 1'b0;
        channel_valid_2 <= 1'b0;  
        cmd_operate_complete <= 1'b0;
    end
    else if(!cmd_operate_complete & device_clk_edge)begin
        case(cmd_state)
            IDLE:begin
                cmd_operate_complete <= 1'b1;
            end
            CONFIG_START:begin 
                O_CSb <= 1'b0;
                O_SDI <= data_to_spi[data_cnt];
                data_cnt <= data_cnt - 1'd1;
                cmd_state <= TRANSMIT_LOW;
            end
            CONVST_START:begin
                O_CONVST <= 1'b1;
                clk_cnt <= clk_cnt + 1'd1;
                cmd_state <=  (clk_cnt == CONV_HIGH) ? CONVST_WAIT : cmd_state;
            end
            CONVST_WAIT:begin
                clk_cnt <= 8'd0;
                O_CONVST <= (AD_BUSY) ? 1'b0 : O_CONVST;
                cmd_state <= (!AD_BUSY) ? CONFIG_START : cmd_state;
            end
            TRANSMIT_LOW:begin
                O_SCLK <= 1'b0;
                cmd_state <= TRANSMIT_HIGH;
            end
            TRANSMIT_HIGH:begin
                O_SCLK <= 1'b1;
                O_SDI <= data_to_spi[data_cnt];
                data_cnt <= data_cnt - 1'd1;
                data_from_spiA <= {data_from_spiA[14:0],SDOA};
                data_from_spiB <= {data_from_spiB[14:0],SDOB};
                cmd_state <= (data_cnt == 4'd0) ? FRAME_DONE : TRANSMIT_LOW;
            end
            FRAME_DONE:begin
                O_CSb <= 1'b1;
                //channel_valid_2 <= 1'b1;
                //channel_valid_1 <= channel_valid_2;
                channel_valid_1 <= 1'b1;
                channel_data_valid <= channel_valid_1;
                cmd_state <= (reg_state ==  RegOptFinish) ? TRANSMIT_FINISH : DATA_RELOAD;
            end
            DATA_RELOAD:begin
                if(!rst_operate_complete)
                    cmd_state <= CONFIG_START;
                else
                    cmd_state <= CONVST_START;
            end
            TRANSMIT_FINISH:begin 
                cmd_operate_complete <= 1'b1;
                cmd_state <= IDLE;
            end
            default:begin cmd_operate_complete <= 1'b1;cmd_state <= IDLE;end
        endcase
    end
end

//need:add a busy counter at CONV_BUSY state
//reset part
always@(posedge clk or posedge rst)begin
    if(rst)begin
        rst_operate_complete    <= 1'b1;
        O_RSTSETb               <= 1'b0;
        ad_init_rst             <= 1'b1;
        timeout_rst             <= 1'b0;
        rst_state               <= IDLE;
        O_SER_PARb              <= 1'b1;
        O_SER1Wb                <= 1'b1;
        O_REFSEL                <= 1'b1;
        reg_config_flag         <= 1'b0;
    end
    else if((ad_init_rst | ad_full_rst | ad_partial_rst) & rst_operate_complete)begin
        rst_state   <=  ad_init_rst ? INIT_RST : 
                        ad_partial_rst ? PARTIAL_RST :
                        ad_full_rst ? FULL_RST : RST_FINISH;
        rst_operate_complete    <= 1'b0;
        O_RSTSETb               <= 1'b0;
        timeout_rst             <= 1'b0;
    end
    else if(!rst_operate_complete)begin
        case(rst_state) 
            IDLE:begin
                rst_operate_complete    <= 1'b1;
            end
            INIT_RST:begin 
                O_SER_PARb <= 1'b1; //choose serial 
                O_REFSEL   <= 1'b1; //ref inside
                O_SER1Wb   <= 1'b1; //choose SDOA SDO
                ad_init_rst <= 1'b0;
                O_RSTSETb  <= (rst_cnt == RESETb_WAIT) ? 1'b1 : O_RSTSETb;
                reg_config_flag <= (rst_cnt == RESETb_WAIT + WRITE_FULL) ? 1'b1 : 1'b0;
                rst_state  <= (rst_cnt == RESETb_WAIT + WRITE_FULL + 3) ? INIT_RST_WRITE : rst_state; end
            INIT_RST_WRITE:begin
                //reg_config_flag <= (rst_cnt == RESETb_WAIT + WRITE_FULL) ? 1'b1 : 1'b0;
                rst_state  <= ((cmd_operate_complete == 1'b1)) ? RST_FINISH : rst_state;
                
                timeout_rst <= (rst_cnt == RESETb_WAIT + DEVICE_SETUP_Full) ? 1'b1 : timeout_rst;
                rst_operate_complete <= timeout_rst ? 1'b1 : rst_operate_complete;
            end
            INIT_RST_WAIT:begin
                rst_state  <= (rst_cnt == RESETb_WAIT + DEVICE_SETUP_Full) ? RST_FINISH : rst_state;
            end
            PARTIAL_RST:begin 
                //wait for complete
                O_RSTSETb  <= (rst_cnt == RESETb_LOW_Partial) ? 1'b1 : O_RSTSETb;
                rst_state  <= (rst_cnt == RESETb_LOW_Partial + DEVICE_SETUP_Partial) ? RST_FINISH : rst_state;
            end
            FULL_RST:begin 
                rst_state <= INIT_RST;
            end
            RST_FINISH:begin rst_operate_complete <= 1'b1; rst_state <= IDLE; end
            default:begin rst_operate_complete <= 1'b1; rst_state <= IDLE;end
        endcase
    end
end
//rst counter
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

reg cmd_operate_complete_r;
reg rst_operate_complete_r;
// 检测上升沿并产生一个周期的高电平
always @(posedge clk or posedge rst) begin
    if(rst) begin
        rst_operate_complete_r <= 1'b1;
        cmd_operate_complete_r <= 1'b1;
        o_rst_done <= 1'b0;
        o_conv_done <= 1'b0;
    end
    else begin
        rst_operate_complete_r <= rst_operate_complete;
        cmd_operate_complete_r <= cmd_operate_complete;
        o_rst_done <= rst_operate_complete & ~rst_operate_complete_r;
        o_conv_done <= (cmd_operate_complete & ~cmd_operate_complete_r) & rst_operate_complete_r;
    end
end
endmodule
