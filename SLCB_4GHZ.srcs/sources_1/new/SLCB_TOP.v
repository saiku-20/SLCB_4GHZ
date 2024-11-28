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
    output        [1:0]             SPI_RSTb                    ,
    output        [1:0]             SPI_SCLK                    ,
    output        [1:0]             SPI_CSb                     ,
    input         [1:0]             SPI_SDO                     ,
    output        [1:0]             SPI_SDI                     ,
    input         [1:0]             SPI_BUSYb                  ,
                          
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
    
    wire                O_N_WR            ;
    wire                O_N_RD            ;
    wire                O_N_CE            ;
    wire          [7:0] O_PCADD           ;
    wire          [63:0] O_WRData          ;
    wire          [63:0] I_RDData          ;
    
    wire                            CAP_EN_DATABUS        ;
    wire          [63:0]            IN_CAP_DATA_DATABUS   ;
    
    wire                            EMPTY_DATABUS         ;
    wire                            ALEMPTY_DATABUS       ;
    wire                            RD_DATA_EN_DATABUS    ;
    wire        [63:0]              O_CAP_DATA_DATABUS    ;
    
    wire                            CAP_EN_FAILBUS        ;
    wire          [63:0]            IN_CAP_DATA_FAILBUS   ;
    
    wire                            EMPTY_FAILBUS         ;
    wire                            ALEMPTY_FAILBUS       ;
    wire                            RD_DATA_EN_FAILBUS    ;
    wire        [63:0]              O_CAP_DATA_FAILBUS    ;
    
    wire c_rd_fpga_version;
    wire c_rd_board_version;
    
    wire c_wr_databus_verify;
    wire c_wr_failbus_verify;
    wire c_wr_syncbus_verify;
    wire c_rd_databus_verify;
    wire c_rd_failbus_verify;
    wire c_rd_syncbus_verify;
    
    wire c_wr_pin_en        ;
    wire c_wr_reg_rdwr      ;
    //wire c_wr_reg_read      ; 
    wire c_wr_reg_rst       ;          
    wire c_rd_pin_en        ;
    wire c_rd_reg_read      ;
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
          .EMPTY_DATABUS        (EMPTY_DATABUS)  ,
          .ALEMPTY_DATABUS      (ALEMPTY_DATABUS)  ,
          .RD_DATA_EN_DATABUS   (RD_DATA_EN_DATABUS)  ,
          .O_CAP_DATA_DATABUS   (O_CAP_DATA_DATABUS)  ,
          //TX                     
          .CAP_EN_DATABUS       (CAP_EN_DATABUS)  ,
          .IN_CAP_DATA_DATABUS  (IN_CAP_DATA_DATABUS),
          //RX                  
          .EMPTY_FAILBUS        (EMPTY_FAILBUS)  ,
          .ALEMPTY_FAILBUS      (ALEMPTY_FAILBUS)  ,
          .RD_DATA_EN_FAILBUS   (RD_DATA_EN_FAILBUS)  ,
          .O_CAP_DATA_FAILBUS   (O_CAP_DATA_FAILBUS)  ,
          //TX                     
          .CAP_EN_FAILBUS       (CAP_EN_FAILBUS)  ,
          .IN_CAP_DATA_FAILBUS  (IN_CAP_DATA_FAILBUS)       
      );
      
      genvar r;
      parameter   GROUP_NUMS = 2;
      parameter   GROUP_PART_NUM = 1;
      parameter   GROUP_CH_NUM = GROUP_PART_NUM*4;
      parameter   CH_NUMS = 4*GROUP_NUMS*GROUP_PART_NUM;
      wire        [CH_NUMS-1:0]  P_B_Pin_En;
      SYNC_LDC #(CH_NUMS) u_PinEnConfig(P_B_Pin_En,O_CAP_DATA_DATABUS[CH_NUMS-1:0], ~system_rst, c_wr_pin_en, clk_200m);
      
      wire  c_pe_rdwr_en,c_pe_read_en,c_pe_rst_en;
      assign c_pe_rst_en = c_wr_reg_rst;
      assign c_pe_rdwr_en = RD_DATA_EN_DATABUS && (!O_N_CE) && (!O_N_WR) && c_wr_reg_rdwr;
      assign c_pe_read_en = CAP_EN_DATABUS && (!O_N_CE) && (!O_N_RD)&& c_rd_reg_read;
    SLCB_ADATE328_GEN u_SLCB_ADATE328_GEN(
      .clk           (clk_200m),
      .rst           (system_rst),
      
      .P_B_Pin_En    (P_B_Pin_En[3:0]),
                     
    //  .C_WR_PIN_EN   (c_wr_pin_en),
      .C_PE_RST_EN   (c_pe_rst_en),
      .C_PE_RDWR_EN  (c_pe_rdwr_en),
      .C_PE_READ_EN  (c_pe_read_en),
      //.C_PE_REG_RD (),
                   
      .I_PE_WR_DATA     (O_CAP_DATA_DATABUS),
      .O_PE_RD_DATA     (O_PE_RD_DATA),
      
      .O_SPI_RSTb       (SPI_RSTb[0])   ,
      .O_SPI_SCLK       (SPI_SCLK[0])   ,
      .O_SPI_CSb        (SPI_CSb[0])   ,
      .I_SPI_SDO        (SPI_SDO[0])   ,
      .O_SPI_SDI        (SPI_SDI[0])   ,

      .I_SPI_BUSYb      (SPI_BUSYb[0])
    ); 
      ////use to calculate the speed
      //reg [24:0] rx_cnt;
      //reg [6:0]  rx_rst_cnt;
      //always@(posedge clk_200m)begin
      //  if(RD_DATA_EN_DATABUS)
      //      rx_cnt <= rx_cnt + 1'd1;
      //  else if(&rx_rst_cnt)
      //      rx_cnt <= 25'd0;
      //end
      //always@(posedge clk_200m)begin
      //  if(!RD_DATA_EN_DATABUS)
      //      rx_rst_cnt <= rx_rst_cnt + 1'd1;
      //  else 
      //      rx_rst_cnt <= 7'd0;
      //end
      
    SLCB_DataBus_Unpacking_Module u_SLCB_DataBus_Unpacking_Module(
        .RESET                (system_rst)   ,
        .CLK                  (clk_200m)   ,
                              
        .DataBus_txfifo_en    (CAP_EN_DATABUS)   ,
        .DataBus_txfifo_data  (IN_CAP_DATA_DATABUS)   ,
        
        .DataBus_rxfifo_en    (RD_DATA_EN_DATABUS)   ,
        .DataBus_rxfifo_data  (O_CAP_DATA_DATABUS)   ,
        .DataBus_rxfifo_empty (EMPTY_DATABUS)   ,
                              
        .O_N_WR               (O_N_WR)   ,
        .O_N_RD               (O_N_RD)   ,
        .O_N_CE               (O_N_CE)   ,
        .O_PCADD              (O_PCADD)   ,
        .O_WRData             (O_WRData)   ,
        .I_RDData             (I_RDData)   
        //.O_SLCB_CTRL_STATE    ()           
    );
    /*
    wire read,write,pe_rst;
    wire read_done,write_done,reset_done;
    wire [28:0] send_data,recive_data;
    SLCB_ADATE328_SPI u_SLCB_ADATE328_SPI_W(
        .clk        (clk_200m)       ,
        .rst        (system_rst)       ,
        .i_write     (write)         ,
     //   .i_read      (read)             ,
        .i_pe_rst    (pe_rst)       ,
        .o_read_done  (read_done)       ,
        .o_write_done (write_done)       ,
        .o_reset_done (reset_done)      ,
        .i_send_data  (send_data)       ,
        .o_recive_data(recive_data)       ,
        .O_SPI_RSTb   (SPI_RSTb)       ,
        .O_SPI_SCLK   (SPI_SCLK)       ,
        .O_SPI_CSb    (SPI_CSb)       ,
        .I_SPI_SDO    (SPI_SDO)       ,
        .O_SPI_SDI    (SPI_SDI)       ,
        .I_SPI_BUSYb (SPI_BUSYb)
    );
    */
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
 //SLCB_ADATE328_SPI u_SLCB_ADATE328_SPI_E(
 //     .clk_200    (clk_200m)       ,
 //     .rst        (system_rst)       ,
 //     ._write     (write)         ,
 ////     ._read      (read)             ,
 //     ._pe_rst    (pe_rst)       ,
 //     .read_done  (read_done)       ,
 //     .write_done (write_done)       ,
 //     .send_data  (send_data)       ,
 //     .recive_data(recive_data)       ,
 //     .SPI_RSTb   (SPI_RSTb)       ,
 //     .SPI_SCLK   (SPI_SCLK)       ,
 //     .SPI_CSb    (SPI_CSb)       ,
 //     .SPI_SDO    (SPI_SDO)       ,
 //     .SPI_SDI    (SPI_SDI)       ,
 //     ._SPI_BUSYb (_SPI_BUSYb)
 // );
        
     SLCB_DataBus_Check  u_SLCB_DataBus_Check(
         .CLK_IN  (clk_200m)             ,
         .RESET   (system_rst)           ,
                  
         .DATA_WR (c_wr_databus_verify)  ,
         .DATA_IN (O_WRData)             ,
                  
         .DATA_RD (c_rd_databus_verify)  ,
         .DATA_OUT(I_RDData)
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
    assign c_wr_reg_rdwr            =       WR_CON_C2[1];
    assign c_wr_reg_rst             =       WR_CON_C2[2];
    
    assign c_rd_pin_en              =       RD_CON_C2[0];
    assign c_rd_reg_read            =       RD_CON_C2[1];
    //assign c_rd_pin_rd              =       WR_CON_C2[2];
    
    
    
//assign s_axi_tx_tdata_0 = 64'hA5A5A5A5_5A5A5A5A;
//assign s_axi_tx_tdata_1 = 64'hAAAAAAAA_55555555;
//assign s_axi_tx_tvalid_0 = 1'd1;
//assign s_axi_tx_tvalid_1 = 1'd1;
ila_0 u_ila_0 (
	.clk(clk_200m), // input wire clk
	.probe0(clk_50m), // input wire [0:0]  probe0  
	.probe1(clk_25m), // input wire [0:0]  probe1 
	.probe2(CAP_EN_DATABUS), // input wire [0:0]  probe2 
	.probe3(IN_CAP_DATA_DATABUS), // input wire [63:0]  probe3 
	.probe4(RD_DATA_EN_DATABUS), // input wire [0:0]  probe4 
	.probe5(O_CAP_DATA_DATABUS), // input wire [63:0]  probe5 
	.probe6(EMPTY_DATABUS), // input wire [0:0]  probe6 
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
	.probe7(CAP_EN_DATABUS), // input wire [0:0]  probe7 
	.probe8(send_data), // input wire [28:0]  probe8 
	.probe9(recive_data), // input wire [28:0]  probe9 
	.probe10(SPI_RSTb), // input wire [0:0]  probe10 
	.probe11(SPI_SCLK), // input wire [0:0]  probe11 
	.probe12(SPI_CSb), // input wire [0:0]  probe12 
	.probe13(SPI_SDO), // input wire [0:0]  probe13 
	.probe14(SPI_SDI), // input wire [0:0]  probe14 
	.probe15(SPI_BUSYb), // input wire [0:0]  probe15 
	.probe16(RD_DATA_EN_DATABUS), // input wire [0:0]  probe16 
	.probe17(EMPTY_DATABUS), // input wire [0:0]  probe17 
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
