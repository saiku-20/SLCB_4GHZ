`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 15:36:28
// Design Name: 
// Module Name: ad7616_softserial_tb
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


module ad7616_softserial_tb();
        // 定义信号
    reg clk;
    reg rst;
    reg i_start_conv;
    reg i_ad_full_rst;
    reg i_ad_partial_rst;
    reg [15:0] i_ad_channelsel;
    reg [11:0] i_ad_sample_nums;
    reg i_ad_fifo_read;
    reg I_AD_BUSY;
    reg I_SDOA;
    reg I_SDOB;
    
    // 输出信号声明
    wire o_conv_done;
    wire o_rst_done;
    wire o_ad_fifo_empty;
    wire [63:0] o_ad_conv_data;
    wire O_RSTSETb;
    wire O_SER_PARb;
    wire O_REFSEL;
    wire O_SER1Wb;
    wire O_CONVST;
    wire O_CSb;
    wire O_SCLK;
    wire O_SDI;
    
    reg r_BURSTEN;
    reg r_SEQEN;
    reg [2:0] r_OS;
    reg r_STATUSE;
    reg r_CRCEN;     
    reg [7:0] r_ChannelSelBA;
    reg [15:0] r_InRangeA;   //0X0
    reg [15:0] r_InRangeB;
    reg [127:0] r_ASEL;
    reg [127:0] r_BSEL;
    reg [31:0] r_SSREN;

    // 时钟周期参数 (200MHz = 5ns周期)
    parameter CLK_PERIOD = 5.0;
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // 复位信号生成
    initial begin
        rst = 1;                     // 初始复位
        #(CLK_PERIOD * 10) rst = 0;  // 10个时钟周期后释放复位
    end
        // 初始化输入信�?
    initial begin
        i_start_conv = 0;
        i_ad_full_rst = 0;
        i_ad_partial_rst = 0;
        i_ad_channelsel = 16'hF321;
        i_ad_sample_nums = 12'd3;
        i_ad_fifo_read = 0;
        I_AD_BUSY = 0;
        I_SDOA = 0;
        I_SDOB = 0;

        r_BURSTEN      = 1'b0;
        r_SEQEN        = 1'b0;
        r_OS           = 3'b0;
        r_STATUSE      = 1'b0;
        r_CRCEN        = 1'b0;     
        r_ChannelSelBA = 8'h11;
        r_InRangeA     = 16'b00_00_00_00_00_00_00_00;   //0X0
        r_InRangeB     = 16'b00_00_00_00_00_00_00_00;
        r_ASEL         = 128'h01234567_01234567_01234567_01234567;
        r_BSEL         = 128'h01234567_01234567_01234567_01234567;
        r_SSREN        = 32'b00000001_00000000_00000000_00000000;
    end
   // 添加波形输出
    initial begin
        $dumpfile("ad7616_tb.vcd");
        $dumpvars(0, ad7616_softserial_tb);
    end


    // 修改仿真时间
    initial begin
        #(CLK_PERIOD * 50000);        // 仿真5000ns (1000个时钟周�?)
        $display("Simulation finished!");
        $finish;
    end
    // 添加 I_AD_BUSY 信号的响应
    always @(O_CONVST)begin
        if(O_CONVST)begin
            #20;
            #100 I_AD_BUSY = 1;
            #500 I_AD_BUSY = 0;
        end
    end
    // 建议添加 SDOA/SDOB 数据模拟
    reg conv_start_flag,rst_start_flag;
    initial begin 
        conv_start_flag = 0;
        rst_start_flag <= 0;
    end
    
    always @(posedge o_rst_done or posedge o_conv_done) begin
        if(o_rst_done) begin
            conv_start_flag <= 1;
            rst_start_flag <= 0;
            end
        else if(o_conv_done) begin
            rst_start_flag <= 1;
            conv_start_flag = 0;
        end
    end

    always @(negedge O_CSb) begin
        // 模拟串行数据输出
        if(conv_start_flag) begin
            repeat(16) @(posedge O_SCLK) begin
                I_SDOA <= $random;
                I_SDOB <= $random;
            end
        end
        
    end

    initial begin 
        wait(o_rst_done);
        #(CLK_PERIOD * 100);
        i_start_conv = 1;
        #(CLK_PERIOD);
        i_start_conv = 0;

        wait(o_conv_done);
        #(CLK_PERIOD * 100);
        if(rst_start_flag) begin
            #(CLK_PERIOD * 100);
            i_ad_partial_rst <= 1;
            #(CLK_PERIOD * 10);
            i_ad_partial_rst <= 0;  
        end 

        wait(o_rst_done);
        #(CLK_PERIOD * 100);
        i_start_conv = 1;
        #(CLK_PERIOD);
        i_start_conv = 0;
        
        wait(o_conv_done);

        #(CLK_PERIOD * 100);
        i_ad_full_rst <= 1;
        #(CLK_PERIOD * 10);
        i_ad_full_rst <= 0;  
    end
    always @(*)begin
        
    end
AD7616_SoftwareSerial AD7616_SoftwareSerial_1(
    .clk             (clk),
    .rst             (rst),

    .i_ad_start_conv (i_start_conv),
    .i_ad_read_reg   (),
    .i_ad_full_rst   (i_ad_full_rst),
    .i_ad_partial_rst(i_ad_partial_rst),
    .i_ad_channelsel (i_ad_channelsel),  //A[]

    .i_ad_sample_nums(i_ad_sample_nums),

    .o_conv_done     (o_conv_done),
    .o_rst_done      (o_rst_done),

    .o_ad_fifo_empty (o_ad_fifo_empty),
    .i_ad_fifo_read  (i_ad_fifo_read),
    .o_ad_fifo_dout  (o_ad_conv_data),

    .O_RSTSETb       (O_RSTSETb),
    .O_SER_PARb      (O_SER_PARb),
    .O_REFSEL        (O_REFSEL),
    .O_SER1Wb        (O_SER1Wb),

    .O_CONVST        (O_CONVST ),
    .I_AD_BUSY       (I_AD_BUSY),
    .O_CSb           (O_CSb    ),
    .O_SCLK          (O_SCLK   ),
    .O_SDI           (O_SDI    ),
    .I_SDOA          (I_SDOA   ),
    .I_SDOB          (I_SDOB   ),

        // 配置输入端口
    .i_BURSTEN        (r_BURSTEN     )  ,  
    .i_SEQEN          (r_SEQEN       )  ,  
    .i_OS             (r_OS          )  ,  
    .i_STATUSE        (r_STATUSE     )  ,  
    .i_CRCEN          (r_CRCEN       )  ,  
    .i_ChannelSelBA   (r_ChannelSelBA)  ,  
    .i_InRangeA       (r_InRangeA    )  ,  
    .i_InRangeB       (r_InRangeB    )  ,  
    .i_ASEL           (r_ASEL        )  ,  
    .i_BSEL           (r_BSEL        )  ,  
    .i_SSREN          (r_SSREN       )
);
endmodule
