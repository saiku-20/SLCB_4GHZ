//--###############################################################################################
//--#
//--# File Name		: rst_syc_module
//--# Designer		: 数字站
//--# Tool			: Vivado 2021.1
//--# Design Date	: 2024.4.8
//--# Description	: 利用计数器同步或者生成复位信号；
//--# Version		: 0.0
//--# Coding scheme	: GBK（If the Chinese comment of the file is garbled, please do not save it and check whether the file is opened in GBK encoding mode）
//--#
//--###############################################################################################
module rst_syc_module #(
    parameter			RST_IN_VLD  =   1'b0        ,//复位输入有效电平，默认低电平；
    parameter			RST_OUT_VLD =   1'b1        ,//复位输出有效电平，默认高电平；
    parameter			RST_CYCLE	=   2	         //同步时钟个数；
)(
    input								CLK_IN		    ,//系统时钟信号；
    input								rst_n_in    ,//复位输入信号，默认低电平有效；
    output  reg                         rst_out      //复位输出信号，默认高电平有效；
);
    localparam          CNT_W       =   clogb2(RST_CYCLE-1);//通过自定义函数计算计数器位宽；
    reg                 [CNT_W - 1 : 0] cnt        ;//

    //自定义计算位宽函数；
    function integer clogb2(input integer depth);begin
        if(depth == 0)
            clogb2 = 1;
        else if(depth != 0)
            for(clogb2=0 ; depth>0 ; clogb2=clogb2+1)
                depth=depth >> 1;
        end
    endfunction

    //同步复位计数器；
    always@(posedge CLK_IN)begin
        if(rst_n_in == RST_IN_VLD)begin//初始值为0;
            cnt <= 'd0;
        end
        else if((cnt == RST_CYCLE - 1) || (RST_CYCLE == 0))begin//计数到指定数值时保持不变；
            cnt <= cnt;
        end
        else begin
            cnt <= cnt + 'd1;
        end
    end

    //生成同步复位信号。
    always@(posedge CLK_IN)begin
        if(((cnt == RST_CYCLE - 1) || (RST_CYCLE == 0)))begin//初始值为0;
            rst_out <= ~RST_OUT_VLD;
        end
        else begin
            rst_out <= RST_OUT_VLD;
        end
    end

endmodule