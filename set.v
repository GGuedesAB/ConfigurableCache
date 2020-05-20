module set
#(parameter SET_ADDR_LENGTH = 4, parameter TAG_SIZE = 8,
  parameter WORD_SIZE = 16, parameter NUM_OF_BLOCKS = 4,
  parameter WORD_OFFSET = 4,
  parameter NUM_OF_WORDS_IN_BLOCK = 16,
  parameter EXTERNAL_ADDR_SIZE = 16)
(
    input [31:0] id,
    input clk,
    input rst,
    input activate,
    input new_word,
    input [EXTERNAL_ADDR_SIZE-1:0] r_addr,
    input [WORD_SIZE-1:0] incoming_word,
    input block_ready,
    input [NUM_OF_WORDS_IN_BLOCK*WORD_SIZE-1:0] incoming_block,
    output busy,
    output [EXTERNAL_ADDR_SIZE-1:0] r_requested_addr,
    output [WORD_SIZE-1:0] q
);

wire replacing_block;
wire [1:0] block_mux;
wire [NUM_OF_BLOCKS-1:0] block_we;
wire data_ready;
wire match;

wire [WORD_SIZE-1:0] all_outputs [NUM_OF_BLOCKS-1:0];

wire [WORD_OFFSET-1:0] r_word_offset;
assign busy = !match && activate;
assign q = (match == 1) ? all_outputs[block_mux] : 0;
assign r_word_offset = r_addr [WORD_OFFSET-1:0];

control_table c_t (clk, rst, activate, block_ready, r_addr, data_ready, replacing_block, match, block_mux, block_we);

block b0 (clk, rst, r_word_offset, incoming_block, incoming_word, block_ready, new_word, block_we[0], all_outputs[0]);
block b1 (clk, rst, r_word_offset, incoming_block, incoming_word, block_ready, new_word, block_we[1], all_outputs[1]);
block b2 (clk, rst, r_word_offset, incoming_block, incoming_word, block_ready, new_word, block_we[2], all_outputs[2]);
block b3 (clk, rst, r_word_offset, incoming_block, incoming_word, block_ready, new_word, block_we[3], all_outputs[3]);

reg [EXTERNAL_ADDR_SIZE-1:0] reg_r_requested_addr;

assign r_requested_addr = reg_r_requested_addr;

always @(posedge clk) begin
    if (! data_ready) begin
        reg_r_requested_addr <= r_addr;
    end
    else begin
        reg_r_requested_addr <= r_requested_addr;
    end
end

endmodule
