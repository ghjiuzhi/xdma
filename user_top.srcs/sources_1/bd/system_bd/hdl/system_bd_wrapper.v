//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Sat Nov 15 18:35:53 2025
//Host        : Wang-Moonin running 64-bit major release  (build 9200)
//Command     : generate_target system_bd_wrapper.bd
//Design      : system_bd_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_bd_wrapper
   (DDR4_act_n,
    DDR4_adr,
    DDR4_ba,
    DDR4_bg,
    DDR4_ck_c,
    DDR4_ck_t,
    DDR4_cke,
    DDR4_cs_n,
    DDR4_dm_n,
    DDR4_dq,
    DDR4_dqs_c,
    DDR4_dqs_t,
    DDR4_odt,
    DDR4_reset_n,
    ddr4_sys_clk_clk_n,
    ddr4_sys_clk_clk_p,
    ddr4_test_araddr,
    ddr4_test_arburst,
    ddr4_test_arcache,
    ddr4_test_arlen,
    ddr4_test_arlock,
    ddr4_test_arprot,
    ddr4_test_arqos,
    ddr4_test_arready,
    ddr4_test_arregion,
    ddr4_test_arsize,
    ddr4_test_arvalid,
    ddr4_test_awaddr,
    ddr4_test_awburst,
    ddr4_test_awcache,
    ddr4_test_awlen,
    ddr4_test_awlock,
    ddr4_test_awprot,
    ddr4_test_awqos,
    ddr4_test_awready,
    ddr4_test_awregion,
    ddr4_test_awsize,
    ddr4_test_awvalid,
    ddr4_test_bready,
    ddr4_test_bresp,
    ddr4_test_bvalid,
    ddr4_test_rdata,
    ddr4_test_rlast,
    ddr4_test_rready,
    ddr4_test_rresp,
    ddr4_test_rvalid,
    ddr4_test_wdata,
    ddr4_test_wlast,
    ddr4_test_wready,
    ddr4_test_wstrb,
    ddr4_test_wvalid,
    ddr4_user_clk,
    ddr4_user_rstn,
    init_calib_complete,
    pcie_axi_aclk,
    pcie_axi_aresetn,
    pcie_clk_clk_n,
    pcie_clk_clk_p,
    pcie_link_up,
    pcie_mgt_rxn,
    pcie_mgt_rxp,
    pcie_mgt_txn,
    pcie_mgt_txp,
    pcie_rstn,
    pice_irq,
    user_axilite_araddr,
    user_axilite_arprot,
    user_axilite_arready,
    user_axilite_arvalid,
    user_axilite_awaddr,
    user_axilite_awprot,
    user_axilite_awready,
    user_axilite_awvalid,
    user_axilite_bready,
    user_axilite_bresp,
    user_axilite_bvalid,
    user_axilite_rdata,
    user_axilite_rready,
    user_axilite_rresp,
    user_axilite_rvalid,
    user_axilite_wdata,
    user_axilite_wready,
    user_axilite_wstrb,
    user_axilite_wvalid);
  output DDR4_act_n;
  output [16:0]DDR4_adr;
  output [1:0]DDR4_ba;
  output [0:0]DDR4_bg;
  output [0:0]DDR4_ck_c;
  output [0:0]DDR4_ck_t;
  output [0:0]DDR4_cke;
  output [0:0]DDR4_cs_n;
  inout [7:0]DDR4_dm_n;
  inout [63:0]DDR4_dq;
  inout [7:0]DDR4_dqs_c;
  inout [7:0]DDR4_dqs_t;
  output [0:0]DDR4_odt;
  output DDR4_reset_n;
  input ddr4_sys_clk_clk_n;
  input ddr4_sys_clk_clk_p;
  input [31:0]ddr4_test_araddr;
  input [1:0]ddr4_test_arburst;
  input [3:0]ddr4_test_arcache;
  input [7:0]ddr4_test_arlen;
  input [0:0]ddr4_test_arlock;
  input [2:0]ddr4_test_arprot;
  input [3:0]ddr4_test_arqos;
  output ddr4_test_arready;
  input [3:0]ddr4_test_arregion;
  input [2:0]ddr4_test_arsize;
  input ddr4_test_arvalid;
  input [31:0]ddr4_test_awaddr;
  input [1:0]ddr4_test_awburst;
  input [3:0]ddr4_test_awcache;
  input [7:0]ddr4_test_awlen;
  input [0:0]ddr4_test_awlock;
  input [2:0]ddr4_test_awprot;
  input [3:0]ddr4_test_awqos;
  output ddr4_test_awready;
  input [3:0]ddr4_test_awregion;
  input [2:0]ddr4_test_awsize;
  input ddr4_test_awvalid;
  input ddr4_test_bready;
  output [1:0]ddr4_test_bresp;
  output ddr4_test_bvalid;
  output [31:0]ddr4_test_rdata;
  output ddr4_test_rlast;
  input ddr4_test_rready;
  output [1:0]ddr4_test_rresp;
  output ddr4_test_rvalid;
  input [31:0]ddr4_test_wdata;
  input ddr4_test_wlast;
  output ddr4_test_wready;
  input [3:0]ddr4_test_wstrb;
  input ddr4_test_wvalid;
  output ddr4_user_clk;
  output [0:0]ddr4_user_rstn;
  output init_calib_complete;
  output pcie_axi_aclk;
  output pcie_axi_aresetn;
  input [0:0]pcie_clk_clk_n;
  input [0:0]pcie_clk_clk_p;
  output pcie_link_up;
  input [7:0]pcie_mgt_rxn;
  input [7:0]pcie_mgt_rxp;
  output [7:0]pcie_mgt_txn;
  output [7:0]pcie_mgt_txp;
  input pcie_rstn;
  input [0:0]pice_irq;
  output [31:0]user_axilite_araddr;
  output [2:0]user_axilite_arprot;
  input user_axilite_arready;
  output user_axilite_arvalid;
  output [31:0]user_axilite_awaddr;
  output [2:0]user_axilite_awprot;
  input user_axilite_awready;
  output user_axilite_awvalid;
  output user_axilite_bready;
  input [1:0]user_axilite_bresp;
  input user_axilite_bvalid;
  input [31:0]user_axilite_rdata;
  output user_axilite_rready;
  input [1:0]user_axilite_rresp;
  input user_axilite_rvalid;
  output [31:0]user_axilite_wdata;
  input user_axilite_wready;
  output [3:0]user_axilite_wstrb;
  output user_axilite_wvalid;

  wire DDR4_act_n;
  wire [16:0]DDR4_adr;
  wire [1:0]DDR4_ba;
  wire [0:0]DDR4_bg;
  wire [0:0]DDR4_ck_c;
  wire [0:0]DDR4_ck_t;
  wire [0:0]DDR4_cke;
  wire [0:0]DDR4_cs_n;
  wire [7:0]DDR4_dm_n;
  wire [63:0]DDR4_dq;
  wire [7:0]DDR4_dqs_c;
  wire [7:0]DDR4_dqs_t;
  wire [0:0]DDR4_odt;
  wire DDR4_reset_n;
  wire ddr4_sys_clk_clk_n;
  wire ddr4_sys_clk_clk_p;
  wire [31:0]ddr4_test_araddr;
  wire [1:0]ddr4_test_arburst;
  wire [3:0]ddr4_test_arcache;
  wire [7:0]ddr4_test_arlen;
  wire [0:0]ddr4_test_arlock;
  wire [2:0]ddr4_test_arprot;
  wire [3:0]ddr4_test_arqos;
  wire ddr4_test_arready;
  wire [3:0]ddr4_test_arregion;
  wire [2:0]ddr4_test_arsize;
  wire ddr4_test_arvalid;
  wire [31:0]ddr4_test_awaddr;
  wire [1:0]ddr4_test_awburst;
  wire [3:0]ddr4_test_awcache;
  wire [7:0]ddr4_test_awlen;
  wire [0:0]ddr4_test_awlock;
  wire [2:0]ddr4_test_awprot;
  wire [3:0]ddr4_test_awqos;
  wire ddr4_test_awready;
  wire [3:0]ddr4_test_awregion;
  wire [2:0]ddr4_test_awsize;
  wire ddr4_test_awvalid;
  wire ddr4_test_bready;
  wire [1:0]ddr4_test_bresp;
  wire ddr4_test_bvalid;
  wire [31:0]ddr4_test_rdata;
  wire ddr4_test_rlast;
  wire ddr4_test_rready;
  wire [1:0]ddr4_test_rresp;
  wire ddr4_test_rvalid;
  wire [31:0]ddr4_test_wdata;
  wire ddr4_test_wlast;
  wire ddr4_test_wready;
  wire [3:0]ddr4_test_wstrb;
  wire ddr4_test_wvalid;
  wire ddr4_user_clk;
  wire [0:0]ddr4_user_rstn;
  wire init_calib_complete;
  wire pcie_axi_aclk;
  wire pcie_axi_aresetn;
  wire [0:0]pcie_clk_clk_n;
  wire [0:0]pcie_clk_clk_p;
  wire pcie_link_up;
  wire [7:0]pcie_mgt_rxn;
  wire [7:0]pcie_mgt_rxp;
  wire [7:0]pcie_mgt_txn;
  wire [7:0]pcie_mgt_txp;
  wire pcie_rstn;
  wire [0:0]pice_irq;
  wire [31:0]user_axilite_araddr;
  wire [2:0]user_axilite_arprot;
  wire user_axilite_arready;
  wire user_axilite_arvalid;
  wire [31:0]user_axilite_awaddr;
  wire [2:0]user_axilite_awprot;
  wire user_axilite_awready;
  wire user_axilite_awvalid;
  wire user_axilite_bready;
  wire [1:0]user_axilite_bresp;
  wire user_axilite_bvalid;
  wire [31:0]user_axilite_rdata;
  wire user_axilite_rready;
  wire [1:0]user_axilite_rresp;
  wire user_axilite_rvalid;
  wire [31:0]user_axilite_wdata;
  wire user_axilite_wready;
  wire [3:0]user_axilite_wstrb;
  wire user_axilite_wvalid;

  system_bd system_bd_i
       (.DDR4_act_n(DDR4_act_n),
        .DDR4_adr(DDR4_adr),
        .DDR4_ba(DDR4_ba),
        .DDR4_bg(DDR4_bg),
        .DDR4_ck_c(DDR4_ck_c),
        .DDR4_ck_t(DDR4_ck_t),
        .DDR4_cke(DDR4_cke),
        .DDR4_cs_n(DDR4_cs_n),
        .DDR4_dm_n(DDR4_dm_n),
        .DDR4_dq(DDR4_dq),
        .DDR4_dqs_c(DDR4_dqs_c),
        .DDR4_dqs_t(DDR4_dqs_t),
        .DDR4_odt(DDR4_odt),
        .DDR4_reset_n(DDR4_reset_n),
        .ddr4_sys_clk_clk_n(ddr4_sys_clk_clk_n),
        .ddr4_sys_clk_clk_p(ddr4_sys_clk_clk_p),
        .ddr4_test_araddr(ddr4_test_araddr),
        .ddr4_test_arburst(ddr4_test_arburst),
        .ddr4_test_arcache(ddr4_test_arcache),
        .ddr4_test_arlen(ddr4_test_arlen),
        .ddr4_test_arlock(ddr4_test_arlock),
        .ddr4_test_arprot(ddr4_test_arprot),
        .ddr4_test_arqos(ddr4_test_arqos),
        .ddr4_test_arready(ddr4_test_arready),
        .ddr4_test_arregion(ddr4_test_arregion),
        .ddr4_test_arsize(ddr4_test_arsize),
        .ddr4_test_arvalid(ddr4_test_arvalid),
        .ddr4_test_awaddr(ddr4_test_awaddr),
        .ddr4_test_awburst(ddr4_test_awburst),
        .ddr4_test_awcache(ddr4_test_awcache),
        .ddr4_test_awlen(ddr4_test_awlen),
        .ddr4_test_awlock(ddr4_test_awlock),
        .ddr4_test_awprot(ddr4_test_awprot),
        .ddr4_test_awqos(ddr4_test_awqos),
        .ddr4_test_awready(ddr4_test_awready),
        .ddr4_test_awregion(ddr4_test_awregion),
        .ddr4_test_awsize(ddr4_test_awsize),
        .ddr4_test_awvalid(ddr4_test_awvalid),
        .ddr4_test_bready(ddr4_test_bready),
        .ddr4_test_bresp(ddr4_test_bresp),
        .ddr4_test_bvalid(ddr4_test_bvalid),
        .ddr4_test_rdata(ddr4_test_rdata),
        .ddr4_test_rlast(ddr4_test_rlast),
        .ddr4_test_rready(ddr4_test_rready),
        .ddr4_test_rresp(ddr4_test_rresp),
        .ddr4_test_rvalid(ddr4_test_rvalid),
        .ddr4_test_wdata(ddr4_test_wdata),
        .ddr4_test_wlast(ddr4_test_wlast),
        .ddr4_test_wready(ddr4_test_wready),
        .ddr4_test_wstrb(ddr4_test_wstrb),
        .ddr4_test_wvalid(ddr4_test_wvalid),
        .ddr4_user_clk(ddr4_user_clk),
        .ddr4_user_rstn(ddr4_user_rstn),
        .init_calib_complete(init_calib_complete),
        .pcie_axi_aclk(pcie_axi_aclk),
        .pcie_axi_aresetn(pcie_axi_aresetn),
        .pcie_clk_clk_n(pcie_clk_clk_n),
        .pcie_clk_clk_p(pcie_clk_clk_p),
        .pcie_link_up(pcie_link_up),
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_rstn(pcie_rstn),
        .pice_irq(pice_irq),
        .user_axilite_araddr(user_axilite_araddr),
        .user_axilite_arprot(user_axilite_arprot),
        .user_axilite_arready(user_axilite_arready),
        .user_axilite_arvalid(user_axilite_arvalid),
        .user_axilite_awaddr(user_axilite_awaddr),
        .user_axilite_awprot(user_axilite_awprot),
        .user_axilite_awready(user_axilite_awready),
        .user_axilite_awvalid(user_axilite_awvalid),
        .user_axilite_bready(user_axilite_bready),
        .user_axilite_bresp(user_axilite_bresp),
        .user_axilite_bvalid(user_axilite_bvalid),
        .user_axilite_rdata(user_axilite_rdata),
        .user_axilite_rready(user_axilite_rready),
        .user_axilite_rresp(user_axilite_rresp),
        .user_axilite_rvalid(user_axilite_rvalid),
        .user_axilite_wdata(user_axilite_wdata),
        .user_axilite_wready(user_axilite_wready),
        .user_axilite_wstrb(user_axilite_wstrb),
        .user_axilite_wvalid(user_axilite_wvalid));
endmodule
