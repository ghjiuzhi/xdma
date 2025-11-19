`timescale 1ns / 1ps
`include "user_parameter.vh"
module user_top(
    //pcie 
    input                               pcie_clk_n              ,   
    input                               pcie_clk_p              ,  
    input       [07:00]                 pcie_mgt_rxn            ,
    input       [07:00]                 pcie_mgt_rxp            ,
    output      [07:00]                 pcie_mgt_txn            ,
    output      [07:00]                 pcie_mgt_txp            ,
    input                               pcie_rstn               ,  
	//ddr4 clk
	input								i_ddr4_clk_n			,
	input								i_ddr4_clk_p			,
	//ddr4
	output		      					DDR4_act_n				,
	output		[16:00]					DDR4_adr				,
	output		[01:00]					DDR4_ba					,
	output		[00:00]					DDR4_bg					,
	output		[00:00]					DDR4_ck_c				,
	output		[00:00]					DDR4_ck_t				,
	output		[00:00]					DDR4_cke				,
	output		[00:00]					DDR4_cs_n				,
	inout 		[07:00]					DDR4_dm_n				,
	inout 		[63:00]					DDR4_dq					,
	inout 		[07:00]					DDR4_dqs_c				,
	inout 		[07:00]					DDR4_dqs_t				,
	output		[00:00]					DDR4_odt				,
	output		      					DDR4_reset_n				

    );
/////////////////////////////////////////////////////////////////////
//	  parameter  
/////////////////////////////////////////////////////////////////////		
	parameter MAXI_ADDR_WIDTH = 32		;
	parameter MAXI_DATA_WIDTH = 32		;

/////////////////////////////////////////////////////////////////////
//	  wire & reg  
/////////////////////////////////////////////////////////////////////	
	//ddr4	
	wire									ddr4_user_clk			;
	wire									ddr4_user_rstn			;
	wire									ddr4_calib_ok			;
	wire									ddr4_test_boot			;
	wire									ddr4_test_finish		;
	wire		[31:00]						ddr4_error_cnt			;	


    wire                                    pcie_link_up        ;   
    wire                                    pcie_axi_aclk       ;   
    wire                                    pcie_axi_aresetn    ;
	//ddr4 test		
	wire		[MAXI_ADDR_WIDTH-1:00]		ddr4_test_awaddr		;
	wire		[01:00]						ddr4_test_awburst		;
	wire		[03:00]						ddr4_test_awcache		;
	wire		[07:00]						ddr4_test_awlen			;
	wire									ddr4_test_awlock		;
	wire		[02:00]						ddr4_test_awprot		;
	wire		[03:00]						ddr4_test_awqos			;
	wire									ddr4_test_awready		;
	wire		[02:00]						ddr4_test_awsize		;
	wire									ddr4_test_awvalid		;
	wire									ddr4_test_bready		;
	wire		[01:00]						ddr4_test_bresp			;
	wire									ddr4_test_bvalid		;
	wire		[MAXI_DATA_WIDTH-1:00]		ddr4_test_wdata			;
	wire									ddr4_test_wlast			;
	wire									ddr4_test_wready		;
	wire		[MAXI_DATA_WIDTH/8-1:00]	ddr4_test_wstrb			;
	wire									ddr4_test_wvalid		;
	wire        [MAXI_ADDR_WIDTH-1:00]		ddr4_test_araddr		;
	wire        [01:00]						ddr4_test_arburst		;
	wire        [03:00]                 	ddr4_test_arcache		;
	wire        [07:00]            			ddr4_test_arlen		    ;
	wire                            		ddr4_test_arlock		;
	wire		[02:00]						ddr4_test_arprot		;
	wire		[03:00]						ddr4_test_arqos		    ;
	wire                            		ddr4_test_arready		;
	wire        [02:00]           			ddr4_test_arsize		;
	wire                            		ddr4_test_arvalid		;
	wire        [MAXI_DATA_WIDTH-1:0]		ddr4_test_rdata		    ;
	wire                            		ddr4_test_rlast		    ;
	wire                            		ddr4_test_rready		;
	wire		[01:00]						ddr4_test_rresp		    ;
	wire                            		ddr4_test_rvalid		;	
	//user axi lite slaver		
    wire 		[31:0]						user_axilite_araddr    	;
    wire 		[2:0]						user_axilite_arprot    	;
    wire 									user_axilite_arready   	;
    wire 									user_axilite_arvalid   	;
    wire 		[31:0]						user_axilite_awaddr    	;
    wire 		[2:0]						user_axilite_awprot    	;
    wire 									user_axilite_awready   	;
    wire 									user_axilite_awvalid   	;
    wire 									user_axilite_bready    	;
    wire 		[1:0]						user_axilite_bresp     	;
    wire 									user_axilite_bvalid    	;
    wire 		[31:0]						user_axilite_rdata     	;
    wire 									user_axilite_rready    	;
    wire 		[1:0]						user_axilite_rresp     	;
    wire 									user_axilite_rvalid    	;
    wire 		[31:0]						user_axilite_wdata     	;
    wire 									user_axilite_wready    	;
    wire 		[3:0]						user_axilite_wstrb     	;
    wire 									user_axilite_wvalid    	;

system_bd system_bd_inst(
	.DDR4_act_n					(DDR4_act_n				),
	.DDR4_adr					(DDR4_adr				),
	.DDR4_ba					(DDR4_ba				),
	.DDR4_bg					(DDR4_bg				),
	.DDR4_ck_c					(DDR4_ck_c				),
	.DDR4_ck_t					(DDR4_ck_t				),
	.DDR4_cke					(DDR4_cke				),
	.DDR4_cs_n					(DDR4_cs_n				),
	.DDR4_dm_n					(DDR4_dm_n				),
	.DDR4_dq					(DDR4_dq				),
	.DDR4_dqs_c					(DDR4_dqs_c				),
	.DDR4_dqs_t					(DDR4_dqs_t				),
	.DDR4_odt					(DDR4_odt				),
	.DDR4_reset_n				(DDR4_reset_n			),
	.ddr4_user_clk				(ddr4_user_clk			),
	.ddr4_user_rstn				(ddr4_user_rstn			),    

	.ddr4_test_araddr			(ddr4_test_araddr		),
	.ddr4_test_arburst			(ddr4_test_arburst		),
	.ddr4_test_arcache			(ddr4_test_arcache		),
	.ddr4_test_arlen			(ddr4_test_arlen		),
	.ddr4_test_arlock			(ddr4_test_arlock		),
	.ddr4_test_arprot			(ddr4_test_arprot		),
	.ddr4_test_arqos			(ddr4_test_arqos		),
	.ddr4_test_arready			(ddr4_test_arready		),
	.ddr4_test_arsize			(ddr4_test_arsize		),
	.ddr4_test_arvalid			(ddr4_test_arvalid		),
	.ddr4_test_awaddr			(ddr4_test_awaddr		),
	.ddr4_test_awburst			(ddr4_test_awburst		),
	.ddr4_test_awcache			(ddr4_test_awcache		),
	.ddr4_test_awlen			(ddr4_test_awlen		),
	.ddr4_test_awlock			(ddr4_test_awlock		),
	.ddr4_test_awprot			(ddr4_test_awprot		),
	.ddr4_test_awqos			(ddr4_test_awqos		),
	.ddr4_test_awready			(ddr4_test_awready		),
	.ddr4_test_awsize			(ddr4_test_awsize		),
	.ddr4_test_awvalid			(ddr4_test_awvalid		),
	.ddr4_test_bready			(ddr4_test_bready		),
	.ddr4_test_bresp			(ddr4_test_bresp		),
	.ddr4_test_bvalid			(ddr4_test_bvalid		),
	.ddr4_test_rdata			(ddr4_test_rdata		),
	.ddr4_test_rlast			(ddr4_test_rlast		),
	.ddr4_test_rready			(ddr4_test_rready		),
	.ddr4_test_rresp			(ddr4_test_rresp		),
	.ddr4_test_rvalid			(ddr4_test_rvalid		),
	.ddr4_test_wdata			(ddr4_test_wdata		),
	.ddr4_test_wlast			(ddr4_test_wlast		),
	.ddr4_test_wready			(ddr4_test_wready		),
	.ddr4_test_wstrb			(ddr4_test_wstrb		),
	.ddr4_test_wvalid			(ddr4_test_wvalid		),

	.init_calib_complete    (ddr4_calib_ok			),
	.ddr4_sys_clk_clk_n     (i_ddr4_clk_n			),	
	.ddr4_sys_clk_clk_p     (i_ddr4_clk_p			),

    .pcie_clk_clk_n         (pcie_clk_n         ),
    .pcie_clk_clk_p         (pcie_clk_p         ),
    .pcie_link_up           (pcie_link_up       ),
    .pcie_mgt_rxn           (pcie_mgt_rxn       ),
    .pcie_mgt_rxp           (pcie_mgt_rxp       ),
    .pcie_mgt_txn           (pcie_mgt_txn       ),
    .pcie_mgt_txp           (pcie_mgt_txp       ),
    .pcie_rstn              (pcie_rstn          ),
    .pcie_axi_aclk          (pcie_axi_aclk      ),
    .pcie_axi_aresetn       (pcie_axi_aresetn   ),
	.pice_irq				(1'b0				),
	.user_axilite_araddr		(user_axilite_araddr		),
	.user_axilite_arprot		(user_axilite_arprot		),
	.user_axilite_arready		(user_axilite_arready		),
	.user_axilite_arvalid		(user_axilite_arvalid		),
	.user_axilite_awaddr		(user_axilite_awaddr		),
	.user_axilite_awprot		(user_axilite_awprot		),
	.user_axilite_awready		(user_axilite_awready		),
	.user_axilite_awvalid		(user_axilite_awvalid		),
	.user_axilite_bready		(user_axilite_bready		),
	.user_axilite_bresp			(user_axilite_bresp			),
	.user_axilite_bvalid		(user_axilite_bvalid		),
	.user_axilite_rdata			(user_axilite_rdata			),
	.user_axilite_rready		(user_axilite_rready		),
	.user_axilite_rresp			(user_axilite_rresp			),
	.user_axilite_rvalid		(user_axilite_rvalid		),
	.user_axilite_wdata			(user_axilite_wdata			),
	.user_axilite_wready		(user_axilite_wready		),
	.user_axilite_wstrb			(user_axilite_wstrb			),
	.user_axilite_wvalid	    (user_axilite_wvalid		)

);

/////////////////////////////////////////////////////////////////////
//	 user_saxi_lite 
/////////////////////////////////////////////////////////////////////
user_saxi_lite#(
	.C_BASE_ADDRESS				(`C_BASE_ADDRESS)
)user_saxi_lite_inst(
	.o_ddr4_test_boot			(ddr4_test_boot			),	
	.i_ddr4_error_cnt			(ddr4_error_cnt			),	
	.i_ddr4_test_finish			(ddr4_test_finish		),	
	
	.S_AXI_ACLK                 (pcie_axi_aclk          ),
	.S_AXI_ARESETN              (pcie_axi_aresetn       ),
	.S_AXI_AWADDR               (user_axilite_awaddr   	),
	.S_AXI_AWPROT               (user_axilite_awprot   	),
	.S_AXI_AWVALID              (user_axilite_awvalid  	),
	.S_AXI_AWREADY              (user_axilite_awready  	),
	.S_AXI_WDATA                (user_axilite_wdata    	),
	.S_AXI_WSTRB                (user_axilite_wstrb    	),
	.S_AXI_WVALID               (user_axilite_wvalid   	),
	.S_AXI_WREADY               (user_axilite_wready   	),
	.S_AXI_BRESP                (user_axilite_bresp    	),
	.S_AXI_BVALID               (user_axilite_bvalid   	),
	.S_AXI_BREADY               (user_axilite_bready   	),
	.S_AXI_ARADDR               (user_axilite_araddr   	),
	.S_AXI_ARPROT               (user_axilite_arprot   	),
	.S_AXI_ARVALID              (user_axilite_arvalid  	),
	.S_AXI_ARREADY              (user_axilite_arready  	),
	.S_AXI_RDATA                (user_axilite_rdata    	),
	.S_AXI_RRESP                (user_axilite_rresp    	),
	.S_AXI_RVALID               (user_axilite_rvalid   	),
	.S_AXI_RREADY               (user_axilite_rready   	)	
);


mem_rw_test#(
	.MAXI_ADDR_WIDTH	(MAXI_ADDR_WIDTH	),
	.MAXI_DATA_WIDTH    (MAXI_DATA_WIDTH	)
)mem_rw_test_inst(
	.i_ddr4_user_clk			(ddr4_user_clk			),		
	.i_ddr4_user_rst			(~ddr4_user_rstn		),
	.i_ddr4_calib_ok			(ddr4_calib_ok			),	
	.i_ddr4_test_boot			(ddr4_test_boot			),	
	.o_ddr4_test_finish			(ddr4_test_finish		),
	.o_error_cnt				(ddr4_error_cnt			),
	.ddr4_test_maxi_awid		(ddr4_test_awid			),
	.ddr4_test_maxi_awaddr		(ddr4_test_awaddr		),        
	.ddr4_test_maxi_awlen		(ddr4_test_awlen		),        
	.ddr4_test_maxi_awsize		(ddr4_test_awsize		),        
	.ddr4_test_maxi_awburst		(ddr4_test_awburst		),        
	.ddr4_test_maxi_awlock		(ddr4_test_awlock		),        
	.ddr4_test_maxi_awcache		(ddr4_test_awcache		),        
	.ddr4_test_maxi_awprot		(ddr4_test_awprot		),        
	.ddr4_test_maxi_awqos		(ddr4_test_awqos		),        
	.ddr4_test_maxi_awvalid		(ddr4_test_awvalid		),        
	.ddr4_test_maxi_awready		(ddr4_test_awready		),        
	.ddr4_test_maxi_wdata		(ddr4_test_wdata		),        
	.ddr4_test_maxi_wstrb		(ddr4_test_wstrb		),        
	.ddr4_test_maxi_wlast		(ddr4_test_wlast		), 
	.ddr4_test_maxi_wvalid		(ddr4_test_wvalid		),        
	.ddr4_test_maxi_wready		(ddr4_test_wready		),       
	.ddr4_test_maxi_bresp		(ddr4_test_bresp		),        
	.ddr4_test_maxi_bvalid		(ddr4_test_bvalid		),        
	.ddr4_test_maxi_bready		(ddr4_test_bready		),	
	.ddr4_test_maxi_araddr		(ddr4_test_araddr		),	
	.ddr4_test_maxi_arlen		(ddr4_test_arlen		),
	.ddr4_test_maxi_arsize		(ddr4_test_arsize		),
	.ddr4_test_maxi_arburst		(ddr4_test_arburst		),
	.ddr4_test_maxi_arlock		(ddr4_test_arlock		), 
	.ddr4_test_maxi_arcache		(ddr4_test_arcache		),
	.ddr4_test_maxi_arprot		(ddr4_test_arprot		),
	.ddr4_test_maxi_arqos		(ddr4_test_arqos		),   
	.ddr4_test_maxi_arvalid		(ddr4_test_arvalid		),
	.ddr4_test_maxi_arready		(ddr4_test_arready		),
	.ddr4_test_maxi_rdata		(ddr4_test_rdata		),
	.ddr4_test_maxi_rresp		(ddr4_test_rresp		),
	.ddr4_test_maxi_rlast		(ddr4_test_rlast		),
	.ddr4_test_maxi_rvalid		(ddr4_test_rvalid		),  
	.ddr4_test_maxi_rready		(ddr4_test_rready		)			
);	
endmodule
