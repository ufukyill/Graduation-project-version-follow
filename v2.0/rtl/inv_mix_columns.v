module inv_mix_columns(
    input [127:0] inputData,
	input startTransition,
	output reg [127:0] outputData
);
reg [31 : 0] w0, w1, w2, w3;
reg [31 : 0] ws0, ws1, ws2, ws3;
always @(posedge startTransition) begin : inv_mix_columns
    
    w0 = inputData[127 : 096];
    w1 = inputData[095 : 064];
    w2 = inputData[063 : 032];
    w3 = inputData[031 : 000];
  
    ws0 = inv_mixw(w0);
    ws1 = inv_mixw(w1);
    ws2 = inv_mixw(w2);
    ws3 = inv_mixw(w3);
   
    outputData= {ws0, ws1, ws2, ws3};



end



 

    //INV MIXWORD FUNCTION
    function [31 : 0] inv_mixw(input [31 : 0] w);
    reg [7 : 0] b0, b1, b2, b3;
    reg [7 : 0] mb0, mb1, mb2, mb3;
    begin
    b0 = w[31 : 24];
    b1 = w[23 : 16];
    b2 = w[15 : 08];
    b3 = w[07 : 00];

    mb0 = gm14(b0) ^ gm11(b1) ^ gm13(b2) ^ gm09(b3);
    mb1 = gm09(b0) ^ gm14(b1) ^ gm11(b2) ^ gm13(b3);
    mb2 = gm13(b0) ^ gm09(b1) ^ gm14(b2) ^ gm11(b3);
    mb3 = gm11(b0) ^ gm13(b1) ^ gm09(b2) ^ gm14(b3);

    inv_mixw = {mb0, mb1, mb2, mb3};
    end
    endfunction






    //GAOLIS MULTIPLICATION FUNCTIONS 
    //FROM :https://github.com/secworks/aes/blob/master/src/rtl/aes_encipher_block.v
    function [7 : 0] gm2(input [7 : 0] op);
    begin
    gm2 = {op[6 : 0], 1'b0} ^ (8'h1b & {8{op[7]}});
    end
    endfunction // gm2

    function [7 : 0] gm3(input [7 : 0] op);
    begin
    gm3 = gm2(op) ^ op;
    end
    endfunction // gm3

    function [7 : 0] gm4(input [7 : 0] op);
    begin
    gm4 = gm2(gm2(op));
    end
    endfunction // gm4

    function [7 : 0] gm8(input [7 : 0] op);
    begin
    gm8 = gm2(gm4(op));
    end
    endfunction // gm8

    function [7 : 0] gm09(input [7 : 0] op);
    begin
    gm09 = gm8(op) ^ op;
    end
    endfunction // gm09

    function [7 : 0] gm11(input [7 : 0] op);
    begin
    gm11 = gm8(op) ^ gm2(op) ^ op;
    end
    endfunction // gm11

    function [7 : 0] gm13(input [7 : 0] op);
    begin
    gm13 = gm8(op) ^ gm4(op) ^ op;
    end
    endfunction // gm13

    function [7 : 0] gm14(input [7 : 0] op);
    begin
    gm14 = gm8(op) ^ gm4(op) ^ gm2(op);
    end
    endfunction // gm14




endmodule







