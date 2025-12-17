/*
//datain
[7:0]       [15:8]      [23:16]     [31:24]
[39:32]     [47:40]     [55:48]     [63:56]
[71:64]     [79:72]     [87:80]     [95:88]
[103:96]    [111:104]   [119:112]   [127:120]

//列混合
02 03 01 01         
01 02 03 01         
01 01 02 03         
03 01 01 02         


//列混合逆运算
0e 0b 0d 09
09 0e 0b 0d
0d 09 0e 0b
0b 0d 09 0e

GF(2^8)上运算 加法运算即异或运算
*/

module  mixcolum(
  input			      clk, 
  input               rst_n,
  input               start_i,
  input               decrypt_i,
  input [127:0]	      data_i,

  output reg[127:0]   data_o,
  output reg          ready_o 
); 

//reg  [7:0] memory_r[15:0] ;
//reg  [7:0] memory[15:0] ;
reg  [2:0] cnt;
wire       add_cnt;
wire       end_cnt;
reg        flag;
integer i=0 ;

// 
reg  [7:0] a;
reg  [7:0] b;
reg  [7:0] c;
reg  [7:0] d;
wire [7:0] b0;
wire [7:0] b1;
wire [7:0] b2;
wire [7:0] b3;

function [7:0] mul_02;
  input [7:0] in;
  reg   [7:0] reg_in;
  reg [8:0]  shift_in;
  begin
    reg_in = in;
    shift_in= ( reg_in<<1 );
    mul_02= shift_in[8] ? shift_in[7:0]^8'h1b : shift_in[7:0] ;
  end
endfunction

function [7:0] mbyte;
  input [7:0] in0,in1,in2,in3;
  reg [7:0] w1,w2,w3,w4,w5,w6,w7,w8,outx_var;
  begin
    w1 = in0 ^in1;
    w2 = in0 ^in2;
    w3 = in2 ^in3;
    w4 = mul_02(w1);
    w5 = mul_02(w3);
    w6 = w2 ^w4 ^w5;
    w7 = mul_02(w6);
    w8 = mul_02(w7);
    outx_var = in1^w3^w4;
    if(decrypt_i) begin
      mbyte=outx_var^w8;
    end
    else begin
      mbyte=outx_var;
    end
  end
endfunction
/*
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    for(i=0;i<16;i=i+1) begin
        memory[i] <= 0;
    end
  end
  else  if(start_i) begin
    for(i=0;i<16;i=i+1) begin
        memory[i] <= data_i[127-i*8-:8];  
    end
  end
end*/
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    flag <= 0;
  end
  else if(cnt ==4 ) begin
    flag <= 0;
  end
  else  if(start_i) begin
    flag <= 1'b1;
  end
end

always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    cnt <= 0;
  end
  else if(add_cnt) begin
    if(end_cnt) begin
      cnt <= 0;
    end
    else begin
      cnt <= cnt+1'b1;
    end
  end
end
assign add_cnt=flag;
assign end_cnt=add_cnt && cnt==4;


assign b0 = mbyte (a,b,c,d);  
assign b1 = mbyte (b,c,d,a);   
assign b2 = mbyte (c,d,a,b);   
assign b3 = mbyte (d,a,b,c);

always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    /*for(i=0;i<16;i=i+1) begin
        memory_r[i] <= 0;
    end*/
    data_o <= 0;   
  end
  else if(cnt==0)begin
  //第0行
    data_o[127:120] <= b0 ; 
    data_o[119:112] <= b1 ;      
    data_o[111:104] <= b2 ;    
    data_o[103:96]  <= b3 ;
  end
  else if(cnt==1)begin      
    //第1行
    data_o[95:88]  <= b0 ;    
    data_o[87:80]  <= b1 ;      
    data_o[79:72]  <= b2 ;   
    data_o[71:64]  <= b3 ; 
  end
  else if(cnt==2)begin  
    //第2行
    data_o[63:56]  <= b0 ;       
    data_o[55:48]  <= b1 ;         
    data_o[47:40]  <= b2 ;       
    data_o[39:32]  <= b3 ;  
  end
  else if(cnt==3)begin       
    //第3行
    data_o[31:24] <= b0 ;   
    data_o[23:16] <= b1 ;   
    data_o[15:8]  <= b2 ;   
    data_o[7:0]   <= b3 ;   
  end
end
always @(* )  begin
  if(cnt==0)begin
  //第0行
     a = data_i[127:120];  
     b = data_i[119:112];       
     c = data_i[111:104];     
     d = data_i[103:96] ;
  end
  else if(cnt==1)begin      
    //第1行
    a = data_i[95:88] ;   
    b = data_i[87:80] ;     
    c = data_i[79:72] ;  
    d = data_i[71:64] ;
  end
  else if(cnt==2)begin  
    //第2行
    a = data_i[63:56] ;      
    b = data_i[55:48] ;        
    c = data_i[47:40] ;      
    d = data_i[39:32] ; 
  end
  else if(cnt==3)begin       
    //第3行
    a = data_i[31:24] ;    
    b = data_i[23:16] ;    
    c = data_i[15:8]  ;    
    d = data_i[7:0]   ;    
  end
  else begin       
    //第3行
    a = 0 ;    
    b = 0 ;    
    c = 0 ;    
    d = 0 ;    
  end
end



/*
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    data_o <= 0;
  end
  else  begin
    for(i=0;i<16;i=i+1) begin
        data_o[127-i*8-:8] <= memory_r[i] ;
    end
  end
end
*/
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    ready_o <= 0;
  end
  else  begin
    ready_o <= end_cnt ;
  end
end

endmodule


