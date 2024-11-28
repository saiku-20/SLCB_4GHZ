`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/09 22:31:55
// Design Name: 
// Module Name: unpacking_tb
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

`define DLY #1
module unpacking_tb;
    reg clk_200;
    reg rst;
    reg user_clk_out;
    parameter CLK_200M_CYCLE = 5;
    parameter USER_CLK_CYCLE = 20;
    parameter RST_TIME = 5;
    
    reg    EMPTY_DATABUS ;           
    //wire    ALEMPTY_DATABUS   ;       
    wire    RD_DATA_EN_DATABUS  ;      
    reg  [63:0]  O_CAP_DATA_DATABUS ; 
                                      
    wire     CAP_EN_DATABUS      ;     
    wire  [63:0]  IN_CAP_DATA_DATABUS ;
    
    wire        O_N_WR            ;
    wire        O_N_RD            ;
    wire        O_N_CE            ;
    wire  [7:0] O_PCADD           ;
    wire  [63:0]O_WRData          ;
    reg   [63:0]I_RDData          ;
    
    always #(2.5) clk_200 = ~clk_200;
    always #(USER_CLK_CYCLE/2)user_clk_out = ~user_clk_out;
    localparam  pcie_preamble       = 24'h5555_d5,
                squence_numble      = 8'hff,
                crc_enable          = 1'b0,
                reserve0            = 3'b000,
                rd_length           = 10'd16,
                wr_length           = 10'd20,
                Bus_Cmd             = 4'b001,
                add_equpment        = 4'b000,
                                   
                fpga_choose         = 4'hf,
                sys_board_choose    = 3'b010,
                slot_choose         = 39'h1,
                reserve1            = 8'h0,
                o_pcadd             = 8'b1010_0101;
                //get_head_flag       = 1'b0;
    integer i;
    initial begin
        i=0;
        clk_200 = 1'b1;
        user_clk_out = 1'b1;
        EMPTY_DATABUS = 1'b1;
        I_RDData = 64'haaaa_bbbb_cccc_dddd;
        rst = 1'b1;
        #(USER_CLK_CYCLE*RST_TIME);
        rst = 1'b0;
        #(USER_CLK_CYCLE*10);
        #(2.5);
        clk_200 = 1'b1;
        //O_CAP_DATA_DATABUS <=  64'h5555_D5aa_1234_4321;
        EMPTY_DATABUS = 1'b0;
        
        wait(RD_DATA_EN_DATABUS)begin
            #1;
            O_CAP_DATA_DATABUS <= {pcie_preamble,squence_numble,crc_enable,reserve0,rd_length,wr_length,Bus_Cmd,add_equpment};
            @(posedge RD_DATA_EN_DATABUS)
                O_CAP_DATA_DATABUS <=  {fpga_choose,sys_board_choose,slot_choose,reserve1,o_pcadd};
            @(posedge RD_DATA_EN_DATABUS)
                O_CAP_DATA_DATABUS <=  64'haa55_55aa_1234_4321;
            //#(CLK_200M_CYCLE);
            @(posedge RD_DATA_EN_DATABUS)
                O_CAP_DATA_DATABUS <= 64'h1111_2222_3333_4444;
            @(posedge RD_DATA_EN_DATABUS)
            //O_CAP_DATA_DATABUS <=  64'h1111_2222_3333_4444;
            //#(CLK_200M_CYCLE);
                O_CAP_DATA_DATABUS <=  64'h2111_2222_3333_4444;
            @(posedge RD_DATA_EN_DATABUS)
            //#(CLK_200M_CYCLE);
                O_CAP_DATA_DATABUS <=  64'h3111_2222_3333_4444;
            while(i<20)
            begin
                i=i+1;
                @(posedge RD_DATA_EN_DATABUS)
                    O_CAP_DATA_DATABUS  <=  O_CAP_DATA_DATABUS + i;
            end    
            #(CLK_200M_CYCLE);
        end
        EMPTY_DATABUS = 1'b1;
    end
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
