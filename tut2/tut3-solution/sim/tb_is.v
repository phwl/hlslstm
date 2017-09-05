/* 
(C) Yeyong Pang 2014 http://yeyongpang.cnblogs.com

Filename    : DWT.v
Compiler    : Modelsim-Altera Starter 10.1d
Description : Test Bench for Sample Solution of Discrete Walsh Transform Processor in Verilog
Release     : 18/06/2014 1.0
*/
`timescale 1ps / 1ps

module tb_is;
  
localparam USER_CLK_PERIOD = 2; //5ns, 200MHz

reg user_clk;
reg user_rst_n;

initial begin
    user_clk    <= 1'b0;
end

always #(USER_CLK_PERIOD/2) user_clk = ~user_clk;

//reset generation
initial begin
   user_rst_n          <= 1'b0;

   # 100000;
   user_rst_n          <= 1'b1;
end

reg 	[16*64-1:0]X_data;
wire 	[22*64-1:0]checkdata;
wire 	[16*64-1:0]X_data_new;

assign X_data_new = 1024'h0000000100020003000400050006000700080009000a000b000c000d000e000f0010001100120013001400150016001700180019001a001b001c001d001e001f0020002100220023002400250026002700280029002a002b002c002d002e002f0030003100320033003400350036003700380039003a003b003c003d003e003f;

always @(posedge user_clk)
begin
	X_data = X_data_new;
end

DWT DWT_inst(
	.iCLK(user_clk),
	.iRST_N(1'b1),
	.iDATA(X_data),
	.oDATA(checkdata)
	);

endmodule