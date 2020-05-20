module control_table
#(parameter TAG_SIZE = 8, parameter NUM_OF_BLOCKS = 4,
  parameter EXTERNAL_ADDR_SIZE = 16)
(
    input clk,
    input rst,
    input activate,
    input block_ready,
    input [EXTERNAL_ADDR_SIZE-1:0] r_addr,
    output data_ready,
    output replacing_block,
    output match,
    output [1:0] block_mux,
    output [NUM_OF_BLOCKS-1:0] block_we
);

integer i;
wire [TAG_SIZE-1:0] r_tag;
reg [TAG_SIZE:0] blck_map [NUM_OF_BLOCKS-1:0];
reg [NUM_OF_BLOCKS-1:0] reg_block_we;
reg [1:0] reg_block_mux;
reg reg_match;

reg [1:0] circular_list;
wire [NUM_OF_BLOCKS-1:0] decode_tag_match ;
wire replacing;

assign r_tag = r_addr[EXTERNAL_ADDR_SIZE-1:EXTERNAL_ADDR_SIZE-TAG_SIZE];
assign data_ready = reg_match;
assign block_we = (activate == 1) ? ((block_ready == 1) ? reg_block_we : 0) : 0;
assign block_mux = reg_block_mux;
assign replacing_block = replacing;
assign match = reg_match;

always @(posedge clk) begin
    if (rst) begin
        circular_list <= 2'b0;
        for (i = 0; i<NUM_OF_BLOCKS ; i++) begin
            blck_map[i] <= 0;
        end
    end
    else if (!activate) begin
        for (i = 0; i<NUM_OF_BLOCKS ; i++) begin
            blck_map[i] <= blck_map[i];
            circular_list <= circular_list;
        end
    end
    else if (block_ready && !reg_match) begin
        blck_map[circular_list] <= {1'b1, r_tag};
        circular_list <= circular_list + 2'b1;
    end
    else if (block_ready && replacing) begin
        blck_map[reg_block_mux] <= {1'b1, r_tag};
        circular_list <= circular_list;
    end
    else begin
        for (i = 0; i<NUM_OF_BLOCKS ; i++) begin
            blck_map[i] <= blck_map[i];
            circular_list <= circular_list;
        end
    end
    for (i = 0; i<NUM_OF_BLOCKS; i++) begin
        reg_block_we [i] <= 0;
    end
    if (replacing) begin
        reg_block_we [reg_block_mux] <= 1'b1;
    end
    else begin
        reg_block_we [circular_list] <= 1'b1;
    end
end

assign replacing = (reg_match == 1 && blck_map[reg_block_mux][TAG_SIZE] == 1) ? 1 : 0;

genvar j;
generate
    for (j = 0; j<NUM_OF_BLOCKS; j = j + 1) begin
        assign decode_tag_match [j] = (r_tag == blck_map[j][TAG_SIZE-1:0] && blck_map[j][TAG_SIZE] == 1) ? 1 : 0;
    end
endgenerate

always @ (*) begin
    reg_match = 0;
    reg_block_mux = 0;
    for (i = 0; i<NUM_OF_BLOCKS; i++) begin
        if (decode_tag_match[i] != 0) begin
            reg_match = 1;
            reg_block_mux = i;
        end
    end
end

endmodule
