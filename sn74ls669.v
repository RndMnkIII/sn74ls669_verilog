//sn74ls669.sv
//Author: @RndMnkIII
//Date: 03/04/2023
//Build from TI sn74ls669 schematics
//for simulation assigned a gate delay of 5ns
`default_nettype none
`timescale 1ns/1ns
`define ASYNC_SIMU

module sn74ls669 #(parameter DFF_RISE = 5, DFF_FALL = 5)
(
	input wire CLOCK,
	input wire U_Dn,
	input wire LOADn,
	input wire ENABLE_Pn,
	input wire ENABLE_Tn,
	input wire [3:0] DATA, //D,C,B,A
	output wire [3:0] Q, //D,C,B,A
	output wire RCOn
);

	wire CLOCKn;
	wire U_D;
	wire U_Dnn;
	wire LOAD, LOADnn;
	wire ENABLE_P;
	wire ENABLE_T;
	wire ENA;
	wire dataa_ld, datab_ld, datac_ld, datad_ld;

	//Global signals
	assign #1 CLOCKn = ~CLOCK;
	assign #1 U_D = ~U_Dn;
	assign #1 U_Dnn = ~U_D;
	assign #1 LOAD = ~LOADn;
	assign #1 LOADnn = ~LOAD;
	assign #1 ENABLE_P = ~ENABLE_Pn;
	assign #1 ENABLE_T = ~ENABLE_Tn;
	assign #1 ENA = LOADn & ENABLE_P & ENABLE_T;

	assign #3 dataa_ld = DATA[0] & LOAD;
	assign #3 datab_ld = DATA[1] & LOAD;
	assign #3 datac_ld = DATA[2] & LOAD;
	assign #3 datad_ld = DATA[3] & LOAD;

	//block A
	wire dffa_q, dffa_qn;
	wire anda_1, anda_2, nora_1, nanda_1, anda_3, anda_4, ora_1;

	assign #3 anda_1 = dffa_q & U_D;
	assign #3 anda_2 = dffa_qn & U_Dnn;
	assign #3 nora_1 = ~(anda_1 | anda_2);

	assign #3 nanda_1 = ~(ENA & ENA);
	assign #3 anda_3 = dffa_q & nanda_1 & LOADnn;
	assign #3 anda_4 = ENA & dffa_qn;
	assign #3 ora_1 = anda_3 | anda_4 | dataa_ld;

	FE_DFF #(.DELAY_RISE(DFF_RISE), .DELAY_FALL(DFF_FALL)) dff_a( .D(ora_1), .clk(CLOCKn), .Q(dffa_q), .Qn(dffa_qn));

	//block B
	wire dffb_q, dffb_qn;
	wire andb_1, andb_2, norb_1, nandb_1, andb_3, andb_4, orb_1;

	assign #3 andb_1 = dffb_q & U_D;
	assign #3 andb_2 = dffb_qn & U_Dnn;
	assign #3 norb_1 = ~(andb_1 | andb_2);

	assign #3 nandb_1 = ~(ENA & nora_1);
	assign #3 andb_3 = dffb_q & nandb_1 & LOADnn;
	assign #3 andb_4 = nora_1 & ENA & dffb_qn;
	assign #3 orb_1 = andb_3 | andb_4 | datab_ld;

	FE_DFF #(.DELAY_RISE(DFF_RISE), .DELAY_FALL(DFF_FALL)) dff_b( .D(orb_1), .clk(CLOCKn), .Q(dffb_q), .Qn(dffb_qn));

	//block C
	wire dffc_q, dffc_qn;
	wire andc_1, andc_2, norc_1, nandc_1, andc_3, andc_4, orc_1;

	assign #3 andc_1 = dffc_q & U_D;
	assign #3 andc_2 = dffc_qn & U_Dnn;
	assign #3 norc_1 = ~(andc_1 | andc_2);

	assign #3 nandc_1 = ~(ENA & nora_1 & norb_1);
	assign #3 andc_3 = dffc_q & nandc_1 & LOADnn;
	assign #3 andc_4 = ENA & nora_1 & norb_1 & dffc_qn;
	assign #3 orc_1 = andc_3 | andc_4 | datac_ld;

	FE_DFF #(.DELAY_RISE(DFF_RISE), .DELAY_FALL(DFF_FALL)) dff_c( .D(orc_1), .clk(CLOCKn), .Q(dffc_q), .Qn(dffc_qn));

	//block D
	wire dffd_q, dffd_qn;
	wire andd_1, andd_2, nord_1, nandd_1, andd_3, andd_4, ord_1;

	assign #3 andd_1 = dffd_q & U_D;
	assign #3 andd_2 = dffd_qn & U_Dnn;
	assign #3 nord_1 = ~(andd_1 | andd_2);

	assign #3 nandd_1 = ~(ENA & nora_1 & norb_1 & norc_1);
	assign #3 andd_3 = dffd_q & nandd_1 & LOADnn;
	assign #3 andd_4 = ENA & nora_1 & norb_1 & norc_1 & dffd_qn;
	assign #3 ord_1 = andd_3 | andd_4 | datad_ld;

	FE_DFF #(.DELAY_RISE(DFF_RISE), .DELAY_FALL(DFF_FALL)) dff_d( .D(ord_1), .clk(CLOCKn), .Q(dffd_q), .Qn(dffd_qn));

	assign #3 RCOn = ~(ENABLE_T & nord_1 & norc_1 & norb_1 & nora_1);
	assign Q = {dffd_q,dffc_q,dffb_q,dffa_q};
endmodule

module FE_DFF #(parameter DELAY_RISE = 20, DELAY_FALL = 21)
(
	input wire D, 
	input wire clk,
	output wire Q,
	output wire Qn
);
	reg Q_current = 1'b0;

	always @(negedge clk) 
	begin
		Q_current <= D; 
	end 
	assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
	assign Qn = ~Q;
endmodule 
