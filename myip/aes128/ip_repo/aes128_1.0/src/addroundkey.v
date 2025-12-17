module  addroundkey(
	input			     clk, 
    input                rst_n,
    input                start_i,
	input       [127:0]	data,
    input       [127:0]  key,
	output      [127:0]  data_o,
    output reg           ready_o 
);

    //wire  [127:0] datakey;
    assign data_o = data ^ key ;
    /*always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            data_o <= 0;
        end
        else if(start_i) begin
            data_o <= datakey ;
        end
    end*/
    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            ready_o <= 0;
        end
        else   begin
            ready_o <= start_i ;
        end
    end

endmodule
