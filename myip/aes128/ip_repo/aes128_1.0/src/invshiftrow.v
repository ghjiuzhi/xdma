/*
输入数据
din[31:0]	    din[63:32]	    din[95:64]	    din[127:96]

a[7:0]	        b[7:0]	        c[7:0]	        d[7:0]
a[15:8]	        b[15:8]	        c[15:8]	        d[15:8]
a[23:16]	    b[23:16]	    c[23:16]	    d[23:16]
a[31:24]	    b[31:24]	    c[31:24]	    d[31:24]

正向行移位			
dout[31:0]	    dout[63:32]	    dout[95:64]	    dout[127:96]

a[7:0]	        b[7:0]	        c[7:0]	        d[7:0]
b[15:8]	        c[15:8] 	    d[15:8]	        a[15:8]
c[23:16]	    d[23:16]	    a[23:16]	    b[23:16]
d[31:24]	    a[31:24]	    b[31:24]	    c[31:24]

逆向行移位	    		        
dout[31:0]	    dout[63:32]	    dout[95:64]	    dout[127:96]

a[7:0]	        b[7:0]	        c[7:0]	        d[7:0]
d[15:8]	        a[15:8] 	    b[15:8]	        c[15:8]
c[23:16]	    d[23:16]	    a[23:16]	    b[23:16]
b[31:24]	    c[31:24]	    d[31:24]	    a[31:24]

*/

module invshiftrow(
	input			 clk, 
    input            rst_n,
    input            start_i,
    input            decrypt_i,
	input [127:0]	 data_i,
	output reg[127:0]data_o,
    output reg       ready_o 
);


reg [31:0] a;
reg [31:0] b;
reg [31:0] c;
reg [31:0] d;
wire [31:0] a_r;
wire [31:0] b_r;
wire [31:0] c_r;
wire [31:0] d_r;
//reg [127:0] data_o_r;
reg       ready_r0;
reg       ready_r1;

always@(posedge clk  or negedge rst_n) begin
    if(!rst_n) begin
        a <= 0;
        b <= 0;
        c <= 0;
        d <= 0;
    end
    else if(start_i) begin
        a <= data_i[31:0];
        b <= data_i[63:32];
        c <= data_i[95:64];
        d <= data_i[127:96];
    end
end
assign a_r=decrypt_i ? {a[31:24],b[23:16],c[15:8],d[7:0]} : {a[31:24],d[23:16],c[15:8],b[7:0]};
assign b_r=decrypt_i ? {b[31:24],c[23:16],d[15:8],a[7:0]} : {b[31:24],a[23:16],d[15:8],c[7:0]};
assign c_r=decrypt_i ? {c[31:24],d[23:16],a[15:8],b[7:0]} : {c[31:24],b[23:16],a[15:8],d[7:0]};
assign d_r=decrypt_i ? {d[31:24],a[23:16],b[15:8],c[7:0]} : {d[31:24],c[23:16],b[15:8],a[7:0]};
always@(posedge clk  or negedge rst_n) begin
    if(!rst_n) begin
       // data_o_r <= 0;
        data_o <= 0;
    end
    else  begin
        data_o <= {d_r,c_r,b_r,a_r};
        //data_o <= data_o_r;
    end
end
always@(posedge clk  or negedge rst_n) begin
    if(!rst_n) begin
        ready_o <= 0;
        ready_r0 <= 0;                
        ready_r1 <= 0;    
    end
    else  begin
        ready_r0 <= start_i;
        ready_r1 <= ready_r0;                
        ready_o <= ready_r1;
    end
end

endmodule