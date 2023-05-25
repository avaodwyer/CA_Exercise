module forwarding_unit(
    input wire clk,
    input wire [4:0] ID_EX_Rs1,
    input wire [4:0] ID_EX_Rs2,
    input wire [4:0] EX_MEM_Rd,
    input wire [4:0] MEM_WB_Rd,
    input wire MEM_WB_RegWrite,
    input wire EX_MEM_RegWrite,
    output reg [1:0] mux_con_1,
    output reg [1:0] mux_con_2
);

always@(*) begin
    if (((MEM_WB_RegWrite == 1'b1) && (MEM_WB_Rd != 5'b0) && (MEM_WB_Rd == ID_EX_Rs1)) && !(EX_MEM_RegWrite && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rs1)))
        mux_con_1 <= 2'b10; // the ID/EX stage is just bypass the value
    else if ( (EX_MEM_RegWrite == 1'b1) && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rs1)) // this is for the ID/EX stage
        mux_con_1 <= 2'b01;
    else
        mux_con_1 <= 2'b00;
    if (((MEM_WB_RegWrite == 1'b1) && (MEM_WB_Rd != 5'b0) && (MEM_WB_Rd == ID_EX_Rs2)) && !(EX_MEM_RegWrite && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rs2)))
        mux_con_2 <= 2'b10;
    else if ( (EX_MEM_RegWrite == 1'b1) && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rs2))
        mux_con_2 <= 2'b01;
    else
        mux_con_2 <= 2'b00;

end

endmodule
