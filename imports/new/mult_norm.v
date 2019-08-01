`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/03 14:57:53
// Design Name: 
// Module Name: mult_norm
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


module mult_norm(
input clk,
input rstn,
(* DONT_TOUCH = "TRUE" *)input [23:0]        reciprocal_squa_root,
(* DONT_TOUCH = "TRUE" *)input [63:0]          s_axis_raw_tdata           ,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_raw_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_raw_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)output 		        s_axis_raw_tready 	  		,
(* DONT_TOUCH = "TRUE" *)output reg [63:0]         m_axis_result_tdata           ,
(* DONT_TOUCH = "TRUE" *)output		        m_axis_result_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)output  		        m_axis_result_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)input 		        m_axis_result_tready 	  		
    );
    
    genvar i;   
    (* DONT_TOUCH = "TRUE" *)reg axis_valid_reg;
    (* DONT_TOUCH = "TRUE" *)reg axis_last_reg;
    (* DONT_TOUCH = "TRUE" *)wire axis_ready;
//--------------------------ready-----------------------------------------------   
    assign s_axis_raw_tready = axis_ready;
    assign axis_ready = m_axis_result_tready || !axis_valid_reg;
//--------------------------valid-----------------------------------------------    
    always@(posedge clk)
    begin
        if (!rstn) begin
            axis_valid_reg <= 0;
        end
        else begin
            if(axis_ready)
                axis_valid_reg <= s_axis_raw_tvalid;
            else
                axis_valid_reg <= axis_valid_reg;
        end
    end
        
    assign m_axis_result_tvalid = axis_valid_reg;
//--------------------------last-----------------------------------------------    
    always@(posedge clk)
    begin
        if (!rstn) begin
            axis_last_reg <= 0;
        end
        else begin
            if(axis_ready)
                axis_last_reg <= s_axis_raw_tlast;
            else
                axis_last_reg <= axis_last_reg;
        end
    end    
    
    assign m_axis_result_tlast = axis_last_reg;
//--------------------------data------------------------------------------------        
    (* DONT_TOUCH = "TRUE" *)wire signed [31:0] result_tdata[0:7];
    generate
    for(i=0;i<8;i=i+1)
    begin: mult_norm
        mult_gen_norm mult (
          .CLK(clk),  // input wire CLK
          .CE(axis_ready && s_axis_raw_tvalid),    // input wire CE
          .A(s_axis_raw_tdata[i*8+7:i*8]),      // input wire [7 : 0] A
          .B(reciprocal_squa_root),      // input wire [23 : 0] B
          .P(result_tdata[i])      // output wire [31 : 0] P
        );
    end
    endgenerate
    
    generate
    for(i=0;i<8;i=i+1)
    begin
//        assign m_axis_result_tdata[i*8+7:i*8] = result_tdata[i][20:13];
        always@(*)
        begin
            if(result_tdata[i]>127*512)        m_axis_result_tdata[i*8+7:i*8] <= 127;
            else if(result_tdata[i]<-128*512)  m_axis_result_tdata[i*8+7:i*8] <= -128;
            else if(result_tdata[i][8])        m_axis_result_tdata[i*8+7:i*8] <= result_tdata[i][16:9] + 1;
            else                                m_axis_result_tdata[i*8+7:i*8] <= result_tdata[i][16:9];
        end
    end
    endgenerate
    
endmodule
