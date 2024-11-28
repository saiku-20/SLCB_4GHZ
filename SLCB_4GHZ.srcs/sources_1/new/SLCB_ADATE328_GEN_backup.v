`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/17 20:44:19
// Design Name: 
// Module Name: SLCB_ADATE328_GEN
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
//serial traslate
module SLCB_ADATE328_GEN(
    input               clk                   ,
    input               rst                   ,
    
    input     [3:0]     P_B_Pin_En              ,
    //input               C_WR_PIN_EN           ,
    input               C_PE_RST_EN           ,
    input               C_PE_RDWR_EN          , //write frame to read or write
    input               C_PE_READ_EN          ,
   
    
    input      [63:0]   I_PE_WR_DATA          ,
    output reg [63:0]   O_PE_RD_DATA          ,  
    
    output               O_SPI_RSTb           ,
    output               O_SPI_SCLK           ,
    output               O_SPI_CSb            ,
    input                I_SPI_SDO            ,
    output               O_SPI_SDI            ,

    input                I_SPI_BUSYb 
    
);



localparam  READ = 1'b0,WRITE =  1'b1;
localparam  IDLE            =   5'd0,
            DATA_WR         =   5'd1,
            WAIT_WR_DONE    =   5'd2,
            DATA_RD         =   5'd3,
            WAIT_RD_DONE    =   5'd4,
            DATA_RD_NEXT    =   5'd5,

            DATA_WR0        =   5'd6,
            WAIT_WR0_DONE   =   5'd7,
            DATA_RD0        =   5'd8,
            WAIT_RD0_DONE   =   5'd9,
            DATA_RD0_NEXT   =   5'd10,
            FINISH          =   5'd11;
            
reg  [28:0] Data_To_SPI;
wire [28:0] Data_From_SPI;

reg i_pe_rdwr_en_r;
always@(posedge clk)begin
    if(C_PE_RDWR_EN)
        i_pe_rdwr_en_r <= 1'b1;
    else
        i_pe_rdwr_en_r <= 1'b0;   
end

//spi module
reg write,pe_rst;
SLCB_ADATE328_SPI u_SLCB_ADATE328_SPI(
    .clk        (clk)               ,
    .rst        (rst)               ,
    .i_write     (write)            ,
    //.i_read      (read)            ,
    .i_pe_rst    (pe_rst)           ,
    .o_read_done  (read_done)       ,
    .o_write_done (write_done)      ,
    .o_reset_done (reset_done)      ,
    .i_send_data  (Data_To_SPI)     ,
    .o_recive_data(Data_From_SPI)   ,
    .O_SPI_RSTb   (O_SPI_RSTb)      ,
    .O_SPI_SCLK   (O_SPI_SCLK)      ,
    .O_SPI_CSb    (O_SPI_CSb)       ,
    .I_SPI_SDO    (I_SPI_SDO)       ,
    .O_SPI_SDI    (O_SPI_SDI)       ,
    .I_SPI_BUSYb (I_SPI_BUSYb)
);

//TX to spi fifo
reg        spi_tx_en;
reg        spi_tx_en_r;
wire [63:0]spi_tx_combine_data;
wire [7:0] spi_tx_count;
wire       spi_tx_empty;
fifo_generator_64in_64out_D128_1 u_TX_fifo_generator_64in_64out_D128_1 (
  .clk(clk),                // input wire clk
  .srst(rst|pe_rst),              // input wire srst
  .din(I_PE_WR_DATA),                // input wire [63 : 0] din
  .wr_en(i_pe_rdwr_en_r),            // input wire wr_en
  .rd_en(spi_tx_en),            // input wire rd_en
  .dout(spi_tx_combine_data),              // output wire [63 : 0] dout
  .full(),              // output wire full
  .empty(spi_tx_empty),            // output wire empty
  .data_count(spi_tx_count)  // output wire [7 : 0] data_count
);

//rx from spi fifo
reg         spi_rx_en;
wire  [28:0] spi_rx_data;
wire [10:0] spi_rx_count;
wire        spi_rx_empty;
fifo_generator_29in_29out u_RX_fifo_generator_29in_29out (
  .clk(clk),                // input wire clk
  .srst(rst|pe_rst),              // input wire srst
  .din(Data_From_SPI),                // input wire [28 : 0] din
  .wr_en(read_done),            // input wire wr_en
  .rd_en(spi_rx_en),            // input wire rd_en
  .dout(spi_rx_data),              // output wire [28 : 0] dout
  .full(),              // output wire full
  .empty(spi_rx_empty),            // output wire empty
  .data_count(spi_rx_count)  // output wire [10 : 0] data_count
);

//read commed
reg [4:0] read_state;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        read_state       <= 5'd0;
        spi_rx_en        <= 1'b0;
    end
    else if(!spi_rx_empty )begin
        case(read_state)
            5'd0:begin 
                spi_rx_en <= 1'b0;
                read_state <= 5'd1;
            end
            5'd1:begin 
                O_PE_RD_DATA[31:0] <= {7'b0,1'b0,spi_rx_data[24:17],spi_rx_data[15:0]};
                spi_rx_en  <= 1'b1;read_state <= 5'd2;end
            5'd2:begin
                spi_rx_en  <= 1'b0;
                read_state <= 5'd3;
            end    
            5'd3:begin
                O_PE_RD_DATA[63:32] <= {7'b0,1'b0,spi_rx_data[24:17],spi_rx_data[15:0]};
                spi_rx_en  <= 1'b1;
                read_state <= 5'd4;
            end
            5'd4:begin 
                if(C_PE_READ_EN) begin
                    O_PE_RD_DATA <= 64'b0;
                    spi_rx_en    <= 1'b0;
                    read_state   <= 5'd1;
                end
                else
                    spi_rx_en    <= 1'b0;
                    read_state   <= read_state;
            end
        endcase
    end
    else
        spi_rx_en  <= 1'b0;
        O_PE_RD_DATA <= 64'hffff_ffff_ffff_ffff;
        read_state <= 5'd0;
end

//save for one claps,
reg [4:0] send_state;
reg spi_tx_ready;
reg [63:0] spi_tx_combine_data_r;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        spi_tx_ready <= 1'b1;
        spi_tx_combine_data_r <= 64'd0;end
    else if(spi_tx_en)begin
        spi_tx_ready <= 1'b0;
        spi_tx_combine_data_r <= spi_tx_combine_data;end
     else if(send_state == FINISH)   //to combine mulit spi parts ,just change the judget method in here.
        spi_tx_ready <= 1'b1;
    else begin
        spi_tx_ready <= spi_tx_ready;
        spi_tx_combine_data_r <= spi_tx_combine_data_r;end
end

reg error0,error1,wr_rd0,wr_rd1;
always@(posedge clk or posedge rst)begin
    if(rst)begin
        error0 <= 1'b0;
        error1 <= 1'b0;
        wr_rd0 <= 1'b1;
        wr_rd1 <= 1'b1;end
    else if(spi_tx_en_r)begin
        error0 <= (!(|spi_tx_combine_data_r[31:0])) | (&spi_tx_combine_data_r[31:0]); //0 ： data is valid 
        error1 <= (!(|spi_tx_combine_data_r[63:32])) | (&spi_tx_combine_data_r[63:32]); //
        wr_rd0 <= spi_tx_combine_data_r[24];  //0 is read
        wr_rd1 <= spi_tx_combine_data_r[56];  //1 is write
        end
end

always@(posedge clk or posedge rst)begin
    if(rst)begin
        spi_tx_en <= 1'b0; 
        spi_tx_en_r <= 1'b0;end
    else if((!spi_tx_empty) && (!spi_tx_en) && spi_tx_ready)begin
        spi_tx_en <= 1'b1;
        spi_tx_en_r <= spi_tx_en;end
    else begin
        spi_tx_en <= 1'b0;
        spi_tx_en_r <= spi_tx_en;end
end
//C_PE_RDWR_EN
reg write_r;
reg [3:0] SHIFT_REG;
wire [3:0] state;
assign state = {error1,error0,wr_rd1,wr_rd0};


always@(posedge clk or posedge rst)begin
    if(rst)begin
        write   <= 1'b0;
        write_r <= 1'b0;
        SHIFT_REG <= 4'b1;
        send_state <= 5'd0;end
    else if(!spi_tx_ready)begin
       case(state)
           4'b0010:begin 
                case(send_state)
                    IDLE:begin send_state <= DATA_WR; end
                    DATA_WR:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[55:48],WRITE,spi_tx_combine_data_r[47:32]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR_DONE:begin 
                         if(write_done)
                            send_state <= DATA_RD;
                         else 
                            send_state <= send_state; 
                    end
                    DATA_RD:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[23:16],READ,spi_tx_combine_data_r[15:0]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD_NEXT;end
                    end
                    WAIT_RD_DONE:begin
                        if(write_done) 
                            send_state <= DATA_RD_NEXT;
                        else 
                            send_state <= send_state;
                    end
                    DATA_RD_NEXT:begin
                        if(|SHIFT_REG) 
                            send_state <= DATA_RD;
                        else
                            send_state <= FINISH;
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001;end
                endcase end
           4'b0001:begin 
                case(send_state)
                    IDLE:begin send_state <= DATA_RD; end
                    DATA_RD:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[55:48],READ,spi_tx_combine_data_r[47:32]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD_NEXT;end
                    end
                    WAIT_RD_DONE:begin
                        if(write_done)begin
                            send_state <= DATA_RD_NEXT;end
                        else
                            send_state <= send_state;
                    end
                    DATA_RD_NEXT:begin
                        if(|SHIFT_REG) send_state <= DATA_RD;
                        else send_state <= DATA_WR;
                    end
                    DATA_WR:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[23:16],WRITE,spi_tx_combine_data_r[15:0]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR_DONE:begin 
                         if(write_done) 
                            send_state <= FINISH;
                         else 
                            send_state <= send_state; 
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                endcase end
           4'b0011:begin 
                case(send_state)
                    IDLE:begin send_state <= DATA_WR; end
                    DATA_WR:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[55:48],WRITE,spi_tx_combine_data_r[47:32]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR_DONE:begin 
                         if(write_done)
                            send_state <= DATA_WR0;
                         else 
                            send_state <= send_state; 
                    end
                    DATA_WR0:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR0_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[23:16],WRITE,spi_tx_combine_data_r[15:0]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR0_DONE:begin 
                         if(write_done) 
                            send_state <= FINISH;
                         else 
                            send_state <= send_state; 
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                endcase end
           4'b0000:begin
                case(send_state)
                    IDLE:begin send_state <= DATA_RD; end
                    DATA_RD:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|SHIFT_REG & |(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[55:48],READ,spi_tx_combine_data_r[47:32]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD_NEXT;end
                    end
                    WAIT_RD_DONE:begin
                        if(write_done) 
                            send_state <= DATA_RD_NEXT;
                        else 
                            send_state <= send_state;end
                    DATA_RD_NEXT:begin
                        if(|SHIFT_REG) 
                            send_state <= DATA_RD;
                        else 
                            send_state <= DATA_RD0;
                    end
                    DATA_RD0:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD0_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|SHIFT_REG & |(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[23:16],READ,spi_tx_combine_data_r[15:0]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD0_NEXT;end
                    end
                    WAIT_RD0_DONE:begin
                        if(write_done)
                            send_state <= DATA_RD0_NEXT;
                        else 
                            send_state <= send_state;
                    end
                    DATA_RD0_NEXT:begin
                        if(|SHIFT_REG)
                            send_state <= DATA_RD0;
                        else
                            send_state <= FINISH;
                    end 
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                  endcase
                end
           4'b011X:begin
                case(send_state)
                    IDLE:begin send_state <= DATA_WR; end
                    DATA_WR:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[55:48],WRITE,spi_tx_combine_data_r[47:32]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR_DONE:begin 
                         if(write_done)
                            send_state <= FINISH;
                         else
                            send_state <= send_state; 
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                endcase end
           4'b010X:begin 
                case(send_state)
                    IDLE:begin  send_state <= DATA_RD; end
                    DATA_RD:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[55:48],READ,spi_tx_combine_data_r[47:32]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD_NEXT;end                                                                                                   
                    end
                    WAIT_RD_DONE:begin
                        if(write_done)
                            send_state <= DATA_RD_NEXT;
                        else
                            send_state <= send_state;
                    end
                    DATA_RD_NEXT:begin
                        if(|SHIFT_REG)
                            send_state <= DATA_RD;
                        else
                            send_state <= FINISH;
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                    endcase end
           4'b10X1:begin 
                case(send_state)
                    IDLE:begin send_state <= DATA_WR; end
                    DATA_WR:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_WR_DONE;end
                        else begin
                            Data_To_SPI <= {P_B_Pin_En,spi_tx_combine_data_r[23:16],WRITE,spi_tx_combine_data_r[15:0]}; 
                            write_r <= |P_B_Pin_En; write <= write_r;end
                    end
                    WAIT_WR_DONE:begin 
                         if(write_done)
                            send_state <= FINISH;
                         else
                            send_state <= send_state; 
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                endcase end
           4'b10X0:begin
                case(send_state)
                    IDLE:begin send_state <= DATA_RD; end
                    DATA_RD:begin
                        if(write_r && write)begin
                            write_r <= 1'b0;write <= 1'b0;send_state <= WAIT_RD_DONE;
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};end
                        else if(|SHIFT_REG & |(P_B_Pin_En & SHIFT_REG)) begin
                            Data_To_SPI <= {P_B_Pin_En & SHIFT_REG,spi_tx_combine_data_r[23:16],READ,spi_tx_combine_data_r[15:0]};
                            write_r <= |(P_B_Pin_En & SHIFT_REG); write <= write_r;end
                        else begin
                            SHIFT_REG <= {SHIFT_REG[2:0],1'b0};
                            send_state <= DATA_RD_NEXT;end
                    end
                    WAIT_RD_DONE:begin
                        if(write_done)begin
                            send_state <= DATA_RD_NEXT;end
                        else
                            send_state <= send_state;
                    end
                    DATA_RD_NEXT:begin
                        if(|SHIFT_REG)
                            send_state <= DATA_RD;
                        else
                            send_state <= FINISH;
                    end
                    default:begin send_state <= IDLE; SHIFT_REG  <= 4'b0001; end
                endcase end
           4'b11XX:begin send_state <= FINISH; end
           default:begin send_state <= IDLE; end
       endcase
    end
end

//hdw reset
reg pe_rst_ready;
reg [4:0] rst_state;
always@(posedge clk or posedge rst )begin
    if(rst)begin
        pe_rst <= 1'b0;
        rst_state <= 5'd0;
        pe_rst_ready <= 1'b1;end
    else begin
        case(rst_state)
            5'd0:begin rst_state <= C_PE_RST_EN ? 5'd1 : rst_state;end
            5'd1:begin pe_rst_ready <= 1'b0;pe_rst <= 1'b1;rst_state <= 5'd2;end
            5'd2:begin pe_rst_ready <= 1'b0;pe_rst <= 1'b0;rst_state <= 5'd3;end
            5'd3:begin rst_state <= reset_done ? 5'd4: rst_state;end
            5'd4:begin pe_rst_ready <= 1'b1;rst_state <= 5'd5;end
            default:begin pe_rst_ready <= 1'b1;rst_state <= 5'd0;end
        endcase end
end

endmodule