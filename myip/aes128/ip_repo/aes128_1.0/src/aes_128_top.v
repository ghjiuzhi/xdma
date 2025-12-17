module  aes_128_top(
	input			clk, 
    input           rst_n,
    //input           start_i,
    //input           decrypt_i,
	//input [127:0]	data_i,
    //input           key_in, 
	//output  [63:0]  dout0,
    //output  [63:0]  dout1,
    output          ready 
);
reg [63:0] dout0;
reg [63:0] dout1;
reg [127:0]     data0=128'h0E0D0C0B0A0908070605040302017412;
reg [127:0]     data1=128'hce3eb4552d43849f75004a9c7a143949;
reg [127:0]     key = 128'h10a58869d74be5a374cf867cfb473859;
reg [11:0]       cnt;

wire [127:0]     data_o;
wire             ready_o;
reg  [127:0]     outputdata;
reg              outputdata_vld;



reg             start_i     ;
reg             decrypt_i   ;
reg  [127:0]    data_i      ;

aes_top u_aes_aes_top(
	.clk       (clk          )  , 
    .rst_n     (rst_n        )  ,
    .start_i   (start_i      )  ,
    .decrypt   (decrypt_i    )  ,
	.data_in   (data_i       )  ,
    .key_in    (key          )  , 
	.data_o    (data_o       )  ,
    .ready_o   (ready_o      )      
);


always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
      cnt <= 0;
    end
    else if(cnt == 2500) begin
        cnt <= 0;
    end
    else  begin
      cnt <= cnt + 1'b1;
    end
end


always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
      start_i <= 0;
      decrypt_i <= 0;
      data_i <= 0;
    end
    else if(cnt==3) begin
        data_i <= data0;
        decrypt_i <= (cnt>=1250);
        start_i <= (cnt==5) | (cnt==1255);
    end
    else if(cnt==1253) begin
        data_i <= data1 ;
        decrypt_i <= (cnt>=1250);
        start_i <= (cnt==5) | (cnt==1255);
    end
    else   begin
        decrypt_i <= (cnt>=1250);
        start_i <= (cnt==5) | (cnt==1255);
    end
end

always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
      outputdata <= 0;
      outputdata_vld <= 0;
    end
    else  begin
      outputdata <= data_o;
      outputdata_vld <= ready_o;
    end
end
always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
      dout0 <= 0;
      dout1 <= 0;
    end
    else  begin
       dout0 <= outputdata[63:0];
       dout1 <= outputdata[127:64];
    end
end

assign ready =outputdata_vld;

endmodule 