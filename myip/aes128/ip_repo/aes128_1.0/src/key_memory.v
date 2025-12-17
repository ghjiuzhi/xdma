module key_memory(
    //exterior
    input                 clk                ,
    input                 rst_n              ,
    input                 start_i            ,
    input       [127:0]   key_in             ,
    input       [3:0]     rcon               ,
    output      [127:0]   key_rcon           ,  
    output reg            allkey_done        
);


    reg [3:0]   cnt;
    wire        add_cnt;
    wire        end_cnt;

    //interior
    reg  [127:0]   key_extend_data    ;
    reg            key_extend_en        ;
    wire [3:0]     rd_num             ;
    wire [127:0]   key_extend_in      ;
    wire           key_extend_ready   ;
    key_extend u_key_extend(
        .clk      (clk                  ) ,
        .rst_n    (rst_n                ) ,
        .start_i  (key_extend_en        ) ,
        .rd_num   (rd_num               ) ,
        .key_in   (key_extend_data      ) ,
        .ready_o  (key_extend_ready     ) ,
        .key_out  (key_extend_in        ) 
    );

    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        cnt <= 0;
      end
      else if(add_cnt)begin
        if(end_cnt) begin
          cnt <= 0;
        end
        else begin
          cnt <= cnt+1'b1;
        end
      end
    end
    assign add_cnt= key_extend_ready;
    assign end_cnt= add_cnt && cnt== ( rcon-1 );  //0-10

    assign rd_num = cnt;
    //key_extend_i
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        key_extend_data <= 0;
      end
      else if(add_cnt) begin
        key_extend_data <= key_extend_in ;
      end
      else if(cnt==0) begin
        key_extend_data <= key_in;
      end
    end
    //key_strat_i 
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        key_extend_en <= 1'b0;
      end
      else if( start_i && rcon ) begin
        key_extend_en <= 1'b1 ;
      end
      else if( end_cnt==0 )begin
        key_extend_en <= add_cnt ;
      end
      else begin
        key_extend_en <= 1'b0;
      end
    end

/************************ exterior  **********************/
    //allkey_done
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        allkey_done <= 0; 
      end
      else  if(rcon==0)  begin
        allkey_done <= start_i ;
      end
      else  if(end_cnt)  begin
        allkey_done <= 1'b1 ;
      end
      else begin
        allkey_done <= 0; 
      end
    end
    assign key_rcon = (rcon==0) ? key_in : key_extend_in ;
   /* always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        key_rcon <= 0; 
      end
      else if(rcon==0)begin
          key_rcon <= key_in ;
      end
      else if(end_cnt)begin
        key_rcon <= key_extend_in ;
      end
    end */

endmodule

