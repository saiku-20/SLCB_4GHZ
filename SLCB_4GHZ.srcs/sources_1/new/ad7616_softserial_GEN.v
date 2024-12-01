
// Note: RESET signal is already synchronized in the top level module
// 注意：复位信号已在顶层模块完成同步
module ad7616_softserial_GEN #(
    parameter   TIMEOUT_VALUE = 10'd1000,
    parameter   AD_REG_PREAMBLE = 32'h5A5A_A5A5
)(
    input               clk                     ,    
    input               rst                     ,

    input     [15:0]    P_B_Pin_En              ,

    input               C_AD_FULL_RST_EN        ,
    input               C_AD_PART_RST_EN        ,
    input               C_AD_START_CONV_EN      ,
    input               C_AD_READ_REG_EN        ,
    input               C_AD_READ_DATA_EN       ,   

    input               C_AD_REG_CONFIG_EN      ,

    input      [63:0]   I_AD_WR_DATA            , //WRITE TO ADC
    output reg [63:0]   O_AD_RD_DATA            ,

    output   reg        O_RSTSETb,         // 复位控制信号 / Reset control signal
    output   reg        O_SER_PARb,        // 串/并行选择信号 / Serial/Parallel selection       //
    output   reg        O_REFSEL,          // 参考电压选择 / Reference voltage selection        //
    output   reg        O_SER1Wb,          // 串行接口模式选择 / Serial interface mode selection //
    output   reg        O_CONVST,          // 转换启动信号 / Conversion start signal
    input               I_AD_BUSY,         // AD忙标志 / AD busy flag
    output   reg        O_CSb,             // 片选信号 / Chip select signal
    output   reg        O_SCLK,            // 串行时钟 / Serial clock
    output   reg        O_SDI,             // 串行数据输入 / Serial data input
    input               I_SDOA,            // 串行数据输出A / Serial data output A
    input               I_SDOB             // 串行数据输出B / Serial data output B

);
// Internal signals for AD7616
    wire        ad_conv_done;
    wire        ad_rst_done;

    wire        ad_fifo_empty;
    wire        ad_fifo_read;
    //wire [63:0] ad_fifo_dout;
    
    // Configuration parameters (you may need to adjust these values)
    reg [15:0] SampleNums   ;
    reg        Reserved     ;
    reg        BURSTEN      ;// Burst mode disabled
    reg        SEQEN        ;// Sequencer disabled
    reg [2:0]  OS           ;// No oversampling
    reg        STATUSE      ;// Status disabled
    reg        CRCEN        ;// CRC disabled
    reg [7:0]  ChannelSelBA ;// Default channel selection
    reg [15:0] InRangeA     ; // Default input range A
    reg [15:0] InRangeB     ; // Default input range B
    reg [127:0] ASEL        ; // Default A channel sequence
    reg [127:0] BSEL        ; // Default B channel sequence
    reg [31:0] SSREN        ; // Default sequence stack register


    localparam ST_IDLE          = 4'd0;
    localparam ST_CONFIG_RANGE  = 4'd1;
    localparam ST_CONFIG_ASEL_H = 4'd2;
    localparam ST_CONFIG_ASEL_L = 4'd3;
    localparam ST_CONFIG_BSEL_H = 4'd4;
    localparam ST_CONFIG_BSEL_L = 4'd5;

    reg [3:0] config_reg_state;   
    //reg [3:0] Reserved0;
    reg [0:0] Reserved1;
    //localparam [47:0] AD_REG_PREAMBLE = 48'h5A5A_A5A5;
    reg [31:0] timeout_cnt;
    //localparam TIMEOUT_VALUE = 10'd1000; 

    // Timeout counter logic
    always @(posedge clk) begin
        if(rst)
            timeout_cnt <= 32'd0;
        else if(C_AD_REG_CONFIG_EN || config_reg_state == ST_IDLE)
            timeout_cnt <= 32'd0;
        else
            timeout_cnt <= timeout_cnt + 1'd1;
    end

    always@(posedge clk)begin
        if(rst)begin
            config_reg_state <= ST_IDLE;
            //Reserved0         <= 4'b0;
            SampleNums        <= 16'd0;
            Reserved1         <= 1'b0;
            BURSTEN          <= 1'b0;
            SEQEN            <= 1'b0;
            OS               <= 3'b0;
            STATUSE          <= 1'b0;
            CRCEN            <= 1'b0;     
            ChannelSelBA     <= 8'h11;
            InRangeA         <= 16'b00_00_00_00_00_00_00_00;   //0X0
            InRangeB         <= 16'b00_00_00_00_00_00_00_00;
            ASEL             <= 128'h01234567_01234567_01234567_01234567;
            BSEL             <= 128'h01234567_01234567_01234567_01234567;
            SSREN            <= 32'b00000001_00000000_00000000_00000000;
        end 
        else if(C_AD_REG_CONFIG_EN && (timeout_cnt < TIMEOUT_VALUE))begin
            case(config_reg_state)
                ST_IDLE:begin
                    if(I_AD_WR_DATA[63:32] == AD_REG_PREAMBLE)begin
                        //Reserved0    <= I_AD_WR_DATA[31:28];
                        SampleNums   <= I_AD_WR_DATA[31:16];  // 采样次数16bits
                        Reserved1    <= I_AD_WR_DATA[15];
                        BURSTEN      <= I_AD_WR_DATA[14];
                        SEQEN        <= I_AD_WR_DATA[13];
                        OS           <= I_AD_WR_DATA[12:10];
                        STATUSE      <= I_AD_WR_DATA[9];
                        CRCEN        <= I_AD_WR_DATA[8];
                        ChannelSelBA <= I_AD_WR_DATA[7:0];
                        config_reg_state <= ST_CONFIG_RANGE;
                    end
                end
                ST_CONFIG_RANGE:begin
                    InRangeA     <= I_AD_WR_DATA[63:48];
                    InRangeB     <= I_AD_WR_DATA[47:32];
                    SSREN        <= I_AD_WR_DATA[31:0];
                    config_reg_state <= ST_CONFIG_ASEL_H;
                end
                ST_CONFIG_ASEL_H:begin ASEL[127:64]         <= I_AD_WR_DATA;config_reg_state <= ST_CONFIG_ASEL_L;end
                ST_CONFIG_ASEL_L:begin ASEL[63:0]           <= I_AD_WR_DATA;config_reg_state <= ST_CONFIG_BSEL_H;end
                ST_CONFIG_BSEL_H:begin BSEL[127:64]         <= I_AD_WR_DATA;config_reg_state <= ST_CONFIG_BSEL_L;end
                ST_CONFIG_BSEL_L:begin BSEL[63:0]           <= I_AD_WR_DATA;config_reg_state <= ST_IDLE;end
                default:begin config_reg_state <= ST_IDLE;end
            endcase
        end
        else
            config_reg_state <= ST_IDLE;
    end
    // Update O_PE_RD_DATA based on FIFO output


    assign ad_fifo_read = C_AD_READ_DATA_EN && !ad_fifo_empty;


    AD7616_SoftwareSerial u_AD7616_SoftwareSerial(
        .clk                (clk),
        .rst                (rst),
        // Control signals
        .i_ad_start_conv    (C_AD_START_CONV_EN),
        .i_ad_read_reg      (C_AD_READ_REG_EN),
        .i_ad_full_rst      (C_AD_FULL_RST_EN),
        .i_ad_partial_rst   (C_AD_PART_RST_EN),
        .i_ad_channelsel    (P_B_Pin_En),
        .i_ad_sample_nums   (SampleNums),  
        
        // Status outputs
        .o_conv_done        (ad_conv_done),
        .o_rst_done         (ad_rst_done),
        
        // FIFO interface
        .o_ad_fifo_empty    (ad_fifo_empty),
        .i_ad_fifo_read     (ad_fifo_read),  // Always ready to read
        .o_ad_fifo_dout     (O_AD_RD_DATA),
        
        // AD7616 interface signals
        .O_RSTSETb          (O_RSTSETb),
        .O_SER_PARb         (O_SER_PARb),
        .O_REFSEL           (O_REFSEL),
        .O_SER1Wb           (O_SER1Wb),
        .O_CONVST           (O_CONVST),
        .I_AD_BUSY          (I_AD_BUSY),  // Connect to actual BUSY signal if available
        .O_CSb              (O_CSb),
        .O_SCLK             (ad_SCLK),
        .O_SDI              (ad_SDI),
        .I_SDOA             (I_SDOA),  // Connect to actual SDOA if available
        .I_SDOB             (I_SDOB),  // Connect to actual SDOB if available
        
        // Configuration parameters
        .i_BURSTEN          (BURSTEN),
        .i_SEQEN            (SEQEN),
        .i_OS               (OS),
        .i_STATUSE          (STATUSE),
        .i_CRCEN            (CRCEN),
        .i_ChannelSelBA     (ChannelSelBA),
        .i_InRangeA         (InRangeA),
        .i_InRangeB         (InRangeB),
        .i_ASEL             (ASEL),
        .i_BSEL             (BSEL),
        .i_SSREN            (SSREN)
    );


endmodule
