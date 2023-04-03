`default_nettype none
`timescale 1ns/1ns
// Testbench for sn74ls669 module
//iverilog -o ls669_test sn74ls669_tb.v sn74ls669.v
//vvp ls669_test

//This testbench replicates TI SN74ls669 datasheet
//typical load, count and inhibit sequences, page number 5

module sn74ls669_tb();
	reg [3:0] D;
	reg clk;
	initial clk=1'b1;

	reg U_Dn, LOADn, ENPn, ENTn;
	wire [3:0] Q;
	wire RCOn;


	always #16 clk = !clk; //around 32MHz clock

	sn74ls669 #(.DFF_RISE(5), .DFF_FALL(5)) dut(
		.CLOCK(clk),
		.U_Dn(U_Dn),
		.LOADn(LOADn),
		.ENABLE_Pn(ENPn),
		.ENABLE_Tn(ENTn),
		.DATA(D), //D,C,B,A
		.Q(Q), //D,C,B,A
		.RCOn(RCOn)
	);


	initial begin 
	    $dumpfile("dump.vcd"); 
        $dumpvars(0, sn74ls669_tb);
		LOADn <= 1'b1;
		D <= 4'b0000;
		U_Dn = 1'b1;
		ENPn = 1'b1;
		ENTn = 1'b1;
		#16;
		D <= 4'b1101;
		ENPn = 1'b0;
		ENTn = 1'b0;
		#2;
		LOADn <= 1'b0;

		#38;
		LOADn <= 1'b1;

		#8;
		#136;
		ENPn = 1'b1;
		ENTn = 1'b1;

		#32;
		U_Dn = 1'b0;

		#32;
		ENPn = 1'b0;
		ENTn = 1'b0;

	    repeat (20) @(posedge clk);
        $finish;
	end 
endmodule 