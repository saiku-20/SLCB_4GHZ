//--###############################################################################################
//--#
//--# File Name		: rst_syc_module
//--# Designer		: ����վ
//--# Tool			: Vivado 2021.1
//--# Design Date	: 2024.4.8
//--# Description	: ���ü�����ͬ���������ɸ�λ�źţ�
//--# Version		: 0.0
//--# Coding scheme	: GBK��If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode��
//--#
//--###############################################################################################
module rst_syc_module #(
    parameter			RST_IN_VLD  =   1'b0        ,//��λ������Ч��ƽ��Ĭ�ϵ͵�ƽ��
    parameter			RST_OUT_VLD =   1'b1        ,//��λ�����Ч��ƽ��Ĭ�ϸߵ�ƽ��
    parameter			RST_CYCLE	=   2	         //ͬ��ʱ�Ӹ�����
)(
    input								CLK_IN		    ,//ϵͳʱ���źţ�
    input								rst_n_in    ,//��λ�����źţ�Ĭ�ϵ͵�ƽ��Ч��
    output  reg                         rst_out      //��λ����źţ�Ĭ�ϸߵ�ƽ��Ч��
);
    localparam          CNT_W       =   clogb2(RST_CYCLE-1);//ͨ���Զ��庯�����������λ��
    reg                 [CNT_W - 1 : 0] cnt        ;//

    //�Զ������λ������
    function integer clogb2(input integer depth);begin
        if(depth == 0)
            clogb2 = 1;
        else if(depth != 0)
            for(clogb2=0 ; depth>0 ; clogb2=clogb2+1)
                depth=depth >> 1;
        end
    endfunction

    //ͬ����λ��������
    always@(posedge CLK_IN)begin
        if(rst_n_in == RST_IN_VLD)begin//��ʼֵΪ0;
            cnt <= 'd0;
        end
        else if((cnt == RST_CYCLE - 1) || (RST_CYCLE == 0))begin//������ָ����ֵʱ���ֲ��䣻
            cnt <= cnt;
        end
        else begin
            cnt <= cnt + 'd1;
        end
    end

    //����ͬ����λ�źš�
    always@(posedge CLK_IN)begin
        if(((cnt == RST_CYCLE - 1) || (RST_CYCLE == 0)))begin//��ʼֵΪ0;
            rst_out <= ~RST_OUT_VLD;
        end
        else begin
            rst_out <= RST_OUT_VLD;
        end
    end

endmodule