module block
#(parameter BLCK_ADDR = 4, parameter NUM_OF_WORDS = 16, parameter WORD_SIZE = 16)
(
    input clk,
    input rst,
    input [BLCK_ADDR-1:0] r_addr,
    input [WORD_SIZE*NUM_OF_WORDS-1:0] w_block_data,
    input [WORD_SIZE-1:0] w_word_data,
    input block_ready,
    input new_word,
    input new_block,
    output [WORD_SIZE-1:0] q
);

integer i;
reg [WORD_SIZE-1:0] blck [NUM_OF_WORDS-1:0];
assign q =  blck[r_addr];
wire word_we;
wire [WORD_SIZE-1:0] parse_block [NUM_OF_WORDS-1:0];
assign word_we = new_word & block_ready;

genvar j;
generate
for (j = 0; j<NUM_OF_WORDS; j = j + 1) begin
    assign parse_block[j] = w_block_data[((j+1)*16-1):j*16];
end
endgenerate

always @(posedge clk ) begin
    if (new_block) begin
        for (i = 0; i<NUM_OF_WORDS; i++) begin
            blck[i] <= parse_block[i];
        end
    end
    else if (word_we) begin
        blck[r_addr] <= w_word_data;
    end
    else begin
        for (i = 0; i<NUM_OF_WORDS ; i++) begin
            if (rst) begin
                blck[i] <= 16'b0;
            end
            else begin
                blck[i] <= blck[i];
            end
        end
    end
end

endmodule