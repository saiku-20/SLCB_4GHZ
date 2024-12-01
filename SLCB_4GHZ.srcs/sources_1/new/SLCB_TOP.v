`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/11 18:46:25
// Design Name: 
// Module Name: SLCB_TOP
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

//(* MARK_DEBUG = "TRUE" *)
module SLCB_TOP(
    input						    clk_50m		        ,//?????????
    input                           clk_25m_p           ,
    input                           clk_25m_n           ,
    input						    rst_n	            ,//????��??????????��??

    input                           gt_refclk_p         ,//gt???��?????????
    input                           gt_refclk_n         ,//gt???��?????????
    
    input                           gt_rx_databus_p           ,//gt??????????????
    input                           gt_rx_databus_n           ,//gt??????????????
    output                          gt_tx_databus_p           ,//gt??????????????
    output                          gt_tx_databus_n           ,//gt??????????????
    
    input                           gt_rx_failbus_p             ,//gt??????????????
    input                           gt_rx_failbus_n             ,//gt??????????????
    output                          gt_tx_failbus_p             ,//gt??????????????
    output                          gt_tx_failbus_n             ,//gt??????????????
    //output      [1  :0]             dislabe  ,                 //?????????????????
    output        [1:0]             O_PE_SPI_RSTb                    ,
    output        [1:0]             O_PE_SPI_SCLK                    ,
    output        [1:0]             O_PE_SPI_CSb                     ,
    input         [1:0]             I_PE_SPI_SDO                     ,
    output        [1:0]             O_PE_SPI_SDI                     ,
    input         [1:0]             I_PE_SPI_BUSYb                  ,

    output                          O_AD_RSTSETb                    ,
    output                          O_AD_SER_PARb                   ,
    output                          O_AD_REFSEL                     ,
    output                          O_AD_SER1Wb                     ,
    output                          O_AD_CONVST                     ,
    output                          O_AD_SPI_RSTb                    ,
    output                          O_AD_SPI_SCLK                    ,
    output                          O_AD_SPI_CSb                     ,
    input                           I_AD_SPI_SDO                     ,
    output                          O_AD_SPI_SDI                     ,
    input                           I_AD_SPI_BUSYb                  ,
                          
    output      [7:0]               led
);
    localparam  clk_200m_nums = 200000000;
    localparam  clk_50m_nums =   50000000;
    localparam  clk_25m_nums =   25000000;
    wire                           system_rst            ;//????��????
    reg                            clk_50m_led           ;
    reg                            clk_200m_led          ;
    reg                            clk_25m_led           ;
    wire                           HARD_ERR_DATABUS      ;
    wire                           SOFT_ERR_DATABUS      ;
    wire                           LANE_UP_DATABUS       ;
    wire                           CHANNEL_UP_DATABUS    ;
    wire                           HARD_ERR_FAILBUS      ;
    wire                           SOFT_ERR_FAILBUS      ;
    wire                           LANE_UP_FAILBUS       ;
    wire                           CHANNEL_UP_FAILBUS    ;
    
    wire                           O_N_WR                 ;
    wire                           O_N_RD                 ;
    wire                           O_N_CE                 ;
    wire          [7:0]            O_PCADD                ;
    wire          [63:0]           O_WRData               ;
     reg          [63:0]           I_RDData               ;
    
    wire                            DataBus_txfifo_en        ;
    wire          [63:0]            DataBus_txfifo_data   ;
    
    wire                            DataBus_rxfifo_empty         ;
    wire                            Databus_rxfifo_alempty       ;
    wire                            DataBus_rxfifo_en    ;
    wire        [63:0]              DataBus_rxfifo_data    ;
    
    wire                            FailBus_txfifo_en        ;
    wire          [63:0]            FailBus_txfifo_data   ;
    
    wire                            FailBus_rxfifo_empty         ;
    wire                            FailBus_rxfifo_alempty       ;
    wire                            FailBus_rxfifo_en    ;
    wire        [63:0]              FailBus_rxfifo_data    ;
    
    wire c_rd_fpga_version;
    wire c_rd_board_version;
    
    wire c_wr_databus_verify;
    wire c_wr_failbus_verify;
    wire c_wr_syncbus_verify;
    wire c_rd_databus_verify;
    wire c_rd_failbus_verify;
    wire c_rd_syncbus_verify;
    
    wire c_wr_pin_en        ;
    wire c_wr_pe_reg_rdwr   ;
    //wire c_wr_reg_read      ; 
    wire c_wr_pe_reg_rst    ;          
    wire c_rd_pin_en        ;
    wire c_rd_pe_reg_read   ;
    //assign dislabe = 2'd0;
    assign led[1:0] = {CHANNEL_UP_DATABUS,CHANNEL_UP_FAILBUS};
    assign led[4:2] = {clk_25m_led,clk_50m_led,clk_200m_led};
    //assign 
    wire clk_200m;
    wire locked;
    //assign clk_i = clk_50m;
    clk_wiz_0 u_clk_wiz_0(
        // Clock out ports
        .clk_out1(clk_200m),     // output clk_out1
        .reset(!rst_n),          // input reset
        .locked(locked),         // output locked
        .clk_in1(clk_50m));      // input clk_in1
    
    //??????��?????�?
    rst_syc_module #(
        .RST_IN_VLD     ( 1'b0      ),//??��??????��?????????????
        .RST_OUT_VLD    ( 1'b1      ),//??��?????��??????????????
        .RST_CYCLE	    ( 8	        ) //???????????
    )
    rst_syc_module (
        .CLK_IN		    ( clk_200m	    ),//?????????
        .rst_n_in       ( rst_n&&(locked)),//??��????????????????��??
        .rst_out        ( system_rst) //??��???????????????��???
    );
    
    wire clk_25m;
    IBUFDS #(
      .DIFF_TERM("FALSE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst (
      .O(clk_25m),  // Buffer output
      .I(clk_25m_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(clk_25m_n) // Diff_n buffer input (connect directly to top-level port)
   );
   
    SLCB_Aurora_Module u_SLCB_Aurora_Module(
          .CKP                  (clk_200m)   ,
          .init_clk             (clk_50m)   ,
          .system_rst           (system_rst)   ,
          .drp_clk              (clk_50m)      ,
                                
          .gt_refclk_p          (gt_refclk_p)   ,
          .gt_refclk_n          (gt_refclk_n)   ,
                                
          .gt_rx_databus_p      (gt_rx_databus_p)   , 
          .gt_rx_databus_n      (gt_rx_databus_n)   ,
          .gt_tx_databus_p      (gt_tx_databus_p)   ,
          .gt_tx_databus_n      (gt_tx_databus_n)   ,
          .gt_rx_failbus_p      (gt_rx_failbus_p)   ,
          .gt_rx_failbus_n      (gt_rx_failbus_n)   ,
          .gt_tx_failbus_p      (gt_tx_failbus_p)   ,
          .gt_tx_failbus_n      (gt_tx_failbus_n)   ,
                                
          .HARD_ERR_DATABUS     (HARD_ERR_DATABUS)   ,
          .SOFT_ERR_DATABUS     (SOFT_ERR_DATABUS)   ,
          .LANE_UP_DATABUS      (LANE_UP_DATABUS)   ,
          .CHANNEL_UP_DATABUS   (CHANNEL_UP_DATABUS)   ,
          .HARD_ERR_FAILBUS     (HARD_ERR_FAILBUS)   ,
          .SOFT_ERR_FAILBUS     (SOFT_ERR_FAILBUS)   ,
          .LANE_UP_FAILBUS      (LANE_UP_FAILBUS)   ,
          .CHANNEL_UP_FAILBUS   (CHANNEL_UP_FAILBUS)   ,
                                
          //RX                  
          .EMPTY_DATABUS        (DataBus_rxfifo_empty)  ,
          .ALEMPTY_DATABUS      (Databus_rxfifo_alempty)  ,
          .RD_DATA_EN_DATABUS   (DataBus_rxfifo_en)  ,
          .O_CAP_DATA_DATABUS   (DataBus_rxfifo_data)  ,
          //TX                     
          .CAP_EN_DATABUS       (DataBus_txfifo_en)  ,
          .IN_CAP_DATA_DATABUS  (DataBus_txfifo_data),
          //RX                  
          .EMPTY_FAILBUS        (FailBus_rxfifo_empty)  ,
          .ALEMPTY_FAILBUS      (FailBus_rxfifo_alempty)  ,
          .RD_DATA_EN_FAILBUS   (FailBus_rxfifo_en)  ,
          .O_CAP_DATA_FAILBUS   (FailBus_rxfifo_data)  ,
          //TX                     
          .CAP_EN_FAILBUS       (FailBus_txfifo_en)  ,
          .IN_CAP_DATA_FAILBUS  (FailBus_txfifo_data)       
      );
      
      wire [15:0] fpga_version_rd_data;
      wire [63:0] adate328_rd_data;
      wire [63:0] databus_check_data;
      wire [63:0] ad7616_rd_data;
      always @(*) begin
        case (1'b1)
            c_rd_fpga_version:  I_RDData = {48'b0,fpga_version_rd_data};
            c_rd_databus_verify:I_RDData = databus_check_data;
            c_rd_failbus_verify:I_RDData = FailBus_rxfifo_data;
            c_rd_pe_reg_read:   I_RDData = adate328_rd_data;
            c_rd_ad_read_data:  I_RDData = ad7616_rd_data;
            default:            I_RDData = 64'd0;
        endcase
      end     

      genvar r;
      parameter   GROUP_NUMS = 2;
      parameter   GROUP_PART_NUM = 1;
      parameter   GROUP_CH_NUM = GROUP_PART_NUM*4;
      parameter   CH_NUMS = 4*GROUP_NUMS*GROUP_PART_NUM;
      wire        [CH_NUMS-1:0]  P_B_Pin_En;
      SYNC_LDC #(CH_NUMS) u_PinEnConfig(P_B_Pin_En,DataBus_rxfifo_data[CH_NUMS-1:0], ~system_rst, c_wr_pin_en, clk_200m);
      
      wire  c_pe_rdwr_en,c_pe_read_en,c_pe_rst_en;
      assign c_pe_rst_en = c_wr_pe_reg_rst;
      assign c_pe_rdwr_en = DataBus_rxfifo_en && (!O_N_CE) && (!O_N_WR) && c_wr_pe_reg_rdwr;
      assign c_pe_read_en = DataBus_txfifo_en && (!O_N_CE) && (!O_N_RD) && c_rd_pe_reg_read;
    SLCB_ADATE328_GEN u_SLCB_ADATE328_GEN(
      .clk           (clk_200m),
      .rst           (system_rst),
      
      .P_B_Pin_En    (P_B_Pin_En[3:0]),
                     
      .C_PE_RST_EN   (c_pe_rst_en),
      .C_PE_RDWR_EN  (c_pe_rdwr_en),
      .C_PE_READ_EN  (c_pe_read_en),
      //.C_PE_REG_RD (),
                   
      .I_PE_WR_DATA     (O_WRData),
      .O_PE_RD_DATA     (adate328_rd_data), //read form spi
      
      .O_SPI_RSTb       (O_PE_SPI_RSTb[0])   ,
      .O_SPI_SCLK       (O_PE_SPI_SCLK[0])   ,
      .O_SPI_CSb        (O_PE_SPI_CSb[0])   ,
      .I_SPI_SDO        (I_PE_SPI_SDO[0])   ,
      .O_SPI_SDI        (O_PE_SPI_SDI[0])   ,

      .I_SPI_BUSYb      (I_PE_SPI_BUSYb[0])
    ); 

wire c_ad_full_rst_en,c_ad_part_rst_en,c_ad_start_conv_en,c_ad_read_reg_en;
assign c_ad_full_rst_en = c_wr_ad_full_rst;
assign c_ad_part_rst_en = c_wr_ad_part_rst;
assign c_ad_start_conv_en = c_wr_ad_start_conv;
assign c_ad_read_reg_en = c_rd_ad_read_reg;  //reverse
assign c_ad_read_data_en = DataBus_txfifo_en && (!O_N_CE) && (!O_N_RD) && c_rd_ad_read_data;
assign c_ad_reg_config_en = DataBus_rxfifo_en && (!O_N_CE) && (!O_N_WR) && c_wr_ad_reg_config;
ad7616_softserial_GEN  #(
    .AD_REG_PREAMBLE(32'h5A5A_A5A5),
    .TIMEOUT_VALUE(10'd1000)    
) u_ad7616_softserial_GEN(
    .clk                (clk_200m),                    // 系统时钟
    .rst                (system_rst),                    // 复位信号
    
    .P_B_Pin_En         (P_B_Pin_En[15:0]),            // [15:0] 引脚使能
    // Control signals
    .C_AD_FULL_RST_EN   (c_ad_full_rst_en),      // 完全复位使能
    .C_AD_PART_RST_EN   (c_ad_part_rst_en),      // 部分复位使能
    .C_AD_START_CONV_EN (c_ad_start_conv_en),    // 开始转换使能
    .C_AD_READ_REG_EN   (c_ad_read_reg_en),      // 读寄存器使能
    .C_AD_READ_DATA_EN  (c_ad_read_data_en),     // 读数据使能

    .C_AD_REG_CONFIG_EN (c_ad_reg_config_en),    // 寄存器配置使能
    // Data interface
    .I_AD_WR_DATA       (DataBus_txfifo_data),          // [63:0] 写入ADC的数据
    .O_AD_RD_DATA       (ad7616_rd_data),          // [63:0] 从ADC读出的数据
    
    // AD7616 interface signals
    .O_RSTSETb          (O_AD_RSTSETb),             // 复位控制
    .O_SER_PARb         (O_AD_SER_PARb),            // 串/并行选择
    .O_REFSEL           (O_AD_REFSEL),              // 参考电压选择
    .O_SER1Wb           (O_AD_SER1Wb),              // 串行接口模式选择
    .O_CONVST           (O_AD_CONVST),              // 转换启动信号
    .I_AD_BUSY          (I_AD_SPI_BUSY),             // AD忙标志
    .O_CSb              (O_AD_SPI_CSb),                 // 片选信号
    .O_SCLK             (O_AD_SPI_SCLK),                // 串行时钟
    .O_SDI              (O_AD_SPI_SDI),                 // 串行数据输入
    .I_SDOA             (I_AD_SPI_SDOA),                // 串行数据输出A
    .I_SDOB             (I_AD_SPI_SDOB)                 // 串行数据输出B
);

      ////use to calculate the speed
      //reg [24:0] rx_cnt;
      //reg [6:0]  rx_rst_cnt;
      //always@(posedge clk_200m)begin
      //  if(DataBus_rxfifo_en)
      //      rx_cnt <= rx_cnt + 1'd1;
      //  else if(&rx_rst_cnt)
      //      rx_cnt <= 25'd0;
      //end
      //always@(posedge clk_200m)begin
      //  if(!DataBus_rxfifo_en)
      //      rx_rst_cnt <= rx_rst_cnt + 1'd1;
      //  else 
      //      rx_rst_cnt <= 7'd0;
      //end
    
/*
//????spi��??
    SLCB_SPI_offline_Debug u_SLCB_SPI_offline_Debug(
        .clk            (clk_200m),
        .rst            (system_rst),
        .o_write        (write) ,
        .o_read         (read) ,
        .o_pe_rst       (pe_rst) , 
        .i_read_done     (read_done)     ,
        .i_write_done    (write_done)     ,
        .i_reset_done    (reset_done)     ,
        .o_send_data     (send_data)     ,
        .i_recive_data   (recive_data)     ,
        .I_SPI_BUSYb     (SPI_BUSYb)
    );
 */   
        
    SLCB_DataBus_Check  u_SLCB_DataBus_Check(
        .CLK_IN  (clk_200m)             ,
        .RESET   (system_rst)           ,
                 
        .DATA_WR (c_wr_databus_verify)  ,
        .DATA_IN (O_WRData)             ,
                 
        .DATA_RD (c_rd_databus_verify)  ,
        .DATA_OUT(databus_check_data)
    );
    

    SLCB_Version_Read u_SLCB_Version_Read (
        .RESET              (system_rst),             // Input: Reset signal
        .CLK_IN             (clk_200m),            // Input: Clock signal
        .VERSION_RD         (c_rd_fpga_version),        // Input: Version read control
        .FPGA_ID_RD         (),        // Input: FPGA ID read control
        .FPGA_VER_ID_DATA   (fpga_version_rd_data)   // Output: 16-bit version/ID data
    );
      

    SLCB_DataBus_Unpacking_Module u_SLCB_DataBus_Unpacking_Module(
        .RESET                (system_rst)   ,
        .CLK                  (clk_200m)   ,
                              
        .DataBus_txfifo_en    (DataBus_txfifo_en)   ,
        .DataBus_txfifo_data  (DataBus_txfifo_data)   ,
        
        .DataBus_rxfifo_en    (DataBus_rxfifo_en)   ,
        .DataBus_rxfifo_data  (DataBus_rxfifo_data)   ,
        .DataBus_rxfifo_empty (DataBus_rxfifo_empty)   ,
                              
        .O_N_WR               (O_N_WR)      ,
        .O_N_RD               (O_N_RD)      ,
        .O_N_CE               (O_N_CE)      ,
        .O_PCADD              (O_PCADD)     ,
        .O_WRData             (O_WRData)    ,
        .I_RDData             (I_RDData)   
        //.O_SLCB_CTRL_STATE    ()           
    );

      wire [7:0] WR_CON_C1 ,WR_CON_C2 ,WR_CON_C3 ,WR_CON_C4 ,WR_CON_C5 ,WR_CON_C6 ,WR_CON_C7 ,WR_CON_C8 ;
      wire [7:0] WR_CON_C9 ,WR_CON_C10,WR_CON_C11,WR_CON_C12,WR_CON_C13,WR_CON_C14,WR_CON_C15,WR_CON_C16;
      wire [7:0] WR_CON_C17,WR_CON_C18,WR_CON_C19,WR_CON_C20,WR_CON_C21,WR_CON_C22,WR_CON_C23,WR_CON_C24;
      wire [7:0] WR_CON_C25,WR_CON_C26,WR_CON_C27,WR_CON_C28,WR_CON_C29,WR_CON_C30,WR_CON_C31,WR_CON_C32;
      wire [7:0] WR_CON_C33,WR_CON_C34,WR_CON_C35,WR_CON_C36,WR_CON_C37,WR_CON_C38,WR_CON_C39,WR_CON_C40;
      wire [7:0] WR_CON_C41,WR_CON_C42,WR_CON_C43,WR_CON_C44,WR_CON_C45,WR_CON_C46,WR_CON_C47,WR_CON_C48;
      wire [7:0] WR_CON_C49,WR_CON_C50,WR_CON_C51,WR_CON_C52,WR_CON_C53,WR_CON_C54,WR_CON_C55,WR_CON_C56;
      wire [7:0] WR_CON_C57,WR_CON_C58,WR_CON_C59,WR_CON_C60,WR_CON_C61,WR_CON_C62,WR_CON_C63,WR_CON_C64;
      
      wire [7:0] RD_CON_C1 ,RD_CON_C2 ,RD_CON_C3 ,RD_CON_C4 ,RD_CON_C5 ,RD_CON_C6 ,RD_CON_C7 ,RD_CON_C8 ;
      wire [7:0] RD_CON_C9 ,RD_CON_C10,RD_CON_C11,RD_CON_C12,RD_CON_C13,RD_CON_C14,RD_CON_C15,RD_CON_C16;
      wire [7:0] RD_CON_C17,RD_CON_C18,RD_CON_C19,RD_CON_C20,RD_CON_C21,RD_CON_C22,RD_CON_C23,RD_CON_C24;
      wire [7:0] RD_CON_C25,RD_CON_C26,RD_CON_C27,RD_CON_C28,RD_CON_C29,RD_CON_C30,RD_CON_C31,RD_CON_C32;
      wire [7:0] RD_CON_C33,RD_CON_C34,RD_CON_C35,RD_CON_C36,RD_CON_C37,RD_CON_C38,RD_CON_C39,RD_CON_C40;
      wire [7:0] RD_CON_C41,RD_CON_C42,RD_CON_C43,RD_CON_C44,RD_CON_C45,RD_CON_C46,RD_CON_C47,RD_CON_C48;
      wire [7:0] RD_CON_C49,RD_CON_C50,RD_CON_C51,RD_CON_C52,RD_CON_C53,RD_CON_C54,RD_CON_C55,RD_CON_C56;
      wire [7:0] RD_CON_C57,RD_CON_C58,RD_CON_C59,RD_CON_C60,RD_CON_C61,RD_CON_C62,RD_CON_C63,RD_CON_C64; 

        DECODER_64 u_DECODER_64(  
                   .CLK         (clk_200m), 
                   .N_CARD_EN   (O_N_CE), 
                   .N_RD        (O_N_RD), 
                   .N_WR        (O_N_WR), 
                   .PC_ADD      ({0,O_PCADD}),
                   .WR_EN       (64'h0),  
                   .I_DEData    (I_RDData), 
                   .O_DEData    (O_WRData),
                   .WR_CON_C1 (WR_CON_C1),    .WR_CON_C2 (WR_CON_C2),   .WR_CON_C3 (WR_CON_C3),   .WR_CON_C4 (WR_CON_C4),   .WR_CON_C5 (WR_CON_C5),   .WR_CON_C6 (WR_CON_C6),   .WR_CON_C7 (WR_CON_C7),   .WR_CON_C8 (WR_CON_C8),
                   .WR_CON_C9 (WR_CON_C9),    .WR_CON_C10(WR_CON_C10),  .WR_CON_C11(WR_CON_C11),  .WR_CON_C12(WR_CON_C12),  .WR_CON_C13(WR_CON_C13),  .WR_CON_C14(WR_CON_C14),  .WR_CON_C15(WR_CON_C15),  .WR_CON_C16(WR_CON_C16),
                   .WR_CON_C17(WR_CON_C17),   .WR_CON_C18(WR_CON_C18),  .WR_CON_C19(WR_CON_C19),  .WR_CON_C20(WR_CON_C20),  .WR_CON_C21(WR_CON_C21),  .WR_CON_C22(WR_CON_C22),  .WR_CON_C23(WR_CON_C23),  .WR_CON_C24(WR_CON_C24),
                   .WR_CON_C25(WR_CON_C25),   .WR_CON_C26(WR_CON_C26),  .WR_CON_C27(WR_CON_C27),  .WR_CON_C28(WR_CON_C28),  .WR_CON_C29(WR_CON_C29),  .WR_CON_C30(WR_CON_C30),  .WR_CON_C31(WR_CON_C31),  .WR_CON_C32(WR_CON_C32),
                   .WR_CON_C33(WR_CON_C33),   .WR_CON_C34(WR_CON_C34),  .WR_CON_C35(WR_CON_C35),  .WR_CON_C36(WR_CON_C36),  .WR_CON_C37(WR_CON_C37),  .WR_CON_C38(WR_CON_C38),  .WR_CON_C39(WR_CON_C39),  .WR_CON_C40(WR_CON_C40),
                   .WR_CON_C41(WR_CON_C41),   .WR_CON_C42(WR_CON_C42),  .WR_CON_C43(WR_CON_C43),  .WR_CON_C44(WR_CON_C44),  .WR_CON_C45(WR_CON_C45),  .WR_CON_C46(WR_CON_C46),  .WR_CON_C47(WR_CON_C47),  .WR_CON_C48(WR_CON_C48),
                   .WR_CON_C49(WR_CON_C49),   .WR_CON_C50(WR_CON_C50),  .WR_CON_C51(WR_CON_C51),  .WR_CON_C52(WR_CON_C52),  .WR_CON_C53(WR_CON_C53),  .WR_CON_C54(WR_CON_C54),  .WR_CON_C55(WR_CON_C55),  .WR_CON_C56(WR_CON_C56),
                   .WR_CON_C57(WR_CON_C57),   .WR_CON_C58(WR_CON_C58),  .WR_CON_C59(WR_CON_C59),  .WR_CON_C60(WR_CON_C60),  .WR_CON_C61(WR_CON_C61),  .WR_CON_C62(WR_CON_C62),  .WR_CON_C63(WR_CON_C63),  .WR_CON_C64(WR_CON_C64),

                   .RD_CON_C1 (RD_CON_C1 ),  .RD_CON_C2 (RD_CON_C2 ),  .RD_CON_C3 (RD_CON_C3 ),  .RD_CON_C4 (RD_CON_C4 ),  .RD_CON_C5 (RD_CON_C5 ),  .RD_CON_C6 (RD_CON_C6 ),  .RD_CON_C7 (RD_CON_C7 ),  .RD_CON_C8 (RD_CON_C8 ),
                   .RD_CON_C9 (RD_CON_C9 ),  .RD_CON_C10(RD_CON_C10),  .RD_CON_C11(RD_CON_C11),  .RD_CON_C12(RD_CON_C12),  .RD_CON_C13(RD_CON_C13),  .RD_CON_C14(RD_CON_C14),  .RD_CON_C15(RD_CON_C15),  .RD_CON_C16(RD_CON_C16),
                   .RD_CON_C17(RD_CON_C17),  .RD_CON_C18(RD_CON_C18),  .RD_CON_C19(RD_CON_C19),  .RD_CON_C20(RD_CON_C20),  .RD_CON_C21(RD_CON_C21),  .RD_CON_C22(RD_CON_C22),  .RD_CON_C23(RD_CON_C23),  .RD_CON_C24(RD_CON_C24),
                   .RD_CON_C25(RD_CON_C25),  .RD_CON_C26(RD_CON_C26),  .RD_CON_C27(RD_CON_C27),  .RD_CON_C28(RD_CON_C28),  .RD_CON_C29(RD_CON_C29),  .RD_CON_C30(RD_CON_C30),  .RD_CON_C31(RD_CON_C31),  .RD_CON_C32(RD_CON_C32),
                   .RD_CON_C33(RD_CON_C33),  .RD_CON_C34(RD_CON_C34),  .RD_CON_C35(RD_CON_C35),  .RD_CON_C36(RD_CON_C36),  .RD_CON_C37(RD_CON_C37),  .RD_CON_C38(RD_CON_C38),  .RD_CON_C39(RD_CON_C39),  .RD_CON_C40(RD_CON_C40),
                   .RD_CON_C41(RD_CON_C41),  .RD_CON_C42(RD_CON_C42),  .RD_CON_C43(RD_CON_C43),  .RD_CON_C44(RD_CON_C44),  .RD_CON_C45(RD_CON_C45),  .RD_CON_C46(RD_CON_C46),  .RD_CON_C47(RD_CON_C47),  .RD_CON_C48(RD_CON_C48),
                   .RD_CON_C49(RD_CON_C49),  .RD_CON_C50(RD_CON_C50),  .RD_CON_C51(RD_CON_C51),  .RD_CON_C52(RD_CON_C52),  .RD_CON_C53(RD_CON_C53),  .RD_CON_C54(RD_CON_C54),  .RD_CON_C55(RD_CON_C55),  .RD_CON_C56(RD_CON_C56),
                   .RD_CON_C57(RD_CON_C57),  .RD_CON_C58(RD_CON_C58),  .RD_CON_C59(RD_CON_C59),  .RD_CON_C60(RD_CON_C60),  .RD_CON_C61(RD_CON_C61),  .RD_CON_C62(RD_CON_C62),  .RD_CON_C63(RD_CON_C63),  .RD_CON_C64(RD_CON_C64)  
           );
    
    assign c_rd_fpga_version        =       RD_CON_C1[0];
    assign c_rd_board_version       =       RD_CON_C1[1];
    
    assign c_wr_databus_verify      =       WR_CON_C1[3];
    assign c_wr_failbus_verify      =       WR_CON_C1[4];
    assign c_wr_syncbus_verify      =       WR_CON_C1[6];
    
    assign c_rd_databus_verify      =       RD_CON_C1[3];
    assign c_rd_failbus_verify      =       RD_CON_C1[4];
    assign c_rd_syncbus_verify      =       RD_CON_C1[6];
    
    assign c_wr_pin_en              =       WR_CON_C2[0];
    assign c_wr_pe_reg_rdwr         =       WR_CON_C2[1];
    assign c_wr_pe_reg_rst          =       WR_CON_C2[2];

    assign c_wr_ad_full_rst         =       WR_CON_C2[3];
    assign c_wr_ad_part_rst         =       WR_CON_C2[4];
    assign c_wr_ad_start_conv       =       WR_CON_C2[5];
    assign c_wr_ad_reg_config       =       WR_CON_C2[6];    
    
    assign c_rd_pin_en              =       RD_CON_C2[0];
    assign c_rd_pe_reg_read         =       RD_CON_C2[1];
    assign c_rd_ad_read_reg         =       RD_CON_C2[2];
    assign c_rd_ad_read_data        =       RD_CON_C2[3];
    //assign c_rd_pin_rd              =       WR_CON_C2[2];
    
    
    
//assign s_axi_tx_tdata_0 = 64'hA5A5A5A5_5A5A5A5A;
//assign s_axi_tx_tdata_1 = 64'hAAAAAAAA_55555555;
//assign s_axi_tx_tvalid_0 = 1'd1;
//assign s_axi_tx_tvalid_1 = 1'd1;
ila_0 u_ila_0 (
	.clk(clk_200m), // input wire clk
	.probe0(clk_50m), // input wire [0:0]  probe0  
	.probe1(clk_25m), // input wire [0:0]  probe1 
	.probe2(DataBus_txfifo_en), // input wire [0:0]  probe2 
	.probe3(DataBus_txfifo_data), // input wire [63:0]  probe3 
	.probe4(DataBus_rxfifo_en), // input wire [0:0]  probe4 
	.probe5(DataBus_rxfifo_data), // input wire [63:0]  probe5 
	.probe6(DataBus_rxfifo_empty), // input wire [0:0]  probe6 
	.probe7(O_N_WR), // input wire [0:0]  probe7 
	.probe8(O_N_RD), // input wire [0:0]  probe8 
	.probe9(O_N_CE), // input wire [0:0]  probe9 
	.probe10(O_PCADD), // input wire [7:0]  probe10 
	.probe11(O_WRData), // input wire [63:0]  probe11 
	.probe12(I_RDData), // input wire [63:0]  probe12 
	.probe13(LANE_UP_DATABUS), // input wire [0:0]  probe13 
	.probe14(CHANNEL_UP_DATABUS), // input wire [0:0]  probe14 
	.probe15(SPI_RSTb), // input wire [0:0]  probe15 
	.probe16(SPI_SCLK), // input wire [0:0]  probe16 
	.probe17(c_wr_databus_verify), // input wire [0:0]  probe17 
	.probe18(c_rd_databus_verify), // input wire [0:0]  probe18 
	.probe19(SPI_BUSYb), // input wire [0:0]  probe19
	.probe20(rx_cnt),
	.probe21(rx_rst_cnt)
);

ila_1 u_ila_1 (
	.clk(clk_200m), // input wire clk
	.probe0(system_rst), // input wire [0:0]  probe0  
	.probe1(write), // input wire [0:0]  probe1 
	.probe2(read), // input wire [0:0]  probe2 
	.probe3(pe_rst), // input wire [0:0]  probe3 
	.probe4(read_done), // input wire [0:0]  probe4 
	.probe5(read_done), // input wire [0:0]  probe5 
	.probe6(reset_done), // input wire [0:0]  probe6 
	.probe7(DataBus_txfifo_en), // input wire [0:0]  probe7 
	.probe8(send_data), // input wire [28:0]  probe8 
	.probe9(recive_data), // input wire [28:0]  probe9 
	.probe10(SPI_RSTb), // input wire [0:0]  probe10 
	.probe11(SPI_SCLK), // input wire [0:0]  probe11 
	.probe12(SPI_CSb), // input wire [0:0]  probe12 
	.probe13(SPI_SDO), // input wire [0:0]  probe13 
	.probe14(SPI_SDI), // input wire [0:0]  probe14 
	.probe15(SPI_BUSYb), // input wire [0:0]  probe15 
	.probe16(DataBus_rxfifo_en), // input wire [0:0]  probe16 
	.probe17(DataBus_rxfifo_empty), // input wire [0:0]  probe17 
	.probe18(c_wr_databus_verify), // input wire [0:0]  probe18 
	.probe19(c_rd_databus_verify) // input wire [0:0]  probe19
);

    reg [27:0]  clk_200m_cnt;
    reg [25:0]  clk_50m_cnt; 
    reg [24:0]  clk_25m_cnt;
    always@(posedge clk_200m or posedge system_rst)begin
        if(system_rst)begin
            clk_200m_cnt    <=  28'b0;
            clk_200m_led    <=  1'b0;
        end
        else if(clk_200m_cnt == clk_200m_nums)begin
            clk_200m_cnt    <=  28'b0;
            clk_200m_led    <=  ~clk_200m_led;
        end   
        else
            clk_200m_cnt    <=  clk_200m_cnt + 1'd1;
    end
    always@(posedge clk_50m or posedge system_rst)begin
        if(system_rst)begin
            clk_50m_cnt     <=  26'b0;
            clk_50m_led     <=  1'b0;
        end
        else if(clk_50m_cnt == clk_50m_nums)begin
            clk_50m_cnt    <=  26'b0;
            clk_50m_led    <=  ~clk_50m_led;
        end
        else
            clk_50m_cnt     <=   clk_50m_cnt + 1'd1;  
    end
    always@(posedge clk_25m or posedge system_rst)begin
        if(system_rst)begin
            clk_25m_cnt     <=  25'b0;
            clk_25m_led     <=  1'b0;
        end
        else if(clk_25m_cnt == clk_25m_nums)begin
            clk_25m_cnt    <=  25'b0;
            clk_25m_led    <=  ~clk_25m_led;
        end
        else
            clk_25m_cnt     <=   clk_25m_cnt + 1'd1;  
    end
endmodule
