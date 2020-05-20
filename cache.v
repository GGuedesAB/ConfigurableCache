module cache
#(parameter NUM_OF_SETS = 4,
  parameter WORD_SIZE = 16,
  parameter NUM_OF_WORDS_IN_BLOCK = 16,
  parameter EXTERNAL_ADDR_SIZE = 16)
(
    input clk,
    input rst,
    input block_ready,
    input [EXTERNAL_ADDR_SIZE-1:0] addr,
    input [WORD_SIZE*NUM_OF_WORDS_IN_BLOCK-1:0] incoming_block,
    input store_op,
    input [WORD_SIZE-1:0] incoming_word,
    output data_ready,
    output busy,
    output [EXTERNAL_ADDR_SIZE-1:0] requested_addr,
    output [WORD_SIZE*NUM_OF_WORDS_IN_BLOCK-1:0] commit_block,
    output request_data,
    output [WORD_SIZE-1:0] word
);

wire [NUM_OF_SETS-1:0] set_addr;
wire [NUM_OF_SETS-1:0] set_status;
wire [NUM_OF_SETS-1:0] activate;
wire [WORD_SIZE-1:0] word_decoder [NUM_OF_SETS-1:0];
wire [WORD_SIZE*NUM_OF_WORDS_IN_BLOCK-1:0] block_decoder [NUM_OF_SETS-1:0];

assign set_addr = addr[2*NUM_OF_SETS-1:NUM_OF_SETS] % NUM_OF_SETS;
assign word = word_decoder[set_addr];
assign busy = (set_status > 0) ? 1 : 0;
genvar j;
generate
    for (j = 0; j<NUM_OF_SETS; j = j + 1) begin
        assign block_decoder [j] = (j == set_addr) ? incoming_block : 0;
        assign activate [j] = (j == set_addr) ? 1 : 0;
    end
endgenerate

set s0 (0, clk, rst, activate[0], store_op, addr, incoming_word, block_ready, block_decoder[0], set_status[0], requested_addr, word_decoder[0]);
set s1 (1, clk, rst, activate[1], store_op, addr, incoming_word, block_ready, block_decoder[1], set_status[1], requested_addr, word_decoder[1]);
set s2 (2, clk, rst, activate[2], store_op, addr, incoming_word, block_ready, block_decoder[2], set_status[2], requested_addr, word_decoder[2]);
set s3 (3, clk, rst, activate[3], store_op, addr, incoming_word, block_ready, block_decoder[3], set_status[3], requested_addr, word_decoder[3]);

endmodule
