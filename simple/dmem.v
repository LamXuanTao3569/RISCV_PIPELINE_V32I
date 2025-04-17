module dmem (
    input  wire        clk,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:31];
    always @(posedge clk) begin
        if (we) mem[addr[31:2]] <= write_data;
    end
    assign read_data = mem[addr[31:2]];
endmodule