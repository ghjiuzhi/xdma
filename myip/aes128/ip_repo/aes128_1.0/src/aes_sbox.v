module  aes_sbox(
	input			 clk, 
    input            rst_n,
    input            start_i,
    input            decrypt_i,
	input [127:0]	 data_i,
	output reg[127:0]data_o,
    output reg       ready_o 
);

reg [4:0]     state;
reg [4:0]     next_state;
localparam    STATE0=5'b0000_1 ,
              STATE1=5'b0001_0 ,
              STATE2=5'b0010_0 ,
              STATE3=5'b0100_0 ,
              STATE4=5'b1000_0 ;
wire          s0_s1;
wire          s1_s2;
wire          s2_s3;
wire          s3_s4;
wire          s4_s0;

reg [31:0]    sbox_word;
reg  [127:0]  data_i_var;
reg           work_en;
reg           ready_o_r0;
wire          done;
reg           start;
wire [31:0]   sboxout;
sbox_word u_sbox_word(
  .clk        (clk          ) , 
  .rst_n      (rst_n        ) ,
  .start_i    (work_en      ) ,
  .decrypt_i  (decrypt_i    ) ,
  .data_i     (sbox_word    ) ,
  .data_o     (sboxout      ) ,
  .ready_o    (done         )  
);
//***********************fsm********************************//
always@(posedge clk or negedge rst_n ) begin
    if(!rst_n) begin
      state <= STATE0;
    end
    else  begin
      state <= next_state;
    end
end
always @(*)   begin
  case(state)
  STATE0:begin
    if(s0_s1) begin
      next_state = STATE1;
    end
    else begin
      next_state = STATE0;
    end
  end
  STATE1:begin
    if(s1_s2) begin
      next_state = STATE2;
    end
    else begin
      next_state = STATE1;
    end
  end
  STATE2:begin
    if(s2_s3) begin
      next_state = STATE3;
    end
    else begin
      next_state = STATE2;
    end
  end
  STATE3:begin
    if(s3_s4) begin
      next_state = STATE4;
    end
    else begin
      next_state = STATE3;
    end
  end
  STATE4:begin
    if(s4_s0) begin
      next_state = STATE0;
    end
    else begin
      next_state = STATE4;
    end
  end
  default:next_state =STATE0;
  endcase
end
assign s0_s1= state==STATE0 && (start  ) ;
assign s1_s2= state==STATE1 && (done     ) ;
assign s2_s3= state==STATE2 && (done     ) ;
assign s3_s4= state==STATE3 && (done     ) ;
assign s4_s0= state==STATE4 && (done     ) ;

always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    start <= 0;
  end
  else   begin  //////
    start <= start_i;
  end
end
//
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    data_i_var <= 0;
  end
  else  if(start_i) begin  //////
    data_i_var <= data_i;
  end
end

//sbox_word
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
      sbox_word <= 0;
  end
  else if(s0_s1) begin
    sbox_word <= data_i_var[127:96]; 
  end
  else if(s1_s2) begin
    sbox_word <= data_i_var[95:64];
  end
  else if(s2_s3) begin
    sbox_word <= data_i_var[63:32];
  end
  else if(s3_s4) begin
    sbox_word <= data_i_var[31:0];
  end
end


//   work_en
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    work_en <= 0;
  end
  else if(s0_s1 | s1_s2 | s2_s3 | s3_s4) begin
    work_en <= 1'b1;
  end
  else begin
    work_en <= 0;
  end
end


always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    data_o <= 0;
  end
  else if(s1_s2) begin
    data_o[127:96] <= sboxout; 
  end
  else if(s2_s3) begin
    data_o[95:64] <= sboxout; 
  end
  else if(s3_s4) begin
    data_o[63:32] <= sboxout; 
  end
  else if(s4_s0) begin
    data_o[31:0] <= sboxout; 
  end
end
//ready_o
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    ready_o <= 0;
    ready_o_r0 <=0;
  end
  else  	begin
    ready_o_r0 <= s4_s0 ;
    ready_o <= ready_o_r0;
  end
end

endmodule