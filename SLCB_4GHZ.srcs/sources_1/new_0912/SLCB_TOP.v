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
    input						    clk		            ,//ϵͳʱ���źţ�
    input						    rst_n	            ,//ϵͳ��λ�źţ��͵�ƽ��Ч��

    input                           gt_refclk_p         ,//gt��ֲο�ʱ���źţ�
    input                           gt_refclk_n         ,//gt��ֲο�ʱ���źţ�
    input                           gt_rx_p_0           ,//gt���ղ�������ߣ�
    input                           gt_rx_n_0           ,//gt���ղ�������ߣ�
    output                          gt_tx_p_0           ,//gt���Ͳ�������ߣ�
    output                          gt_tx_n_0           ,//gt���Ͳ�������ߣ�
    input                           gt_rx_p_1           ,//gt���ղ�������ߣ�
    input                           gt_rx_n_1           ,//gt���ղ�������ߣ�
    output                          gt_tx_p_1           ,//gt���Ͳ�������ߣ�
    output                          gt_tx_n_1           ,//gt���Ͳ�������ߣ�
    output      [1  :0]             dislabe  ,            //���ת��ģ��ʧ���źţ�
    
    output      [1:0]               led
);
    wire                            system_rst          ;//ϵͳ��λ�źţ�
    //GT�շ���0������źţ�
    wire                            user_clk_0          ;//�û��ο�ʱ���źţ�
    wire                            user_reset_0        ;//������û��ĸ�λ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            hard_err_0          ;//Ӳ������ָʾ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            soft_err_0          ;//�������ָʾ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            channel_up_0        ;//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
    (* MARK_DEBUG = "TRUE" *)wire                            lane_up_0           ;//��ͨ����ʼ���ɹ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            s_axi_tx_tdata_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [7  : 0]            s_axi_tx_tkeep_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tlast_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tvalid_0   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tready_0   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            m_axi_rx_tdata_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [7 : 0]             m_axi_rx_tkeep_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tlast_0    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tvalid_0   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    //GT�շ���1������źţ�
    wire                            user_clk_1          ;//�û��ο�ʱ���źţ�
    wire                            user_reset_1        ;//������û��ĸ�λ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            hard_err_1          ;//Ӳ������ָʾ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            soft_err_1          ;//�������ָʾ�źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            channel_up_1        ;//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
    (* MARK_DEBUG = "TRUE" *)wire                            lane_up_1           ;//��ͨ����ʼ���ɹ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            s_axi_tx_tdata_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [7  : 0]            s_axi_tx_tkeep_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tlast_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tvalid_1   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            s_axi_tx_tready_1   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [63 : 0]            m_axi_rx_tdata_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire        [7 : 0]             m_axi_rx_tkeep_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tlast_1    ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�
    (* MARK_DEBUG = "TRUE" *)wire                            m_axi_rx_tvalid_1   ;//�û��������ݵ�AXI_STEAM���ӿ��źţ�

    assign dislabe = 2'd0;
    assign led = {channel_up_0,channel_up_1};
    
    wire clk_i;
    assign clk_i = clk;
    //������λͬ��ģ�飻
    rst_syc_module #(
        .RST_IN_VLD     ( 1'b0      ),//��λ������Ч��ƽ��Ĭ�ϵ͵�ƽ��
        .RST_OUT_VLD    ( 1'b1      ),//��λ�����Ч��ƽ��Ĭ�ϸߵ�ƽ��
        .RST_CYCLE	    ( 8	        ) //ͬ��ʱ�Ӹ�����
    )
    rst_syc_module (
        .clk		    ( clk	    ),//ϵͳʱ���źţ�
        .rst_n_in       ( rst_n     ),//��λ�����źţ�Ĭ�ϵ͵�ƽ��Ч��
        .rst_out        ( system_rst) //��λ����źţ�Ĭ�ϸߵ�ƽ��Ч��
    );

/*
    //���������û���������ģ��0.
    user_test_data #(
        .TX_DATA_LEN    ( 20        ),//����һ֡���ݵĳ��ȣ�
        .KEEP           ( 8'hfc     ) //���һ�����ݵ����룻
    )
    u_user_test_data_0 (
        .clk		        ( user_clk_0        ),//ϵͳʱ���źţ�
        .rst 	            ( user_reset_0      ),//ϵͳ��λ�źţ��ߵ�ƽ��Ч��
        .m_axi_tx_tdata     ( s_axi_tx_tdata_0  ),//�������ݵ������źţ�
        .m_axi_tx_tkeep     ( s_axi_tx_tkeep_0  ),//�������ݵ����������źţ��͵�ƽ��Ч��
        .m_axi_tx_tlast     ( s_axi_tx_tlast_0  ),//����һ֡���ݵ����һ������ָʾ�źţ�
        .m_axi_tx_tvalid    ( s_axi_tx_tvalid_0 ),//�������ݵ���Чָʾ�źţ�
        .m_axi_tx_tready    ( s_axi_tx_tready_0 ),//�������ݵ�Ӧ���źţ�
        .s_axi_rx_tdata     ( m_axi_rx_tdata_0  ),//�������ݵ������źţ�
        .s_axi_rx_tkeep     ( m_axi_rx_tkeep_0  ),//�������ݵ����������źţ�
        .s_axi_rx_tlast     ( m_axi_rx_tlast_0  ),//����һ֡���ݵ����һ������ָʾ�źţ�
        .s_axi_rx_tvalid    ( m_axi_rx_tvalid_0 ) //�������ݵ���Чָʾ�źţ�
    );

    //���������û���������ģ��1.
    user_test_data #(
        .TX_DATA_LEN    ( 20        ),//����һ֡���ݵĳ��ȣ�
        .KEEP           ( 8'hf0     ) //���һ�����ݵ����룻
    )
    u_user_test_data_1 (
        .clk		        ( user_clk_1        ),//ϵͳʱ���źţ�
        .rst 	            ( user_reset_1      ),//ϵͳ��λ�źţ��ߵ�ƽ��Ч��
        .m_axi_tx_tdata     ( s_axi_tx_tdata_1  ),//�������ݵ������źţ�
        .m_axi_tx_tkeep     ( s_axi_tx_tkeep_1  ),//�������ݵ����������źţ��͵�ƽ��Ч��
        .m_axi_tx_tlast     ( s_axi_tx_tlast_1  ),//����һ֡���ݵ����һ������ָʾ�źţ�
        .m_axi_tx_tvalid    ( s_axi_tx_tvalid_1 ),//�������ݵ���Чָʾ�źţ�
        .m_axi_tx_tready    ( s_axi_tx_tready_1 ),//�������ݵ�Ӧ���źţ�
        .s_axi_rx_tdata     ( m_axi_rx_tdata_1  ),//�������ݵ������źţ�
        .s_axi_rx_tkeep     ( m_axi_rx_tkeep_1  ),//�������ݵ����������źţ�
        .s_axi_rx_tlast     ( m_axi_rx_tlast_1  ),//����һ֡���ݵ����һ������ָʾ�źţ�
        .s_axi_rx_tvalid    ( m_axi_rx_tvalid_1 ) //�������ݵ���Чָʾ�źţ�
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
    //��������ͨ����GT�շ�����
    aurora_module u_aurora_module(
        .gt_refclk_p        ( gt_refclk_p       ),//GT��ֲο�ʱ�ӣ�IP����Ϊ156.25MHZ;
        .gt_refclk_n        ( gt_refclk_n       ),//GT��ֲο�ʱ�ӣ�IP����Ϊ156.25MHZ;
        .system_rst         ( system_rst        ),//ϵͳ��λ�źţ�
        .init_clk           ( clk               ),//��ʼ��ʱ�ӣ�IP����Ϊ100MHz��
        .drp_clk            ( clk               ),//DRPʱ���ź�,IP����Ϊ100MHz��
        //QPLL��DRP�ӿڣ�
        .qpll_drpaddr       ( 0                 ),//QPLL��DRP��ַ�źţ�
        .qpll_drpdi         ( 0                 ),//QPLL��DRP���������źţ�
        .qpll_drprdy        (                   ),//QPLL��DRPӦ���źţ�
        .qpll_drpen         ( 0                 ),//QPLL��DRPʹ���źţ�
        .qpll_drpwe         ( 0                 ),//QPLL��DRP��дָʾ�źţ�
        .qpll_drpdo         (                   ),//QPLL��DRP��������źţ�
        //GT�շ���0������źţ�
        .gt_rx_p_0          ( gt_rx_p_0         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_rx_n_0          ( gt_rx_n_0         ),//GT�շ����Ľ������ݲ�����ţ�
        .user_clk_0         ( user_clk_0        ),//�û��ο�ʱ���źţ�
        .user_reset_0       ( user_reset_0      ),//������û��ĸ�λ�źţ�
        .gt_loopback_0      ( 3'b000            ),//GT�շ����Ļػ�ģʽ�����źţ�
        .gt_tx_p_0          ( gt_tx_p_0         ),//GT�շ����ķ������ݲ�����ţ�
        .gt_tx_n_0          ( gt_tx_n_0         ),//GT�շ����ķ������ݲ�����ţ�
        .hard_err_0         ( hard_err_0        ),//Ӳ������ָʾ�źţ�
        .soft_err_0         ( soft_err_0        ),//�������ָʾ�źţ�
        .channel_up_0       ( channel_up_0      ),//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
        .lane_up_0          ( lane_up_0         ),//��ͨ����ʼ���ɹ��źţ�
        .s_axi_tx_tdata_0   ( s_axi_tx_tdata_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tkeep_0   ( s_axi_tx_tkeep_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tlast_0   ( s_axi_tx_tlast_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tvalid_0  ( s_axi_tx_tvalid_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tready_0  ( s_axi_tx_tready_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tdata_0   ( m_axi_rx_tdata_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tkeep_0   ( m_axi_rx_tkeep_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tlast_0   ( m_axi_rx_tlast_0  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tvalid_0  ( m_axi_rx_tvalid_0 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .gt_drpaddr_0       ( 0                 ),//GT�շ�����DRP��ַ�źţ�
        .gt_drpdi_0         ( 0                 ),//GT�շ�����DRP���������źţ�
        .gt_drprdy_0        (                   ),//GT�շ�����DRPӦ���źţ�
        .gt_drpen_0         ( 0                 ),//GT�շ�����DRPʹ���źţ�
        .gt_drpwe_0         ( 0                 ),//GT�շ�����DRP��дָʾ�źţ�
        .gt_drpdo_0         (                   ),//GT�շ�����DRP��������źţ�
        //GT�շ���1������źţ�
        .gt_rx_p_1          ( gt_rx_p_1         ),//GT�շ����Ľ������ݲ�����ţ�
        .gt_rx_n_1          ( gt_rx_n_1         ),//GT�շ����Ľ������ݲ�����ţ�
        .user_clk_1         ( user_clk_1        ),//�û��ο�ʱ���źţ�
        .user_reset_1       ( user_reset_1      ),//������û��ĸ�λ�źţ�
        .gt_loopback_1      ( 3'b000            ),//GT�շ����Ļػ�ģʽ�����źţ�
        .gt_tx_p_1          ( gt_tx_p_1         ),//GT�շ����ķ������ݲ�����ţ�
        .gt_tx_n_1          ( gt_tx_n_1         ),//GT�շ����ķ������ݲ�����ţ�
        .hard_err_1         ( hard_err_1        ),//Ӳ������ָʾ�źţ�
        .soft_err_1         ( soft_err_1        ),//�������ָʾ�źţ�
        .channel_up_1       ( channel_up_1      ),//ͨ����ʼ�������ͨ��׼��������ʱ���ߣ�
        .lane_up_1          ( lane_up_1         ),//��ͨ����ʼ���ɹ��źţ�
        .s_axi_tx_tdata_1   ( s_axi_tx_tdata_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tkeep_1   ( s_axi_tx_tkeep_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tlast_1   ( s_axi_tx_tlast_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tvalid_1  ( s_axi_tx_tvalid_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .s_axi_tx_tready_1  ( s_axi_tx_tready_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tdata_1   ( m_axi_rx_tdata_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tkeep_1   ( m_axi_rx_tkeep_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tlast_1   ( m_axi_rx_tlast_1  ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .m_axi_rx_tvalid_1  ( m_axi_rx_tvalid_1 ),//�û��������ݵ�AXI_STEAM���ӿ��źţ�
        .gt_drpaddr_1       ( 0                 ),//GT�շ�����DRP��ַ�źţ�
        .gt_drpdi_1         ( 0                 ),//GT�շ�����DRP���������źţ�
        .gt_drprdy_1        (                   ),//GT�շ�����DRPӦ���źţ�
        .gt_drpen_1         ( 0                 ),//GT�շ�����DRPʹ���źţ�
        .gt_drpwe_1         ( 0                 ),//GT�շ�����DRP��дָʾ�źţ�
        .gt_drpdo_1         (                   ) //GT�շ�����DRP��������źţ�
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
