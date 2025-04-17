module hazard_detection (
    input id_ex_mem_read,
    input [4:0] id_ex_rd, if_id_rs1, if_id_rs2,
    output reg stall
);
    always @(*) begin
        if (id_ex_mem_read && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2))
            stall = 1; // Stall for load-use hazard
        else
            stall = 0;
    end
endmodule