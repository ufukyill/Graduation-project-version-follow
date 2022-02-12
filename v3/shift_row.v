
// This is AES ShiftRow module. On the postaive edge of startTransition, certain values
// are cyclically shifted to the right. If the inputData is aranged as a 4x4 matrix as shown on 
// the LHS, then the ouput of this module is as shown on the RHS.
//		[a00, a01, a02, a03]		 [a00, a01, a02, a03]
//		[a10, a11, a12, a13] ==> [a13, a10, a11, a12]
//		[a20, a21, a22, a23] ==> [a22, a23, a20, a21]
//		[a30, a31, a32, a33]     [a31, a32, a33, a30]

module shift_row(
	input [127:0] inputData,
	input startTransition,
	output reg [127:0] outputData
);


reg [31:0] word1,word2,word3,word4,word1shifted,word2shifted,word3shifted,word4shifted;

always @(posedge startTransition) begin 
	word1=inputData[127:96];
	word2=inputData[95:64];
	word3=inputData[63:32];
	word4=inputData[31:0];

	word1shifted={word1[31:24],word2[23:16],word3[15:8],word4[7:0]};
	word2shifted={word2[31:24],word3[23:16],word4[15:8],word1[7:0]};
	word3shifted={word3[31:24],word4[23:16],word1[15:8],word2[7:0]};
	word4shifted={word4[31:24],word1[23:16],word2[15:8],word3[7:0]};

	outputData={word1shifted,word2shifted,word3shifted,word4shifted};
end
endmodule
