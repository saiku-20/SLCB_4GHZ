`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/12 16:20:25
// Design Name: 
// Module Name: SLCB_DataBus_Unwrapping
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
// SLCB Data Bus Unpacking Module
// SLCB 数据总线解包模块
// 
// This module handles unpacking of data bus protocol frames
// 该模块处理数据总线协议帧的解包
//
// Protocol Frame Format / 协议帧格式:
// First Frame / 第一帧:
// [63:40] - Preamble / 前导码 (24'h5555d5)
// [39:32] - Sequence Number / 序列号
// [31:30] - Reserved / 保留位
// [29]    - CRC Enable / CRC使能
// [28:4]  - Length / 数据长度
// [3:0]   - Bus Command / 总线命令
//
// Second Frame / 第二帧:
// [63:59] - System Board Select / 系统板卡选择
// [58:53] - FPGA Select / FPGA选择
// [52:47] - Reserved / 保留位
// [46:8]  - Slot Select / 槽位选择
// [7:0]   - PC Address / PC地址

module SLCB_DataBus_Unpacking_Module(
    // Clock and Reset / 时钟和复位
    input               RESET,              // System reset / 系统复位
    input               CLK,                // System clock / 系统时钟
    
    // TX FIFO Interface / 发送FIFO接口
    output  reg         DataBus_txfifo_en,  // TX FIFO enable / 发送FIFO使能
    output   [63:0]     DataBus_txfifo_data, // TX FIFO data / 发送FIFO数据
    
    // RX FIFO Interface / 接收FIFO接口
    output  reg         DataBus_rxfifo_en,  // RX FIFO enable / 接收FIFO使能
    input        [63:0] DataBus_rxfifo_data, // RX FIFO data / 接收FIFO数据
    input               DataBus_rxfifo_empty, // RX FIFO empty flag / 接收FIFO空标志
    
    // Control Interface / 控制接口
    output  reg         O_N_WR,             // Write enable / 写使能
    output  reg         O_N_RD,             // Read enable / 读使能
    output  reg         O_N_CE,             // Chip enable / 片选使能
    output  reg   [7:0] O_PCADD,            // PC address / PC地址
    output  reg   [63:0] O_WRData,           // Write data / 写数据
    input         [63:0] I_RDData            // Read data / 读数据
);
// State Machine Definition / 状态机定义
localparam  IDLE              =   0,  // Idle state / 空闲状态
            DOWNLOAD_PACKAGE  =   1,  // Download first frame / 下载第一帧
            DOWNLOAD_PACKAGE2 =   2,  // Download second frame / 下载第二帧  
            WRITE             =   3,  // Write operation / 写操作
            READ              =   4,  // Read operation / 读操作
            DOWNLOAD          =   5,  // Download data / 下载数据
            UPLOAD            =   6,  // Upload data / 上传数据
            TIMEOUT           =   7,  // Timeout state / 超时状态
            ERROR             =   8;  // Error state / 错误状态

// Protocol Frame Registers / 协议帧寄存器
reg     [23:0]      pcie_preamble;    // PCIe preamble / PCIe前导码
reg     [7:0]       squence_numble;   // Sequence number / 序列号
reg                 crc_enable;       // CRC check enable / CRC校验使能
reg     [1:0]       reserve0;         // Reserved bits / 保留位
reg     [24:0]      length;          // Data length / 数据长度
reg     [3:0]       Bus_Cmd;         // Bus command / 总线命令
reg     [3:0]       Bus_Cmd_temp;    // Bus command temporary / 总线命令临时    
// Second Frame Registers / 第二帧寄存器
reg     [4:0]       sys_board_choose; // System board selection / 系统板卡选择
reg     [5:0]       fpga_choose;      // FPGA selection / FPGA选择
reg     [5:0]       reserve1;         // Reserved bits / 保留位
reg     [38:0]      slot_choose;      // Slot selection / 槽位选择
reg     [7:0]       o_pcadd;          // PC address / PC地址
reg                 get_head_flag;    // Header received flag / 帧头接收标志

// State Machine and Control Registers / 状态机和控制寄存器
reg     [3:0]   operate_state;        // Current state / 当前状态
reg             write_en;             // Write enable flag / 写使能标志
reg             read_en;              // Read enable flag / 读使能标志
reg             read_complete;        // Read complete flag / 读完成标志
reg             write_complete;       // Write complete flag / 写完成标志

// Timeout Counters / 超时计数器
reg     [5:0]   package_timeout_cnt;  // Package timeout counter / 数据包超时计数器
reg     [5:0]   recive_timeout_cnt;   // Receive timeout counter / 接收超时计数器
reg     [4:0]   input_data_valid_r;   // Input data valid register / 输入数据有效寄存器

// Data Registers / 数据寄存器
reg     [63:0]  download_data;        // Download data buffer / 下载数据缓存
reg     [63:0]  download_package_data; // Package data buffer / 数据包缓存
reg             dbus_first_frame_flag; // First frame flag / 第一帧标志
reg             DataBus_rxfifo_empty_r;
always@(posedge CLK)begin
    if(RESET)begin
        O_WRData <= 64'b0;
        DataBus_rxfifo_empty_r <= 1'b0;
    end
    O_WRData <= DataBus_rxfifo_data;
    DataBus_rxfifo_empty_r <= DataBus_rxfifo_empty;
end
always@(posedge CLK or posedge RESET)begin
    if(RESET)begin
        dbus_first_frame_flag <= 1'b0;
        download_package_data <= 64'h0;
    end
    else if(operate_state == IDLE && DataBus_rxfifo_data[63:40] == 24'h5555d5)begin
        dbus_first_frame_flag   <=  1'b1;
        download_package_data   <=  DataBus_rxfifo_data;end
    else
        dbus_first_frame_flag   <=  1'b0;
end

// State Machine Logic / 状态机逻辑
always @(posedge CLK)begin
    if(RESET)begin
        operate_state   <=  IDLE;
    end
    else begin
        case(operate_state)
            IDLE:begin
                // Wait for first frame with valid preamble
                // 等待带有有效前导码的第一帧
                if(DataBus_rxfifo_en && dbus_first_frame_flag)
                    operate_state   <=  DOWNLOAD_PACKAGE;
            end
            
            DOWNLOAD_PACKAGE:begin
                // Check second frame and handle timeout
                // 检查第二帧并处理超时
                if(DataBus_rxfifo_data[63:40] != 24'h5555d5)
                    operate_state   <=  DOWNLOAD_PACKAGE2;
                else if(&package_timeout_cnt)
                    operate_state <=  IDLE;
                else
                    operate_state <= operate_state; 
            end
            
            DOWNLOAD_PACKAGE2:begin
                // Process command and transition to read/write
                // 处理命令并转换到读/写状态
                if(write_en)
                    operate_state <= WRITE;
                else if(read_en)
                    operate_state <= READ;
                else if(&package_timeout_cnt)
                    operate_state <=  IDLE;
                else
                    operate_state <= operate_state;
            end
            
            WRITE:begin
                if(write_complete)
                    operate_state   <=  IDLE;  
            end
            READ:begin
                if(read_complete)
                    operate_state   <=  IDLE;
            end
            TIMEOUT:begin
                operate_state   <=  IDLE;
            end
            default:begin operate_state <= IDLE; end
         endcase
    end
end

// Timeout Counter Logic / 超时计数器逻辑
always@(posedge CLK)begin
    if(RESET)
        recive_timeout_cnt <= 6'd0;
    else if(((~DataBus_rxfifo_en)&&(~O_N_WR)) || ((~DataBus_txfifo_en)&&(~O_N_RD)))
        recive_timeout_cnt <= recive_timeout_cnt + 1'd1;
    else
        recive_timeout_cnt <= 6'd0;
end

// Package Counter Logic / 数据包计数器逻辑
always@(posedge CLK)begin
    if(RESET)
        package_timeout_cnt <= 0;
    else if(operate_state == DOWNLOAD_PACKAGE || operate_state == DOWNLOAD_PACKAGE2)
        package_timeout_cnt <= package_timeout_cnt + 1'b1;
    else
        package_timeout_cnt <= 6'd0;  
end

// Read/Write Control Logic / 读写控制逻辑
always @(posedge CLK)begin
    case(operate_state)
        IDLE:begin
            write_en    <=  1'b0;
            read_en     <=  1'b0;
        end
        DOWNLOAD_PACKAGE2:begin
            // Decode bus command and set read/write flags
            // 解码总线命令并设置读写标志
            if(Bus_Cmd_temp[3:0] == 4'b0001)begin
                write_en    <=  1'b1;
                read_en     <=  1'b0;
            end
            else if(Bus_Cmd_temp[3:0] == 4'b0010)begin
                write_en    <=  1'b0;
                read_en     <=  1'b1;
            end
            else begin
                write_en    <=  1'b0;
                read_en     <=  1'b0;
            end
        end
        default:begin
            write_en    <=  1'b0;
            read_en     <=  1'b0;
        end
    endcase
end

// FIFO Control Logic / FIFO控制逻辑
always@(posedge CLK)begin
    if(RESET)begin
        DataBus_rxfifo_en   <=  1'b0;
    end
    else    begin
    case(operate_state)
        IDLE:begin
            // Enable RX FIFO when not empty and not already enabled
            // 当FIFO非空且未使能时使能RX FIFO
            DataBus_rxfifo_en   <=  (~DataBus_rxfifo_empty_r & ~DataBus_rxfifo_en);   
        end
        WRITE:begin
            // Enable RX FIFO during write operations
            // 写操作期间使能RX FIFO
            DataBus_rxfifo_en   <=  (~DataBus_rxfifo_empty_r & ~DataBus_rxfifo_en);
        end
        READ:begin
            // Enable RX FIFO during read operations
            // 读操作期间使能RX FIFO
            DataBus_rxfifo_en   <=  (~DataBus_rxfifo_empty_r & ~DataBus_rxfifo_en);
        end
        default:begin
            DataBus_rxfifo_en   <= 1'b0;
        end
    endcase
    end
end 

// Input Data Valid Register Logic / 输入数据有效寄存器逻辑
// Implements 4-clock cycle delay for data validation
// 实现4个时钟周期的数据有效延迟
always@(posedge CLK)begin
    if(RESET)
        input_data_valid_r  <=  5'b00000;
    else if(&input_data_valid_r)
        input_data_valid_r  <=  5'b00000;
    else
        input_data_valid_r  <=  {input_data_valid_r[3:0],~O_N_RD};
end

// TX FIFO Enable Control / 发送FIFO使能控制
always@(posedge CLK)begin
    if(RESET)
        DataBus_txfifo_en   <=  1'b0;
    else if(&input_data_valid_r)
        DataBus_txfifo_en   <=  1'b1;
    else
        DataBus_txfifo_en   <=  1'b0;
end

// Data Path Assignments / 数据通路分配
assign  DataBus_txfifo_data = I_RDData;    // TX FIFO data from read data / 发送FIFO数据来自读数据
//assign  O_WRData = download_data;          // Write data from download buffer / 写数据来自下载缓存

// PC Address Control / PC地址控制
always@(posedge CLK)begin
    if(RESET)
        O_PCADD <= 8'h0;
    else
        O_PCADD <= o_pcadd;
end

// Read/Write Counter Logic / 读写计数器逻辑
reg [24:0]   rcv_wr_num;    // Write data counter / 写数据计数器
reg [24:0]   rcv_rd_num;    // Read data counter / 读数据计数器

// Write Counter Control / 写计数器控制
always@(posedge CLK)begin
    if(operate_state == IDLE || (&recive_timeout_cnt))
        rcv_wr_num          <=  25'h0;
    else if(operate_state == DOWNLOAD_PACKAGE2)
        rcv_wr_num          <=  length - 3'h4; // Subtract header frames / 减去头帧
    else if((~O_N_WR) && DataBus_rxfifo_en && rcv_wr_num != 25'h0)
        rcv_wr_num          <=  rcv_wr_num - 2'h2;
end

// Read Counter Control / 读计数器控制
always@(posedge CLK)begin
    if(operate_state == IDLE || (&recive_timeout_cnt))
        rcv_rd_num              <=  25'h0;
    else if(operate_state == DOWNLOAD_PACKAGE2)
        rcv_rd_num              <=  length;
    else if((~O_N_RD) && DataBus_txfifo_en && rcv_rd_num != 25'h0)
        rcv_rd_num              <=  rcv_rd_num - 2'h2;
end

// Operation Complete Flags / 操作完成标志
always@(posedge CLK)begin
    // Write complete when counter reaches zero
    // 计数器到零时写完成
    if(operate_state == WRITE && rcv_wr_num == 25'h0)
        write_complete          <=  1'b1;
    else
        write_complete          <=  1'b0;
end

always@(posedge CLK)begin
    // Read complete when counter reaches zero
    // 计数器到零时读完成
    if(operate_state == READ && rcv_rd_num == 25'h0)
        read_complete           <=  1'b1;
    else
        read_complete           <=  1'b0;
end

// Chip Enable Control / 片选控制
always@(posedge CLK)
if(RESET)
    O_N_CE  <=  1'b1;
else if(operate_state == WRITE || operate_state == READ || operate_state == DOWNLOAD_PACKAGE2)
    O_N_CE  <=  1'b0;
else
    O_N_CE  <=  1'b1;

// Write Enable Control with Pipeline Delay / 写使能控制(带流水线延迟)
reg O_N_WR_rr;    // Second stage pipeline / 第二级流水线
reg O_N_WR_r;     // First stage pipeline / 第一级流水线

always@(posedge CLK)
if(RESET)begin
    O_N_WR   <=  1'b1;
    O_N_WR_r <=  1'b1;
    O_N_WR_rr <=  1'b1;
end
else if(operate_state == WRITE && (rcv_wr_num != 25'h0))begin
    O_N_WR_rr  <=  1'b0;
    O_N_WR_r   <=  O_N_WR_rr;
    O_N_WR     <=  O_N_WR_r;
end
else begin
    O_N_WR_rr  <=  1'b1;
    O_N_WR_r   <=  O_N_WR_rr;
    O_N_WR     <=  O_N_WR_r;
end

// Read Enable Control / 读使能控制
always@(posedge CLK)
if(RESET)
    O_N_RD  <=  1'b1;
else if((operate_state == READ) && (rcv_rd_num != 25'h0))
    O_N_RD  <=  1'b0;
else
    O_N_RD  <=  1'b1;

endmodule
