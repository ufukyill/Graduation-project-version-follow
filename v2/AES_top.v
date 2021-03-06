
module AES_top(
    input clock, 
    input [127:0] key,
    input [127:0] data_in,
    input enable,
    input ED, // ED=0 for decrption 
    input resetAES,
    output reg completedFlag,
    output reg [127:0] data_out
    
);
//reg clock1MHz;
//reg clock50MHz;
reg encFlag;
reg [127:0] enckey;
reg [127:0] encDataIn;

reg decFlag;
reg [127:0] deckey;
reg [127:0] decDataIn;
wire [127:0] out;
wire [127:0] out2;
wire finishflag;
wire finishflag2;


//assign out= ED ? decDataOut : encDataOut;
//assign finishflag = ED ? dataDecryptedFlag : dataEncryptedFlag;


reg rst;

//fsm states
reg [3:0] state;
reg [3:0] IDLE= 4'd0;
reg [3:0] ENC=4'd1;
reg [3:0] DEC=4'd2;
reg [3:0] WAITFORENC=4'd3;
reg [3:0] WAITFORDEC=4'd4;
reg [3:0] FINISH_enc=4'd5;
reg [3:0] FINISH_dec=4'd6;
reg [3:0] RESET = 4'd7;


encryption encryptAES(
	.inputData				(encDataIn),				
	.key					(enckey),					
	.clock					(clock),						
	.inputsLoadedFlag		(encFlag),	
	.resetModule			(rst),		
	.outputData				(out), 			
	.dataEncryptedFlag	    (finishflag)				
);

decryption decryptAES(
	.inputData				(decDataIn),				
	.key					(deckey),					
	.clock					(clock),						
	.inputsLoadedFlag		(decFlag),	
	.resetModule			(rst),		
	.outputData				(out2),				
	.dataDecryptedFlag	    (finishflag2)				
);

initial begin
    state=4'd0;
    enckey=0;
    encDataIn=0;
    encFlag=0;    
    deckey=0;
    decDataIn=0;
    decFlag=0;
   
end


always @(posedge clock ) begin
    rst=resetAES;
    if (enable==1) begin
        case (state)

            IDLE: begin
            rst = 0;
            encFlag = 0;
            decFlag= 0;
            if (ED == 1) state = ENC;
            if (ED == 0) state = DEC; 
            if (rst == 1) state = RESET;
            end
            
            ENC: begin
                encDataIn=data_in;
                enckey = key;
                encFlag = 1 ;
                
                state = WAITFORENC;
            end
            
            WAITFORENC: begin
                if (finishflag) state= FINISH_enc;
                else state=WAITFORENC;
            end

            DEC:begin
                decDataIn= data_in;
                deckey= key;
                decFlag=1 ;
                state=WAITFORDEC;
            end

            WAITFORDEC: begin
                if (finishflag2) state= FINISH_dec;
                else state=WAITFORDEC;
            end
            
            
            FINISH_enc: begin
                data_out = out;
                completedFlag = 1 ;
                state = RESET;
            end
            
            
            FINISH_dec: begin
                data_out= out2;
                completedFlag = 1 ;
                state = RESET;
            end
            RESET: begin
                
                rst=1;

                enckey=0;
                encDataIn=0;
                encFlag=0;    
                deckey=0;
                decDataIn=0;
                decFlag=0;
                state=IDLE;
            end

            default:begin
            state= IDLE;
            end
            
        endcase

    end


end

endmodule


