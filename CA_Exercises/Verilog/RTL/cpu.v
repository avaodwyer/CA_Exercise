//Module: CPU
//Function: CPU is the top design of the RISC-V processor

//Inputs:
//	clk: main clock
//	arst_n: reset 
// enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory

// Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[63:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[63:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [63:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[63:0]  rdata_ext_2

   );

wire              zero_flag;
wire [      63:0] branch_pc,updated_pc,current_pc,jump_pc;
wire [      31:0] instruction;
wire [       1:0] alu_op;
wire [       3:0] alu_control;
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, jump;
wire [       4:0] regfile_waddr;
wire [      63:0] regfile_wdata,mem_data,alu_out,
                  regfile_rdata_1,regfile_rdata_2,
                  alu_operand_2;

wire signed [63:0] immediate_extended;

immediate_extend_unit immediate_extend_u(
    .instruction         (instruction),
    .immediate_extended  (immediate_extended)
);

//declare registers here
reg  [63:0]  IF_ID1;
reg  [31:0]  IF_ID2;
reg          ID_EX_WB;
reg          ID_EX_M;
reg          ID_EX_EX;
reg  [63:0]  ID_EX1;
reg  [63:0]  ID_EX2;
reg  [63:0]  ID_EX3;
reg  [63:0]  ID_EX4;
reg  [4:0]   ID_EX5;
reg  [4:0]   ID_EX6;
reg          EX_MEM_WB;
reg          EX_MEM_M;
reg          EX_MEM_Z;
reg  [63:0]  EX_MEM1;
reg  [63:0]  EX_MEM2;
reg  [63:0]  EX_MEM3;
reg  [4:0]  EX_MEM4;
reg         MEM_WB_WB;
reg  [63:0]  MEM_WB1;
reg  [63:0]  MEM_WB2;
reg  [4:0]   MEM_WB3;

always@(posedge clk)
begin
   IF_ID1 <= updated_pc;
   ID_EX1 <= IF_ID1;
   IF_ID2 <= instruction;
   // control lines needed here
   ID_EX2 <= regfile_rdata_1;
   ID_EX3 <= regfile_rdata_2;
   ID_EX4 <= immediate_extended;
   ID_EX5 <= {IF_ID2[30],IF_ID2[25],IF_ID2[14:12]};
   ID_EX6 <= IF_ID2[11:7];

end

pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc ),
   .jump_pc   (jump_pc   ),
   .zero_flag (zero_flag ),
   .branch    (branch    ),
   .jump      (jump      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

sram_BW32 #(
   .ADDR_W(9 )
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

sram_BW64 #(
   .ADDR_W(10)
) data_memory(
   .clk      (clk            ),
   .addr     (alu_out        ),
   .wen      (mem_write      ),
   .ren      (mem_read       ),
   .wdata    (regfile_rdata_2),
   .rdata    (mem_data       ),   
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);

control_unit control_unit(
   .opcode   (IF_ID2[6:0]),
   .alu_op   (alu_op          ),
   .reg_dst  (reg_dst         ),
   .branch   (branch          ),
   .mem_read (mem_read        ),
   .mem_2_reg(mem_2_reg       ),
   .mem_write(mem_write       ),
   .alu_src  (alu_src         ),
   .reg_write(reg_write       ),
   .jump     (jump            )
);

register_file #(
   .DATA_W(64)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write         ),
   .raddr_1  (IF_ID2[19:15]),
   .raddr_2  (IF_ID2[24:20]),
   .waddr    ( ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);

alu_control alu_ctrl(
   .func7_5_0        (ID_EX5[4:3]),
   .func3          (ID_EX5[2:0]),
   .alu_op         (alu_op            ),
   .alu_control    (alu_control       )
);

mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (ID_EX4),
   .input_b (regfile_rdata_2    ),
   .select_a(alu_src           ),
   .mux_out (alu_operand_2     )
);

alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (regfile_rdata_1 ),
   .alu_in_1 (alu_operand_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);

mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (mem_data     ),
   .input_b  (alu_out      ),
   .select_a (mem_2_reg    ),
   .mux_out  (regfile_wdata)
);

branch_unit#(
   .DATA_W(64)
)branch_unit(
   .updated_pc         (ID_EX1),
   .immediate_extended (ID_EX4),
   .branch_pc          (branch_pc         ),
   .jump_pc            (jump_pc           )
);


endmodule


