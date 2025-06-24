module RegFile(
    input  logic clk,
    input  logic rst_n,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    input  logic [31:0] rd_data,
    input  logic regWEn,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    logic [31:0] registers [0:31];
    assign rs1_data = (rs1 == 0) ? 32'b0 : registers[rs1];
    assign rs2_data = (rs2 == 0) ? 32'b0 : registers[rs2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            for (int i = 0; i < 32; i++) registers[i] <= 0;
        else if (regWEn && rd != 0)
            registers[rd] <= rd_data;
    end
endmodule 