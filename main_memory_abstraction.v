module main_memory
#(parameter BLOCK_SIZE = 256, parameter MEMORY_SIZE = 1024, parameter ADDR_WIDTH = 16)
(
    input clk,
    input rst,
    input we,
    input [ADDR_WIDTH-1:0] r_addr,
    input [ADDR_WIDTH-1:0] w_addr,
    input [BLOCK_SIZE-1:0] block,
    output block_ready,
    // Need to implement FIFO logic
    output fifo_full,
    output [BLOCK_SIZE-1:0] q
);

reg [BLOCK_SIZE-1:0] output_q;

reg [BLOCK_SIZE-1:0] mm [MEMORY_SIZE-1:0];
reg [3:0] delay;

assign q = output_q;
assign block_ready = (delay == 0) ? 1 : 0;

always @(r_addr) begin
    delay <= 1;
end

integer i;
always @(posedge clk) begin
    if (rst) begin
        delay <= 0;
        output_q <= 0;
        for (i = 0; i<MEMORY_SIZE; i++) begin
            mm [i] <= 0;
        end
    end
    else if (we) begin
        mm [w_addr] <= block;
    end
    else begin
        for (i = 0; i<MEMORY_SIZE; i++) begin
            mm [i] <= mm [i];
        end
    end
    if (delay < 10 && delay > 0) begin
        delay <= delay + 1;
        output_q <= 0;
    end
    else begin
        delay = 0;
        output_q <= mm[r_addr];
    end
end

endmodule

module mainmm ();
parameter BLOCK_SIZE = 256;
parameter MEMORY_SIZE = 1024;
parameter ADDR_WIDTH = 16;
reg clk;
reg rst;
reg we;
reg [ADDR_WIDTH-1:0] r_addr;
reg [ADDR_WIDTH-1:0] w_addr;
reg [BLOCK_SIZE-1:0] block;
wire block_ready;
// Need to implement FIFO logic
wire fifo_full;
wire [BLOCK_SIZE-1:0] q;

main_memory m_m (clk, rst, we, r_addr, w_addr, block, block_ready, fifo_full, q);

always #1 clk = ~clk;

always @(posedge block_ready) begin
    #2 r_addr = (r_addr % 2) + 3;
end

initial
begin
    $dumpfile("my_dumpfile.vcd");
    $dumpvars(0, mainmm);
    //$readmemh("program.hex", m_m.mm, 0, 1023);
    #0 clk = 0;
    #0 rst = 1;
    #0 r_addr = 0;
    #0 w_addr = 0;
    #0 block = 0;
    #0 we = 0;
    #2 rst = 0;
    
    #0 we = 1;
    #0 w_addr = 16'h3;
    #0 block = 256'hFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADAFADA;
    #2 we = 0;
    
    #0 we = 1;
    #0 w_addr = 16'h4;
    #0 block = 256'hCECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECECE;
    #2 we = 0;

    //#1 r_addr = 16'h3;
    
    //#15 r_addr = 16'h4;
    
    //#20 r_addr = 16'h3;
    #100 $finish;
end
endmodule