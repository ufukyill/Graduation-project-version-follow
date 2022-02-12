`timescale 1ns / 100ps
module AES_top_tb;

reg clock;
reg [127:0] key;
reg [127:0] data_in;
reg enable;
reg ED;
wire completedFlag;
wire [127:0] data_out;

reg [127:0] expVal;
//reg [127:0] expValDec;

AES_top dut(
    .clock(clock),
    .key(key),
    .data_in(data_in),
    .enable(enable),
    .ED(ED),
    .completedFlag(completedFlag),
    .data_out(data_out)
);

// Creating the prameters required for the 50MHz clock, and the stoppage of the test bench.
localparam NUM_CYCLES = 200000;
localparam CLOCK_FREQ = 50000000;
real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;
integer half_cycle = 0;

initial begin
    key=128'h000102030405060708090a0b0c0d0e0f;
    expVal= 128'h00112233445566778899aabbccddeeff;
    data_in= 128'h69c4e0d86a7b0430d8cdb78070b4c55a;
    enable=1'b1;
    
    clock=1'b0;
end

initial begin
    repeat(500) @(posedge clock);
    ED=1'b0;
end
always begin
    #(HALF_CLOCK_PERIOD);
	clock = ~clock;
	half_cycle = half_cycle + 1;

    if (half_cycle == (2 * NUM_CYCLES)) begin
        
        if (data_out != expVal) begin
            $display("Fail\n\n",
                        "For the following inputs\n",
                        "input value : %h \n",data_in,
                        "key:%h\n",key,
                        "expected output:%h\n",expVal,
                        "acquired output:%h\n",data_out
                        );
        end

        if (data_out==expVal) begin
            $display(
                "Pass\n\n",
                "for the following input\n",data_in,
                "input value\n",data_in,
                "key\n",key,
                "expected output\n",expVal,
                "acquired output\n",data_out
            );
        end
        $stop;
    end

end

endmodule