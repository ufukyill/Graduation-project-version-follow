/* 
we are going to recieve 9 distinct data packages : [31:0] dataholder[0:8]
the last data package(dataholder[8]) going to be 32'h....0000
    [31:28]= 0 OR 1, which indicates first quad (dataholder[0:3]) is key or data
    ([31:28]= 0 means key, [31:28]= 1 means data)
    hence second quad (dataholder[4:7]) going to be determined too.
    [27:24]=4'hE means enable
    [23:16]=8'hEC means encryption, [23:16]=8'hDE means decryption 
    [15:0]=16'h0 

*/
module AES_top_wb #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i, 
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i, //MSB FIRST   
    input [31:0] wbs_adr_i, 
    output wbs_ack_o,
    output [31:0] wbs_dat_o

    //Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq 
);

//Signals
wire completedFlag;
wire [127:0] aes_out;
reg [127:0] key_in;
reg [127:0] text;
reg [31:0] dataholder[0:8];
reg en;
reg EncDec;//EncDec=1 for encryption, dec otherwise 
reg rst;
reg wbsack;
reg [31:0] wbsdataout;

reg [3:0] index;//counter index for collecting
reg [2:0] idrive;//counter index for drive control
reg [3:0] i ;


//fsm states
reg [2:0] state;
reg [2:0] IDLE=3'd0;                   
reg [2:0] COLLECT_DATA=3'd1;
reg [2:0] CONTROL=3'd2;
reg [2:0] WAITFORPROCESS=3'd3;
reg [2:0] DRIVETOBUS=3'd4;
reg [2:0] DRIVECONTROL=3'd5;
reg [2:0] TERMINATE=3'd6;
reg [2:0] RESET=3'd7;

assign wbs_ack_o = wbsack;
assign wbs_dat_o=wbsdataout;

//module instantiation
AES_top Aescore(
    .clock(wb_clk_i),
    .key(key_in),
    .data_in(text),
    .enable(en),
    .ED(EncDec),
    .resetAES(rst),
    .completedFlag(completedFlag),
    .data_out(aes_out)
);

//variable initialization
initial begin
    text=0;
    key_in=0;
    index=0;
    idrive=0;
    en=1'b0;
    dataholder[8][31:0]=32'b0;
    dataholder[7][31:0]=32'b0;
    dataholder[6][31:0]=32'b0;
    dataholder[5][31:0]=32'b0;
    dataholder[4][31:0]=32'b0;
    dataholder[3][31:0]=32'b0;
    dataholder[2][31:0]=32'b0;
    dataholder[1][31:0]=32'b0;
    dataholder[0][31:0]=32'b0;

    state=3'd0;
end

always @(negedge wbs_stb_i) begin
    wbsack<=0;
end
always @(posedge wb_clk_i ) begin
    if (wb_rst_i) begin
        wbsack<=0;
    end
end
always @(posedge wb_clk_i ) begin
    

    rst<=wb_rst_i;
   
    if ( wbs_stb_i && wbs_cyc_i &&(wbs_adr_i ==32'h30000000) && (wbs_sel_i == 4'hF) ) begin 
        case (state)
        
            IDLE: begin 
                if (wbs_stb_i) begin
                    wbsack = 1'b1;
                    rst=0;
                    if (wbs_we_i   )  begin
                        wbsack=1'b0;
                        state= COLLECT_DATA;
                    end else if (!wbs_we_i  ) begin 
                        wbsack=1'b0;
                        state= DRIVETOBUS;
                    end else begin
                        state =IDLE;
                    end                    
                end


            end

            CONTROL: begin
                
                if (index<4'd9) begin
                    state=IDLE;
                    wbsack=1'b1;
                end else begin
                    if(dataholder[8][27:24] == 4'hE) begin
                        en=1'b1;
                    end else begin//enable needed
                        state=RESET;
                    end
                    if (en) begin
                        if (dataholder[8][31:28]==4'b0000) begin//first quad of recieved data is key
                            key_in={dataholder[0],dataholder[1],dataholder[2],dataholder[3]};
                            text  ={dataholder[4],dataholder[5],dataholder[6],dataholder[7]};
                            if (dataholder[8][23:16]==8'hEC) EncDec=1'b1;
                            else if (dataholder[8][23:16]==8'hDE) EncDec=1'b0;
                            else state= RESET;
                                
                            
                        end
                        else if (dataholder[8][31:28]==4'b0001) begin//first quad of recieved data is text
                            text={dataholder[0],dataholder[1],dataholder[2],dataholder[3]};
                            key_in  ={dataholder[4],dataholder[5],dataholder[6],dataholder[7]};
                            if (dataholder[8][23:16]==8'hEC) EncDec=1'b1;
                            else if (dataholder[8][23:16]==8'hDE) EncDec=1'b0;
                            else state= RESET;

                        end 
                        else begin//package order could not specified 
                            state= RESET;
                        end

                    end else begin//enable did not recieved
                        state=RESET;
                    end
                    state=WAITFORPROCESS;
                    index=0;
                    wbsack=1'b0;

                end 
            end

            
            COLLECT_DATA: begin //collect data in the holders
                

                 dataholder[index]<=wbs_dat_i;
                index=index+1'b1;
                state=CONTROL;
            end

            WAITFORPROCESS: begin
              
                
                if (completedFlag) begin
                    state= IDLE;
                    wbsack=1'b1;              
                end else  begin
                    state = WAITFORPROCESS;
                end

            end

            DRIVETOBUS: begin
                
                wbsdataout <= aes_out[127-(32*idrive) -:32];
                idrive=idrive+1'b1;
                state= DRIVECONTROL;
            end
            DRIVECONTROL: begin
              if (idrive<4) begin
                state=IDLE;
                wbsack=1'b1;      
              end else begin//DRIVING OVER
                idrive=0;
                state=TERMINATE;
            
              end
            end

            TERMINATE : begin//raise ack
                wbsack<=1'b1;
                state = RESET;
            end

            RESET: begin
              
                rst=1;
                

                for (i=0; i<4'd9 ;i=i+1'b1 ) begin
                    dataholder[i]=32'b0;
                end

                text=128'b0;
                key_in=128'b0;
                index=0;
                idrive=0;
                en=1'b0;
                EncDec=1'bz;
                state=3'd0;//idle
            end
            default:begin
            state= IDLE;
            
            end 
        endcase
    
    


    end else if (!wbs_stb_i) begin
        wbsack=0;
        
    end

end
endmodule


