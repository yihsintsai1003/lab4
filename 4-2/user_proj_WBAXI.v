// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_WBAXI #(
    parameter BITS = 32,
    parameter DELAYS=10,
    parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    output awvalid,
    output [(pADDR_WIDTH-1):0] awaddr,
    output wvalid,
    output [(pDATA_WIDTH-1):0] wdata,

    output ss_tvalid,
    output [(pDATA_WIDTH-1):0] ss_tdata,
    output ss_tlast,
     
    output sm_tready,


    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

// rename 
wire clk;
wire rst_n;

assign clk = wb_clk_i;
assign rst_n = ~wb_rst_i;

wire valid;
assign valid = (wbs_stb_i && wbs_cyc_i && (wbs_adr_i[31:24] == 8'h30))?1:0;

wire awvalid;
wire [(pADDR_WIDTH-1):0] awriteaddr;
wire wvalid;
wire [(pDATA_WIDTH-1):0] wdata;
assign awvalid = (valid  && wbs_we_i && (wbs_adr_i[6] == 1))?1:0;
assign awriteaddr = (valid  && wbs_we_i && (wbs_adr_i[6] == 1))?wbs_adr_i[(pADDR_WIDTH-1):0]:0;
assign wvalid = (valid  && wbs_we_i && (wbs_adr_i[6] == 1))?1:0;
assign wdata = (valid  && wbs_we_i && (wbs_adr_i[6] == 1))?wbs_dat_i:0;

wire sstvalid;
wire [(pDATA_WIDTH-1):0] sstdata;
assign sstvalid = (valid && (wbs_adr_i[7:0] == 8'h80))?1:0;
assign sstdata = (valid && (wbs_adr_i[7:0] == 8'h80))?wbs_dat_i:0;

wire smtready;
assign smtready = (valid && (wbs_adr_i[7:0] == 8'h84))?1:0;


endmodule