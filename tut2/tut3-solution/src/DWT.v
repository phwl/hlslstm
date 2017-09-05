/* 
(C) Yeyong Pang 2014 http://yeyongpang.cnblogs.com

Filename    : DWT.v
Compiler    : Quartus II 13.0.0 Build 156
Description : Sample Solution of Discrete Walsh Transform Processor in Verilog
Release     : 18/06/2014 1.0
*/

module DWT (
	iCLK,
	iRST_N,
	iDATA,
	oDATA
);

genvar  rid,cid,instid;

parameter N = 64;
parameter Word_Length = 16;
parameter Out_Length = Word_Length+6;//log2(64)=6

input            						iCLK;
input            						iRST_N;
input      	[N*Word_Length-1:0]	iDATA;
output wire	[N*Out_Length-1:0]	oDATA;

parameter [N*N-1:0] Walsh_Matrix ={
64'b1111111111111111111111111111111111111111111111111111111111111111,
64'b1001011001101001011010011001011001101001100101101001011001101001,
64'b1001011001101001011010011001011010010110011010010110100110010110,
64'b1111111111111111111111111111111100000000000000000000000000000000,
64'b1001011001101001100101100110100110010110011010011001011001101001,
64'b1111111111111111000000000000000000000000000000001111111111111111,
64'b1111111111111111000000000000000011111111111111110000000000000000,
64'b1001011001101001100101100110100101101001100101100110100110010110,
64'b1001011010010110100101101001011010010110100101101001011010010110,
64'b1111111100000000000000001111111100000000111111111111111100000000,
64'b1111111100000000000000001111111111111111000000000000000011111111,
64'b1001011010010110100101101001011001101001011010010110100101101001,
64'b1111111100000000111111110000000011111111000000001111111100000000,
64'b1001011010010110011010010110100101101001011010011001011010010110,
64'b1001011010010110011010010110100110010110100101100110100101101001,
64'b1111111100000000111111110000000000000000111111110000000011111111,
64'b1001100110011001100110011001100110011001100110011001100110011001,
64'b1111000000001111000011111111000000001111111100001111000000001111,
64'b1111000000001111000011111111000011110000000011110000111111110000,
64'b1001100110011001100110011001100101100110011001100110011001100110,
64'b1111000000001111111100000000111111110000000011111111000000001111,
64'b1001100110011001011001100110011001100110011001101001100110011001,
64'b1001100110011001011001100110011010011001100110010110011001100110,
64'b1111000000001111111100000000111100001111111100000000111111110000,
64'b1111000011110000111100001111000011110000111100001111000011110000,
64'b1001100101100110011001101001100101100110100110011001100101100110,
64'b1001100101100110011001101001100110011001011001100110011010011001,
64'b1111000011110000111100001111000000001111000011110000111100001111,
64'b1001100101100110100110010110011010011001011001101001100101100110,
64'b1111000011110000000011110000111100001111000011111111000011110000,
64'b1111000011110000000011110000111111110000111100000000111100001111,
64'b1001100101100110100110010110011001100110100110010110011010011001,
64'b1010101010101010101010101010101010101010101010101010101010101010,
64'b1100001100111100001111001100001100111100110000111100001100111100,
64'b1100001100111100001111001100001111000011001111000011110011000011,
64'b1010101010101010101010101010101001010101010101010101010101010101,
64'b1100001100111100110000110011110011000011001111001100001100111100,
64'b1010101010101010010101010101010101010101010101011010101010101010,
64'b1010101010101010010101010101010110101010101010100101010101010101,
64'b1100001100111100110000110011110000111100110000110011110011000011,
64'b1100001111000011110000111100001111000011110000111100001111000011,
64'b1010101001010101010101011010101001010101101010101010101001010101,
64'b1010101001010101010101011010101010101010010101010101010110101010,
64'b1100001111000011110000111100001100111100001111000011110000111100,
64'b1010101001010101101010100101010110101010010101011010101001010101,
64'b1100001111000011001111000011110000111100001111001100001111000011,
64'b1100001111000011001111000011110011000011110000110011110000111100,
64'b1010101001010101101010100101010101010101101010100101010110101010,
64'b1100110011001100110011001100110011001100110011001100110011001100,
64'b1010010101011010010110101010010101011010101001011010010101011010,
64'b1010010101011010010110101010010110100101010110100101101010100101,
64'b1100110011001100110011001100110000110011001100110011001100110011,
64'b1010010101011010101001010101101010100101010110101010010101011010,
64'b1100110011001100001100110011001100110011001100111100110011001100,
64'b1100110011001100001100110011001111001100110011000011001100110011,
64'b1010010101011010101001010101101001011010101001010101101010100101,
64'b1010010110100101101001011010010110100101101001011010010110100101,
64'b1100110000110011001100111100110000110011110011001100110000110011,
64'b1100110000110011001100111100110011001100001100110011001111001100,
64'b1010010110100101101001011010010101011010010110100101101001011010,
64'b1100110000110011110011000011001111001100001100111100110000110011,
64'b1010010110100101010110100101101001011010010110101010010110100101,
64'b1010010110100101010110100101101010100101101001010101101001011010,
64'b1100110000110011110011000011001100110011110011000011001111001100};

wire    [N*N*Word_Length-1:0] datax_sig;

generate
    for(rid=0;rid<N;rid=rid+1) begin: label_r
		for(cid=0;cid<N;cid=cid+1) begin: label_c
			assign datax_sig[rid*N*Word_Length+(cid+1)*Word_Length-1:rid*N*Word_Length+cid*Word_Length] = Walsh_Matrix[rid*N+cid]?iDATA[(cid+1)*Word_Length-1:cid*Word_Length]:(~iDATA[(cid+1)*Word_Length-1:cid*Word_Length]+16'h1);
		end
    end
endgenerate

wire    [N*Out_Length-1:0] result_sig;

generate
    for(instid=0;instid<N;instid=instid+1) begin: label_i
		Parallel_Adder	Parallel_Adder_inst (
			.clock   ( iCLK ),
			.data0x  ( datax_sig[instid*Word_Length*N+15  :instid*Word_Length*N+0  ] ),
			.data10x ( datax_sig[instid*Word_Length*N+31  :instid*Word_Length*N+16 ] ),
			.data11x ( datax_sig[instid*Word_Length*N+47  :instid*Word_Length*N+32 ] ),
			.data12x ( datax_sig[instid*Word_Length*N+63  :instid*Word_Length*N+48 ] ),
			.data13x ( datax_sig[instid*Word_Length*N+79  :instid*Word_Length*N+64 ] ),
			.data14x ( datax_sig[instid*Word_Length*N+95  :instid*Word_Length*N+80 ] ),
			.data15x ( datax_sig[instid*Word_Length*N+111 :instid*Word_Length*N+96 ] ),
			.data16x ( datax_sig[instid*Word_Length*N+127 :instid*Word_Length*N+112] ),
			.data17x ( datax_sig[instid*Word_Length*N+143 :instid*Word_Length*N+128] ),
			.data18x ( datax_sig[instid*Word_Length*N+159 :instid*Word_Length*N+144] ),
			.data19x ( datax_sig[instid*Word_Length*N+175 :instid*Word_Length*N+160] ),
			.data1x  ( datax_sig[instid*Word_Length*N+191 :instid*Word_Length*N+176] ),
			.data20x ( datax_sig[instid*Word_Length*N+207 :instid*Word_Length*N+192] ),
			.data21x ( datax_sig[instid*Word_Length*N+223 :instid*Word_Length*N+208] ),
			.data22x ( datax_sig[instid*Word_Length*N+239 :instid*Word_Length*N+224] ),
			.data23x ( datax_sig[instid*Word_Length*N+255 :instid*Word_Length*N+240] ),
			.data24x ( datax_sig[instid*Word_Length*N+271 :instid*Word_Length*N+256] ),
			.data25x ( datax_sig[instid*Word_Length*N+287 :instid*Word_Length*N+272] ),
			.data26x ( datax_sig[instid*Word_Length*N+303 :instid*Word_Length*N+288] ),
			.data27x ( datax_sig[instid*Word_Length*N+319 :instid*Word_Length*N+304] ),
			.data28x ( datax_sig[instid*Word_Length*N+335 :instid*Word_Length*N+320] ),
			.data29x ( datax_sig[instid*Word_Length*N+351 :instid*Word_Length*N+336] ),
			.data2x  ( datax_sig[instid*Word_Length*N+367 :instid*Word_Length*N+352] ),
			.data30x ( datax_sig[instid*Word_Length*N+383 :instid*Word_Length*N+368] ),
			.data31x ( datax_sig[instid*Word_Length*N+399 :instid*Word_Length*N+384] ),
			.data32x ( datax_sig[instid*Word_Length*N+415 :instid*Word_Length*N+400] ),
			.data33x ( datax_sig[instid*Word_Length*N+431 :instid*Word_Length*N+416] ),
			.data34x ( datax_sig[instid*Word_Length*N+447 :instid*Word_Length*N+432] ),
			.data35x ( datax_sig[instid*Word_Length*N+463 :instid*Word_Length*N+448] ),
			.data36x ( datax_sig[instid*Word_Length*N+479 :instid*Word_Length*N+464] ),
			.data37x ( datax_sig[instid*Word_Length*N+495 :instid*Word_Length*N+480] ),
			.data38x ( datax_sig[instid*Word_Length*N+511 :instid*Word_Length*N+496] ),
			.data39x ( datax_sig[instid*Word_Length*N+527 :instid*Word_Length*N+512] ),
			.data3x  ( datax_sig[instid*Word_Length*N+543 :instid*Word_Length*N+528] ),
			.data40x ( datax_sig[instid*Word_Length*N+559 :instid*Word_Length*N+544] ),
			.data41x ( datax_sig[instid*Word_Length*N+575 :instid*Word_Length*N+560] ),
			.data42x ( datax_sig[instid*Word_Length*N+591 :instid*Word_Length*N+576] ),
			.data43x ( datax_sig[instid*Word_Length*N+607 :instid*Word_Length*N+592] ),
			.data44x ( datax_sig[instid*Word_Length*N+623 :instid*Word_Length*N+608] ),
			.data45x ( datax_sig[instid*Word_Length*N+639 :instid*Word_Length*N+624] ),
			.data46x ( datax_sig[instid*Word_Length*N+655 :instid*Word_Length*N+640] ),
			.data47x ( datax_sig[instid*Word_Length*N+671 :instid*Word_Length*N+656] ),
			.data48x ( datax_sig[instid*Word_Length*N+687 :instid*Word_Length*N+672] ),
			.data49x ( datax_sig[instid*Word_Length*N+703 :instid*Word_Length*N+688] ),
			.data4x  ( datax_sig[instid*Word_Length*N+719 :instid*Word_Length*N+704] ),
			.data50x ( datax_sig[instid*Word_Length*N+735 :instid*Word_Length*N+720] ),
			.data51x ( datax_sig[instid*Word_Length*N+751 :instid*Word_Length*N+736] ),
			.data52x ( datax_sig[instid*Word_Length*N+767 :instid*Word_Length*N+752] ),
			.data53x ( datax_sig[instid*Word_Length*N+783 :instid*Word_Length*N+768] ),
			.data54x ( datax_sig[instid*Word_Length*N+799 :instid*Word_Length*N+784] ),
			.data55x ( datax_sig[instid*Word_Length*N+815 :instid*Word_Length*N+800] ),
			.data56x ( datax_sig[instid*Word_Length*N+831 :instid*Word_Length*N+816] ),
			.data57x ( datax_sig[instid*Word_Length*N+847 :instid*Word_Length*N+832] ),
			.data58x ( datax_sig[instid*Word_Length*N+863 :instid*Word_Length*N+848] ),
			.data59x ( datax_sig[instid*Word_Length*N+879 :instid*Word_Length*N+864] ),
			.data5x  ( datax_sig[instid*Word_Length*N+895 :instid*Word_Length*N+880] ),
			.data60x ( datax_sig[instid*Word_Length*N+911 :instid*Word_Length*N+896] ),
			.data61x ( datax_sig[instid*Word_Length*N+927 :instid*Word_Length*N+912] ),
			.data62x ( datax_sig[instid*Word_Length*N+943 :instid*Word_Length*N+928] ),
			.data63x ( datax_sig[instid*Word_Length*N+959 :instid*Word_Length*N+944] ),
			.data6x  ( datax_sig[instid*Word_Length*N+975 :instid*Word_Length*N+960] ),
			.data7x  ( datax_sig[instid*Word_Length*N+991 :instid*Word_Length*N+976] ),
			.data8x  ( datax_sig[instid*Word_Length*N+1007:instid*Word_Length*N+992] ),
			.data9x  ( datax_sig[instid*Word_Length*N+1023:instid*Word_Length*N+1008]),
			.result  ( result_sig[(instid+1)*Out_Length-1 :instid*Out_Length] )
			);
    end
endgenerate

assign oDATA=result_sig;

endmodule
