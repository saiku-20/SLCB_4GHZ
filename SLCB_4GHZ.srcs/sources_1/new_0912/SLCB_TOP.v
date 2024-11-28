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


module SLCB_TOP(
    input						    clk		            ,//系统时钟信号；
    input						    rst_n	            ,//系统复位信号，低电平有效；

    input                           gt_refclk_p         ,//gt差分参考时钟信号；
    input                           gt_refclk_n         ,//gt差分参考时钟信号；
    input                           gt_rx_p_0           ,//gt接收差分数据线；
    input                           gt_rx_n_0           ,//gt接收差分数据线；
    output                          gt_tx_p_0           ,//gt发送差分数据线；
    output                          gt_tx_n_0           ,//gt发送差分数据线；
    input                           gt_rx_p_1           ,//gt接收差分数据线；
    input                           gt_rx_n_1           ,//gt接收差分数据线；
    output                          gt_tx_p_1           ,//gt发送差分数据线；
    output                          gt_tx_n_1           ,//gt发送差分数据线；
    output      [1  :0]             dislabe  ,            //光电转换模块失能信号；
    
    output      [1:0]               led
);
    wire                            system_rst          ;//系统复位信号；
    //GT收发器0的相关信号；
    wire                            user_clk_0          ;//用户参考时钟信号；
    wire                            user_reset_0        ;//输出给用户的复位信号；
    (* MARK_DEBUG = "TRUE" *)wire                            hard_err_0          ;//硬件错误指示信号；
    (* MARK_DEBUG = "TRUE" *)wire                            soft_err_0          ;//软件错误指示信号；
    (* MARK_DEBUG = "TRUE" *)wire                            channel_up_0        ;//通道初始化完成且通道准备好数据时拉高；
    (* MARK_DEBUG = "TRUE" *)wire                            lane_up_0           ;//单通道初始化成功信号；
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            s_axi_tx_tdata_0    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [7  : 0]            s_axi_tx_tkeep_0    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tlast_0    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tvalid_0   ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tready_0   ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            m_axi_rx_tdata_0    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [7 : 0]             m_axi_rx_tkeep_0    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tlast_0    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tvalid_0   ;//用户接收数据的AXI_STEAM流接口信号；
    //GT收发器1的相关信号；
    wire                            user_clk_1          ;//用户参考时钟信号；
    wire                            user_reset_1        ;//输出给用户的复位信号；
    (* MARK_DEBUG = "TRUE" *)wire                            hard_err_1          ;//硬件错误指示信号；
    (* MARK_DEBUG = "TRUE" *)wire                            soft_err_1          ;//软件错误指示信号；
    (* MARK_DEBUG = "TRUE" *)wire                            channel_up_1        ;//通道初始化完成且通道准备好数据时拉高；
    (* MARK_DEBUG = "TRUE" *)wire                            lane_up_1           ;//单通道初始化成功信号；
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            s_axi_tx_tdata_1    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [7  : 0]            s_axi_tx_tkeep_1    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tlast_1    ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tvalid_1   ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tready_1   ;//用户发送数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            m_axi_rx_tdata_1    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire        [7 : 0]             m_axi_rx_tkeep_1    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tlast_1    ;//用户接收数据的AXI_STEAM流接口信号；
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tvalid_1   ;//用户接收数据的AXI_STEAM流接口信号；

    assign dislabe = 2'd0;
    assign led = {channel_up_0,channel_up_1};
    
    wire clk_i;
    assign clk_i = clk;
    //例化复位同步模块；
    rst_syc_module #(
        .RST_IN_VLD     ( 1'b0      ),//复位输入有效电平，默认低电平；
        .RST_OUT_VLD    ( 1'b1      ),//复位输出有效电平，默认高电平；
        .RST_CYCLE	    ( 8	        ) //同步时钟个数；
    )
    rst_syc_module (
        .clk		    ( clk	    ),//系统时钟信号；
        .rst_n_in       ( rst_n     ),//复位输入信号，默认低电平有效；
        .rst_out        ( system_rst) //复位输出信号，默认高电平有效；
    );

/*
    //例化生成用户测试数据模块0.
    user_test_data #(
        .TX_DATA_LEN    ( 20        ),//发送一帧数据的长度；
        .KEEP           ( 8'hfc     ) //最后一个数据的掩码；
    )
    u_user_test_data_0 (
        .clk		        ( user_clk_0        ),//系统时钟信号；
        .rst 	            ( user_reset_0      ),//系统复位信号，高电平有效；
        .m_axi_tx_tdata     ( s_axi_tx_tdata_0  ),//发送数据的数据信号；
        .m_axi_tx_tkeep     ( s_axi_tx_tkeep_0  ),//发送数据的数据掩码信号，低电平有效；
        .m_axi_tx_tlast     ( s_axi_tx_tlast_0  ),//发送一帧数据的最后一个数据指示信号；
        .m_axi_tx_tvalid    ( s_axi_tx_tvalid_0 ),//发送数据的有效指示信号；
        .m_axi_tx_tready    ( s_axi_tx_tready_0 ),//发送数据的应答信号；
        .s_axi_rx_tdata     ( m_axi_rx_tdata_0  ),//接收数据的数据信号；
        .s_axi_rx_tkeep     ( m_axi_rx_tkeep_0  ),//接收数据的数据掩码信号；
        .s_axi_rx_tlast     ( m_axi_rx_tlast_0  ),//接收一帧数据的最后一个数据指示信号；
        .s_axi_rx_tvalid    ( m_axi_rx_tvalid_0 ) //接收数据的有效指示信号；
    );

    //例化生成用户测试数据模块1.
    user_test_data #(
        .TX_DATA_LEN    ( 20        ),//发送一帧数据的长度；
        .KEEP           ( 8'hf0     ) //最后一个数据的掩码；
    )
    u_user_test_data_1 (
        .clk		        ( user_clk_1        ),//系统时钟信号；
        .rst 	            ( user_reset_1      ),//系统复位信号，高电平有效；
        .m_axi_tx_tdata     ( s_axi_tx_tdata_1  ),//发送数据的数据信号；
        .m_axi_tx_tkeep     ( s_axi_tx_tkeep_1  ),//发送数据的数据掩码信号，低电平有效；
        .m_axi_tx_tlast     ( s_axi_tx_tlast_1  ),//发送一帧数据的最后一个数据指示信号；
        .m_axi_tx_tvalid    ( s_axi_tx_tvalid_1 ),//发送数据的有效指示信号；
        .m_axi_tx_tready    ( s_axi_tx_tready_1 ),//发送数据的应答信号；
        .s_axi_rx_tdata     ( m_axi_rx_tdata_1  ),//接收数据的数据信号；
        .s_axi_rx_tkeep     ( m_axi_rx_tkeep_1  ),//接收数据的数据掩码信号；
        .s_axi_rx_tlast     ( m_axi_rx_tlast_1  ),//接收一帧数据的最后一个数据指示信号；
        .s_axi_rx_tvalid    ( m_axi_rx_tvalid_1 ) //接收数据的有效指示信号；
    );
*/
assign s_axi_tx_tdata_0 = 64'hA5A5A5A5_5A5A5A5A;
assign s_axi_tx_tdata_1 = 64'hAAAAAAAA_55555555;
assign s_axi_tx_tvalid_0 = 1'd1;
assign s_axi_tx_tvalid_1 = 1'd1;
/*
    always @(posedge user_clk_0)begin
        if(system_rst)begin
            s_axi_tx_tdata_0 <= 64'h0;
        end
        else
    end
    */
    //例化两个通道的GT收发器；
    aurora_module u_aurora_module(
        .gt_refclk_p        ( gt_refclk_p       ),//GT差分参考时钟，IP设置为156.25MHZ;
        .gt_refclk_n        ( gt_refclk_n       ),//GT差分参考时钟，IP设置为156.25MHZ;
        .system_rst         ( system_rst        ),//系统复位信号；
        .init_clk           ( clk               ),//初始化时钟，IP设置为100MHz。
        .drp_clk            ( clk               ),//DRP时钟信号,IP设置为100MHz。
        //QPLL的DRP接口；
        .qpll_drpaddr       ( 0                 ),//QPLL的DRP地址信号；
        .qpll_drpdi         ( 0                 ),//QPLL的DRP数据输入信号；
        .qpll_drprdy        (                   ),//QPLL的DRP应答信号；
        .qpll_drpen         ( 0                 ),//QPLL的DRP使能信号；
        .qpll_drpwe         ( 0                 ),//QPLL的DRP读写指示信号；
        .qpll_drpdo         (                   ),//QPLL的DRP数据输出信号；
        //GT收发器0的相关信号；
        .gt_rx_p_0          ( gt_rx_p_0         ),//GT收发器的接收数据差分引脚；
        .gt_rx_n_0          ( gt_rx_n_0         ),//GT收发器的接收数据差分引脚；
        .user_clk_0         ( user_clk_0        ),//用户参考时钟信号；
        .user_reset_0       ( user_reset_0      ),//输出给用户的复位信号；
        .gt_loopback_0      ( 3'b000            ),//GT收发器的回环模式控制信号；
        .gt_tx_p_0          ( gt_tx_p_0         ),//GT收发器的发送数据差分引脚；
        .gt_tx_n_0          ( gt_tx_n_0         ),//GT收发器的发送数据差分引脚；
        .hard_err_0         ( hard_err_0        ),//硬件错误指示信号；
        .soft_err_0         ( soft_err_0        ),//软件错误指示信号；
        .channel_up_0       ( channel_up_0      ),//通道初始化完成且通道准备好数据时拉高；
        .lane_up_0          ( lane_up_0         ),//单通道初始化成功信号；
        .s_axi_tx_tdata_0   ( s_axi_tx_tdata_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tkeep_0   ( s_axi_tx_tkeep_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tlast_0   ( s_axi_tx_tlast_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tvalid_0  ( s_axi_tx_tvalid_0 ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tready_0  ( s_axi_tx_tready_0 ),//用户发送数据的AXI_STEAM流接口信号；
        .m_axi_rx_tdata_0   ( m_axi_rx_tdata_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tkeep_0   ( m_axi_rx_tkeep_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tlast_0   ( m_axi_rx_tlast_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tvalid_0  ( m_axi_rx_tvalid_0 ),//用户接收数据的AXI_STEAM流接口信号；
        .gt_drpaddr_0       ( 0                 ),//GT收发器的DRP地址信号；
        .gt_drpdi_0         ( 0                 ),//GT收发器的DRP数据输入信号；
        .gt_drprdy_0        (                   ),//GT收发器的DRP应答信号；
        .gt_drpen_0         ( 0                 ),//GT收发器的DRP使能信号；
        .gt_drpwe_0         ( 0                 ),//GT收发器的DRP读写指示信号；
        .gt_drpdo_0         (                   ),//GT收发器的DRP数据输出信号；
        //GT收发器1的相关信号；
        .gt_rx_p_1          ( gt_rx_p_1         ),//GT收发器的接收数据差分引脚；
        .gt_rx_n_1          ( gt_rx_n_1         ),//GT收发器的接收数据差分引脚；
        .user_clk_1         ( user_clk_1        ),//用户参考时钟信号；
        .user_reset_1       ( user_reset_1      ),//输出给用户的复位信号；
        .gt_loopback_1      ( 3'b000            ),//GT收发器的回环模式控制信号；
        .gt_tx_p_1          ( gt_tx_p_1         ),//GT收发器的发送数据差分引脚；
        .gt_tx_n_1          ( gt_tx_n_1         ),//GT收发器的发送数据差分引脚；
        .hard_err_1         ( hard_err_1        ),//硬件错误指示信号；
        .soft_err_1         ( soft_err_1        ),//软件错误指示信号；
        .channel_up_1       ( channel_up_1      ),//通道初始化完成且通道准备好数据时拉高；
        .lane_up_1          ( lane_up_1         ),//单通道初始化成功信号；
        .s_axi_tx_tdata_1   ( s_axi_tx_tdata_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tkeep_1   ( s_axi_tx_tkeep_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tlast_1   ( s_axi_tx_tlast_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tvalid_1  ( s_axi_tx_tvalid_1 ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tready_1  ( s_axi_tx_tready_1 ),//用户发送数据的AXI_STEAM流接口信号；
        .m_axi_rx_tdata_1   ( m_axi_rx_tdata_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tkeep_1   ( m_axi_rx_tkeep_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tlast_1   ( m_axi_rx_tlast_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tvalid_1  ( m_axi_rx_tvalid_1 ),//用户接收数据的AXI_STEAM流接口信号；
        .gt_drpaddr_1       ( 0                 ),//GT收发器的DRP地址信号；
        .gt_drpdi_1         ( 0                 ),//GT收发器的DRP数据输入信号；
        .gt_drprdy_1        (                   ),//GT收发器的DRP应答信号；
        .gt_drpen_1         ( 0                 ),//GT收发器的DRP使能信号；
        .gt_drpwe_1         ( 0                 ),//GT收发器的DRP读写指示信号；
        .gt_drpdo_1         (                   ) //GT收发器的DRP数据输出信号；
    );
    
    /*
    ila_0 u_ila_1 (
	.clk(user_clk_1), // input wire clk


	.probe0(s_axi_tx_tvalid_0), // input wire [0:0]  probe0  
	.probe1(s_axi_tx_tready_0), // input wire [0:0]  probe1 
	.probe2(m_axi_rx_tvalid_0), // input wire [0:0]  probe2 
	.probe3(s_axi_tx_tvalid_1), // input wire [0:0]  probe3 
	.probe4(s_axi_tx_tready_1), // input wire [0:0]  probe4 
	.probe5(m_axi_rx_tvalid_1), // input wire [0:0]  probe5 
	.probe6(s_axi_tx_tdata_0), // input wire [63:0]  probe6 
	.probe7(m_axi_rx_tdata_0), // input wire [63:0]  probe7 
	.probe8(s_axi_tx_tdata_1), // input wire [63:0]  probe8 
	.probe9(m_axi_rx_tdata_1), // input wire [63:0]  probe9m_
	.probe10(channel_up_0), // input wire [0:0]  probe10 
	.probe11(channel_up_1), // input wire [0:0]  probe11 
	.probe12(user_clk_0), // input wire [0:0]  probe12 
	.probe13(user_clk_1) // input wire [0:0]  probe13
);*/
endmodule
