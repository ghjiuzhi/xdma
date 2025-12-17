`timescale 1ns / 1ps

module sbox_word(
	input			    clk, 
    input               rst_n,
    input               start_i,
    input               decrypt_i,
	input       [31:0]	data_i,
	output reg  [31:0]  data_o,
    output reg          ready_o 
//读取S盒数据
    //output reg  [7:0]   addr_s,
   // input       [7:0]   mem_out_s       
);
  
    reg [2:0]   state;
    reg [2:0]   state_next;

	reg [7:0]	byte_0;
    reg [7:0]	byte_1;
    reg [7:0]   byte_2;
    reg [7:0]   byte_3;

    reg [7:0]	dout_0;
    reg [7:0]	dout_1;
    reg [7:0]   dout_2;
    reg [7:0]   dout_3;
	 
	reg [7:0]	 addr_s;
    reg [7:0]    addr_sinv;
	wire [7:0]	 mem_out_s;
    wire [7:0]	 mem_out_sinv;
	 
    memory_S_inv   u_Sinv(.clk(clk),.rst_n(rst_n), .addr(addr_sinv) , .mem_out(mem_out_sinv));
    memory_S   u_S(.clk(clk),.rst_n(rst_n), .addr(addr_s) , .mem_out(mem_out_s));
     
    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            byte_0 <= 0;
            byte_1 <= 0;
            byte_2 <= 0;
            byte_3 <= 0; 
        end
        else begin
            byte_0 <= data_i[7:0];
            byte_1 <= data_i[15:8];
            byte_2 <= data_i[23:16];
            byte_3 <= data_i[31:24];
        end
    end
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
            state_next =1;
        end
        else begin
            state_next=0;
        end
        1: begin
            state_next =2;
        end
        2: begin
            state_next =3;
        end
        3: begin
            state_next =4;
        end
        4: begin
            state_next =5;
        end
        5:begin
            state_next =6;
        end
        6:begin
            state_next =0;
        end
        default:state_next =0;
        endcase
    end

    always @(*) begin
        case (state)
        1: begin
        if(decrypt_i) begin
            addr_sinv=byte_0 ;
            addr_s = 0;
        end
        else begin
            addr_s=byte_0 ;
            addr_sinv =0;
        end
        end
        2: begin
        if(decrypt_i) begin
            addr_sinv=byte_1 ;
            addr_s = 0;
        end
        else begin
            addr_s=byte_1 ;
            addr_sinv =0;    
        end
        end
        3: begin
        if(decrypt_i) begin
            addr_sinv=byte_2;
            addr_s = 0;
        end
        else begin
            addr_s=byte_2 ;
            addr_sinv =0;
        end
        end
        4: begin
        if(decrypt_i) begin
            addr_sinv=byte_3 ;
            addr_s = 0;
        end
        else begin
            addr_s=byte_3 ;
            addr_sinv =0;
        end
        end
        default: begin
            addr_s=0 ;
            addr_sinv =0;
        end
        endcase
    end

    always @(*) begin
        case (state)
        2: begin
        if(decrypt_i) begin
            dout_0=mem_out_sinv ;
            dout_3 =data_o[31:24]; 
            dout_2 =data_o[23:16]; 
            dout_1 =data_o[15:8] ;
        end
        else begin
            dout_0=mem_out_s ; 
            dout_3 =data_o[31:24]; 
            dout_2 =data_o[23:16]; 
            dout_1 =data_o[15:8] ;
        end
        end
        3: begin
        if(decrypt_i) begin
            dout_1=mem_out_sinv ;
            dout_3 =data_o[31:24]; 
            dout_2 =data_o[23:16];
            dout_0 =data_o[7:0]  ;
        end
        else begin
            dout_1=mem_out_s ; 
            dout_3 =data_o[31:24]; 
            dout_2 =data_o[23:16];
            dout_0 =data_o[7:0]  ;    
        end
        end
        4: begin
        if(decrypt_i) begin
            dout_2=mem_out_sinv ;
            dout_3 =data_o[31:24];
            dout_1 =data_o[15:8] ;
            dout_0 =data_o[7:0]  ;
        end
        else begin
            dout_2=mem_out_s ;
            dout_3 =data_o[31:24]; 
            dout_1 =data_o[15:8] ;
            dout_0 =data_o[7:0]  ;
        end
        end
        5: begin
        if(decrypt_i) begin
            dout_3=mem_out_sinv ; 
            dout_2 =data_o[23:16]; 
            dout_1 =data_o[15:8] ;
            dout_0 =data_o[7:0]  ;
        end
        else begin
            dout_3=mem_out_s ; 
            dout_2 =data_o[23:16]; 
            dout_1 =data_o[15:8] ;
            dout_0 =data_o[7:0]  ;
        end
        end
        default: begin
            dout_3 =data_o[31:24]; 
            dout_2 =data_o[23:16]; 
            dout_1 =data_o[15:8] ;
            dout_0 =data_o[7:0]  ;
        end
        endcase
    end

    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            data_o <= 0;
        end
        else  begin
            data_o  <= {dout_3,dout_2,dout_1,dout_0}; 
        end
    end

    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            ready_o <= 0;
        end
        else   begin
            ready_o <= state==6;
        end
    end

endmodule