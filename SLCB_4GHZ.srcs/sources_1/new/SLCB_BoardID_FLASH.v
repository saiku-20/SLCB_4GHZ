`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/10 22:01:47
// Design Name: 
// Module Name: BOARD_ID_FLASH
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
//

module SLCB_BoardID_FLASH(
    input           SYS_CLK_200,
    input           RESET,
    
    input           I_CMD_VALID,
    input           I_PROGRAM_VALID,
    input           I_READ_VALID,
    input           I_STATUS_RD_VALID,
    input   [63:0]  I_PROGRAM_DATA,

    output  [63:0]  O_READ_DATA,

    output  reg     O_FLASH_SI,
    input           I_FLASH_SO,
    output  reg     O_FLASH_CS_N,
    output          O_FLASH_SCLK
);
localparam          IDLE    = 0,
                    CHECK   = 1,
                    CONFIG  = 2,
                    PAGE_WR = 3,
                    PAGE_RD = 4;

localparam          SPACE   = 0,
                    READY   = 1,
                    UPLOAD  = 2;

//signal
    reg     [3:0]   cs_delay_cnt;
    reg             operate_begin;
//lock data
    wire            cmd_valid;
    reg     [1:0]   cmd_valid_r;

    wire            read_valid;
    reg     [1:0]   read_data_valid_r;

    wire            program_valid;
    wire    [6:0]   progrm_fifo_wr_cnt;
    wire    [7:0]   rcv_fifo_wr_cnt;
    reg     [63:0]  pc_cmd_data;
    reg     [63:0]  program_data;
    reg     [1:0]   program_valid_r;
//CLK
    reg     [1:0]   div_cnt;
    reg     [2:0]   sclk_r;
    reg             sclk;
    reg             sclk_neg;
    reg             sclk_pos;
    reg             pre_sclk_neg;
    reg             pre_sclk_pos;
    reg             ini_clk_neg;
    reg             ini_clk_pos;
//ma
    reg     [2:0]   gen_state;
    reg     [2:0]   rd_state;
    reg             check_end;
    reg             config_end;
    reg             page_wr_end;
    reg             page_rd_end;
    wire            is_configed;
    wire            is_busy;

    reg             check_page_wr_req;
//check
    reg             check_seq_flag;
    reg     [4:0]   check_seq_cnt;
    reg     [7:0]   check_opcode;
    reg             check_rcv_flag;
    reg     [7:0]   check_send_byte;
    reg     [7:0]   check_rcv_byte;
    reg     [7:0]   check_byte;   

    reg             config_seq_flag;
    reg     [5:0]   config_seq_cnt;
    wire    [31:0]  config_opcode;
    reg     [31:0]  config_send_byte;
//page_wr
    reg             page_seq_flag;
    reg      [5:0]  page_seq_cnt;
    reg      [6:0]  page_word_cnt;
    wire     [31:0] page_opcode;
    reg      [31:0] page_send_byte;
    wire     [10:0] page_index;
    wire     [7:0]  buffer_index;

    wire     [31:0] wr_fifo_rd_data;
    wire            wr_fifo_rd_empty;  
    wire            wr_fifo_rd_en;
//page_rd
    reg             rcv_seq_flag;
    reg     [5:0]   rcv_seq_cnt;
    reg     [6:0]   rcv_word_cnt;
    wire    [31:0]  rcv_opcode;
    reg     [31:0]  rcv_send_byte;
    reg     [31:0]  rcv_lock_byte;
    reg             rcv_lock_en;
    reg             rcv_send_end;

    reg             rcv_fifo_rd_en;
    wire    [63:0]  rcv_fifo_data;
    wire            rcv_fifo_empty;

//connect
    assign          buffer_index    =   pc_cmd_data[39:32];
    assign          page_index      =   pc_cmd_data[50:40];
    assign          config_opcode   =   32'h3D2A80A6;
    assign          page_opcode     =   {8'h82,5'h0,page_index,buffer_index};
    assign          rcv_opcode      =   {8'hD2,5'H0,page_index,buffer_index};

    assign          O_READ_DATA     =   I_STATUS_RD_VALID ? {41'h0,page_word_cnt,rcv_fifo_wr_cnt,check_byte} : 64'hz;
    assign          O_READ_DATA     =   I_READ_VALID ? rcv_fifo_data : 64'hz;
    assign          is_busy         =   ~check_rcv_byte[7];  //[7] 0:busy 1:ready
    assign          is_configed     =   check_rcv_byte[7] & check_rcv_byte[0];

//lock data
    always@(posedge SYS_CLK_200)begin
        if(RESET)begin
            cmd_valid_r         <=  2'b0;
            program_valid_r     <=  2'b0;
            read_data_valid_r   <=  2'b0;
        end
        else begin
            cmd_valid_r         <=  {cmd_valid_r[0],I_CMD_VALID};
            program_valid_r     <=  {program_valid_r[0],I_PROGRAM_VALID};
            read_data_valid_r   <=  {read_data_valid_r[0],I_READ_VALID};
        end
    end
    always@(posedge SYS_CLK_200)begin
        program_data            <=  I_PROGRAM_DATA;
        if(I_CMD_VALID)
            pc_cmd_data         <=  I_PROGRAM_DATA;
    end
    assign      cmd_valid = ~cmd_valid_r[1] & cmd_valid_r[0];
    assign      program_valid = program_valid_r[1] & program_valid_r[0];
    assign      read_valid  =   ~read_data_valid_r[1] & read_data_valid_r[0];
//clk
    always@(posedge SYS_CLK_200)begin
        if(RESET)
            div_cnt     <= 2'h0;
        else if(div_cnt == 2'h1)
            div_cnt     <= 2'h0;
        else
            div_cnt     <= div_cnt + 1'b1;
    end
    always@(posedge SYS_CLK_200)begin
        if(RESET)
            sclk_r      <= 3'b0;
        else if(div_cnt == 2'h1)
            sclk_r      <= {sclk_r[1:0],~sclk_r[0]};
        else
            sclk_r      <= {sclk_r[1:0],sclk_r[0]};      
    end
    always@(posedge SYS_CLK_200)begin
        sclk            <=  sclk_r[2];
        sclk_neg        <=  sclk_r[2] & ~sclk_r[1];
        sclk_pos        <=  ~sclk_r[2] & sclk_r[1];
        pre_sclk_neg    <=  sclk_r[1] & ~sclk_r[0];
        pre_sclk_pos    <=  ~sclk_r[1] & sclk_r[0];
    end
    assign O_FLASH_SCLK = (O_FLASH_CS_N) ? 1'b0 : sclk;
    //initial
    reg     [9:0]   ini_delay_cnt;
    reg             ini_complete;
    reg             ini_delay_complete;
    always@(posedge SYS_CLK_200)begin
        if(RESET)
            ini_delay_cnt   <=  10'h0;
        else if(ini_delay_cnt == 10'h3ff)
            ini_delay_cnt   <=  ini_delay_cnt;
        else
            ini_delay_cnt   <=  ini_delay_cnt + 1'b1;
    end

    always@(posedge SYS_CLK_200)begin
        ini_delay_complete <= &ini_delay_cnt;
    end

    always@(posedge SYS_CLK_200)begin
        if(RESET)
            ini_complete    <= 1'b0;
        else if(check_end && !ini_complete && is_configed)
            ini_complete    <= 1'b1;
    end
    //main
    always@(posedge SYS_CLK_200)begin
        if(RESET)
            gen_state       <=  IDLE;
        else begin
        case(gen_state)
            IDLE:begin
                if(ini_delay_complete && !ini_complete)
                    gen_state       <=  CONFIG;
                else if(cmd_valid && pc_cmd_data[63:61] == 3'h1)
                    gen_state       <=  PAGE_WR;
                else if(cmd_valid && pc_cmd_data[63:61] == 3'h2)
                    gen_state       <=  PAGE_RD;
            end
            CHECK:begin
                if(check_end)begin
                    if(!ini_complete)
                        gen_state   <=  (is_configed) ? IDLE : CHECK;
                    else
                        gen_state   <=  (is_busy) ? CHECK : IDLE; 
                end
            end
            CONFIG:begin
                if(config_end)
                    gen_state       <=  CHECK;
            end
            
            endcase
        end
    end
//check_end
    always@(posedge SYS_CLK_200)
        check_end   <= (check_seq_cnt == 5'd16 && pre_sclk_pos) ? 1'b1 : 1'b0;
//send_byte
    always@(posedge SYS_CLK_200)begin
        if(gen_state == CHECK)begin
            if(operate_begin)
                check_send_byte     <= check_opcode;
            else if(~check_rcv_flag && pre_sclk_neg) 
                check_send_byte     <= {check_send_byte[6:0],1'b0};
        end
        else
            check_send_byte         <= 8'h0;
    end
//rcv_byte
    always@(posedge SYS_CLK_200)begin
        if(RESET)
            check_rcv_byte      <=  8'h0;
        else if((check_seq_cnt >= 5'd8 && 5'd15 >= check_seq_cnt) && sclk_neg)
            check_rcv_byte      <=  {check_rcv_byte[6:0],I_FLASH_SO};  
    end
//check_byte

endmodule
