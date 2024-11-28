//--###############################################################################################
//--#
//--# File Name		: aurora_module
//--# Designer		: 数字站
//--# Tool			: Vivado 2021.1
//--# Design Date	: 2024.4.9
//--# Description	: 编写aurora64B66B顶层模块
//--# Version		: 0.0
//--# Coding scheme	: GBK（If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode）
//--#
//--###############################################################################################
module aurora_module (
    input               gt_refclk_p         ,//GT差分参考时钟，IP设置为156.25MHZ;
    input               gt_refclk_n         ,//GT差分参考时钟，IP设置为156.25MHZ;
    input               system_rst          ,//系统复位信号；
    input               init_clk            ,//初始化时钟，IP设置为100MHz。
    input               drp_clk             ,//DRP时钟信号,IP设置为100MHz。
    //QPLL的DRP接口；
    input   [7 : 0]     qpll_drpaddr        ,//QPLL的DRP地址信号；
    input   [15 : 0]    qpll_drpdi          ,//QPLL的DRP数据输入信号；
    output              qpll_drprdy         ,//QPLL的DRP应答信号；
    input               qpll_drpen          ,//QPLL的DRP使能信号；
    input               qpll_drpwe          ,//QPLL的DRP读写指示信号；
    output  [15 : 0]    qpll_drpdo          ,//QPLL的DRP数据输出信号；
    //GT收发器0的相关信号；
    input               gt_rx_p_0           ,//GT收发器的接收数据差分引脚；
    input               gt_rx_n_0           ,//GT收发器的接收数据差分引脚；
    output              user_clk_0          ,//用户参考时钟信号；
    output              user_reset_0        ,//输出给用户的复位信号；
    input   [2 : 0]     gt_loopback_0       ,//GT收发器的回环模式控制信号；
    output              gt_tx_p_0           ,//GT收发器的发送数据差分引脚；
    output              gt_tx_n_0           ,//GT收发器的发送数据差分引脚；
    output              hard_err_0          ,//硬件错误指示信号；
    output              soft_err_0          ,//软件错误指示信号；
    output              channel_up_0        ,//通道初始化完成且通道准备好数据时拉高；
    output              lane_up_0           ,//单通道初始化成功信号；
    input   [63 : 0]    s_axi_tx_tdata_0    ,//用户发送数据的AXI_STEAM流接口信号；
    input   [7  : 0]    s_axi_tx_tkeep_0    ,//用户发送数据的AXI_STEAM流接口信号；
    input               s_axi_tx_tlast_0    ,//用户发送数据的AXI_STEAM流接口信号；
    input               s_axi_tx_tvalid_0   ,//用户发送数据的AXI_STEAM流接口信号；
    output              s_axi_tx_tready_0   ,//用户发送数据的AXI_STEAM流接口信号；
    output  [63 : 0]    m_axi_rx_tdata_0    ,//用户接收数据的AXI_STEAM流接口信号；
    output  [7 : 0]     m_axi_rx_tkeep_0    ,//用户接收数据的AXI_STEAM流接口信号；
    output              m_axi_rx_tlast_0    ,//用户接收数据的AXI_STEAM流接口信号；
    output              m_axi_rx_tvalid_0   ,//用户接收数据的AXI_STEAM流接口信号；
    input   [8 : 0]     gt_drpaddr_0        ,//GT收发器的DRP地址信号；
    input   [15 : 0]    gt_drpdi_0          ,//GT收发器的DRP数据输入信号；
    output              gt_drprdy_0         ,//GT收发器的DRP应答信号；
    input               gt_drpen_0          ,//GT收发器的DRP使能信号；
    input               gt_drpwe_0          ,//GT收发器的DRP读写指示信号；
    output  [15 : 0]    gt_drpdo_0          ,//GT收发器的DRP数据输出信号；
    //GT收发器1的相关信号；
    input               gt_rx_p_1           ,//GT收发器的接收数据差分引脚；
    input               gt_rx_n_1           ,//GT收发器的接收数据差分引脚；
    output              user_clk_1          ,//用户参考时钟信号；
    output              user_reset_1        ,//输出给用户的复位信号；
    input   [2 : 0]     gt_loopback_1       ,//GT收发器的回环模式控制信号；
    output              gt_tx_p_1           ,//GT收发器的发送数据差分引脚；
    output              gt_tx_n_1           ,//GT收发器的发送数据差分引脚；
    output              hard_err_1          ,//硬件错误指示信号；
    output              soft_err_1          ,//软件错误指示信号；
    output              channel_up_1        ,//通道初始化完成且通道准备好数据时拉高；
    output              lane_up_1           ,//单通道初始化成功信号；
    input   [63 : 0]    s_axi_tx_tdata_1    ,//用户发送数据的AXI_STEAM流接口信号；
    input   [7  : 0]    s_axi_tx_tkeep_1    ,//用户发送数据的AXI_STEAM流接口信号；
    input               s_axi_tx_tlast_1    ,//用户发送数据的AXI_STEAM流接口信号；
    input               s_axi_tx_tvalid_1   ,//用户发送数据的AXI_STEAM流接口信号；
    output              s_axi_tx_tready_1   ,//用户发送数据的AXI_STEAM流接口信号；
    output  [63 : 0]    m_axi_rx_tdata_1    ,//用户接收数据的AXI_STEAM流接口信号；
    output  [7 : 0]     m_axi_rx_tkeep_1    ,//用户接收数据的AXI_STEAM流接口信号；
    output              m_axi_rx_tlast_1    ,//用户接收数据的AXI_STEAM流接口信号；
    output              m_axi_rx_tvalid_1   ,//用户接收数据的AXI_STEAM流接口信号；
    input   [8 : 0]     gt_drpaddr_1        ,//GT收发器的DRP地址信号；
    input   [15 : 0]    gt_drpdi_1          ,//GT收发器的DRP数据输入信号；
    output              gt_drprdy_1         ,//GT收发器的DRP应答信号；
    input               gt_drpen_1          ,//GT收发器的DRP使能信号；
    input               gt_drpwe_1          ,//GT收发器的DRP读写指示信号；
    output  [15 : 0]    gt_drpdo_1           //GT收发器的DRP数据输出信号；
);
    wire                gt_refclk           ;//GT收发器的单端时钟信号，频率为156.25MHz。
    wire                gt_qpllclk          ;//QPLL的时钟信号；
    wire                gt_qpllrefclk       ;//QPLL的参考时钟信号；
    wire                gt_qpllreset        ;//QPLL的复位信号；
    wire                gt_qplllock         ;//QPLL的锁定信号；
    wire                gt_qpllrefclklost   ;//QPLL的参考时钟失锁信号；

    //例化IBUFGDS_GTE2，将差分时钟转换为单端时钟；
    IBUFDS_GTE2 IBUFDS_GTXE2_CLK1 (
        .O      ( gt_refclk     ),//单端时钟输出信号；
        .ODIV2  (               ),//单端时钟二分频输出信号；
        .CEB    ( 1'b0          ),//IBUFDS_GTE2使能信号；
        .I      ( gt_refclk_p   ),//差分时钟输入信号；
        .IB     ( gt_refclk_n   ) //差分时钟输入信号；
    );

    //例化QPLL模块；
    aurora_64b66b_0_gt_common_wrapper gt_common_support (
        .gt_qpllclk_quad1_out       ( gt_qpllclk        ),//QPLL的时钟信号；
        .gt_qpllrefclk_quad1_out    ( gt_qpllrefclk     ),//QPLL的参考时钟信号；
        .GT0_GTREFCLK0_COMMON_IN    ( gt_refclk         ),//单端时钟输出信号；
        .GT0_QPLLLOCK_OUT           ( gt_qplllock       ),//QPLL的锁定信号；
        .GT0_QPLLRESET_IN           ( gt_qpllreset      ),//QPLL的复位信号；
        .GT0_QPLLLOCKDETCLK_IN      ( init_clk          ),//初始化时钟，IP设置为100MHz。
        .GT0_QPLLREFCLKLOST_OUT     ( gt_qpllrefclklost ),//QPLL的参考时钟失锁信号；
        .qpll_drpaddr_in            ( qpll_drpaddr      ),//QPLL的DRP地址信号；
        .qpll_drpdi_in              ( qpll_drpdi        ),//QPLL的DRP数据输入信号；
        .qpll_drpclk_in             ( drp_clk           ),//DRP时钟信号,IP设置为100MHz。
        .qpll_drpdo_out             ( qpll_drpdo        ),//QPLL的DRP数据输出信号；
        .qpll_drprdy_out            ( qpll_drprdy       ),//QPLL的DRP应答信号；
        .qpll_drpen_in              ( qpll_drpen        ),//QPLL的DRP使能信号；
        .qpll_drpwe_in              ( qpll_drpwe        ) //QPLL的DRP读写指示信号；
    );

    //例化高速收发器0；
    aurora_channel u_aurora_channel_DataBus_0(
        .gt_rx_p            ( gt_rx_p_0         ),//GT收发器的接收数据差分引脚；
        .gt_rx_n            ( gt_rx_n_0         ),//GT收发器的接收数据差分引脚；
        .gt_refclk          ( gt_refclk         ),//GT参考时钟，IP设置为156.25MHZ;
        .user_clk           ( user_clk_0        ),//用户参考时钟信号；
        .user_sys_reset     ( user_reset_0      ),//输出给用户的复位信号；
        .system_rst         ( system_rst        ),//系统复位信号；
        .gt_loopback        ( gt_loopback_0     ),//GT收发器的回环模式控制信号；
        .gt_tx_p            ( gt_tx_p_0         ),//GT收发器的发送数据差分引脚；
        .gt_tx_n            ( gt_tx_n_0         ),//GT收发器的发送数据差分引脚；
        .hard_err           ( hard_err_0        ),//硬件错误指示信号；
        .soft_err           ( soft_err_0        ),//软件错误指示信号；
        .channel_up         ( channel_up_0      ),//通道初始化完成且通道准备好数据时拉高；
        .lane_up            ( lane_up_0         ),//单通道初始化成功信号；
        .s_axi_tx_tdata     ( s_axi_tx_tdata_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tkeep     ( s_axi_tx_tkeep_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tlast     ( s_axi_tx_tlast_0  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tvalid    ( s_axi_tx_tvalid_0 ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tready    ( s_axi_tx_tready_0 ),//用户发送数据的AXI_STEAM流接口信号；
        .m_axi_rx_tdata     ( m_axi_rx_tdata_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tkeep     ( m_axi_rx_tkeep_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tlast     ( m_axi_rx_tlast_0  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tvalid    ( m_axi_rx_tvalid_0 ),//用户接收数据的AXI_STEAM流接口信号；
        .init_clk           ( init_clk          ),//初始化时钟，IP设置为100MHz。
        .drp_clk            ( drp_clk           ),//DRP时钟信号,IP设置为100MHz。
        .gt_drpaddr         ( gt_drpaddr_0      ),//GT收发器的DRP地址信号；
        .gt_drpdi           ( gt_drpdi_0        ),//GT收发器的DRP数据输入信号；
        .gt_drprdy          ( gt_drprdy_0       ),//GT收发器的DRP应答信号；
        .gt_drpen           ( gt_drpen_0        ),//GT收发器的DRP使能信号；
        .gt_drpwe           ( gt_drpwe_0        ),//GT收发器的DRP读写指示信号；
        .gt_drpdo           ( gt_drpdo_0        ),//GT收发器的DRP数据输出信号；
        .qpll_drpaddr       ( qpll_drpaddr      ),//QPLL的DRP地址信号；
        .qpll_drpdi         ( qpll_drpdi        ),//QPLL的DRP数据输入信号；
        .qpll_drpen         ( qpll_drpen        ),//QPLL的DRP使能信号；
        .qpll_drpwe         ( qpll_drpwe        ),//QPLL的DRP读写指示信号；
        .gt_qpllclk         ( gt_qpllclk        ),//QPLL的时钟信号；
        .gt_qpllrefclk      ( gt_qpllrefclk     ),//QPLL的参考时钟信号；
        .gt_qpllreset       ( gt_qpllreset      ),//QPLL的复位信号；
        .gt_qplllock        ( gt_qplllock       ),//QPLL的锁定信号；
        .gt_qpllrefclklost  ( gt_qpllrefclklost ) //QPLL的参考时钟失锁信号；
    );

    //例化高速收发器1；
    aurora_channel u_aurora_channel_FailBus_1(
        .gt_rx_p            ( gt_rx_p_1         ),//GT收发器的接收数据差分引脚；
        .gt_rx_n            ( gt_rx_n_1         ),//GT收发器的接收数据差分引脚；
        .gt_refclk          ( gt_refclk         ),//GT参考时钟，IP设置为156.25MHZ;
        .user_clk           ( user_clk_1        ),//用户参考时钟信号；
        .user_sys_reset     ( user_reset_1      ),//输出给用户的复位信号；
        .system_rst         ( system_rst        ),//系统复位信号；
        .gt_loopback        ( gt_loopback_1     ),//GT收发器的回环模式控制信号；
        .gt_tx_p            ( gt_tx_p_1         ),//GT收发器的发送数据差分引脚；
        .gt_tx_n            ( gt_tx_n_1         ),//GT收发器的发送数据差分引脚；
        .hard_err           ( hard_err_1        ),//硬件错误指示信号；
        .soft_err           ( soft_err_1        ),//软件错误指示信号；
        .channel_up         ( channel_up_1      ),//通道初始化完成且通道准备好数据时拉高；
        .lane_up            ( lane_up_1         ),//单通道初始化成功信号；
        .s_axi_tx_tdata     ( s_axi_tx_tdata_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tkeep     ( s_axi_tx_tkeep_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tlast     ( s_axi_tx_tlast_1  ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tvalid    ( s_axi_tx_tvalid_1 ),//用户发送数据的AXI_STEAM流接口信号；
        .s_axi_tx_tready    ( s_axi_tx_tready_1 ),//用户发送数据的AXI_STEAM流接口信号；
        .m_axi_rx_tdata     ( m_axi_rx_tdata_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tkeep     ( m_axi_rx_tkeep_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tlast     ( m_axi_rx_tlast_1  ),//用户接收数据的AXI_STEAM流接口信号；
        .m_axi_rx_tvalid    ( m_axi_rx_tvalid_1 ),//用户接收数据的AXI_STEAM流接口信号；
        .init_clk           ( init_clk          ),//初始化时钟，IP设置为100MHz。
        .drp_clk            ( drp_clk           ),//DRP时钟信号,IP设置为100MHz。
        .gt_drpaddr         ( gt_drpaddr_1      ),//GT收发器的DRP地址信号；
        .gt_drpdi           ( gt_drpdi_1        ),//GT收发器的DRP数据输入信号；
        .gt_drprdy          ( gt_drprdy_1       ),//GT收发器的DRP应答信号；
        .gt_drpen           ( gt_drpen_1        ),//GT收发器的DRP使能信号；
        .gt_drpwe           ( gt_drpwe_1        ),//GT收发器的DRP读写指示信号；
        .gt_drpdo           ( gt_drpdo_1        ),//GT收发器的DRP数据输出信号；
        .qpll_drpaddr       ( qpll_drpaddr      ),//QPLL的DRP地址信号；
        .qpll_drpdi         ( qpll_drpdi        ),//QPLL的DRP数据输入信号；
        .qpll_drpen         ( qpll_drpen        ),//QPLL的DRP使能信号；
        .qpll_drpwe         ( qpll_drpwe        ),//QPLL的DRP读写指示信号；
        .gt_qpllclk         ( gt_qpllclk        ),//QPLL的时钟信号；
        .gt_qpllrefclk      ( gt_qpllrefclk     ),//QPLL的参考时钟信号；
        .gt_qpllreset       (                   ),//QPLL的复位信号；
        .gt_qplllock        ( gt_qplllock       ),//QPLL的锁定信号；
        .gt_qpllrefclklost  ( gt_qpllrefclklost ) //QPLL的参考时钟失锁信号；
    );
    
endmodule