`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/03 10:45:51
// Design Name: 
// Module Name: mult_squa_adder
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


module mult_squa_adder(
input clk,
input rstn,
(* DONT_TOUCH = "TRUE" *)input [63:0]          s_axis_raw_tdata           ,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_raw_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_raw_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)output 		        s_axis_raw_tready 	  		,
(* DONT_TOUCH = "TRUE" *)output [23:0]         m_axis_squa_sum_tdata           ,
(* DONT_TOUCH = "TRUE" *)output		        m_axis_squa_sum_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)output  		        m_axis_squa_sum_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)input 		        m_axis_squa_sum_tready 	  		
    );
    
    genvar i;   
    (* DONT_TOUCH = "TRUE" *)reg axis_valid_reg [0:4];
    (* DONT_TOUCH = "TRUE" *)reg axis_last_reg [0:4];
    (* DONT_TOUCH = "TRUE" *)wire axis_ready [0:4];
//--------------------------ready-----------------------------------------------   
    assign s_axis_raw_tready = axis_ready[0];
    
    generate
    for(i=0;i<4;i=i+1)
    begin 
        assign axis_ready[i] = axis_ready[i+1] || !axis_valid_reg[i];
    end
    endgenerate
    
    assign axis_ready[4] = m_axis_squa_sum_tready || !axis_valid_reg[4];
//--------------------------valid-----------------------------------------------    
    always@(posedge clk)
    begin
        if (!rstn) begin
            axis_valid_reg[0] <= 0;
        end
        else begin
            if(axis_ready[0])
                axis_valid_reg[0] <= s_axis_raw_tvalid;
            else
                axis_valid_reg[0] <= axis_valid_reg[0];
        end
    end    
    
    generate
    for(i=1;i<5;i=i+1)
    begin 
        always@(posedge clk)
        begin
            if (!rstn) begin
                axis_valid_reg[i] <= 0;
            end
            else begin
                if(axis_ready[i])
                    axis_valid_reg[i] <= axis_valid_reg[i-1];
                else
                    axis_valid_reg[i] <= axis_valid_reg[i];
            end
        end    
    end
    endgenerate
    
    assign m_axis_squa_sum_tvalid = axis_last_reg[4];
    
//--------------------------last-----------------------------------------------    
    always@(posedge clk)
    begin
        if (!rstn) begin
            axis_last_reg[0] <= 0;
        end
        else begin
            if(axis_ready[0])
                axis_last_reg[0] <= s_axis_raw_tlast;
            else
                axis_last_reg[0] <= axis_last_reg[0];
        end
    end    
    
    generate
    for(i=1;i<5;i=i+1)
    begin 
        always@(posedge clk)
        begin
            if (!rstn) begin
                axis_last_reg[i] <= 0;
            end
            else begin
                if(axis_ready[i])
                    axis_last_reg[i] <= axis_last_reg[i-1];
                else
                    axis_last_reg[i] <= axis_last_reg[i];
            end
        end    
    end
    endgenerate
    
    assign m_axis_squa_sum_tlast = axis_last_reg[4];
//--------------------------data------------------------------------------------        
    (* DONT_TOUCH = "TRUE" *)wire [15:0] squa_data [0:7];
    generate
    for(i=0;i<8;i=i+1)
    begin: mult_squa
        mult_gen_0 mult (
          .CLK(clk),  // input wire CLK
          .CE(axis_ready[0] && s_axis_raw_tvalid),    // input wire CE
          .A(s_axis_raw_tdata[i*8+7:i*8]),      // input wire [7 : 0] A
          .B(s_axis_raw_tdata[i*8+7:i*8]),      // input wire [7 : 0] B
          .P(squa_data[i])      // output wire [15 : 0] P
        );
    end
    endgenerate
    
    (* DONT_TOUCH = "TRUE" *)reg [23:0] squa_adder_0 [0:7];
    generate
    for(i=0;i<8;i=i+1)
    begin:adder_tree_0 
        always@(posedge clk)
        begin
            if (!rstn || axis_last_reg[1]) begin
                squa_adder_0[i] <= 0;
            end
            else begin
                if(axis_ready[1] && axis_valid_reg[0])
                    squa_adder_0[i] <= squa_adder_0[i] + squa_data[i];
                else
                    squa_adder_0[i] <= squa_adder_0[i];
            end
        end    
    end
    endgenerate
    
    (* DONT_TOUCH = "TRUE" *)reg [23:0] squa_adder_1 [0:3];
    generate
    for(i=0;i<4;i=i+1)
    begin:adder_tree_1 
        always@(posedge clk)
        begin
            if (!rstn) begin
                squa_adder_1[i] <= 0;
            end
            else begin
                if(axis_ready[2])
                    squa_adder_1[i] <= squa_adder_0[i*2+1] + squa_adder_0[i*2];
                else
                    squa_adder_1[i] <= squa_adder_1[i];
            end
        end    
    end
    endgenerate
    
    (* DONT_TOUCH = "TRUE" *)reg [23:0] squa_adder_2 [0:1];
    generate
    for(i=0;i<2;i=i+1)
    begin:adder_tree_2 
        always@(posedge clk)
        begin
            if (!rstn) begin
                squa_adder_2[i] <= 0;
            end
            else begin
                if(axis_ready[3])
                    squa_adder_2[i] <= squa_adder_1[i*2+1] + squa_adder_1[i*2];
                else
                    squa_adder_2[i] <= squa_adder_2[i];
            end
        end    
    end
    endgenerate
    
    (* DONT_TOUCH = "TRUE" *)reg [23:0] squa_adder_3;
    always@(posedge clk)
    begin
        if (!rstn) begin
            squa_adder_3 <= 0;
        end
        else begin
            if(axis_ready[4])
                squa_adder_3 <= squa_adder_2[1] + squa_adder_2[0];
            else
                squa_adder_3 <= squa_adder_3;
        end
    end   
    
    assign m_axis_squa_sum_tdata = squa_adder_3;
    
endmodule
