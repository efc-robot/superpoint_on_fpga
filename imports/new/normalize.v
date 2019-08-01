`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/01 19:52:59
// Design Name: 
// Module Name: normalize
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


module normalize(
input clk,
input rstn,
(* DONT_TOUCH = "TRUE" *)input [63:0]       s_axis_mm2s_tdata           ,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_mm2s_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)input 			    s_axis_mm2s_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)output 		    s_axis_mm2s_tready 	  		,
(* DONT_TOUCH = "TRUE" *)output [63:0]  m_axis_s2mm_tdata           ,
(* DONT_TOUCH = "TRUE" *)output		    m_axis_s2mm_tvalid 	  		,
(* DONT_TOUCH = "TRUE" *)output		    m_axis_s2mm_tlast 	  		,
(* DONT_TOUCH = "TRUE" *)input 		        m_axis_s2mm_tready 	  		

    );
    
    (* DONT_TOUCH = "TRUE" *)reg [1:0] state=0;
    
    (* DONT_TOUCH = "TRUE" *)wire [63:0] axis_raw_tdata;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tvalid;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tlast;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tready;
    
    (* DONT_TOUCH = "TRUE" *)wire [23:0] axis_squa_sum_tdata;
    (* DONT_TOUCH = "TRUE" *)wire axis_squa_sum_tvalid;
    (* DONT_TOUCH = "TRUE" *)wire axis_squa_sum_tlast;
    (* DONT_TOUCH = "TRUE" *)wire axis_squa_sum_tready;
    
    (* DONT_TOUCH = "TRUE" *)wire [15:0] axis_squa_root_tdata;
    (* DONT_TOUCH = "TRUE" *)wire axis_squa_root_tvalid;
    (* DONT_TOUCH = "TRUE" *)wire axis_squa_root_tready;
    
    (* DONT_TOUCH = "TRUE" *)wire axis_divisor_tready;
    (* DONT_TOUCH = "TRUE" *)wire axis_dividend_tready;
    
    (* DONT_TOUCH = "TRUE" *)wire axis_div_tvalid;          
    (* DONT_TOUCH = "TRUE" *)wire axis_div_tready;          
    (* DONT_TOUCH = "TRUE" *)wire axis_div_tuser;          
    (* DONT_TOUCH = "TRUE" *)wire [23:0] axis_div_tdata;   
    
    (* DONT_TOUCH = "TRUE" *)wire [63:0] axis_raw_tdata_2;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tvalid_2;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tlast_2;
    (* DONT_TOUCH = "TRUE" *)wire axis_raw_tready_2;
    
    always@(posedge clk)
    begin
        if(!rstn)    state <= 0;
        else if((state==0) & s_axis_mm2s_tlast)      state <= 1;
        else if((state==1) & axis_div_tvalid)  state <= 2;
        else if((state==2) & s_axis_mm2s_tlast)      state <= 0;
        else state <= state;
    end     
    
    assign s_axis_mm2s_tready = (axis_raw_tready && (state==0)) || (axis_raw_tready_2 && (state==2));
        
    assign axis_raw_tdata = s_axis_mm2s_tdata;
    assign axis_raw_tvalid = s_axis_mm2s_tvalid && (state==0);
    assign axis_raw_tlast = s_axis_mm2s_tlast && (state==0);
    
    assign axis_raw_tdata_2 = s_axis_mm2s_tdata;
    assign axis_raw_tvalid_2 = s_axis_mm2s_tvalid && (state==2);
    assign axis_raw_tlast_2 = s_axis_mm2s_tlast && (state==2);
    
    mult_squa_adder squa_adder(
        .clk(clk),
        .rstn(rstn),
        .s_axis_raw_tdata(axis_raw_tdata)           ,
        .s_axis_raw_tvalid(axis_raw_tvalid)               ,
        .s_axis_raw_tlast(axis_raw_tlast)               ,
        .s_axis_raw_tready(axis_raw_tready)               ,
        .m_axis_squa_sum_tdata(axis_squa_sum_tdata)           ,
        .m_axis_squa_sum_tvalid(axis_squa_sum_tvalid)               ,
        .m_axis_squa_sum_tlast(axis_squa_sum_tlast)               ,
        .m_axis_squa_sum_tready(axis_squa_sum_tready)               
        );
    
    cordic_0 squa_rooter (
        .aclk(clk),                                        // input wire aclk
        .s_axis_cartesian_tvalid(axis_squa_sum_tvalid),  // input wire s_axis_cartesian_tvalid
        .s_axis_cartesian_tready(axis_squa_sum_tready),  // output wire s_axis_cartesian_tready
        .s_axis_cartesian_tdata({axis_squa_sum_tdata,8'h00}),    // input wire [31 : 0] s_axis_cartesian_tdata
        .m_axis_dout_tvalid(axis_squa_root_tvalid),            // output wire m_axis_dout_tvalid
        .m_axis_dout_tready(axis_squa_root_tready),            // input wire m_axis_dout_tready
        .m_axis_dout_tdata(axis_squa_root_tdata)              // output wire [23 : 0] m_axis_dout_tdata
    ); 
    
    assign axis_squa_root_tready = axis_dividend_tready & axis_divisor_tready;
    
    div_gen_0 reciprocal (
      .aclk(clk),                                      // input wire aclk
      .s_axis_divisor_tvalid(axis_squa_root_tvalid),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tready(axis_divisor_tready),    // output wire s_axis_divisor_tready
      .s_axis_divisor_tdata(axis_squa_root_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(axis_squa_root_tvalid),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tready(axis_dividend_tready),  // output wire s_axis_dividend_tready
      .s_axis_dividend_tdata(24'h40_0000),    // input wire [23 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(axis_div_tvalid),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tready(axis_div_tready),          // input wire m_axis_dout_tready
      .m_axis_dout_tuser(axis_div_tuser),            // output wire [0 : 0] m_axis_dout_tuser
      .m_axis_dout_tdata(axis_div_tdata)            // output wire [23 : 0] m_axis_dout_tdata
    );
    
    (* DONT_TOUCH = "TRUE" *)reg [23 : 0] reciprocal_squa_root;
    always@(posedge clk)
    begin
        if (!rstn)    reciprocal_squa_root <= 0;
        else if(state==1 && axis_div_tvalid)  reciprocal_squa_root <= axis_div_tdata;
        else if(state==2 && s_axis_mm2s_tlast)      reciprocal_squa_root <= 0;
        else reciprocal_squa_root <= reciprocal_squa_root;
    end   
    
    assign axis_div_tready = (state==2);
    
    mult_norm mult_norm(
        .clk(clk),
        .rstn(rstn),
        .reciprocal_squa_root(reciprocal_squa_root),//[23:0]
        .s_axis_raw_tdata(axis_raw_tdata_2)           ,//[64:0]
        .s_axis_raw_tvalid(axis_raw_tvalid_2)               ,
        .s_axis_raw_tlast(axis_raw_tlast_2)               ,
        .s_axis_raw_tready(axis_raw_tready_2)               ,
        .m_axis_result_tdata(m_axis_s2mm_tdata)           ,//[64:0]
        .m_axis_result_tvalid(m_axis_s2mm_tvalid)               ,
        .m_axis_result_tlast(m_axis_s2mm_tlast)               ,
        .m_axis_result_tready(m_axis_s2mm_tready)               
    );  
    
endmodule
