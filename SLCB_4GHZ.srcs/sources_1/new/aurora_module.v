//--###############################################################################################
//--#
//--# File Name		: aurora_module
//--# Designer		: ����վ
//--# Tool			: Vivado 2021.1
//--# Design Date	: 2024.4.9
//--# Description	: ��дaurora64B66B����ģ��
//--# Version		: 0.0
//--# Coding scheme	: GBK��If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode��
//--#
//--###############################################################################################
module aurora_module (
    input               gt_refclk_p         ,//GT��ֲο�ʱ�ӣ�IP����Ϊ156.25MHZ;
    input               gt_refclk_n         ,//GT��ֲο�ʱ�ӣ�IP����Ϊ156.25MHZ;
    input               system_rst          ,//ϵͳ��λ�źţ�
    input               init_clk            ,//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
    input               drp_clk             ,//DRPʱ���ź�,IP����Ϊ100MHz��
    //QPLL��DRP�ӿڣ�
    input   [7 : 0]     qpll_drpaddr        ,//QPLL��DRP��ַ�źţ�
    input   [15 : 0]    qpll_drpdi          ,//QPLL��DRP���������źţ�
    output              qpll_drprdy         ,//QPLL��DRPӦ���źţ�
    input               qpll_drpen          ,//QPLL��DRPʹ���źţ�
    input               qpll_drpwe          ,//QPLL��DRP��дָʾ�źţ�
    output  [15 : 0]    qpll_drpdo          ,//QPLL��DRP��������źţ�
    //GT�շ���0������źţ�
    input               gt_rx_p_0           ,//GT�շ����Ľ������ݲ�����ţ�
    input               gt_rx_n_0           ,//GT�շ����Ľ������ݲ�����ţ�
    output              user_clk_0          ,//�û��ο�ʱ���źţ�
    output              user_reset_0        ,//������û��ĸ�λ�źţ�
    input   [2 : 0]     gt_loopback_0       ,//GT�շ����Ļػ�ģʽ�����źţ�
    output              gt_tx_p_0           ,//GT�շ����ķ������ݲ�����ţ�
    output              gt_tx_n_0           ,//GT�շ����ķ������ݲ�����ţ�
    output              hard_err_0          ,//Ӳ������ָʾ�źţ�
    output              soft_err_0          ,//�������ָʾ�źţ�
    output              channel_up_0        ,//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
    output              lane_up_0           ,//��ͨ����ʼ���ɹ��źţ�
    input   [63 : 0]    s_axi_tx_tdata_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input   [7  : 0]    s_axi_tx_tkeep_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tlast_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tvalid_0   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              s_axi_tx_tready_0   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [63 : 0]    m_axi_rx_tdata_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [7 : 0]     m_axi_rx_tkeep_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tlast_0    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tvalid_0   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input   [8 : 0]     gt_drpaddr_0        ,//GT�շ�����DRP��ַ�źţ�
    input   [15 : 0]    gt_drpdi_0          ,//GT�շ�����DRP���������źţ�
    output              gt_drprdy_0         ,//GT�շ�����DRPӦ���źţ�
    input               gt_drpen_0          ,//GT�շ�����DRPʹ���źţ�
    input               gt_drpwe_0          ,//GT�շ�����DRP��дָʾ�źţ�
    output  [15 : 0]    gt_drpdo_0          ,//GT�շ�����DRP��������źţ�
    //GT�շ���1������źţ�
    input               gt_rx_p_1           ,//GT�շ����Ľ������ݲ�����ţ�
    input               gt_rx_n_1           ,//GT�շ����Ľ������ݲ�����ţ�
    output              user_clk_1          ,//�û��ο�ʱ���źţ�
    output              user_reset_1        ,//������û��ĸ�λ�źţ�
    input   [2 : 0]     gt_loopback_1       ,//GT�շ����Ļػ�ģʽ�����źţ�
    output              gt_tx_p_1           ,//GT�շ����ķ������ݲ�����ţ�
    output              gt_tx_n_1           ,//GT�շ����ķ������ݲ�����ţ�
    output              hard_err_1          ,//Ӳ������ָʾ�źţ�
    output              soft_err_1          ,//�������ָʾ�źţ�
    output              channel_up_1        ,//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
    output              lane_up_1           ,//��ͨ����ʼ���ɹ��źţ�
    input   [63 : 0]    s_axi_tx_tdata_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input   [7  : 0]    s_axi_tx_tkeep_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tlast_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tvalid_1   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              s_axi_tx_tready_1   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [63 : 0]    m_axi_rx_tdata_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [7 : 0]     m_axi_rx_tkeep_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tlast_1    ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tvalid_1   ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input   [8 : 0]     gt_drpaddr_1        ,//GT�շ�����DRP��ַ�źţ�
    input   [15 : 0]    gt_drpdi_1          ,//GT�շ�����DRP���������źţ�
    output              gt_drprdy_1         ,//GT�շ�����DRPӦ���źţ�
    input               gt_drpen_1          ,//GT�շ�����DRPʹ���źţ�
    input               gt_drpwe_1          ,//GT�շ�����DRP��дָʾ�źţ�
    output  [15 : 0]    gt_drpdo_1           //GT�շ�����DRP��������źţ�
);
    wire                gt_refclk           ;//GT�շ����ĵ���ʱ���źţ�Ƶ��Ϊ156.25MHz��
    wire                gt_qpllclk          ;//QPLL��ʱ���źţ�
    wire                gt_qpllrefclk       ;//QPLL�Ĳο�ʱ���źţ�
    wire                gt_qpllreset        ;//QPLL�ĸ�λ�źţ�
    wire                gt_qplllock         ;//QPLL�������źţ�
    wire                gt_qpllrefclklost   ;//QPLL�Ĳο�ʱ��ʧ���źţ�

    //����IBUFGDS_GTE2�������ʱ��ת��Ϊ����ʱ�ӣ�
    IBUFDS_GTE2 IBUFDS_GTXE2_CLK1 (
        .O      ( gt_refclk     ),//����ʱ������źţ�
        .ODIV2  (               ),//����ʱ�Ӷ���Ƶ����źţ�
        .CEB    ( 1'b0          ),//IBUFDS_GTE2ʹ���źţ�
        .I      ( gt_refclk_p   ),//���ʱ�������źţ�
        .IB     ( gt_refclk_n   ) //���ʱ�������źţ�
    );

    //����QPLLģ�飻
    aurora_64b66b_0_gt_common_wrapper gt_common_support (
        .gt_qpllclk_quad1_out       ( gt_qpllclk        ),//QPLL��ʱ���źţ�
        .gt_qpllrefclk_quad1_out    ( gt_qpllrefclk     ),//QPLL�Ĳο�ʱ���źţ�
        .GT0_GTREFCLK0_COMMON_IN    ( gt_refclk         ),//����ʱ������źţ�
        .GT0_QPLLLOCK_OUT           ( gt_qplllock       ),//QPLL�������źţ�
        .GT0_QPLLRESET_IN           ( gt_qpllreset      ),//QPLL�ĸ�λ�źţ�
        .GT0_QPLLLOCKDETCLK_IN      ( init_clk          ),//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
        .GT0_QPLLREFCLKLOST_OUT     ( gt_qpllrefclklost ),//QPLL�Ĳο�ʱ��ʧ���źţ�
        .qpll_drpaddr_in            ( qpll_drpaddr      ),//QPLL��DRP��ַ�źţ�
        .qpll_drpdi_in              ( qpll_drpdi        ),//QPLL��DRP���������źţ�
        .qpll_drpclk_in             ( drp_clk           ),//DRPʱ���ź�,IP����Ϊ100MHz��
        .qpll_drpdo_out             ( qpll_drpdo        ),//QPLL��DRP��������źţ�
        .qpll_drprdy_out            ( qpll_drprdy       ),//QPLL��DRPӦ���źţ�
        .qpll_drpen_in              ( qpll_drpen        ),//QPLL��DRPʹ���źţ�
        .qpll_drpwe_in              ( qpll_drpwe        ) //QPLL��DRP��дָʾ�źţ�
    );

    //���������շ���0��
    aurora_channel u_aurora_channel_DataBus_0(
        .gt_rx_p            ( gt_rx_p_0         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_rx_n            ( gt_rx_n_0         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_refclk          ( gt_refclk         ),//GT�ο�ʱ�ӣ�IP����Ϊ156.25MHZ;
        .user_clk           ( user_clk_0        ),//�û��ο�ʱ���źţ�
        .user_sys_reset     ( user_reset_0      ),//������û��ĸ�λ�źţ�
        .system_rst         ( system_rst        ),//ϵͳ��λ�źţ�
        .gt_loopback        ( gt_loopback_0     ),//GT�շ����Ļػ�ģʽ�����źţ�
        .gt_tx_p            ( gt_tx_p_0         ),//GT�շ����ķ������ݲ�����ţ�
        .gt_tx_n            ( gt_tx_n_0         ),//GT�շ����ķ������ݲ�����ţ�
        .hard_err           ( hard_err_0        ),//Ӳ������ָʾ�źţ�
        .soft_err           ( soft_err_0        ),//�������ָʾ�źţ�
        .channel_up         ( channel_up_0      ),//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
        .lane_up            ( lane_up_0         ),//��ͨ����ʼ���ɹ��źţ�
        .s_axi_tx_tdata     ( s_axi_tx_tdata_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tkeep     ( s_axi_tx_tkeep_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tlast     ( s_axi_tx_tlast_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tvalid    ( s_axi_tx_tvalid_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tready    ( s_axi_tx_tready_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tdata     ( m_axi_rx_tdata_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tkeep     ( m_axi_rx_tkeep_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tlast     ( m_axi_rx_tlast_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tvalid    ( m_axi_rx_tvalid_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .init_clk           ( init_clk          ),//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
        .drp_clk            ( drp_clk           ),//DRPʱ���ź�,IP����Ϊ100MHz��
        .gt_drpaddr         ( gt_drpaddr_0      ),//GT�շ�����DRP��ַ�źţ�
        .gt_drpdi           ( gt_drpdi_0        ),//GT�շ�����DRP���������źţ�
        .gt_drprdy          ( gt_drprdy_0       ),//GT�շ�����DRPӦ���źţ�
        .gt_drpen           ( gt_drpen_0        ),//GT�շ�����DRPʹ���źţ�
        .gt_drpwe           ( gt_drpwe_0        ),//GT�շ�����DRP��дָʾ�źţ�
        .gt_drpdo           ( gt_drpdo_0        ),//GT�շ�����DRP��������źţ�
        .qpll_drpaddr       ( qpll_drpaddr      ),//QPLL��DRP��ַ�źţ�
        .qpll_drpdi         ( qpll_drpdi        ),//QPLL��DRP���������źţ�
        .qpll_drpen         ( qpll_drpen        ),//QPLL��DRPʹ���źţ�
        .qpll_drpwe         ( qpll_drpwe        ),//QPLL��DRP��дָʾ�źţ�
        .gt_qpllclk         ( gt_qpllclk        ),//QPLL��ʱ���źţ�
        .gt_qpllrefclk      ( gt_qpllrefclk     ),//QPLL�Ĳο�ʱ���źţ�
        .gt_qpllreset       ( gt_qpllreset      ),//QPLL�ĸ�λ�źţ�
        .gt_qplllock        ( gt_qplllock       ),//QPLL�������źţ�
        .gt_qpllrefclklost  ( gt_qpllrefclklost ) //QPLL�Ĳο�ʱ��ʧ���źţ�
    );

    //���������շ���1��
    aurora_channel u_aurora_channel_FailBus_1(
        .gt_rx_p            ( gt_rx_p_1         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_rx_n            ( gt_rx_n_1         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_refclk          ( gt_refclk         ),//GT�ο�ʱ�ӣ�IP����Ϊ156.25MHZ;
        .user_clk           ( user_clk_1        ),//�û��ο�ʱ���źţ�
        .user_sys_reset     ( user_reset_1      ),//������û��ĸ�λ�źţ�
        .system_rst         ( system_rst        ),//ϵͳ��λ�źţ�
        .gt_loopback        ( gt_loopback_1     ),//GT�շ����Ļػ�ģʽ�����źţ�
        .gt_tx_p            ( gt_tx_p_1         ),//GT�շ����ķ������ݲ�����ţ�
        .gt_tx_n            ( gt_tx_n_1         ),//GT�շ����ķ������ݲ�����ţ�
        .hard_err           ( hard_err_1        ),//Ӳ������ָʾ�źţ�
        .soft_err           ( soft_err_1        ),//�������ָʾ�źţ�
        .channel_up         ( channel_up_1      ),//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
        .lane_up            ( lane_up_1         ),//��ͨ����ʼ���ɹ��źţ�
        .s_axi_tx_tdata     ( s_axi_tx_tdata_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tkeep     ( s_axi_tx_tkeep_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tlast     ( s_axi_tx_tlast_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tvalid    ( s_axi_tx_tvalid_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tready    ( s_axi_tx_tready_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tdata     ( m_axi_rx_tdata_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tkeep     ( m_axi_rx_tkeep_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tlast     ( m_axi_rx_tlast_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tvalid    ( m_axi_rx_tvalid_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .init_clk           ( init_clk          ),//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
        .drp_clk            ( drp_clk           ),//DRPʱ���ź�,IP����Ϊ100MHz��
        .gt_drpaddr         ( gt_drpaddr_1      ),//GT�շ�����DRP��ַ�źţ�
        .gt_drpdi           ( gt_drpdi_1        ),//GT�շ�����DRP���������źţ�
        .gt_drprdy          ( gt_drprdy_1       ),//GT�շ�����DRPӦ���źţ�
        .gt_drpen           ( gt_drpen_1        ),//GT�շ�����DRPʹ���źţ�
        .gt_drpwe           ( gt_drpwe_1        ),//GT�շ�����DRP��дָʾ�źţ�
        .gt_drpdo           ( gt_drpdo_1        ),//GT�շ�����DRP��������źţ�
        .qpll_drpaddr       ( qpll_drpaddr      ),//QPLL��DRP��ַ�źţ�
        .qpll_drpdi         ( qpll_drpdi        ),//QPLL��DRP���������źţ�
        .qpll_drpen         ( qpll_drpen        ),//QPLL��DRPʹ���źţ�
        .qpll_drpwe         ( qpll_drpwe        ),//QPLL��DRP��дָʾ�źţ�
        .gt_qpllclk         ( gt_qpllclk        ),//QPLL��ʱ���źţ�
        .gt_qpllrefclk      ( gt_qpllrefclk     ),//QPLL�Ĳο�ʱ���źţ�
        .gt_qpllreset       (                   ),//QPLL�ĸ�λ�źţ�
        .gt_qplllock        ( gt_qplllock       ),//QPLL�������źţ�
        .gt_qpllrefclklost  ( gt_qpllrefclklost ) //QPLL�Ĳο�ʱ��ʧ���źţ�
    );
    
endmodule