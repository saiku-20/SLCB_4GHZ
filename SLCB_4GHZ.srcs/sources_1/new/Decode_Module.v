module SYNC_LDC( Q, D, C1, G, CKP);
//����G��T0�йص������ʹ��SYNC_LDC
parameter size=8;

input   CKP;
input   [size-1:0]      D;      //in
input   G;                      //en
input   C1;                     //rst_n
output  [size-1 : 0]    Q;      //out

reg [size-1:0]  Q;

always @(posedge CKP)begin
    if(C1 == 1'b0)
        Q <= 1'b0;
    else if(G == 1'b1)
        Q <= D;
end
endmodule

//To generate a one clk cycle pulse after DELAY_NUM-1 cycle clk of a input negedge;
module negedge_pulse_gen#(
    parameter DELAY_NUM = 2,        //min num=1;
    parameter PULSE_WIDTH = 1,      //min=1;max=DELAY_NUM
    parameter INPUT_SIGNAL_TYPE = 0 //0:input signal is a positive pulse;
)
(
    Q,D,rst,clk
);
    output  Q;
    input   D;
    input   rst,clk;
    
    reg [DELAY_NUM:0]    delay;
    always@(posedge clk)begin
        if(rst==1'b0)
            delay   <=  (INPUT_SIGNAL_TYPE==1)?{(DELAY_NUM+1){1'b1}}:{(DELAY_NUM+1){1'b0}};
        else
            delay   <=  {delay[DELAY_NUM-1:0],D};
    end
    assign Q = (~delay[DELAY_NUM-1-(PULSE_WIDTH-1)])&&delay[DELAY_NUM];
endmodule

//To generate a one clk cycle pulse after DELAY_NUM-1 cycle clk of a input negedge;
module posedge_pulse_gen#(
    parameter DELAY_NUM = 2,        //min num=1;
    parameter PULSE_WIDTH = 1,      //min=1;max=DELAY_NUM
    parameter INPUT_SIGNAL_TYPE = 1 //0:input signal is a positive pulse;
)
(
    Q,D,rst,clk
);
    output  Q;
    input   D;
    input   rst,clk;
    
    reg [DELAY_NUM:0]    delay;
    always@(posedge clk)begin
        if(rst==1'b0)
            delay   <=  (INPUT_SIGNAL_TYPE==1)?{(DELAY_NUM+1){1'b1}}:{(DELAY_NUM+1){1'b0}};
        else
            delay   <=  {delay[DELAY_NUM-1:0],D};
    end
    assign Q = delay[DELAY_NUM-1-(PULSE_WIDTH-1)]&&(~delay[DELAY_NUM]);
endmodule

module DECODE_8_3 (CLK, IN, EN, OUT);
input           CLK;
input [7:0]     IN;
input           EN;
output [2:0]    OUT;

reg [2:0] OUT;

always@(posedge CLK)begin
    if(EN == 1'b1)
    begin
        case(IN)
            8'b0000_0001: OUT <= 3'b000;
            8'b0000_0010: OUT <= 3'b001;
            8'b0000_0100: OUT <= 3'b010;
            8'b0000_1000: OUT <= 3'b011;
            8'b0001_0000: OUT <= 3'b100;
            8'b0010_0000: OUT <= 3'b101;
            8'b0100_0000: OUT <= 3'b110;
            8'b1000_0000: OUT <= 3'b111;
            default:OUT <= 3'b000;
        endcase
    end
    else begin
        OUT <= 3'b000;
    end
end
endmodule

module DECODE_3_8 (CLK, IN, EN, OUT);
input           CLK;
input [2:0]     IN;
input           EN;
output  [7:0]   OUT;

//add your declaration here
reg [7:0] OUT;
//
always @(posedge CLK)
begin
    if(1'b1 == EN)
    begin
        case(IN)
            3'b000: OUT <= 8'b0000_0001;
            3'b001: OUT <= 8'b0000_0010;
            3'b010: OUT <= 8'b0000_0100;
            3'b011: OUT <= 8'b0000_1000;
            3'b100: OUT <= 8'b0001_0000;
            3'b101: OUT <= 8'b0010_0000;
            3'b110: OUT <= 8'b0100_0000;
            3'b111: OUT <= 8'b1000_0000;
            default: OUT <= 8'b0000_0000;
        endcase
    end
    else
        OUT <= 8'b0000_0000;
end
endmodule

module DECODER_64(  CLK, N_CARD_EN, N_RD, N_WR, PC_ADD, WR_EN,  I_DEData, O_DEData,
                    WR_CON_C1 ,WR_CON_C2 ,WR_CON_C3 ,WR_CON_C4 ,WR_CON_C5 ,WR_CON_C6 ,WR_CON_C7 ,WR_CON_C8 ,
                    WR_CON_C9 ,WR_CON_C10,WR_CON_C11,WR_CON_C12,WR_CON_C13,WR_CON_C14,WR_CON_C15,WR_CON_C16,
                    WR_CON_C17,WR_CON_C18,WR_CON_C19,WR_CON_C20,WR_CON_C21,WR_CON_C22,WR_CON_C23,WR_CON_C24,
                    WR_CON_C25,WR_CON_C26,WR_CON_C27,WR_CON_C28,WR_CON_C29,WR_CON_C30,WR_CON_C31,WR_CON_C32,
                    WR_CON_C33,WR_CON_C34,WR_CON_C35,WR_CON_C36,WR_CON_C37,WR_CON_C38,WR_CON_C39,WR_CON_C40,
                    WR_CON_C41,WR_CON_C42,WR_CON_C43,WR_CON_C44,WR_CON_C45,WR_CON_C46,WR_CON_C47,WR_CON_C48,
                    WR_CON_C49,WR_CON_C50,WR_CON_C51,WR_CON_C52,WR_CON_C53,WR_CON_C54,WR_CON_C55,WR_CON_C56,
                    WR_CON_C57,WR_CON_C58,WR_CON_C59,WR_CON_C60,WR_CON_C61,WR_CON_C62,WR_CON_C63,WR_CON_C64,

                    RD_CON_C1 ,RD_CON_C2 ,RD_CON_C3 ,RD_CON_C4 ,RD_CON_C5 ,RD_CON_C6 ,RD_CON_C7 ,RD_CON_C8 ,
                    RD_CON_C9 ,RD_CON_C10,RD_CON_C11,RD_CON_C12,RD_CON_C13,RD_CON_C14,RD_CON_C15,RD_CON_C16,
                    RD_CON_C17,RD_CON_C18,RD_CON_C19,RD_CON_C20,RD_CON_C21,RD_CON_C22,RD_CON_C23,RD_CON_C24,
                    RD_CON_C25,RD_CON_C26,RD_CON_C27,RD_CON_C28,RD_CON_C29,RD_CON_C30,RD_CON_C31,RD_CON_C32,
                    RD_CON_C33,RD_CON_C34,RD_CON_C35,RD_CON_C36,RD_CON_C37,RD_CON_C38,RD_CON_C39,RD_CON_C40,
                    RD_CON_C41,RD_CON_C42,RD_CON_C43,RD_CON_C44,RD_CON_C45,RD_CON_C46,RD_CON_C47,RD_CON_C48,
                    RD_CON_C49,RD_CON_C50,RD_CON_C51,RD_CON_C52,RD_CON_C53,RD_CON_C54,RD_CON_C55,RD_CON_C56,
                    RD_CON_C57,RD_CON_C58,RD_CON_C59,RD_CON_C60,RD_CON_C61,RD_CON_C62,RD_CON_C63,RD_CON_C64  
                    );
    //用于产生系统内部的地�?译码�?
    //PC_ADD�?8�?3】用于产�?64个wr_decode_en,和rd_decode_en, 由N_RD和N_WR切换�?
    //PC_ADD�? 
    //�?多输出：64*8个写选�?�信号，�?64*8个读选�?�信号；
    input               CLK;
    input       [0:64]  I_DEData;
    input       [63:0]  O_DEData;
    input               N_CARD_EN;
    input   [8:0]       PC_ADD;
    input               N_RD,N_WR;
    input   [63:0]      WR_EN;

    output[7:0] WR_CON_C1 ,WR_CON_C2 ,WR_CON_C3 ,WR_CON_C4 ,WR_CON_C5 ,WR_CON_C6 ,WR_CON_C7 ,WR_CON_C8 ;
    output[7:0] WR_CON_C9 ,WR_CON_C10,WR_CON_C11,WR_CON_C12,WR_CON_C13,WR_CON_C14,WR_CON_C15,WR_CON_C16;
    output[7:0] WR_CON_C17,WR_CON_C18,WR_CON_C19,WR_CON_C20,WR_CON_C21,WR_CON_C22,WR_CON_C23,WR_CON_C24;
    output[7:0] WR_CON_C25,WR_CON_C26,WR_CON_C27,WR_CON_C28,WR_CON_C29,WR_CON_C30,WR_CON_C31,WR_CON_C32;
    output[7:0] WR_CON_C33,WR_CON_C34,WR_CON_C35,WR_CON_C36,WR_CON_C37,WR_CON_C38,WR_CON_C39,WR_CON_C40;
    output[7:0] WR_CON_C41,WR_CON_C42,WR_CON_C43,WR_CON_C44,WR_CON_C45,WR_CON_C46,WR_CON_C47,WR_CON_C48;
    output[7:0] WR_CON_C49,WR_CON_C50,WR_CON_C51,WR_CON_C52,WR_CON_C53,WR_CON_C54,WR_CON_C55,WR_CON_C56;
    output[7:0] WR_CON_C57,WR_CON_C58,WR_CON_C59,WR_CON_C60,WR_CON_C61,WR_CON_C62,WR_CON_C63,WR_CON_C64;

    output[7:0] RD_CON_C1 ,RD_CON_C2 ,RD_CON_C3 ,RD_CON_C4 ,RD_CON_C5 ,RD_CON_C6 ,RD_CON_C7 ,RD_CON_C8 ;
    output[7:0] RD_CON_C9 ,RD_CON_C10,RD_CON_C11,RD_CON_C12,RD_CON_C13,RD_CON_C14,RD_CON_C15,RD_CON_C16;
    output[7:0] RD_CON_C17,RD_CON_C18,RD_CON_C19,RD_CON_C20,RD_CON_C21,RD_CON_C22,RD_CON_C23,RD_CON_C24;
    output[7:0] RD_CON_C25,RD_CON_C26,RD_CON_C27,RD_CON_C28,RD_CON_C29,RD_CON_C30,RD_CON_C31,RD_CON_C32;
    output[7:0] RD_CON_C33,RD_CON_C34,RD_CON_C35,RD_CON_C36,RD_CON_C37,RD_CON_C38,RD_CON_C39,RD_CON_C40;
    output[7:0] RD_CON_C41,RD_CON_C42,RD_CON_C43,RD_CON_C44,RD_CON_C45,RD_CON_C46,RD_CON_C47,RD_CON_C48;
    output[7:0] RD_CON_C49,RD_CON_C50,RD_CON_C51,RD_CON_C52,RD_CON_C53,RD_CON_C54,RD_CON_C55,RD_CON_C56;
    output[7:0] RD_CON_C57,RD_CON_C58,RD_CON_C59,RD_CON_C60,RD_CON_C61,RD_CON_C62,RD_CON_C63,RD_CON_C64; 

    wire        clk;
    wire [8:0]  add;
    wire [63:0] decode_en;

    wire [63:0] wr_decode_en;
    wire [63:0] rd_decode_en;

    assign clk = CLK;
    assign add[8:0] = PC_ADD[8:0];
    assign wr_decode_en[63:0] = (decode_en[63:0] | WR_EN[63:0]) & {64{!N_WR}};
    assign rd_decode_en[63:0] = (decode_en[63:0] & {64{!N_RD}});

    //always@(posedge clk)
    //    O_DEData <= I_DEData;
        
    DECODE_6_64 u_decode_6_64(
        .IN(add[8:3]),
        .EN(N_CARD_EN),
        .OUT(decode_en[63:0])
    );
    //WRITE
    DECODE_3_8 UW1 (clk,add[2:0], wr_decode_en[0],  WR_CON_C1[7:0]);
    DECODE_3_8 UW2 (clk,add[2:0], wr_decode_en[1],  WR_CON_C2[7:0]);
    DECODE_3_8 UW3 (clk,add[2:0], wr_decode_en[2],  WR_CON_C3[7:0]);
    DECODE_3_8 UW4 (clk,add[2:0], wr_decode_en[3],  WR_CON_C4[7:0]);
    DECODE_3_8 UW5 (clk,add[2:0], wr_decode_en[4],  WR_CON_C5[7:0]);
    DECODE_3_8 UW6 (clk,add[2:0], wr_decode_en[5],  WR_CON_C6[7:0]);
    DECODE_3_8 UW7 (clk,add[2:0], wr_decode_en[6],  WR_CON_C7[7:0]);
    DECODE_3_8 UW8 (clk,add[2:0], wr_decode_en[7],  WR_CON_C8[7:0]);
    DECODE_3_8 UW9 (clk,add[2:0], wr_decode_en[8],  WR_CON_C9[7:0]);
    DECODE_3_8 UW10(clk,add[2:0], wr_decode_en[9],  WR_CON_C10[7:0]);
    DECODE_3_8 UW11(clk,add[2:0], wr_decode_en[10], WR_CON_C11[7:0]);
    DECODE_3_8 UW12(clk,add[2:0], wr_decode_en[11], WR_CON_C12[7:0]);
    DECODE_3_8 UW13(clk,add[2:0], wr_decode_en[12], WR_CON_C13[7:0]);
    DECODE_3_8 UW14(clk,add[2:0], wr_decode_en[13], WR_CON_C14[7:0]);
    DECODE_3_8 UW15(clk,add[2:0], wr_decode_en[14], WR_CON_C15[7:0]);
    DECODE_3_8 UW16(clk,add[2:0], wr_decode_en[15], WR_CON_C16[7:0]);
    DECODE_3_8 UW17(clk,add[2:0], wr_decode_en[16], WR_CON_C17[7:0]);
    DECODE_3_8 UW18(clk,add[2:0], wr_decode_en[17], WR_CON_C18[7:0]);
    DECODE_3_8 UW19(clk,add[2:0], wr_decode_en[18], WR_CON_C19[7:0]);
    DECODE_3_8 UW20(clk,add[2:0], wr_decode_en[19], WR_CON_C20[7:0]);
    DECODE_3_8 UW21(clk,add[2:0], wr_decode_en[20], WR_CON_C21[7:0]);
    DECODE_3_8 UW22(clk,add[2:0], wr_decode_en[21], WR_CON_C22[7:0]);
    DECODE_3_8 UW23(clk,add[2:0], wr_decode_en[22], WR_CON_C23[7:0]);
    DECODE_3_8 UW24(clk,add[2:0], wr_decode_en[23], WR_CON_C24[7:0]);
    DECODE_3_8 UW25(clk,add[2:0], wr_decode_en[24], WR_CON_C25[7:0]);
    DECODE_3_8 UW26(clk,add[2:0], wr_decode_en[25], WR_CON_C26[7:0]);
    DECODE_3_8 UW27(clk,add[2:0], wr_decode_en[26], WR_CON_C27[7:0]);
    DECODE_3_8 UW28(clk,add[2:0], wr_decode_en[27], WR_CON_C28[7:0]);
    DECODE_3_8 UW29(clk,add[2:0], wr_decode_en[28], WR_CON_C29[7:0]);
    DECODE_3_8 UW30(clk,add[2:0], wr_decode_en[29], WR_CON_C30[7:0]);
    DECODE_3_8 UW31(clk,add[2:0], wr_decode_en[30], WR_CON_C31[7:0]);
    DECODE_3_8 UW32(clk,add[2:0], wr_decode_en[31], WR_CON_C32[7:0]);
    DECODE_3_8 UW33(clk,add[2:0], wr_decode_en[32], WR_CON_C33[7:0]);
    DECODE_3_8 UW34(clk,add[2:0], wr_decode_en[33], WR_CON_C34[7:0]);
    DECODE_3_8 UW35(clk,add[2:0], wr_decode_en[34], WR_CON_C35[7:0]);
    DECODE_3_8 UW36(clk,add[2:0], wr_decode_en[35], WR_CON_C36[7:0]);
    DECODE_3_8 UW37(clk,add[2:0], wr_decode_en[36], WR_CON_C37[7:0]);
    DECODE_3_8 UW38(clk,add[2:0], wr_decode_en[37], WR_CON_C38[7:0]);
    DECODE_3_8 UW39(clk,add[2:0], wr_decode_en[38], WR_CON_C39[7:0]);
    DECODE_3_8 UW40(clk,add[2:0], wr_decode_en[39], WR_CON_C40[7:0]);
    DECODE_3_8 UW41(clk,add[2:0], wr_decode_en[40], WR_CON_C41[7:0]);
    DECODE_3_8 UW42(clk,add[2:0], wr_decode_en[41], WR_CON_C42[7:0]);
    DECODE_3_8 UW43(clk,add[2:0], wr_decode_en[42], WR_CON_C43[7:0]);
    DECODE_3_8 UW44(clk,add[2:0], wr_decode_en[43], WR_CON_C44[7:0]);
    DECODE_3_8 UW45(clk,add[2:0], wr_decode_en[44], WR_CON_C45[7:0]);
    DECODE_3_8 UW46(clk,add[2:0], wr_decode_en[45], WR_CON_C46[7:0]);
    DECODE_3_8 UW47(clk,add[2:0], wr_decode_en[46], WR_CON_C47[7:0]);
    DECODE_3_8 UW48(clk,add[2:0], wr_decode_en[47], WR_CON_C48[7:0]);
    DECODE_3_8 UW49(clk,add[2:0], wr_decode_en[48], WR_CON_C49[7:0]);
    DECODE_3_8 UW50(clk,add[2:0], wr_decode_en[49], WR_CON_C50[7:0]);
    DECODE_3_8 UW51(clk,add[2:0], wr_decode_en[50], WR_CON_C51[7:0]);
    DECODE_3_8 UW52(clk,add[2:0], wr_decode_en[51], WR_CON_C52[7:0]);
    DECODE_3_8 UW53(clk,add[2:0], wr_decode_en[52], WR_CON_C53[7:0]);
    DECODE_3_8 UW54(clk,add[2:0], wr_decode_en[53], WR_CON_C54[7:0]);
    DECODE_3_8 UW55(clk,add[2:0], wr_decode_en[54], WR_CON_C55[7:0]);
    DECODE_3_8 UW56(clk,add[2:0], wr_decode_en[55], WR_CON_C56[7:0]);
    DECODE_3_8 UW57(clk,add[2:0], wr_decode_en[56], WR_CON_C57[7:0]);
    DECODE_3_8 UW58(clk,add[2:0], wr_decode_en[57], WR_CON_C58[7:0]);
    DECODE_3_8 UW59(clk,add[2:0], wr_decode_en[58], WR_CON_C59[7:0]);
    DECODE_3_8 UW60(clk,add[2:0], wr_decode_en[59], WR_CON_C60[7:0]);
    DECODE_3_8 UW61(clk,add[2:0], wr_decode_en[60], WR_CON_C61[7:0]);
    DECODE_3_8 UW62(clk,add[2:0], wr_decode_en[61], WR_CON_C62[7:0]);
    DECODE_3_8 UW63(clk,add[2:0], wr_decode_en[62], WR_CON_C63[7:0]);
    DECODE_3_8 UW64(clk,add[2:0], wr_decode_en[63], WR_CON_C64[7:0]);

    DECODE_3_8 UR1 (clk,add[2:0], rd_decode_en[0],  RD_CON_C1[7:0]);
    DECODE_3_8 UR2 (clk,add[2:0], rd_decode_en[1],  RD_CON_C2[7:0]);
    DECODE_3_8 UR3 (clk,add[2:0], rd_decode_en[2],  RD_CON_C3[7:0]);
    DECODE_3_8 UR4 (clk,add[2:0], rd_decode_en[3],  RD_CON_C4[7:0]);
    DECODE_3_8 UR5 (clk,add[2:0], rd_decode_en[4],  RD_CON_C5[7:0]);
    DECODE_3_8 UR6 (clk,add[2:0], rd_decode_en[5],  RD_CON_C6[7:0]);
    DECODE_3_8 UR7 (clk,add[2:0], rd_decode_en[6],  RD_CON_C7[7:0]);
    DECODE_3_8 UR8 (clk,add[2:0], rd_decode_en[7],  RD_CON_C8[7:0]);
    DECODE_3_8 UR9 (clk,add[2:0], rd_decode_en[8],  RD_CON_C9[7:0]);
    DECODE_3_8 UR10(clk,add[2:0], rd_decode_en[9],  RD_CON_C10[7:0]);
    DECODE_3_8 UR11(clk,add[2:0], rd_decode_en[10], RD_CON_C11[7:0]);
    DECODE_3_8 UR12(clk,add[2:0], rd_decode_en[11], RD_CON_C12[7:0]);
    DECODE_3_8 UR13(clk,add[2:0], rd_decode_en[12], RD_CON_C13[7:0]);
    DECODE_3_8 UR14(clk,add[2:0], rd_decode_en[13], RD_CON_C14[7:0]);
    DECODE_3_8 UR15(clk,add[2:0], rd_decode_en[14], RD_CON_C15[7:0]);
    DECODE_3_8 UR16(clk,add[2:0], rd_decode_en[15], RD_CON_C16[7:0]);
    DECODE_3_8 UR17(clk,add[2:0], rd_decode_en[16], RD_CON_C17[7:0]);
    DECODE_3_8 UR18(clk,add[2:0], rd_decode_en[17], RD_CON_C18[7:0]);
    DECODE_3_8 UR19(clk,add[2:0], rd_decode_en[18], RD_CON_C19[7:0]);
    DECODE_3_8 UR20(clk,add[2:0], rd_decode_en[19], RD_CON_C20[7:0]);
    DECODE_3_8 UR21(clk,add[2:0], rd_decode_en[20], RD_CON_C21[7:0]);
    DECODE_3_8 UR22(clk,add[2:0], rd_decode_en[21], RD_CON_C22[7:0]);
    DECODE_3_8 UR23(clk,add[2:0], rd_decode_en[22], RD_CON_C23[7:0]);
    DECODE_3_8 UR24(clk,add[2:0], rd_decode_en[23], RD_CON_C24[7:0]);
    DECODE_3_8 UR25(clk,add[2:0], rd_decode_en[24], RD_CON_C25[7:0]);
    DECODE_3_8 UR26(clk,add[2:0], rd_decode_en[25], RD_CON_C26[7:0]);
    DECODE_3_8 UR27(clk,add[2:0], rd_decode_en[26], RD_CON_C27[7:0]);
    DECODE_3_8 UR28(clk,add[2:0], rd_decode_en[27], RD_CON_C28[7:0]);
    DECODE_3_8 UR29(clk,add[2:0], rd_decode_en[28], RD_CON_C29[7:0]);
    DECODE_3_8 UR30(clk,add[2:0], rd_decode_en[29], RD_CON_C30[7:0]);
    DECODE_3_8 UR31(clk,add[2:0], rd_decode_en[30], RD_CON_C31[7:0]);
    DECODE_3_8 UR32(clk,add[2:0], rd_decode_en[31], RD_CON_C32[7:0]);
    DECODE_3_8 UR33(clk,add[2:0], rd_decode_en[32], RD_CON_C33[7:0]);
    DECODE_3_8 UR34(clk,add[2:0], rd_decode_en[33], RD_CON_C34[7:0]);
    DECODE_3_8 UR35(clk,add[2:0], rd_decode_en[34], RD_CON_C35[7:0]);
    DECODE_3_8 UR36(clk,add[2:0], rd_decode_en[35], RD_CON_C36[7:0]);
    DECODE_3_8 UR37(clk,add[2:0], rd_decode_en[36], RD_CON_C37[7:0]);
    DECODE_3_8 UR38(clk,add[2:0], rd_decode_en[37], RD_CON_C38[7:0]);
    DECODE_3_8 UR39(clk,add[2:0], rd_decode_en[38], RD_CON_C39[7:0]);
    DECODE_3_8 UR40(clk,add[2:0], rd_decode_en[39], RD_CON_C40[7:0]);
    DECODE_3_8 UR41(clk,add[2:0], rd_decode_en[40], RD_CON_C41[7:0]);
    DECODE_3_8 UR42(clk,add[2:0], rd_decode_en[41], RD_CON_C42[7:0]);
    DECODE_3_8 UR43(clk,add[2:0], rd_decode_en[42], RD_CON_C43[7:0]);
    DECODE_3_8 UR44(clk,add[2:0], rd_decode_en[43], RD_CON_C44[7:0]);
    DECODE_3_8 UR45(clk,add[2:0], rd_decode_en[44], RD_CON_C45[7:0]);
    DECODE_3_8 UR46(clk,add[2:0], rd_decode_en[45], RD_CON_C46[7:0]);
    DECODE_3_8 UR47(clk,add[2:0], rd_decode_en[46], RD_CON_C47[7:0]);
    DECODE_3_8 UR48(clk,add[2:0], rd_decode_en[47], RD_CON_C48[7:0]);
    DECODE_3_8 UR49(clk,add[2:0], rd_decode_en[48], RD_CON_C49[7:0]);
    DECODE_3_8 UR50(clk,add[2:0], rd_decode_en[49], RD_CON_C50[7:0]);
    DECODE_3_8 UR51(clk,add[2:0], rd_decode_en[50], RD_CON_C51[7:0]);
    DECODE_3_8 UR52(clk,add[2:0], rd_decode_en[51], RD_CON_C52[7:0]);
    DECODE_3_8 UR53(clk,add[2:0], rd_decode_en[52], RD_CON_C53[7:0]);
    DECODE_3_8 UR54(clk,add[2:0], rd_decode_en[53], RD_CON_C54[7:0]);
    DECODE_3_8 UR55(clk,add[2:0], rd_decode_en[54], RD_CON_C55[7:0]);
    DECODE_3_8 UR56(clk,add[2:0], rd_decode_en[55], RD_CON_C56[7:0]);
    DECODE_3_8 UR57(clk,add[2:0], rd_decode_en[56], RD_CON_C57[7:0]);
    DECODE_3_8 UR58(clk,add[2:0], rd_decode_en[57], RD_CON_C58[7:0]);
    DECODE_3_8 UR59(clk,add[2:0], rd_decode_en[58], RD_CON_C59[7:0]);
    DECODE_3_8 UR60(clk,add[2:0], rd_decode_en[59], RD_CON_C60[7:0]);
    DECODE_3_8 UR61(clk,add[2:0], rd_decode_en[60], RD_CON_C61[7:0]);
    DECODE_3_8 UR62(clk,add[2:0], rd_decode_en[61], RD_CON_C62[7:0]);
    DECODE_3_8 UR63(clk,add[2:0], rd_decode_en[62], RD_CON_C63[7:0]);
    DECODE_3_8 UR64(clk,add[2:0], rd_decode_en[63], RD_CON_C64[7:0]);
endmodule

module DECODE_6_64 (IN, EN, OUT);
    input [5:0] IN;
    input EN;
    output [63:0] OUT;

    reg [63:0] OUT;

    always @(IN or EN)begin
        if(1'b0 == EN)begin
            case(IN)
                6'h00: OUT = 64'h0000_0000_0000_0001;
                6'h01: OUT = 64'h0000_0000_0000_0002;
                6'h02: OUT = 64'h0000_0000_0000_0004;
                6'h03: OUT = 64'h0000_0000_0000_0008;
                6'h04: OUT = 64'h0000_0000_0000_0010;
                6'h05: OUT = 64'h0000_0000_0000_0020;
                6'h06: OUT = 64'h0000_0000_0000_0040;
                6'h07: OUT = 64'h0000_0000_0000_0080;
                6'h08: OUT = 64'h0000_0000_0000_0100;
                6'h09: OUT = 64'h0000_0000_0000_0200;
                6'h0a: OUT = 64'h0000_0000_0000_0400;
                6'h0b: OUT = 64'h0000_0000_0000_0800;
                6'h0c: OUT = 64'h0000_0000_0000_1000;
                6'h0d: OUT = 64'h0000_0000_0000_2000;
                6'h0e: OUT = 64'h0000_0000_0000_4000;
                6'h0f: OUT = 64'h0000_0000_0000_8000;

                6'h10: OUT = 64'h0000_0000_0001_0000;
                6'h11: OUT = 64'h0000_0000_0002_0000;
                6'h12: OUT = 64'h0000_0000_0004_0000;
                6'h13: OUT = 64'h0000_0000_0008_0000;
                6'h14: OUT = 64'h0000_0000_0010_0000;
                6'h15: OUT = 64'h0000_0000_0020_0000;
                6'h16: OUT = 64'h0000_0000_0040_0000;
                6'h17: OUT = 64'h0000_0000_0080_0000;
                6'h18: OUT = 64'h0000_0000_0100_0000;
                6'h19: OUT = 64'h0000_0000_0200_0000;
                6'h1a: OUT = 64'h0000_0000_0400_0000;
                6'h1b: OUT = 64'h0000_0000_0800_0000;
                6'h1c: OUT = 64'h0000_0000_1000_0000;
                6'h1d: OUT = 64'h0000_0000_2000_0000;
                6'h1e: OUT = 64'h0000_0000_4000_0000;
                6'h1f: OUT = 64'h0000_0000_8000_0000;

                6'h20: OUT = 64'h0000_0001_0000_0000;
                6'h21: OUT = 64'h0000_0002_0000_0000;
                6'h22: OUT = 64'h0000_0004_0000_0000;
                6'h23: OUT = 64'h0000_0008_0000_0000;
                6'h24: OUT = 64'h0000_0010_0000_0000;
                6'h25: OUT = 64'h0000_0020_0000_0000;
                6'h26: OUT = 64'h0000_0040_0000_0000;
                6'h27: OUT = 64'h0000_0080_0000_0000;
                6'h28: OUT = 64'h0000_0100_0000_0000;
                6'h29: OUT = 64'h0000_0200_0000_0000;
                6'h2a: OUT = 64'h0000_0400_0000_0000;
                6'h2b: OUT = 64'h0000_0800_0000_0000;
                6'h2c: OUT = 64'h0000_1000_0000_0000;
                6'h2d: OUT = 64'h0000_2000_0000_0000;
                6'h2e: OUT = 64'h0000_4000_0000_0000;
                6'h2f: OUT = 64'h0000_8000_0000_0000;
                
                6'h30: OUT = 64'h0001_0000_0000_0000;
                6'h31: OUT = 64'h0002_0000_0000_0000;
                6'h32: OUT = 64'h0004_0000_0000_0000;
                6'h33: OUT = 64'h0008_0000_0000_0000;
                6'h34: OUT = 64'h0010_0000_0000_0000;
                6'h35: OUT = 64'h0020_0000_0000_0000;
                6'h36: OUT = 64'h0040_0000_0000_0000;
                6'h37: OUT = 64'h0080_0000_0000_0000;
                6'h38: OUT = 64'h0100_0000_0000_0000;
                6'h39: OUT = 64'h0200_0000_0000_0000;
                6'h3a: OUT = 64'h0400_0000_0000_0000;
                6'h3b: OUT = 64'h0800_0000_0000_0000;
                6'h3c: OUT = 64'h1000_0000_0000_0000;
                6'h3d: OUT = 64'h2000_0000_0000_0000;
                6'h3e: OUT = 64'h4000_0000_0000_0000;
                6'h3f: OUT = 64'h8000_0000_0000_0000;
                default: OUT = 64'h0000_0000_0000_0000;
            endcase
        end
        else
            OUT = 64'h0000_0000_0000_0000;
    end

endmodule

module DECODE_5_32 (IN, EN, OUT);
    input [4:0] IN;
    input EN;
    output [31:0] OUT;

    reg [31:0] OUT;

    always @(IN or EN)begin
        if(1'b0 == EN)begin
            case(IN)
                5'h00: OUT = 32'h0000_0001;
                5'h01: OUT = 32'h0000_0002;
                5'h02: OUT = 32'h0000_0004;
                5'h03: OUT = 32'h0000_0008;
                5'h04: OUT = 32'h0000_0010;
                5'h05: OUT = 32'h0000_0020;
                5'h06: OUT = 32'h0000_0040;
                5'h07: OUT = 32'h0000_0080;
                5'h08: OUT = 32'h0000_0100;
                5'h09: OUT = 32'h0000_0200;
                5'h0a: OUT = 32'h0000_0400;
                5'h0b: OUT = 32'h0000_0800;
                5'h0c: OUT = 32'h0000_1000;
                5'h0d: OUT = 32'h0000_2000;
                5'h0e: OUT = 32'h0000_4000;
                5'h0f: OUT = 32'h0000_8000;
                
                5'h10: OUT = 32'h0001_0000;
                5'h11: OUT = 32'h0002_0000;
                5'h12: OUT = 32'h0004_0000;
                5'h13: OUT = 32'h0008_0000;
                5'h14: OUT = 32'h0010_0000;
                5'h15: OUT = 32'h0020_0000;
                5'h16: OUT = 32'h0040_0000;
                5'h17: OUT = 32'h0080_0000;
                5'h18: OUT = 32'h0100_0000;
                5'h19: OUT = 32'h0200_0000;
                5'h1a: OUT = 32'h0400_0000;
                5'h1b: OUT = 32'h0800_0000;
                5'h1c: OUT = 32'h1000_0000;
                5'h1d: OUT = 32'h2000_0000;
                5'h1e: OUT = 32'h4000_0000;
                5'h1f: OUT = 32'h8000_0000;

                default: OUT = 32'h0000_0000;
            endcase
        end
        else
            OUT = 32'h0000_0000;
    end
endmodule
