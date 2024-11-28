`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/12 10:44:56
// Design Name: 
// Module Name: SLCB_Aurora_Module
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


module SLCB_Aurora_Module(
    input               CKP                      ,
    input               init_clk                 ,
    input               system_rst               ,
    input               drp_clk                  ,
    
    input               gt_refclk_p              ,
    input               gt_refclk_n              ,
    
    input               gt_rx_databus_p          , 
    input               gt_rx_databus_n          ,
    output              gt_tx_databus_p          ,
    output              gt_tx_databus_n          ,   
    input               gt_rx_failbus_p          ,
    input               gt_rx_failbus_n          ,
    output              gt_tx_failbus_p          ,
    output              gt_tx_failbus_n          ,
                                             
    output     reg     HARD_ERR_DATABUS         ,
    output     reg     SOFT_ERR_DATABUS         ,
    output     reg     LANE_UP_DATABUS          ,
    output     reg     CHANNEL_UP_DATABUS       ,                                            
    output     reg     HARD_ERR_FAILBUS         ,
    output     reg     SOFT_ERR_FAILBUS         ,
    output     reg     LANE_UP_FAILBUS          ,
    output     reg     CHANNEL_UP_FAILBUS       ,
    
    //DATABUS RX
    output              EMPTY_DATABUS,
    output              ALEMPTY_DATABUS,
    input               RD_DATA_EN_DATABUS,
    output    [63:0]    O_CAP_DATA_DATABUS,
    //TX
    input               CAP_EN_DATABUS,
    input     [63:0]    IN_CAP_DATA_DATABUS,
    //FAILBUS RX
    output              EMPTY_FAILBUS,
    output              ALEMPTY_FAILBUS,
    input               RD_DATA_EN_FAILBUS,
    output    [63:0]    O_CAP_DATA_FAILBUS,
    //TX
    input               CAP_EN_FAILBUS,
    input     [63:0]    IN_CAP_DATA_FAILBUS           
  );
    
    wire                 hard_err_i_databus;   
    wire                 soft_err_i_databus;   
    wire                 lane_up_i_databus;    
    wire                 channel_up_i_databus;   
    wire            hard_err_i_failbus;   
    wire            soft_err_i_failbus;   
    wire            lane_up_i_failbus;    
    wire            channel_up_i_failbus;
    
    wire            sys_reset_out_dataBus;
    wire            sys_reset_out_failBus;
    
    wire     [63:0]      s_axi_tx_tdata_databus     ;
    wire                 s_axi_tx_tvalid_databus    ;
    wire                 s_axi_tx_tready_databus    ;
    wire     [63:0]      m_axi_rx_tdata_databus     ;
    wire                 m_axi_rx_tvalid_databus    ;          

   wire      [63:0]       s_axi_tx_tdata_failbus          ; 
   wire                   s_axi_tx_tvalid_failbus         ;
   wire                   s_axi_tx_tready_failbus         ;
   wire     [63:0]        m_axi_rx_tdata_failbus          ;
   wire                   m_axi_rx_tvalid_failbus         ;
    
     //System Interface
    wire                 reset_i ;
    //wire                 gt_reset_i;
    wire                 refclk1_in;
    wire                init_clk_i;
    wire                drp_clk_i;
    wire                 gt_rxcdrovrden_i ;
    wire                 power_down_i;
    wire      [2:0]      loopback_i ;
    wire                 mmcm_not_locked_out;
    wire                gt_qpllclk_quad1_out;
    wire                gt_qpllrefclk_quad1_out;
    
    wire    [8:0]        drpaddr_in_i;
    wire    [15:0]      drpdi_in_i;
    wire    [15:0]     drpdo_out_i;
    wire               drprdy_out_i;
    wire               drpen_in_i;
    wire               drpwe_in_i;
    
    wire               PMA_INIT;
    wire               gt_reset_i_tmp;
    wire               gt_reset_i_tmp2;  
    assign PMA_INIT = system_rst;
    assign  reset_i  =   system_rst | gt_reset_i_tmp2;    
    aurora_64b66b_sync_rst_delay   u_sync_rst_delay
    (
     .prmry_in     (PMA_INIT),
     .scndry_aclk  (user_clk_out),
     .scndry_out   (gt_reset_i_tmp2)
    );    
//˫����λ˳��
//1.reset_pb�����źŵȴ����?128*user_clk��ʱ��������pma_init
//2.����pma_init�󡣱���pma_init��reset����״̬����һ���ӣ��Է�ֹCC�ַ��Ĵ��䣬��ȷ��Զ��agent��⵽�Ȳ���¼�
//3.�������?1s������pma_init
//4.Ȼ������reset_pb���ڲ��߼��ȴ�user_clk�ȶ�������reset_pb���ͺ�����͵�ƽ��sys_reset_out�ź�
   
   //reg [127:0]        pma_init_stage = {128{1'b1}};
    //reg [23:0]         pma_init_pulse_width_cnt = 24'h0;
    
    //reg pma_init_assertion = 1'b0;
    //reg pma_init_assertion_r;
    //reg gt_reset_i_delayed_r1;
    //reg gt_reset_i_delayed_r2;
    //wire gt_reset_i_delayed;  
     
   //  assign gt_reset_i_eff = pma_init_assertion ? 1'b1 : gt_reset_i_delayed;
   //  assign  gt_reset_i_tmp = PMA_INIT;
   //  assign  gt_reset_i = gt_reset_i_eff; 
   // // pma_init�Ȼָ��ٻָ�reset_pb
   // always @(posedge init_clk_i)
   // begin
   //     pma_init_stage[127:0] <= {pma_init_stage[126:0], gt_reset_i_tmp};
   // end
   // assign gt_reset_i_delayed = pma_init_stage[127];

    //always @(posedge init_clk_i)
    //begin
    //    gt_reset_i_delayed_r1     <=  gt_reset_i_delayed;
    //    gt_reset_i_delayed_r2     <=  gt_reset_i_delayed_r1;
    //    pma_init_assertion_r  <= pma_init_assertion;
    //    if(~gt_reset_i_delayed_r2 & gt_reset_i_delayed_r1 & ~pma_init_assertion & (pma_init_pulse_width_cnt != 24'hFFFFFF))
    //        pma_init_assertion <= 1'b1;
    //    else if (pma_init_assertion & pma_init_pulse_width_cnt == 24'hFFFFFF)
    //        pma_init_assertion <= 1'b0;
    //
    //    if(pma_init_assertion)
    //        pma_init_pulse_width_cnt <= pma_init_pulse_width_cnt + 24'h1;
    //end

    // System Interface
     assign power_down_i      =   1'b0;
    // Native DRP Interface
     assign  drpaddr_in_i   =  'h0;
     assign  drpdi_in_i     =  16'h0;
     assign  drpwe_in_i     =  1'b0;
     assign  drpen_in_i     =  1'b0;
     assign  loopback_i  =  3'b000; 
     assign  gt_rxcdrovrden_i  =  1'b0;
    
    //--- Instance of GT differential buffer ---------//
     IBUFDS_GTE2 IBUFDS_GTXE2_CLK1  
     (
         .O               (refclk1_in),
         .ODIV2           (),
         .CEB             (1'b0),
         .I               (gt_refclk_p),
         .IB              (gt_refclk_n)
     );
    BUFG initclk_bufg_i
   (
      .I  (init_clk),
      .O  (init_clk_i)
   );
   BUFG drpclk_bufg_i
   (
      .I  (drp_clk),
      .O  (drp_clk_i)
   );
      // Register User Outputs from core.
     always @(posedge user_clk_out)
     begin
     
         HARD_ERR_DATABUS         <=  hard_err_i_databus;
         SOFT_ERR_DATABUS         <=  soft_err_i_databus;
         LANE_UP_DATABUS          <=  lane_up_i_databus;
         CHANNEL_UP_DATABUS       <=  channel_up_i_databus;
         
         HARD_ERR_FAILBUS         <=  hard_err_i_failbus;
         SOFT_ERR_FAILBUS         <=  soft_err_i_failbus;
         LANE_UP_FAILBUS          <=  lane_up_i_failbus;
         CHANNEL_UP_FAILBUS       <=  channel_up_i_failbus;
         //DATA_ERR_COUNT   <=  data_err_count_o;
     end

//
   aurora_64b66b_Master u_aurora_Channel_DataBus (
  .rxp(gt_rx_databus_p),                              // input wire [0 : 0] rxp
  .rxn(gt_rx_databus_n),                                          // input wire [0 : 0] rxn
  .refclk1_in(refclk1_in),                            // input wire refclk1_in
  .reset_pb(reset_i),                                // input wire reset_pb
  .power_down(power_down_i),                            // input wire power_down
  .pma_init(PMA_INIT),                                // input wire pma_init
  .loopback(loopback_i),                                // input wire [2 : 0] loopback
  .txp(gt_tx_databus_p),                                          // output wire [0 : 0] txp
  .txn(gt_tx_databus_n),                                          // output wire [0 : 0] txn
  .hard_err(hard_err_i_databus),                                // output wire hard_err
  .soft_err(soft_err_i_databus),                                // output wire soft_err
  .channel_up(channel_up_i_databus),                            // output wire channel_up
  .lane_up(lane_up_i_databus),                                  // output wire [0 : 0] lane_up
  .tx_out_clk( ),                            // output wire tx_out_clk
  .gt_pll_lock( ),                          // output wire gt_pll_lock
  .s_axi_tx_tdata (s_axi_tx_tdata_databus ),                    // input wire [0 : 63] s_axi_tx_tdata
  .s_axi_tx_tvalid(s_axi_tx_tvalid_databus),                  // input wire s_axi_tx_tvalid
  .s_axi_tx_tready(s_axi_tx_tready_databus),                  // output wire s_axi_tx_tready
  .m_axi_rx_tdata (m_axi_rx_tdata_databus ),                    // output wire [0 : 63] m_axi_rx_tdata
  .m_axi_rx_tvalid(m_axi_rx_tvalid_databus),                  // output wire m_axi_rx_tvalid
  
  .mmcm_not_locked_out(mmcm_not_locked_out),          // output wire mmcm_not_locked_out
  .drpaddr_in(drpaddr_in_i),                            // input wire [8 : 0] drpaddr_in
  .drpdi_in(drpdi_in_i),                                // input wire [15 : 0] drpdi_in
  .drprdy_out( ),                            // output wire drprdy_out
  .drpen_in(drpen_in_i),                                // input wire drpen_in
  .drpwe_in(drpwe_in_i),                                // input wire drpwe_in
  .drpdo_out( ),                              // output wire [15 : 0] drpdo_out
  
  .init_clk(init_clk_i),                                // input wire init_clk
  .drp_clk_in(drp_clk_i),                            // input wire drp_clk_in
  
  .link_reset_out( ),                    // output wire link_reset_out
  .user_clk_out(user_clk_out),                        // output wire user_clk_out
  .sync_clk_out(sync_clk_out),                        // output wire sync_clk_out
  .gt_qpllclk_quad1_out(gt_qpllclk_quad1_out),        // output wire gt_qpllclk_quad1_out
  .gt_qpllrefclk_quad1_out(gt_qpllrefclk_quad1_out),  // output wire gt_qpllrefclk_quad1_out
  .gt_rxcdrovrden_in(gt_rxcdrovrden_i),              // input wire gt_rxcdrovrden_in
  .sys_reset_out(sys_reset_out_dataBus),                      // output wire sys_reset_out
  .gt_reset_out()                        // output wire gt_reset_out
);

aurora_64b66b_Slaver u_aurora_Channel_FailBus (
  .rxp(gt_rx_failbus_p),                                        // input wire [0 : 0] rxp
  .rxn(gt_rx_failbus_n),                                        // input wire [0 : 0] rxn
  .refclk1_in(refclk1_in),                          // input wire refclk1_in
  .user_clk(user_clk_out),                              // input wire user_clk
  .sync_clk(sync_clk_out),                              // input wire sync_clk
  
  .reset_pb(reset_i),                              // input wire reset_pb
  .power_down(power_down_i),                          // input wire power_down
  .pma_init(PMA_INIT),                              // input wire pma_init
  .loopback(loopback_i),                              // input wire [2 : 0] loopback
  .txp(gt_tx_failbus_p),                                        // output wire [0 : 0] txp
  .txn(gt_tx_failbus_n),                                        // output wire [0 : 0] txn
  .hard_err(hard_err_i_failbus),                              // output wire hard_err
  .soft_err(soft_err_i_failbus),                              // output wire soft_err
  .channel_up(channel_up_i_failbus),                          // output wire channel_up
  .lane_up(lane_up_i_failbus),                                // output wire [0 : 0] lane_up 
  .tx_out_clk( ),                          // output wire tx_out_clk
  .gt_pll_lock( ),                        // output wire gt_pll_lock
  .s_axi_tx_tdata   (s_axi_tx_tdata_failbus     ),                  // input wire [0 : 63] s_axi_tx_tdata
  .s_axi_tx_tvalid  (s_axi_tx_tvalid_failbus    ),                // input wire s_axi_tx_tvalid
  .s_axi_tx_tready  (s_axi_tx_tready_failbus    ),                // output wire s_axi_tx_tready
  .m_axi_rx_tdata   (m_axi_rx_tdata_failbus     ),                  // output wire [0 : 63] m_axi_rx_tdata
  .m_axi_rx_tvalid  (m_axi_rx_tvalid_failbus    ),                // output wire m_axi_rx_tvalid
  .mmcm_not_locked(mmcm_not_locked_out),                // input wire mmcm_not_locked
  
  .drpaddr_in(drpaddr_in_i),                          // input wire [8 : 0] drpaddr_in
  .drpdi_in(drpdi_in_i),                              // input wire [15 : 0] drpdi_in
  .drprdy_out( ),                                   // output wire drprdy_out
  .drpen_in(drpen_in_i),                              // input wire drpen_in
  .drpwe_in(drpwe_in_i),                              // input wire drpwe_in
  .drpdo_out( ),                                    // output wire [15 : 0] drpdo_out
  
  .init_clk(init_clk_i),                              // input wire init_clk
  .drp_clk_in(drp_clk_i),                          // input wire drp_clk_in
  .link_reset_out( ),                  // output wire link_reset_out
  .gt_qpllclk_quad1_in(gt_qpllclk_quad1_out),        // input wire gt_qpllclk_quad1_in
  .gt_qpllrefclk_quad1_in(gt_qpllrefclk_quad1_out),  // input wire gt_qpllrefclk_quad1_in
  .gt_rxcdrovrden_in(gt_rxcdrovrden_i),            // input wire gt_rxcdrovrden_in
  .sys_reset_out(sys_reset_out_failBus)                    // output wire sys_reset_out
);

aurora_Process u_aurora_process_databus(
    .RESET                       (sys_reset_out_dataBus),                   
    .CLK                         (CKP),                     
    //tx data from user ram      
    .CAP_EN                      (CAP_EN_DATABUS),        
    .IN_CAP_DATA                 (IN_CAP_DATA_DATABUS),        
    //tx data to aurora          
    .s_axi_tx_tdata            (s_axi_tx_tdata_databus),
    .s_axi_tx_tvalid             (s_axi_tx_tvalid_databus),
    .s_axi_tx_tready            (s_axi_tx_tready_databus),        
    //rx data to user ram     
    .EMPTY                       (EMPTY_DATABUS),        
    .ALEMPTY                     (ALEMPTY_DATABUS),        
    .RD_DATA_EN                  (RD_DATA_EN_DATABUS),        
    .O_CAP_DATA                  (O_CAP_DATA_DATABUS),        
    //rx data from aurora        
    .m_axi_rx_tvalid         (m_axi_rx_tvalid_databus),        
    .m_axi_rx_tdata          (m_axi_rx_tdata_databus),        

    .USER_CLK                    (user_clk_out),        
    .CHANNEL_UP                  (channel_up_i_databus)
);
aurora_Process u_aurora_process_failbus(
    .RESET                       (sys_reset_out_dataBus),                   
    .CLK                         (CKP),                     
    //tx data from user ram      
    .CAP_EN                      (CAP_EN_FAILBUS),        
    .IN_CAP_DATA                 (IN_CAP_DATA_FAILBUS),        
    //tx data to aurora          
    .s_axi_tx_tdata            (s_axi_tx_tdata_failbus),
    .s_axi_tx_tvalid             (s_axi_tx_tvalid_failbus),
    .s_axi_tx_tready            (s_axi_tx_tready_failbus),        
    //rx data to user ram     
    .EMPTY                       (EMPTY_FAILBUS),        
    .ALEMPTY                     (ALEMPTY_FAILBUS),        
    .RD_DATA_EN                  (RD_DATA_EN_FAILBUS),        
    .O_CAP_DATA                  (O_CAP_DATA_FAILBUS),        
    //rx data from aurora        
    .m_axi_rx_tvalid             (m_axi_rx_tvalid_failbus),        
    .m_axi_rx_tdata              (m_axi_rx_tdata_failbus),        

    .USER_CLK                    (user_clk_out),        
    .CHANNEL_UP                  (channel_up_i_failbus)
);
   
endmodule
