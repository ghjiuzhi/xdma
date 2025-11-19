//for sim
//`define SIM
////////////////////////////////////////////////////////
//				axilite
////////////////////////////////////////////////////////
//S_AXI base address 
`define			C_BASE_ADDRESS							    32'h0000_0000
//AXI Address width			
`define			C_S_AXI_ADDR_WIDTH							32
//Width of the AXI R&W data				
`define			C_S_AXI_DATA_WIDTH							32
//Wishbone addr width				
`define			AW											32 
//Wishbone data width				
`define			DW											32 

//REG_DEVICE_ADDR寄存器地址信息	only read		
`define  		REG_DEVICE_BITS				                31:0
`define  		REG_DEVICE_ADDR				                32'h0000_0000
//项目硬件版本、逻辑版本
`define         HEAR_SOFT_ID                                32'h20251014
//REG_TEST1_ADDR寄存器地址信息		read & write	
`define  		REG_TEST1_BITS				    			31:0
`define  		REG_TEST1_WIDTH				    			32
`define  		REG_TEST1_DEFAULT                			32'h5555_6666
`define  		REG_TEST1_ADDR								32'h0000_0004



//addr 0000_1000 
//REG_DDR4_TEST_BOOT_ADDR		read & write	
`define  		REG_DDR4_TEST_BOOT_BITS						31:0
`define  		REG_DDR4_TEST_BOOT_WIDTH					32
`define  		REG_DDR4_TEST_BOOT_DEFAULT					32'd0
`define  		REG_DDR4_TEST_BOOT_ADDR						32'h0000_2000
//REG_DDR4_STATUS_ADDR寄存器地址信息	only read		
`define  		REG_DDR4_STATUS_BITS				      	31:0
`define  		REG_DDR4_STATUS_ADDR				      	32'h0000_2004
//REG_DDR4_ERROR_CNT_ADDR寄存器地址信息	only read		
`define  		REG_DDR4_ERROR_CNT_BITS				      	31:0
`define  		REG_DDR4_ERROR_CNT_ADDR				      	32'h0000_2008
