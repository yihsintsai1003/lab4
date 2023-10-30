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

module user_proj_example #(
    parameter BITS = 32,
    parameter DELAYS=10
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
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;
    wire decoded;

    reg ready;
    reg [BITS-17:0] delayed_count;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i && decoded; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;
    assign wbs_ack_o = ready;

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

    assign decoded = wbs_adr_i[31:20] == 12'h380 ? 1'b1 : 1'b0;

    reg [4:0] curr_state;
    reg [4:0] next_state;

    parameter s0   = 4'b0000; 
    parameter s1   = 4'b0001; 
    parameter s2   = 4'b0010; 
    parameter s3   = 4'b0011; 
    parameter s4   = 4'b0100; 
    parameter s5   = 4'b0101; 
    parameter s6   = 4'b0110; 
    parameter s7   = 4'b0111; 
    parameter s8   = 4'b1000; 
    parameter s9   = 4'b1001; 

    always@(posedge clk)
	    if (rst)
            curr_state <= s0;
	    else    
            curr_state <= next_state;

    always@(*)
	case(curr_state)
    	s0:  if(valid) next_state = s1;
		     else next_state = s0;
		s1:  if(valid) next_state = s2;
		     else next_state = s1;
		s2:  if(valid) next_state = s3;
		     else next_state = s2;
		s3:  if(valid) next_state = s4;
		     else next_state = s3;
		s4:  if(valid) next_state = s5;
		     else next_state = s4;
		s5:  if(valid) next_state = s6;
		     else next_state = s5;
		s6:  if(valid) next_state = s7;
		     else next_state = s6;
		s7:  if(valid) next_state = s8;
		     else next_state = s7;
		s8:  if(valid) next_state = s9;
		     else next_state = s8;
		s9:  if(valid) next_state = s0;		     
		     else next_state = s9;
    endcase

    always@(posedge clk)
	case(curr_state)
		s0:  begin 
        ready <= 1'b0;
		end
		s1:  begin
        ready <= 1'b0;
		end
		s2:  begin
        ready <= 1'b0;
		end
		s3:  begin
		ready <= 1'b0; 
		end
		s4:  begin
        ready <= 1'b0;	 
		end
		s5:  begin
        ready <= 1'b0;			 
		end
		s6:  begin
        ready <= 1'b0;		 
		end
		s7:  begin
        ready <= 1'b0;	 
		end
		s8:  begin
        ready <= 1'b0;			 
		end
		s9:  begin
        ready <= 1'b1;
		end
    endcase

    bram user_bram (
        .CLK(clk),
        .WE0(wstrb),
        .EN0(valid),
        .Di0(wbs_dat_i),
        .Do0(rdata),
        .A0(wbs_adr_i)
    );

endmodule



`default_nettype wire