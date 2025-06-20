module Data_Memory(
    input clk, rst, WE,
    input [1:0] MemOp,
    input [31:0] A, WD,
    output reg [31:0] RD
);
    reg [31:0] mem [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h0;
    end

    always @(posedge clk) begin
        if (WE) begin
            case (MemOp)
                2'b00: begin // sb
                    case (A[1:0])
                        2'b00: mem[A >> 2][7:0] <= WD[7:0];
                        2'b01: mem[A >> 2][15:8] <= WD[7:0];
                        2'b10: mem[A >> 2][23:16] <= WD[7:0];
                        2'b11: mem[A >> 2][31:24] <= WD[7:0];
                    endcase
                end
                2'b01: begin // sh
                    case (A[1])
                        1'b0: mem[A >> 2][15:0] <= WD[15:0];
                        1'b1: mem[A >> 2][31:16] <= WD[15:0];
                    endcase
                end
                2'b10: mem[A >> 2] <= WD; // sw
                default: mem[A >> 2] <= WD;
            endcase
        end
    end

    always @(*) begin
        if (rst == 1'b0)
            RD = 32'h0;
        else begin
            case (MemOp)
                2'b00: begin // lb
                    case (A[1:0])
                        2'b00: RD = {{24{mem[A >> 2][7]}}, mem[A >> 2][7:0]};
                        2'b01: RD = {{24{mem[A >> 2][15]}}, mem[A >> 2][15:8]};
                        2'b10: RD = {{24{mem[A >> 2][23]}}, mem[A >> 2][23:16]};
                        2'b11: RD = {{24{mem[A >> 2][31]}}, mem[A >> 2][31:24]};
                    endcase
                end
                2'b01: begin // lh
                    case (A[1])
                        1'b0: RD = {{16{mem[A >> 2][15]}}, mem[A >> 2][15:0]};
                        1'b1: RD = {{16{mem[A >> 2][31]}}, mem[A >> 2][31:16]};
                    endcase
                end
                2'b10: RD = mem[A >> 2]; // lw
                2'b11: begin // lbu/lhu
                    case (A[1:0])
                        2'b00: RD = {24'b0, mem[A >> 2][7:0]};
                        2'b01: RD = {24'b0, mem[A >> 2][15:8]};
                        2'b10: RD = {24'b0, mem[A >> 2][23:16]};
                        2'b11: RD = {24'b0, mem[A >> 2][31:24]};
                    endcase
                end
                default: RD = mem[A >> 2];
            endcase
        end
    end
endmodule