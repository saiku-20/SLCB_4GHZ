`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 17:23:28
// Design Name: 
// Module Name: aurora_tb
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


module aurora_tb;
reg clk_200;
reg gt_refclk_p,gt_refclk_n;
reg rst; 
reg user_clk_out;
parameter CLK_200M_CYCLE = 5;
parameter USER_CLK_CYCLE = 20;
parameter RST_TIME = 5;

wire gt_rx_databus_p,
      gt_rx_databus_n,
      gt_tx_databus_p,
      gt_tx_databus_n,
      gt_rx_failbus_p,
      gt_rx_failbus_n,
      gt_tx_failbus_p,
      gt_tx_failbus_n;
    
wire HARD_ERR_DATABUS  ,
    SOFT_ERR_DATABUS  ,
    LANE_UP_DATABUS   ,
    CHANNEL_UP_DATABUS,
    HARD_ERR_FAILBUS  ,
    SOFT_ERR_FAILBUS  ,
    LANE_UP_FAILBUS   ,
    CHANNEL_UP_FAILBUS;
    
wire            EMPTY_DATABUS ;      
wire            ALEMPTY_DATABUS   ;  
wire            RD_DATA_EN_DATABUS  ;
wire  [63:0]    O_CAP_DATA_DATABUS  ;
                
wire            CAP_EN_DATABUS      ;
wire  [63:0]    IN_CAP_DATA_DATABUS ;

wire            EMPTY_FAILBUS ;      
wire            ALEMPTY_FAILBUS   ;  
wire            RD_DATA_EN_FAILBUS  ;
wire  [63:0]    O_CAP_DATA_FAILBUS  ;
                
wire            CAP_EN_FAILBUS      ;
wire  [63:0]    IN_CAP_DATA_FAILBUS ;

reg             CAP_EN_DATABUS_t      ;
reg  [63:0]     IN_CAP_DATA_DATABUS_t ;

reg             EMPTY_DATABUS_t;


wire        O_N_WR            ;
wire        O_N_RD            ;
wire        O_N_CE            ;
wire  [7:0] O_PCADD           ;
wire  [63:0]O_WRData          ;
reg   [63:0]I_RDData          ;

wire        F_O_N_WR            ;
wire        F_O_N_RD            ;
wire        F_O_N_CE            ;
wire  [7:0] F_O_PCADD           ;
wire  [63:0]F_O_WRData          ;
reg   [63:0]F_I_RDData          ;

localparam  pcie_preamble       = 24'h5555_d5,
            squence_numble      = 8'hff,
            reserve0            = 2'b00,
            crc_enable          = 1'b0,
            length              = 25'd40,
            Bus_Cmd             = 4'b0010, //010 read ;001 write
              
            sys_board_choose    = 5'b00010,                 
            fpga_choose         = 6'h3f,
            reserve1            = 6'h0,
            slot_choose         = 39'h1,
            o_pcadd             = 8'b1010_0101;
            
always #(2.5) clk_200 = ~clk_200;//
always #(USER_CLK_CYCLE/2)user_clk_out = ~user_clk_out;
always #(7.5) gt_refclk_p = ~gt_refclk_p;
always #(7.5) gt_refclk_n = ~gt_refclk_n;


assign gt_rx_databus_p = gt_tx_failbus_p;
assign gt_rx_databus_n = gt_tx_failbus_n;
assign gt_rx_failbus_p = gt_tx_databus_p;
assign gt_rx_failbus_n = gt_tx_databus_n;
integer i,i1;
initial begin
    i=0;
    i1 = 0;
    clk_200 = 1'b1;
    user_clk_out = 1'b1;
    gt_refclk_p = 1'b1;
    gt_refclk_n = 1'b0;
   // CHANNEL_UP = 1'b0;
    rst = 1'b1;
    #(USER_CLK_CYCLE*RST_TIME);
    rst = 1'b0;
    #(USER_CLK_CYCLE*10);
    //CHANNEL_UP = 1'b1;
    #200;
    #(CLK_200M_CYCLE);
     //#(10000*CLK_200M_CYCLE);
     #(USER_CLK_CYCLE*65);
     wait(CHANNEL_UP_DATABUS && CHANNEL_UP_FAILBUS)
     begin
        #(2000);
        //#(2.5);
        CAP_EN_DATABUS_t = 1'b1;
        IN_CAP_DATA_DATABUS_t = {pcie_preamble,squence_numble,reserve0,crc_enable,length,Bus_Cmd};
        #(CLK_200M_CYCLE);
        CAP_EN_DATABUS_t = 1'b0;
        #(CLK_200M_CYCLE);
        CAP_EN_DATABUS_t = 1'b1;
        IN_CAP_DATA_DATABUS_t = {sys_board_choose,fpga_choose,reserve1,slot_choose,o_pcadd};
        #(CLK_200M_CYCLE);
        CAP_EN_DATABUS_t = 1'b0;
        #(CLK_200M_CYCLE);
        CAP_EN_DATABUS_t = 1'b1;
        IN_CAP_DATA_DATABUS_t = 64'h1111_2222_3333_4440;
        #(CLK_200M_CYCLE);
        CAP_EN_DATABUS_t = 1'b0;
        #(CLK_200M_CYCLE);
        while(i<9)begin
            i = i+1;
            CAP_EN_DATABUS_t = 1'b1;
            IN_CAP_DATA_DATABUS_t = IN_CAP_DATA_DATABUS_t + 1;
            #(CLK_200M_CYCLE);
            CAP_EN_DATABUS_t = 1'b0;
            #(CLK_200M_CYCLE);
        end
        //CAP_EN_DATABUS_t = CAP_EN_DATABUS;
        //IN_CAP_DATA_DATABUS_t = IN_CAP_DATA_DATABUS;
        #(10*CLK_200M_CYCLE);
        @(negedge O_N_RD)
            #(CLK_200M_CYCLE);
            I_RDData =  {pcie_preamble,squence_numble,reserve0,crc_enable,length,4'b0001};
            
            @(negedge CAP_EN_DATABUS)
                I_RDData =  {sys_board_choose,fpga_choose,reserve1,slot_choose,o_pcadd};
        while(i1<8)begin
            i1 = i1 + 1;
            @(negedge CAP_EN_DATABUS)
                I_RDData =  64'h1111_2222_3333_4440 + i1;
        end
     end
     
     //$stop; 
end


SLCB_Aurora_Module u_SLCB_Aurora_Module(
          .CKP                  (clk_200)        ,
          .init_clk             (user_clk_out)   ,
          .system_rst           (rst)            ,
          .drp_clk              (user_clk_out)   ,
                                
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
                                
          //DATABUS RX                  
          .EMPTY_DATABUS        (EMPTY_DATABUS)  ,
          .ALEMPTY_DATABUS      (ALEMPTY_DATABUS)  ,
          .RD_DATA_EN_DATABUS   (RD_DATA_EN_DATABUS)  ,
          .O_CAP_DATA_DATABUS   (O_CAP_DATA_DATABUS)  ,
          //TX                     
          .CAP_EN_DATABUS       (CAP_EN_DATABUS)  ,
          .IN_CAP_DATA_DATABUS  (IN_CAP_DATA_DATABUS),
          //FAILBUS RX                  
          .EMPTY_FAILBUS        (EMPTY_FAILBUS)  ,
          .ALEMPTY_FAILBUS      (ALEMPTY_FAILBUS)  ,
          .RD_DATA_EN_FAILBUS   (RD_DATA_EN_FAILBUS)  ,
          .O_CAP_DATA_FAILBUS   (O_CAP_DATA_FAILBUS)  ,
          //TX                     
          .CAP_EN_FAILBUS       (CAP_EN_DATABUS_t)  ,
          .IN_CAP_DATA_FAILBUS  (IN_CAP_DATA_DATABUS_t)       
            
      );
      
  SLCB_DataBus_Unpacking_Module u_SLCB_DataBus_Unpacking_Module(
        .RESET                (rst)   ,
        .CLK                  (clk_200)     ,
                              
        .DataBus_txfifo_en    (CAP_EN_DATABUS)   ,
        .DataBus_txfifo_data  (IN_CAP_DATA_DATABUS)   ,
        
        .DataBus_rxfifo_en    (RD_DATA_EN_DATABUS)   ,
        .DataBus_rxfifo_data  (O_CAP_DATA_DATABUS)   ,
        .DataBus_rxfifo_empty (EMPTY_DATABUS)   ,
                              
        .O_N_WR               (O_N_WR)     ,
        .O_N_RD               (O_N_RD)     ,
        .O_N_CE               (O_N_CE)     ,
        .O_PCADD              (O_PCADD)    ,
        .O_WRData             (O_WRData)   ,
        .I_RDData             (I_RDData)   
        //.O_SLCB_CTRL_STATE    (O_SLCB_CTRL_STATE)           
    );
    SLCB_DataBus_Unpacking_Module u_SLCB_FailBus_Unpacking_Module(
        .RESET                (rst)   ,
        .CLK                  (clk_200)     ,
                              
        .DataBus_txfifo_en    (CAP_EN_FAILBUS)   ,
        .DataBus_txfifo_data  (IN_CAP_DATA_FAILBUS)   ,
        
        .DataBus_rxfifo_en    (RD_DATA_EN_FAILBUS)   ,
        .DataBus_rxfifo_data  (O_CAP_DATA_FAILBUS)   ,
        .DataBus_rxfifo_empty (EMPTY_FAILBUS)   ,
                              
        .O_N_WR               (F_O_N_WR   )    ,
        .O_N_RD               (F_O_N_RD   )    ,
        .O_N_CE               (F_O_N_CE   )    ,
        .O_PCADD              (F_O_PCADD  )    ,
        .O_WRData             (F_O_WRData )   ,
        .I_RDData             (F_I_RDData )   
        //.O_SLCB_CTRL_STATE    (O_SLCB_CTRL_STATE)           
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
                   .CLK         (clk_200), 
                   .N_CARD_EN   (O_N_CE), 
                   .N_RD        (O_N_RD), 
                   .N_WR        (O_N_WR), 
                   .PC_ADD      ({0,O_PCADD}),
                   .WR_EN       (64'h0),  
                   .I_DEData    (I_DEData), 
                   .O_DEData    (O_DEData),
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
endmodule

//EMPTY_DATABUS_t = 1;
        //#(4000);
        //EMPTY_DATABUS_t = EMPTY_DATABUS;
        /*
        CAP_EN_DATABUS = 1'b1;
        IN_CAP_DATA_DATABUS = 64'h5555_D5aa_1234_4321;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b1;
        IN_CAP_DATA_DATABUS = 64'h5555_aaaa_1234_4321;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b1;
        IN_CAP_DATA_DATABUS = 64'h1234_5678_4321_9876;
         #(CLK_200M_CYCLE);
         //#(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
       CAP_EN_DATABUS = 1'b1;
        IN_CAP_DATA_DATABUS = 64'h2222_3333_4444_5555;
         #(CLK_200M_CYCLE);
        // #(CLK_200M_CYCLE);
        CAP_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        IN_CAP_DATA_DATABUS = 64'h0;
        
        #(3000);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;

        #(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
       // #(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b1;
        #(CLK_200M_CYCLE);
        //#(CLK_200M_CYCLE);
        RD_DATA_EN_DATABUS = 1'b0;*/
