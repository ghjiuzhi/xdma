module  aes_top(
	input       		 clk, 
    input                rst_n,
    input                start_i,
    input                decrypt,
	input       [127:0]	 data_in,
    input       [127:0]  key_in,
	output reg  [127:0]  data_o,
    output reg           ready_o 
);
    localparam  IDLE   =4'b0001,
                FIRST  =4'b0010,
                MIDDLE =4'b0100, 
                FINALLY=4'b1000;
    reg  [3:0]  state;
    reg  [3:0]  state_next;
    wire        idle_first     ;
    wire        first_middle   ;
    wire        middle_finally ;
    wire        finally_idle   ;



    reg  [3:0]      cnt;
    wire            add_cnt;
    wire            end_cnt;
    reg             start_in;
    reg             start_en;

   // reg  [127:0]    data_in ; //输入明文或者密钥寄存
    reg             decrypt_i; //加密解密寄存
    wire            midround_done;//状态条件
    reg             first_round; //状态条件
    reg             finally_end; //状态条件



//密钥寄存器组
    reg [127:0]     key_orginal ;
    reg    [3:0]    rcon        ;
    reg             key_en      ;
    wire            key_done    ;
    wire   [127:0]  key_rdata   ;

 //列混合
    reg             mixcolum_en       ;
    wire  [127:0]   mixcolum_data     ;
    wire   [127:0]  mixcolum_dout     ;
    wire            mixcolum_ready    ;
//行移位   
    reg             invshiftrow_en    ;
    reg   [127:0]   invshiftrow_data  ;
    wire   [127:0]  invshiftrow_dout  ;
    wire            invshiftrow_ready ;	
//字节代换	
    wire            sbox_ready        ;
    wire  [127:0]   sbox_dout         ;
    reg             sbox_en           ;
    wire  [127:0]   sbox_data         ;
//轮密钥加
    reg     addround_flag2;
    reg     addround_flag1;
    reg     addround_en1 ;
    wire            addround_en       ;
    reg   [127:0]   addround_data     ;
    wire  [127:0]   addround_key      ;
    wire  [127:0]   addround_dout     ;
    wire            addround_ready    ;

//******************************************************************/

    //decrypt  打拍
    always @(posedge clk or negedge rst_n)  begin
        if(!rst_n)  begin
        decrypt_i <= 0;
        start_in <= 0;
        start_en <= 0;
        end
        else   begin
        decrypt_i <= decrypt;
        start_in <= start_i;
        start_en <= ~start_in && start_i;
        end
    end
    /*
    always @(posedge clk or negedge rst_n)  begin
        if(!rst_n)  begin
        data_in <= 0;
        end
        else   begin
        data_in <= data_i;
        end
    end*/


    //中间9轮计数
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        cnt <= 0;
      end
      else if(add_cnt) begin
        if(end_cnt) begin
           cnt <= 0; 
        end
        else begin
          cnt <= cnt + 1'b1 ;
        end
      end
    end

    assign add_cnt = (state==MIDDLE) && midround_done ;
    assign end_cnt = add_cnt && (cnt==9-1); 
    assign midround_done = (decrypt_i ? mixcolum_ready : addround_ready);

    always@(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        state <= IDLE;
      end
      else begin
        state <= state_next;
      end
    end
    always @(*) begin
        case (state)
         IDLE  :begin
             if(idle_first) begin
                state_next = FIRST;
             end
             else begin
                state_next = IDLE;
             end
         end 
        FIRST   :begin
             if(first_middle) begin
                state_next = MIDDLE;
             end
             else begin
                state_next = FIRST;
             end
         end
        MIDDLE  :begin
             if(middle_finally) begin
                state_next = FINALLY;
             end
             else begin
                state_next = MIDDLE;
             end
         end
        FINALLY :begin
             if(finally_idle) begin
                state_next = IDLE;
             end
             else begin
                state_next = FINALLY;
             end
         end     
        default:state_next = IDLE;
        endcase
    end
    assign idle_first     = state==IDLE    && (start_en      ) ;   //IDLE初始状态  
    assign first_middle   = state==FIRST   && (first_round  ) ;  //第一次轮密钥加  
    assign middle_finally = state==MIDDLE  && (end_cnt      ) ;       //中间循环9次
    assign finally_idle   = state==FINALLY && (finally_end  ) ;              //最后一次循环


    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            first_round <= 0;
        end
        else if(state==FIRST) begin
            first_round <= addround_ready ;
        end
        else begin
           first_round <= 0; 
        end
    end
    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            finally_end <= 0;
        end
        else if(state==FINALLY) begin
            finally_end <=  addround_ready ;
        end
        else begin
            finally_end <= 0;
        end
    end





    key_memory u_key_memory(
        //exterior
        .clk            (clk         ),
        .rst_n          (rst_n       ),
        .start_i        (key_en      ),
        .key_in         (key_orginal ),
        .rcon           (rcon        ),
        .key_rcon       (key_rdata   ),  
        .allkey_done    (key_done    )
    );
    
    //key_orginal  
    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            key_orginal <= 0;
        end
        else if(start_en) begin
            key_orginal <= key_in ;
        end
    end
    //rcon
    always@(posedge clk  or negedge rst_n) begin
        if(!rst_n) begin
            rcon <= 0;
        end
        else if( ~decrypt_i ) begin
            case(state)
                IDLE : rcon <= 0;
                FIRST: rcon <= 0; //正向加密不需要等所有密钥扩展完，即可加密；
                MIDDLE:  begin   
                    case(cnt)             //逆向加密 必须要等所有密钥扩展完，才能加密  
                        0: rcon <= 1;
                        1: rcon <= 2;
                        2: rcon <= 3;
                        3: rcon <= 4;
                        4: rcon <= 5;
                        5: rcon <= 6;
                        6: rcon <= 7;
                        7: rcon <= 8;
                        8: rcon <= 9; 
                    default:rcon <= 0;
                    endcase
                end
                FINALLY : rcon <= 10; 
                default:;
            endcase
        end
        else if( decrypt_i ) begin
            case(state)
                IDLE : rcon <= 10;
                FIRST: rcon <= 10; //正向加密不需要等所有密钥扩展完，即可加密；
                MIDDLE:  begin   
                    case(cnt)             //逆向加密 必须要等所有密钥扩展完，才能加密  
                        0: rcon <= 9;
                        1: rcon <= 8;
                        2: rcon <= 7;
                        3: rcon <= 6;
                        4: rcon <= 5;
                        5: rcon <= 4;
                        6: rcon <= 3;
                        7: rcon <= 2;
                        8: rcon <= 1; 
                    default:rcon <= 0;
                    endcase
                end
                FINALLY : rcon <= 0; 
                default:;
            endcase 
        end
    end
    //key_en 需在字节代换后，开始计算密钥
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        key_en <= 0;
      end
      else  begin
        key_en <= sbox_ready | start_en;    
      end
    end



    addroundkey u_add(              //轮密钥加
    	.clk     (clk           ) , 
        .rst_n   (rst_n         ) ,
        .start_i (addround_en   ) ,
    	.data    (addround_data ) ,
        .key     (addround_key  ) ,

    	.data_o  (addround_dout ) ,
        .ready_o (addround_ready)  
    );
    //轮密钥加 循环条件转换
    assign addround_key = key_rdata ;
    always @(posedge clk or negedge rst_n)  begin
       if(!rst_n)  begin
         addround_en1 <= 0;
         addround_data <= 0;
        // addround_key <= 0;
       end
       else if(state==MIDDLE )begin
          if(~decrypt_i) begin
              addround_en1 <=   mixcolum_ready ;
              addround_data <= mixcolum_dout;
  
              //addround_key <= key_rdata;
          end
          else begin
              addround_data <= sbox_dout  ;
              addround_en1   <= sbox_ready ;
              
              //addround_key <= key_rdata;
          end
       end
       else if(state==FINALLY )begin
          if(~decrypt_i) begin
              addround_en1 <=   invshiftrow_ready  ;
              addround_data <= invshiftrow_dout  ;
  
             // addround_key <= key_rdata;
          end
          else begin
              addround_data <= sbox_dout  ;
              addround_en1   <= sbox_ready ;
              
              //addround_key <= key_rdata;
          end
       end
       else  begin
          if(~decrypt_i) begin
              addround_en1 <= start_en;
              addround_data <= data_in;
              //addround_key <= key_rdata;
          end
          else begin
              addround_en1 <= start_en;
              addround_data <= data_in;
              //addround_key <= key_rdata;
          end
       end
    end
    //轮密钥加 ，需在一轮循环完 和 密钥扩展完 同时完成条件下
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        addround_flag1 <= 0;
      end
      else if(addround_en) begin
         addround_flag1 <= 0;
      end
      else if(addround_en1) begin
         addround_flag1 <= 1'b1;
      end
    end
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
        addround_flag2 <= 0;
      end
      else if(addround_en) begin
         addround_flag2 <= 0;
      end
      else if(key_done) begin
         addround_flag2 <= 1'b1;
      end
    end
    assign addround_en=addround_flag2 & addround_flag1;



    aes_sbox  u_aes_sbox(     //字节代换
    	.clk       (clk                 ), 
        .rst_n     (rst_n               ),
        .start_i   (sbox_en && ~finally_end           ),
        .decrypt_i (decrypt_i           ),
    	.data_i    (sbox_data           ),
    	.data_o    (sbox_dout           ),
        .ready_o   (sbox_ready          )    
    );
    assign sbox_data= decrypt_i ? invshiftrow_dout : addround_dout;
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
            sbox_en   <= 0;
           // sbox_data <= 0;
      end
      else if( ~decrypt_i )begin
            sbox_en   <= addround_ready ;
           // sbox_data <= addround_dout;
      end
      else if(decrypt_i) begin
            sbox_en   <= invshiftrow_ready   ;
            //sbox_data <= invshiftrow_dout;
      end
    end


    invshiftrow  u_invshiftrow(          //行移位
    	.clk        (clk                ), 
        .rst_n      (rst_n              ),
        .start_i    (invshiftrow_en     ),
        .decrypt_i  (decrypt_i          ),
    	.data_i     (invshiftrow_data   ),
    	.data_o     (invshiftrow_dout   ),
        .ready_o    (invshiftrow_ready  ) 
    );

    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
            invshiftrow_en   <= 0;
            invshiftrow_data <= 0;
      end
      else if( ~decrypt_i )begin
            invshiftrow_en   <= sbox_ready ;
            invshiftrow_data <= sbox_dout ;
      end
      else if(decrypt_i) begin
          if(state==FIRST ) begin
            invshiftrow_en   <= addround_ready  ;
            invshiftrow_data <= addround_dout  ;
          end
          else if(state==MIDDLE ||state==FINALLY) begin
            invshiftrow_en   <= mixcolum_ready  ;
            invshiftrow_data <= mixcolum_dout  ;
          end
      end
    end


    mixcolum u_mixcolum(        //列混合
    	.clk       (clk                 ), 
        .rst_n     (rst_n               ),
        .start_i   (mixcolum_en         ),
        .decrypt_i (decrypt_i           ),
    	.data_i    (mixcolum_data       ),

    	.data_o    (mixcolum_dout       ),
        .ready_o   (mixcolum_ready      )     
    ); 
    assign mixcolum_data = decrypt_i ? addround_dout : invshiftrow_dout;
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
            mixcolum_en   <= 0;
           // mixcolum_data <= 0;
      end
      else if( ~decrypt_i && state==MIDDLE )begin
            mixcolum_en   <= invshiftrow_ready;
            //mixcolum_data <= invshiftrow_dout ;
      end
      else if(decrypt_i && state==MIDDLE ) begin
            mixcolum_en   <= addround_ready;
           // mixcolum_data <= addround_dout ;
      end
    end



    //data_o,
    //ready_o 
    always @(posedge clk or negedge rst_n)  begin
      if(!rst_n)  begin
            data_o  <= 0;
            ready_o <= 0;
      end
      else if(finally_end) begin
            data_o  <= addround_dout ;
            ready_o <= finally_end;
      end
      else begin
          ready_o <= 0;
      end
    end


endmodule 