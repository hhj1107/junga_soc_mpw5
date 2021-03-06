`default_nettype none

module wb_led # (
    parameter NUM_LEDS = 8'h08
) (
`ifdef USE_POWER_PINS
  inout vccd1,	// User area 1 1.8V supply
  inout vssd1,	// User area 1 digital ground
`endif
    // RCC
    input wire i_clk,
    input wire i_reset,
    // Output
    output reg [NUM_LEDS-1:0] o_leds,
    // Wishbone
    input  wire [31:0] i_wb_adr,
    input  wire [31:0] i_wb_dat,
    input  wire  [3:0] i_wb_sel,
    input  wire        i_wb_we,
    input  wire        i_wb_cyc,
    input  wire        i_wb_stb,
    output reg  [31:0] o_wb_dat,
    output reg         o_wb_ack
);

// Wishbone register addresses
localparam
    wb_r_DATA  = 1'b0,
    wb_r_MAX   = 1'b1;

// register
reg [31:0] data;

// output generation
always @(posedge i_clk) begin
    o_leds <= data;
end

// Since the incoming wishbone address from the CPU increments by 4 bytes, we
// need to right shift it by 2 to get our actual register index
localparam reg_sel_bits = $clog2(wb_r_MAX + 1);
wire [reg_sel_bits-1:0] register_index = i_wb_adr[reg_sel_bits+1:2];

always @(posedge i_clk) begin
    if (i_reset) begin
        o_wb_ack <= 0;
        data <= 0;
    end else begin
        o_wb_ack <= 1'b0;
        if (i_wb_cyc & i_wb_stb & ~o_wb_ack) begin
            o_wb_ack <= 1'b1;
            case (register_index)
                wb_r_DATA: begin
                    o_wb_dat <= data;
                    if (i_wb_we)
                        data <= i_wb_dat;
                end
            endcase
        end
    end
end

endmodule
