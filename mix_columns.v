
//  At the startTransition, this module will complete the 
// MixColumn opperation.

module mix_columns #(
	parameter ENCRYPT = 1
)(
	input [127:0] inputData,
	input startTransition,
	output reg [127:0] outputData
);
reg [31 : 0] w0, w1, w2, w3;
reg [31 : 0] ws0, ws1, ws2, ws3;
always @(posedge startTransition) begin: mixColumns
	w0=inputData[127:96];
	w1=inputData[95:64];
	w2=inputData[63:32];
	w3=inputData[31:0];

	ws0 = mixword(w0);
	ws1 = mixword(w1);
	ws2 = mixword(w2);
	ws3 = mixword(w3);

	outputData={ws0,ws1,ws2,ws3};
end





//Galois field functions. Due to Nb =4 for 128bit key 
//we need to consider only gm2 and gm3


// gm2
function [7 : 0] gm2(input [7 : 0] op);
begin
  gm2 = {op[6 : 0], 1'b0} ^ (8'h1b & {8{op[7]}});
end
endfunction 

// gm3
function [7 : 0] gm3(input [7 : 0] op);
begin
  gm3 = gm2(op) ^ op;
end
endfunction 

// mixw
function [31 : 0] mixword(input [31 : 0] w);
reg [7 : 0] w0, w1, w2, w3;
reg [7 : 0] mw0, mw1, mw2, mw3;
begin
  w0 = w[31 : 24];
  w1 = w[23 : 16];
  w2 = w[15 : 08];
  w3 = w[07 : 00];

  mw0 = gm2(w0) ^ gm3(w1) ^ w2      ^ w3;
  mw1 = w0      ^ gm2(w1) ^ gm3(w2) ^ w3;
  mw2 = w0      ^ w1      ^ gm2(w2) ^ gm3(w3);
  mw3 = gm3(w0) ^ w1      ^ w2      ^ gm2(w3);

  mixword = {mw0, mw1, mw2, mw3};
end
endfunction 

endmodule


