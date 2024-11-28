//--###############################################################################################
//--#
//--# File Name		: aurora_channel
//--# Designer		: ����վ
//--# Tool			: Vivado 2021.1
//--# Design Date	: 2024.4.9
//--# Description	: aurora_64b66bͨ��ģ��
//--# Version		: 0.0
//--# Coding scheme	: GBK��If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode��
//--#
//--###############################################################################################
module aurora_channel (
    input               gt_rx_p             ,//GT�շ����Ľ������ݲ�����ţ�
    input               gt_rx_n             ,//GT�շ����Ľ������ݲ�����ţ�
    input               gt_refclk           ,//GT�ο�ʱ�ӣ�IP����Ϊ156.25MHZ;
    output              user_clk            ,//�û��ο�ʱ���źţ�
    output              user_sys_reset      ,//������û��ĸ�λ�źţ�
    input               system_rst          ,//ϵͳ��λ�źţ�
    input   [2 : 0]     gt_loopback         ,//GT�շ����Ļػ�ģʽ�����źţ�
    output              gt_tx_p             ,//GT�շ����ķ������ݲ�����ţ�
    output              gt_tx_n             ,//GT�շ����ķ������ݲ�����ţ�
    output              hard_err            ,//Ӳ������ָʾ�źţ�
    output              soft_err            ,//�������ָʾ�źţ�
    output              channel_up          ,//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
    output              lane_up             ,//��ͨ����ʼ���ɹ��źţ�
    input   [63 : 0]    s_axi_tx_tdata      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input   [7  : 0]    s_axi_tx_tkeep      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tlast      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               s_axi_tx_tvalid     ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              s_axi_tx_tready     ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [63 : 0]    m_axi_rx_tdata      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output  [7 : 0]     m_axi_rx_tkeep      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tlast      ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    output              m_axi_rx_tvalid     ,//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    input               init_clk            ,//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
    input               drp_clk             ,//DRPʱ���ź�,IP����Ϊ100MHz��
    input   [8 : 0]     gt_drpaddr          ,//GT�շ�����DRP��ַ�źţ�
    input   [15 : 0]    gt_drpdi            ,//GT�շ�����DRP���������źţ�
    output              gt_drprdy           ,//GT�շ�����DRPӦ���źţ�
    input               gt_drpen            ,//GT�շ�����DRPʹ���źţ�
    input               gt_drpwe            ,//GT�շ�����DRP��дָʾ�źţ�
    output  [15 : 0]    gt_drpdo            ,//GT�շ�����DRP��������źţ�
    input   [7 : 0]     qpll_drpaddr        ,//QPLL��DRP��ַ�źţ�
    input   [15 : 0]    qpll_drpdi          ,//QPLL��DRP���������źţ�
    input               qpll_drpen          ,//QPLL��DRPʹ���źţ�
    input               qpll_drpwe          ,//QPLL��DRP��дָʾ�źţ�
    input               gt_qpllclk          ,//QPLL��ʱ���źţ�
    input               gt_qpllrefclk       ,//QPLL�Ĳο�ʱ���źţ�
    output              gt_qpllreset        ,//QPLL�ĸ�λ�źţ�
    input               gt_qplllock         ,//QPLL�������źţ�
    input               gt_qpllrefclklost    //QPLL�Ĳο�ʱ��ʧ���źţ�
);
    wire                tx_out_clk          ;
    wire                gt_pll_lock         ;
    wire                sync_clk            ;
    wire                mmcm_not_locked     ;
    wire                reset_pb            ;
    wire                gt_rst              ;
    wire                gt_reset_out        ;
    wire                gt_qpllclk_quad1_out;
    wire                gt_qpllrefclk_quad1_out;

    //������λͬ��ģ�飻
    aurora_64b66b_0_SUPPORT_RESET_LOGIC support_reset_logic(
        .RESET          ( system_rst        ),//ϵͳ��λ�źţ�
        .USER_CLK       ( user_clk          ),//�û�ʱ���źţ�
        .INIT_CLK       ( init_clk          ),//��ʼ��ʱ�ӣ�
        .GT_RESET_IN    ( 1'b0              ),//GT�շ�����λ�źţ�
        .SYSTEM_RESET   ( reset_pb          ),//IP��λ�źţ�
        .GT_RESET_OUT   ( gt_rst            ) //GT�շ�����λ�źţ�
    );

    //����MMCMģ�飬ͨ��tx_out_clk�����û�ʱ���źţ�
    aurora_64b66b_0_CLOCK_MODULE clock_module(
        .CLK                ( tx_out_clk        ),//GT�շ���������û�ʱ���źţ�
        .CLK_LOCKED         ( gt_pll_lock       ),//MMCM�����źţ�
        .USER_CLK           ( user_clk          ),//�û�ʱ���źţ�
        .SYNC_CLK           ( sync_clk          ),//ͬ��ʱ���źţ�
        .MMCM_NOT_LOCKED    ( mmcm_not_locked   ) //MMCMû�������źţ�
    );

/*
    //����aurora_64b66b IP��
    aurora_64b66b_0 u_aurora_64b66b_0 (
        .rxp                        ( gt_rx_p           ),//GT�շ����Ľ������ݲ�����ţ�
        .rxn                        ( gt_rx_n           ),//GT�շ����Ľ������ݲ�����ţ�
        .refclk1_in                 ( gt_refclk         ),//GT�ο�ʱ�ӣ�IP����Ϊ156.25MHZ
        .user_clk                   ( user_clk          ),//�û�ʱ�ӣ���TX_OUT_CLKͨ��MMCM���ɣ�
        .sync_clk                   ( sync_clk          ),//ͬ��ʱ���źţ���TX_OUT_CLKͨ��MMCM���ɣ�
        .reset_pb                   ( reset_pb          ),//ϵͳ��λ�źţ�
        .power_down                 ( 1'b0              ),//����ģʽ��
        .pma_init                   ( gt_rst            ),//GT�շ�����λ����ʼ����
        .loopback                   ( gt_loopback       ),//GT�շ����Ļػ�ģʽ�����źţ�
        .txp                        ( gt_tx_p           ),//GT�շ����ķ������ݲ�����ţ�
        .txn                        ( gt_tx_n           ),//GT�շ����ķ������ݲ�����ţ�
        .hard_err                   ( hard_err          ),//Ӳ������ָʾ�źţ�
        .soft_err                   ( soft_err          ),//�������ָʾ�źţ�
        .channel_up                 ( channel_up        ),//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
        .lane_up                    ( lane_up           ),//��ͨ����ʼ���ɹ��źţ�
        .tx_out_clk                 ( tx_out_clk        ),//GT�շ�������ο�ʱ���źţ�ͨ��BUFG���������û�ʱ�ӣ�
        .gt_pll_lock                ( gt_pll_lock       ),//MMCM�����źţ�
        .s_axi_tx_tdata             ( s_axi_tx_tdata    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tkeep             ( s_axi_tx_tkeep    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tlast             ( s_axi_tx_tlast    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tvalid            ( s_axi_tx_tvalid   ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tready            ( s_axi_tx_tready   ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tdata             ( m_axi_rx_tdata    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tkeep             ( m_axi_rx_tkeep    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tlast             ( m_axi_rx_tlast    ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tvalid            ( m_axi_rx_tvalid   ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .mmcm_not_locked            ( mmcm_not_locked   ),//MMCMû������ָʾ�źţ�
        .drp_clk_in                 ( drp_clk           ),//DRPʱ���źţ�
        .drpaddr_in                 ( gt_drpaddr        ),//GT�շ�����DRP��ַ�źţ�
        .drpdi_in                   ( gt_drpdi          ),//GT�շ�����DRP���������źţ�
        .drprdy_out                 ( gt_drprdy         ),//GT�շ�����DRPӦ���źţ�
        .drpen_in                   ( gt_drpen          ),//GT�շ�����DRPʹ���źţ�
        .drpwe_in                   ( gt_drpwe          ),//GT�շ�����DRP��дָʾ�źţ�
        .drpdo_out                  ( gt_drpdo          ),//GT�շ�����DRP��������źţ�
        .qpll_drpaddr_in            ( qpll_drpaddr      ),//QPLL��DRP��ַ�źţ�
        .qpll_drpdi_in              ( qpll_drpdi        ),//QPLL��DRP���������źţ�
        .qpll_drprdy_out            (                   ),//QPLL��DRPӦ���źţ�
        .qpll_drpen_in              ( qpll_drpen        ),//QPLL��DRPʹ���źţ�
        .qpll_drpwe_in              ( qpll_drpwe        ),//QPLL��DRP��дָʾ�źţ�
        .qpll_drpdo_out             (                   ),//QPLL��DRP��������źţ�
        .init_clk                   ( init_clk          ),//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
        .link_reset_out             (                   ),//output wire link_reset_out
        .gt_qpllclk_quad1_in        ( gt_qpllclk        ),//QPLL��ʱ���źţ�
        .gt_qpllrefclk_quad1_in     ( gt_qpllrefclk     ),//QPLL�Ĳο�ʱ���źţ�
        .gt_to_common_qpllreset_out ( gt_qpllreset      ),//QPLL�ĸ�λ�źţ�
        .gt_qplllock_in             ( gt_qplllock       ),//QPLL�������źţ�
        .gt_qpllrefclklost_in       ( gt_qpllrefclklost ),//QPLL�Ĳο�ʱ��ʧ���źţ�
        .gt_rxcdrovrden_in          ( 1'b0              ),//input wire gt_rxcdrovrden_in
        .sys_reset_out              ( user_sys_reset    ) //������û��ĸ�λ�źţ�
    );
*/

aurora_64b66b_0 u_aurora_64b66b_0 (
  .rxp(gt_rx_p),                                        // input wire [0 : 0] rxp
  .rxn(gt_rx_n),                                        // input wire [0 : 0] rxn
  .refclk1_in(gt_refclk),                          // input wire refclk1_in
  .user_clk(user_clk),                              // input wire user_clk
  .sync_clk(sync_clk),                              // input wire sync_clk
  .reset_pb(reset_pb),                              // input wire reset_pb
  .power_down(1'b0 ),                          // input wire power_down
  .pma_init(gt_rst),                              // input wire pma_init
  .loopback(gt_loopback),                              // input wire [2 : 0] loopback
  .txp(gt_tx_p),                                        // output wire [0 : 0] txp
  .txn(gt_tx_n),                                        // output wire [0 : 0] txn
  .hard_err(hard_err),                              // output wire hard_err
  .soft_err(soft_err),                              // output wire soft_err
  .channel_up(channel_up),                          // output wire channel_up
  .lane_up(lane_up),                                // output wire [0 : 0] lane_up
  .tx_out_clk(tx_out_clk),                          // output wire tx_out_clk
  .drp_clk_in(drp_clk),                          // input wire drp_clk_in
  .gt_pll_lock(gt_pll_lock),                        // output wire gt_pll_lock
  .s_axi_tx_tdata(s_axi_tx_tdata),                  // input wire [0 : 63] s_axi_tx_tdata
  .s_axi_tx_tvalid(s_axi_tx_tvalid),                // input wire s_axi_tx_tvalid
  .s_axi_tx_tready(s_axi_tx_tready),                // output wire s_axi_tx_tready
  .m_axi_rx_tdata(m_axi_rx_tdata),                  // output wire [0 : 63] m_axi_rx_tdata
  .m_axi_rx_tvalid(m_axi_rx_tvalid),                // output wire m_axi_rx_tvalid
  .mmcm_not_locked(mmcm_not_locked),                // input wire mmcm_not_locked
  .drpaddr_in(gt_drpaddr),                          // input wire [8 : 0] drpaddr_in
  .drpdi_in(gt_drpdi),                              // input wire [15 : 0] drpdi_in
  .drprdy_out(gt_drprdy),                          // output wire drprdy_out
  .drpen_in(gt_drpen),                              // input wire drpen_in
  .drpwe_in(gt_drpwe),                              // input wire drpwe_in
  .drpdo_out(gt_drpdo),                            // output wire [15 : 0] drpdo_out
  .init_clk(init_clk),                              // input wire init_clk
  .link_reset_out( ),                  // output wire link_reset_out
  .gt_qpllclk_quad1_in(gt_qpllclk),        // input wire gt_qpllclk_quad1_in
  .gt_qpllrefclk_quad1_in(gt_qpllrefclk),  // input wire gt_qpllrefclk_quad1_in
  .gt_rxcdrovrden_in(1'b0 ),            // input wire gt_rxcdrovrden_in
  .sys_reset_out(user_sys_reset)                    // output wire sys_reset_out
);
/*
aurora_64b66b_1 u_aurora_64b66b_1 (
  .rxp(gt_rx_p),                                        // input wire [0 : 0] rxp
  .rxn(gt_rx_n),                                        // input wire [0 : 0] rxn
  .refclk1_in(gt_refclk),                          // input wire refclk1_in
  
  .reset_pb(reset_pb),                              // input wire reset_pb
  .power_down(1'b0),                          // input wire power_down
  .pma_init(gt_rst),                              // input wire pma_init
  .loopback(gt_loopback),                              // input wire [2 : 0] loopback
  .txp(gt_tx_p),                                        // output wire [0 : 0] txp
  .txn(gt_tx_n),                                        // output wire [0 : 0] txn
  .hard_err(hard_err),                              // output wire hard_err
  .soft_err(soft_err),                              // output wire soft_err
  .channel_up(channel_up),                          // output wire channel_up
  .lane_up(lane_up),                                // output wire [0 : 0] lane_up
  .tx_out_clk(tx_out_clk),                          // output wire tx_out_clk
  .drp_clk_in(drp_clk),                          // input wire drp_clk_in
  .gt_pll_lock(gt_pll_lock),                        // output wire gt_pll_lock
  .s_axi_tx_tdata(s_axi_tx_tdata),                  // input wire [0 : 63] s_axi_tx_tdata
  .s_axi_tx_tvalid(s_axi_tx_tvalid),                // input wire s_axi_tx_tvalid
  .s_axi_tx_tready(s_axi_tx_tready),                // output wire s_axi_tx_tready
  .m_axi_rx_tdata(m_axi_rx_tdata),                  // output wire [0 : 63] m_axi_rx_tdata
  .m_axi_rx_tvalid(m_axi_rx_tvalid),                // output wire m_axi_rx_tvalid
  .mmcm_not_locked_out(mmcm_not_locked),                // input wire mmcm_not_locked
  .drpaddr_in(gt_drpaddr),                          // input wire [8 : 0] drpaddr_in
  .drpdi_in(gt_drpdi),                              // input wire [15 : 0] drpdi_in
  .drprdy_out(gt_drprdy),                          // output wire drprdy_out
  .drpen_in(gt_drpen),                              // input wire drpen_in
  .drpwe_in(gt_drpwe),                              // input wire drpwe_in
  .drpdo_out(gt_drpdo),                            // output wire [15 : 0] drpdo_out
  .user_clk_out(user_clk),                        // output wire user_clk_out
  .sync_clk_out(sync_clk),                        // output wire sync_clk_out
  .init_clk(init_clk),                              // input wire init_clk
  .link_reset_out( ),                  // output wire link_reset_out
  .gt_qpllclk_quad1_out(gt_qpllclk_quad1_out),        // output wire gt_qpllclk_quad1_out
  .gt_qpllrefclk_quad1_out(gt_qpllrefclk_quad1_out),  // output wire gt_qpllrefclk_quad1_out
  .gt_rxcdrovrden_in(1'b0),            // input wire gt_rxcdrovrden_in
  .sys_reset_out(user_sys_reset),                    // output wire sys_reset_out
  .gt_reset_out(gt_reset_out)                        // output wire gt_reset_out
);
 */
 

endmodule