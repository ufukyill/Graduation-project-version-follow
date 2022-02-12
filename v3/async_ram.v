module async_ram 
#(
    parameter A_WIDTH = 32, 
    parameter D_WIDTH =128 )
(
    enable,
    RW,
    address,
    data_in,
    data_out
);

input  [A_WIDTH-1 : 0] address;
input  enable,RW;
input  [D_WIDTH-1 : 0] data_in;
output [D_WIDTH-1 : 0] data_out;

reg [D_WIDTH-1 :0] mem [(1<<A_WIDTH)-1 : 0];//2^A_WIDTH-1 : 0 =ADDRESS
reg [D_WIDTH-1 :0] data_out;
always @ (enable or RW ) begin // rw=1 ==> 'read' otherwise 'write'
    if (enable) begin 
        if (RW) data_out=mem[address];
        else mem[address]=data_in;
        
    end else begin
        data_out= 128'bz;//high impedance state 
    end 
              
    
end

endmodule
