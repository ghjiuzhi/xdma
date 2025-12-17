 /*
 1.若i不是4的倍数，那么第i列如下计算：
  w[i] = w[i-4] ^ w[i-1] ;
2.若i是4的倍数，那么第i列如下计算：
 	w[i] = w[i-4] ^ g w[i-1] ;
    g函数由字循环、字节代换和轮常量异或三部分组成，这三部分的作用分别如下：
    （1） 字循环:将1个字中的4个字节循环左移1个字节；
    （2） 字节代换:对字循环的结果使用S盒（参照图1）进行字节代换；
    （3） 轮常量异或:对前两步的结果同轮常量Rcon[j]（其值见表5）进行异或，其中j代表轮数。
    casex (x)
        第 0次: rcon = 8'h01;
        第 1次: rcon = 8'h02;
        第 2次: rcon = 8'h04;
        第 3次: rcon = 8'h08;
        第 4次: rcon = 8'h10;
        第 5次: rcon = 8'h20;
        第 6次: rcon = 8'h40;
        第 7次: rcon = 8'h80;
        第 8次: rcon = 8'h1b;
        第 9次: rcon = 8'h36;
*/
module key_extend(
    input               clk ,
    input               rst_n,
    input               start_i,
    input  [3:0]        rd_num,
    input  [127:0]      key_in,

    output reg          ready_o,
    output reg[127:0]   key_out

);


reg [3:0]   state;
reg [3:0]   state_next;
reg [7:0]   rcon;
reg [31:0]  w0;
reg [31:0]  w1;
reg [31:0]  w2;
reg [31:0]  w3;
wire [31:0]  wreg0;
wire [31:0]  wreg1;
wire [31:0]  wreg2;
wire [31:0]  wreg3;
reg [31:0]  shift_wreg;
wire[31:0]  norshift_wreg;
reg [7:0]  addr;
wire [7:0] mem_out;
reg [7:0] a;
reg [7:0] b;
reg [7:0] c;
reg [7:0] d;
reg [23:0] zero=24'b0;
always @(   rd_num  ) begin
    case(rd_num)  
        0:  rcon = 8'h01;
        1:  rcon = 8'h02;
        2:  rcon = 8'h04;
        3:  rcon = 8'h08;
        4:  rcon = 8'h10;
        5:  rcon = 8'h20;
        6:  rcon = 8'h40;
        7:  rcon = 8'h80;
        8:  rcon = 8'h1b;
        9:  rcon = 8'h36; 
        default :rcon =0;
    endcase
end
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    w0 <= 0;
    w1 <= 0;
    w2 <= 0;
    w3 <= 0;
  end
  else begin
    w3 <= key_in[31:0];  
    w2 <= key_in[63:32]; 
    w1 <= key_in[95:64]; 
    w0 <= key_in[127:96]; 
  end
end
memory_S   u_S(.clk(clk), .rst_n(rst_n),.addr(addr) , .mem_out(mem_out));
//S盒转换
always@(posedge clk  or negedge rst_n) begin
    if(!rst_n) begin
        state <= 0;
    end
    else  begin
        state  <= state_next; 
    end
end
always @(*) begin
    case (state)
    0: 
    if(start_i) begin
        state_next = 1;
    end
    else begin
        state_next = 0;
    end
    1: begin
        state_next = 2;
    end
    2: begin
        state_next = 3;
    end
    3: begin
        state_next = 4;
    end
    4: begin
        state_next = 5;
    end
    5:begin
        state_next =6;
    end
    6:  begin
        state_next = 7;
    end
    7:  begin
        state_next = 0;
    end
    default:state_next = 0;
    endcase
end
always @(*) begin
    case (state)
    1: begin
        addr=w3[7:0] ;
    end
    2: begin
        addr=w3[15:8] ;
    end
    3: begin
        addr=w3[23:16] ;
    end
    4: begin
        addr=w3[31:24] ;
    end
    default:begin
        addr= 0;
    end     
    endcase
end
always @(*) begin
    case (state)
    2: begin
        a=mem_out  ;
        d= shift_wreg[7:0];
        b= shift_wreg[23:16];  
        c= shift_wreg[31:24]; 
    end
    3: begin
        d= shift_wreg[7:0];
        a= shift_wreg[15:8]; 
        c= shift_wreg[31:24];             
        b=mem_out  ;
    end
    4: begin
        d= shift_wreg[7:0];
        a= shift_wreg[15:8];
        b= shift_wreg[23:16];  
        c=mem_out  ;
    end
    5: begin
        a= shift_wreg[15:8];
        b= shift_wreg[23:16];  
        c= shift_wreg[31:24]; 
        d=mem_out  ;
    end
    default:begin
        d= shift_wreg[7:0];
        a= shift_wreg[15:8];
        b= shift_wreg[23:16];  
        c= shift_wreg[31:24]; 
    end     
    endcase
end
//字节移位
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    shift_wreg <= 0;
  end
  else begin    
    shift_wreg <={c,b,a,d};
  end
end
//异或常轮量
assign   norshift_wreg = shift_wreg ^ {rcon,zero} ;
assign   wreg0 = w0 ^ norshift_wreg;
assign   wreg1 = w1 ^ wreg0;
assign   wreg2 = w2 ^ wreg1;
assign   wreg3 = w3 ^ wreg2;  
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    key_out <= 0;
  end
  else if(state==7) begin
    key_out <= {wreg0,wreg1,wreg2,wreg3};
  end
end
always @(posedge clk or negedge rst_n)  begin
  if(!rst_n)  begin
    ready_o <= 0;
  end
  else begin
    ready_o <= state==7;
  end
end

endmodule

