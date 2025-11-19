`timescale 1ns / 1ps
`include "user_parameter.vh"
module mem_rw_test#(
	parameter	MAXI_ADDR_WIDTH = 32	,
	parameter	MAXI_DATA_WIDTH = 32
)(
	input												i_ddr4_user_clk				,
	input												i_ddr4_user_rst				,
	input												i_ddr4_calib_ok				,	
	input												i_ddr4_test_boot			,	
	output												o_ddr4_test_finish			,
	output	reg			[31:00]							o_error_cnt					,
	output 			 	[1:0]		    				ddr4_test_maxi_awid			,
	output 			 	[MAXI_ADDR_WIDTH-1:0]			ddr4_test_maxi_awaddr		,        
	output 			 	[7:0]							ddr4_test_maxi_awlen		,        
	output 			 	[2:0] 							ddr4_test_maxi_awsize		,        
	output 			 	[1:0] 							ddr4_test_maxi_awburst		,        
	output 			 	 								ddr4_test_maxi_awlock		,        
	output 			 	[3:0] 							ddr4_test_maxi_awcache		,        
	output 			 	[2:0] 							ddr4_test_maxi_awprot		,        
	output 			 	[3:0] 							ddr4_test_maxi_awqos		,        
	output 			 	 								ddr4_test_maxi_awvalid		,        
	input			 	 								ddr4_test_maxi_awready		,        
	output  		 	[MAXI_DATA_WIDTH-1:0]			ddr4_test_maxi_wdata		,        
	output  		 	[MAXI_DATA_WIDTH/8-1:0]			ddr4_test_maxi_wstrb		,        
	output  		  									ddr4_test_maxi_wlast		, 
	output  		  									ddr4_test_maxi_wvalid		,        
	input   		  									ddr4_test_maxi_wready		,       
	input   		 	[1:0] 							ddr4_test_maxi_bresp		,        
	input   		  									ddr4_test_maxi_bvalid		,        
	output  		  									ddr4_test_maxi_bready		,	
	output  		 	[MAXI_ADDR_WIDTH-1:0]			ddr4_test_maxi_araddr		,	
	output  		 	[7:0] 							ddr4_test_maxi_arlen		,
	output  		 	[2:0] 							ddr4_test_maxi_arsize		,
	output  		 	[1:0] 							ddr4_test_maxi_arburst		,
	output  		 	 								ddr4_test_maxi_arlock		, 
	output  		 	[3:0] 							ddr4_test_maxi_arcache		,
	output  		 	[2:0] 							ddr4_test_maxi_arprot		,
	output  		 	[3:0] 							ddr4_test_maxi_arqos		,   
	output  		 	 								ddr4_test_maxi_arvalid		,
	input   		 	 								ddr4_test_maxi_arready		,
	input   		 	[MAXI_DATA_WIDTH-1:0]			ddr4_test_maxi_rdata		,
	input   		 	[1:0] 							ddr4_test_maxi_rresp		,
	input   		  									ddr4_test_maxi_rlast		,
	input   		  									ddr4_test_maxi_rvalid		,  
	output  		  									ddr4_test_maxi_rready					
);
/////////////////////////////////////////////////////////////////////
//	 parameter 
/////////////////////////////////////////////////////////////////////	
	localparam	MAXI_MAX_BURST_LEN = 16'd128;	
	localparam	DDR4_RW_LENGTH = 16'd128;	
	localparam	INIT_DELAY_NUM = 8'd200;	
`ifdef	SIM
	localparam	MEM_TOTAL_SIZE = 32'h0000_7E00;
`else 
	localparam	MEM_TOTAL_SIZE = 33'hFFFF_FE00;
`endif

	
	localparam	S_IDLE				=	4'b0001	;
	localparam	S_DDR4_INIT_OK		=	4'b0011	;
	localparam	S_FDMA_TEST_WR		=	4'b0010	;
	localparam	S_FDMA_WR_CYCLE		=	4'b0110	;
	localparam	S_FDMA_WR_PRE		=	4'b0111	;
	localparam	S_FDMA_WR			=	4'b0101	;
	localparam	S_FDMA_WR_VALID		=	4'b0100	;
	localparam	S_FDMA_TEST_RD		=	4'b1100	;
	localparam	S_FDMA_RD_CYCLE		=	4'b1101	;
	localparam	S_FDMA_RD_PRE		=	4'b1111	;
	localparam	S_FDMA_RD			=	4'b1110	;
	localparam	S_FDMA_RD_VALID		=	4'b1010	;
	localparam	S_FDMA_TEST_FINISH	=	4'b1011	;
/////////////////////////////////////////////////////////////////////
//	 wire & reg 
/////////////////////////////////////////////////////////////////////	
	reg 		[MAXI_ADDR_WIDTH-1:00]		ddr4_test_raddr		;
	reg  		        					ddr4_test_rareq		;
	wire 		        					ddr4_test_rbusy		;
	wire 		[MAXI_DATA_WIDTH-1:00]		ddr4_test_rdata		;
	wire 		        					ddr4_test_rvalid	;
	reg 		[MAXI_ADDR_WIDTH-1:00]		ddr4_test_waddr		;
	reg  		        					ddr4_test_wareq		;
	wire 		        					ddr4_test_wbusy		;
	wire 		[MAXI_DATA_WIDTH-1:00]		ddr4_test_wdata		;
	wire          							ddr4_test_wvalid	;

	reg			[03:00]						current_state		;
	reg			[03:00]						next_state			;
	reg			[31:00]						fdma_wr_cnt			;
	reg			[31:00]						fdma_rd_cnt			;
	reg			[03:00]						test_finish_cnt		;
	reg			[07:00]						init_delay_cnt		;
	reg			[02:00]						ddr4_calib_ok_dff	;
	wire									ddr4_calib_ok_pos	;
	reg			[02:00]						ddr4_test_boot_dff	;
	wire									ddr4_test_boot_pos	;	

	//i_ddr4_test_boot
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			begin
				ddr4_calib_ok_dff <= 3'd0;
				ddr4_test_boot_dff <= 3'd0;
			end
		else begin
			ddr4_test_boot_dff <= {ddr4_test_boot_dff[01:00],i_ddr4_test_boot};
			ddr4_calib_ok_dff <= {ddr4_calib_ok_dff[01:00],i_ddr4_calib_ok};
		end
	end
	assign ddr4_test_boot_pos = (~ddr4_test_boot_dff[2] && ddr4_test_boot_dff[1]);	
	assign ddr4_calib_ok_pos = (~ddr4_calib_ok_dff[2] && ddr4_calib_ok_dff[1]);	

	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			init_delay_cnt <= 8'd0;
		else if(ddr4_calib_ok_pos)
			init_delay_cnt <= 8'd1;
		else if(ddr4_test_boot_pos & o_ddr4_test_finish)
			init_delay_cnt <= 8'd1;
		else if(init_delay_cnt != 8'd0)
			begin
				if(init_delay_cnt == INIT_DELAY_NUM)
					init_delay_cnt <= init_delay_cnt;
				else 
					init_delay_cnt <= init_delay_cnt + 1'b1;
			end
		else
			init_delay_cnt <= init_delay_cnt;
	end
	//i_ddr4_user_clk  
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			current_state <= S_IDLE;
		else
			current_state <= next_state;
	end	
	
	always@(*)
	begin
		case(current_state)											
				S_IDLE					:	begin
												if(i_ddr4_calib_ok)
													next_state = S_DDR4_INIT_OK;
												else
													next_state = S_IDLE;
											end
				S_DDR4_INIT_OK			:	begin
												if(init_delay_cnt == INIT_DELAY_NUM - 5)
													next_state = S_FDMA_TEST_WR;
												else
													next_state = S_DDR4_INIT_OK;
											end
				S_FDMA_TEST_WR			:	begin
												if(ddr4_test_waddr == MEM_TOTAL_SIZE)
													next_state = S_FDMA_TEST_RD;
												else
													next_state = S_FDMA_WR_CYCLE;
											end
				S_FDMA_WR_CYCLE			:	next_state = S_FDMA_WR_PRE;						
				S_FDMA_WR_PRE			:	begin
												if(!ddr4_test_wbusy)
													next_state = S_FDMA_WR;
												else 
													next_state = S_FDMA_WR_PRE;
											end						
				S_FDMA_WR				:	begin
												if(fdma_wr_cnt == ddr4_test_waddr + DDR4_RW_LENGTH * (MAXI_DATA_WIDTH/8))
													next_state = S_FDMA_WR_VALID;
												else 
													next_state = S_FDMA_WR;
											end
				S_FDMA_WR_VALID			:	next_state = S_FDMA_TEST_WR;
				S_FDMA_TEST_RD			:	begin
												if(ddr4_test_raddr == MEM_TOTAL_SIZE)
													next_state = S_FDMA_TEST_FINISH;
												else
													next_state = S_FDMA_RD_CYCLE;
											end
				S_FDMA_RD_CYCLE			:	next_state = S_FDMA_RD_PRE;						
				S_FDMA_RD_PRE			:	begin
												if(!ddr4_test_rbusy)
													next_state = S_FDMA_RD;
												else 
													next_state = S_FDMA_RD_PRE;
											end						
				S_FDMA_RD				:	begin
												if(fdma_rd_cnt == ddr4_test_raddr + DDR4_RW_LENGTH * (MAXI_DATA_WIDTH/8))
													next_state = S_FDMA_RD_VALID;
												else 
													next_state = S_FDMA_RD;
											end
				S_FDMA_RD_VALID			:	next_state = S_FDMA_TEST_RD;						
				S_FDMA_TEST_FINISH		:	begin
												if(test_finish_cnt == 4'd10)
													next_state = S_IDLE;
												else 
													next_state = S_FDMA_TEST_FINISH;
											end
				default					:		;	
		endcase
	end			

	//test_finish_cnt
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			test_finish_cnt <= 4'd0;
		else begin
			case(current_state)
				S_DDR4_INIT_OK			:	begin
												if(init_delay_cnt == INIT_DELAY_NUM - 5)
													test_finish_cnt <= 4'd0;
												else
													test_finish_cnt <= test_finish_cnt;
											end
				S_FDMA_TEST_FINISH		:	begin
												if(test_finish_cnt == 4'd10)
													test_finish_cnt <= test_finish_cnt;
												else
													test_finish_cnt <=test_finish_cnt + 1'b1;
											end
				default					:	;
			endcase
		end
	end	
	//o_ddr4_test_finish
	assign o_ddr4_test_finish = (test_finish_cnt >= 4'd8) ? 1'b1 : 1'b0; 		
	
	//ddr4_test_wareq 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			ddr4_test_wareq <= 1'b0;
		else begin
			case(current_state)
				S_FDMA_WR_CYCLE			:	begin
												if(!ddr4_test_wbusy)
													ddr4_test_wareq  <= 1'b1; 
												if(ddr4_test_wareq && ddr4_test_wbusy)
													ddr4_test_wareq  <= 1'b0; 
											end															
				default					:	ddr4_test_wareq <= 1'b0;
			endcase
		end
	end	
	//ddr4_test_waddr 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			ddr4_test_waddr <= 32'd0;
		else begin
			case(current_state)
				S_IDLE,S_FDMA_TEST_FINISH	:	ddr4_test_waddr <= 32'd0;	
				S_FDMA_WR_VALID				:	ddr4_test_waddr <= ddr4_test_waddr + DDR4_RW_LENGTH *(MAXI_DATA_WIDTH/8);													
				default						:	;
			endcase
		end
	end		
	//fdma_wr_cnt 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			fdma_wr_cnt <= 32'd0;
		else begin
			case(current_state)
				S_IDLE,S_FDMA_TEST_FINISH,S_FDMA_TEST_WR	
											:	fdma_wr_cnt <= 32'd0;
				S_FDMA_WR_CYCLE				:	fdma_wr_cnt <= ddr4_test_waddr;
				S_FDMA_WR					:	begin
												if(ddr4_test_wvalid)
													fdma_wr_cnt <= fdma_wr_cnt + (MAXI_DATA_WIDTH/8);
												else 
													fdma_wr_cnt <= fdma_wr_cnt;
											end													
				default						:	;
			endcase
		end
	end	
	
	assign ddr4_test_wdata = fdma_wr_cnt;

	//ddr4_test_rareq 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			ddr4_test_rareq <= 1'b0;
		else begin
			case(current_state)
				S_FDMA_RD_CYCLE			:	begin
												if(!ddr4_test_rbusy)
													ddr4_test_rareq  <= 1'b1; 
												if(ddr4_test_rareq && ddr4_test_rbusy)
													ddr4_test_rareq  <= 1'b0; 
											end															
				default					:	ddr4_test_rareq <= 1'b0;
			endcase
		end
	end	
	//ddr4_test_raddr 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			ddr4_test_raddr <= 32'd0;
		else begin
			case(current_state)
				S_IDLE,S_FDMA_TEST_FINISH	:	ddr4_test_raddr <= 32'd0;	
				S_FDMA_RD_VALID				:	ddr4_test_raddr <= ddr4_test_raddr + DDR4_RW_LENGTH *(MAXI_DATA_WIDTH/8);													
				default						:	;
			endcase
		end
	end		
	//fdma_rd_cnt 
	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			fdma_rd_cnt <= 32'd0;
		else begin
			case(current_state)
				S_IDLE,S_FDMA_TEST_FINISH,S_FDMA_TEST_WR	
											:	fdma_rd_cnt <= 32'd0;
				S_FDMA_RD_CYCLE				:	fdma_rd_cnt <= ddr4_test_raddr;
				S_FDMA_RD					:	begin
												if(ddr4_test_rvalid)
													fdma_rd_cnt <= fdma_rd_cnt + (MAXI_DATA_WIDTH/8);
												else 
													fdma_rd_cnt <= fdma_rd_cnt;
											end													
				default						:	;
			endcase
		end
	end	

	always@(posedge i_ddr4_user_clk)
	begin
		if(i_ddr4_user_rst)
			o_error_cnt <= 32'd0;
		else if(init_delay_cnt == INIT_DELAY_NUM - 5)
			o_error_cnt <= 32'd0;
		else if(ddr4_test_boot_pos & o_ddr4_test_finish)	
			o_error_cnt <= 32'd0;
		else if(ddr4_test_rvalid)
			begin
				if(ddr4_test_rdata != fdma_rd_cnt)
					o_error_cnt <= o_error_cnt + 1'b1;
				else 
					o_error_cnt <= o_error_cnt;
			end
		else 
			o_error_cnt <= o_error_cnt;
	end
	
	
uiFDMA#(
	.M_AXI_ID_WIDTH			(2						), //ID
	.M_AXI_ID			  	(0						), //ID
	.M_AXI_ADDR_WIDTH		(MAXI_ADDR_WIDTH		),//内存地址位宽
	.M_AXI_DATA_WIDTH		(MAXI_DATA_WIDTH		),//AXI总线的数据位宽
	.M_AXI_MAX_BURST_LEN  	(MAXI_MAX_BURST_LEN		) //AXI总线的burst大小
)uiFDMA_test(
	.I_fdma_waddr          	(ddr4_test_waddr   		),//FDMA写通道地址		
	.I_fdma_wareq          	(ddr4_test_wareq   		),//FDMA写通道请求
	.I_fdma_wsize          	(DDR4_RW_LENGTH   		),//FDMA写通道一次FDMA的传输大小                                            
	.O_fdma_wbusy          	(ddr4_test_wbusy   		),//FDMA处于BUSY状态，AXI总线正在写操作  											
	.I_fdma_wdata			(ddr4_test_wdata		),//FDMA写数据
	.O_fdma_wvalid			(ddr4_test_wvalid		),//FDMA写有效
	.I_fdma_wready			(1'b1					),//FDMA写准备好，用户可以写数据
							
	.I_fdma_raddr          	(ddr4_test_raddr		),//FDMA读通道地址
	.I_fdma_rareq          	(ddr4_test_rareq 		),//FDMA读通道请求
	.I_fdma_rsize          	(DDR4_RW_LENGTH  		),//FDMA读通道一次FDMA的传输大小                                      
	.O_fdma_rbusy          	(ddr4_test_rbusy		),//FDMA处于BUSY状态，AXI总线正在读操作 										
	.O_fdma_rdata			(ddr4_test_rdata		),//FDMA读数据
	.O_fdma_rvalid         	(ddr4_test_rvalid		),//FDMA读有效
	.I_fdma_rready		 	(1'b1					),//FDMA读准备好，用户可以读数据                 
	//axifull
	.M_AXI_ACLK				(i_ddr4_user_clk		),
	.M_AXI_ARESETN			(~i_ddr4_user_rst		),
	.M_AXI_AWID				(ddr4_test_maxi_awid	),
	.M_AXI_AWADDR			(ddr4_test_maxi_awaddr	),
	.M_AXI_AWLEN			(ddr4_test_maxi_awlen	),
	.M_AXI_AWSIZE			(ddr4_test_maxi_awsize	),
	.M_AXI_AWBURST			(ddr4_test_maxi_awburst	),
	.M_AXI_AWLOCK			(ddr4_test_maxi_awlock	),  	
	.M_AXI_AWCACHE			(ddr4_test_maxi_awcache	),  	
	.M_AXI_AWPROT			(ddr4_test_maxi_awprot	),  	
	.M_AXI_AWQOS			(ddr4_test_maxi_awqos	),  	
	.M_AXI_AWVALID			(ddr4_test_maxi_awvalid	),  	
	.M_AXI_AWREADY			(ddr4_test_maxi_awready	),  	
	.M_AXI_WID				( 						),
	.M_AXI_WDATA			(ddr4_test_maxi_wdata	),
	.M_AXI_WSTRB			(ddr4_test_maxi_wstrb	),
	.M_AXI_WLAST			(ddr4_test_maxi_wlast	), 			
	.M_AXI_WVALID			(ddr4_test_maxi_wvalid	),
	.M_AXI_WREADY			(ddr4_test_maxi_wready	),
	.M_AXI_BID				( 						),
	.M_AXI_BRESP			(ddr4_test_maxi_bresp	),
	.M_AXI_BVALID			(ddr4_test_maxi_bvalid	),
	.M_AXI_BREADY			(ddr4_test_maxi_bready	), 
	.M_AXI_ARID				(						),	 
									
	.M_AXI_ARADDR			(ddr4_test_maxi_araddr	),	 	
	.M_AXI_ARLEN			(ddr4_test_maxi_arlen	),	 
	.M_AXI_ARSIZE			(ddr4_test_maxi_arsize	),	 
	.M_AXI_ARBURST			(ddr4_test_maxi_arburst	),	 
	.M_AXI_ARLOCK			(ddr4_test_maxi_arlock	),	 
	.M_AXI_ARCACHE			(ddr4_test_maxi_arcache	),	 
	.M_AXI_ARPROT			(ddr4_test_maxi_arprot	),	 
	.M_AXI_ARQOS			(ddr4_test_maxi_arqos	),	 	   
	.M_AXI_ARVALID			(ddr4_test_maxi_arvalid	),	 
	.M_AXI_ARREADY			(ddr4_test_maxi_arready	),	 
	.M_AXI_RID				(	 					),	 
	.M_AXI_RDATA			(ddr4_test_maxi_rdata	),	 
	.M_AXI_RRESP			(ddr4_test_maxi_rresp	),	 
	.M_AXI_RLAST			(ddr4_test_maxi_rlast	),	 
	.M_AXI_RVALID			(ddr4_test_maxi_rvalid	),    
	.M_AXI_RREADY			(ddr4_test_maxi_rready	)		
);	
	
endmodule
