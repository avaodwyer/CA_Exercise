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


wire  [63:0]  IF_ID1;
wire  [31:0]  IF_ID2;
wire          ID_EX_ALUSrc;
wire  [1:0]        ID_EX_ALUOp;
wire          ID_EX_Branch;
wire          ID_EX_MemRead;
wire          ID_EX_MemWrite;
wire          ID_EX_MemtoReg;
wire          ID_EX_RegWrite;
wire          EX_MEM_Zflag;
wire          EX_MEM_Branch;
wire          EX_MEM_MemWrite;
wire          EX_MEM_MemRead;
wire          EX_MEM_MemtoReg;
wire          EX_MEM_RegWrite;
wire          MEM_WB_MemtoReg;
wire          MEM_WB_RegWrite;
wire          EX_MEM_jump;
wire          ID_EX_jump;

wire  [63:0]  ID_EX1;
wire  [63:0]  ID_EX2;
wire  [63:0]  ID_EX3;
wire  [63:0]  ID_EX4;
wire  [4:0]   ID_EX5;
wire  [4:0]   ID_EX6;
wire  [4:0]   ID_EX_Rs1;
wire  [4:0]   ID_EX_Rs2;
wire          EX_MEM_WB;
wire          EX_MEM_M;
wire          EX_MEM_Z;
wire  [63:0]  EX_MEM1_1;
wire  [63:0]  EX_MEM1_2;
wire  [63:0]  EX_MEM2;
wire  [63:0]  EX_MEM3;
wire  [4:0]  EX_MEM4;
wire         MEM_WB_WB;
wire  [63:0]  MEM_WB1;
wire  [63:0]  MEM_WB2;
wire  [4:0]   MEM_WB3;

wire signed [63:0] immediate_extended;
wire [1:0] mux_con_1;
wire [1:0] mux_con_2;

reg_arstn_en#(
    .DATA_W(96)
)IF_ID(
    .clk(clk),
    .arst_n(arst_n),
    .din({updated_pc,instruction}),
    .en(enable),
    .dout({IF_ID1,IF_ID2})
);




reg_arstn_en#(
    .DATA_W(285)
)ID_EX(
    .clk(clk),
    .arst_n(arst_n),
    .din({alu_src,alu_op,branch,mem_write,mem_read,mem_2_reg,reg_write,jump,IF_ID1,regfile_rdata_1,regfile_rdata_2,immediate_extended,IF_ID2[30],IF_ID2[25],IF_ID2[14:12],IF_ID2[11:7],IF_ID2[19:15],IF_ID2[24:20]}),
    .en(enable),
    .dout({ID_EX_ALUSrc,ID_EX_ALUOp,ID_EX_Branch,ID_EX_MemWrite,ID_EX_MemRead,ID_EX_MemtoReg,ID_EX_RegWrite,ID_EX_jump,ID_EX1,ID_EX2,ID_EX3,ID_EX4,ID_EX5,ID_EX6,ID_EX_Rs1,ID_EX_Rs2})
);

reg_arstn_en#(
    .DATA_W(268)
)EX_MEM(
    .clk(clk),
    .arst_n(arst_n),
    .din({zero_flag,ID_EX_Branch,ID_EX_MemWrite,ID_EX_MemRead,ID_EX_MemtoReg,ID_EX_RegWrite,ID_EX_jump,branch_pc,jump_pc,alu_out,ID_EX3,ID_EX6}),
    .en(enable),
    .dout({EX_MEM_Zflag,EX_MEM_Branch,EX_MEM_MemWrite,EX_MEM_MemRead,EX_MEM_MemtoReg,EX_MEM_RegWrite,EX_MEM_jump,EX_MEM1_1,EX_MEM1_2,EX_MEM2,EX_MEM3,EX_MEM4})
);

reg_arstn_en#(
    .DATA_W(135)
)MEM_WB(
    .clk(clk),
    .arst_n(arst_n),
    .din({EX_MEM_MemtoReg,EX_MEM_RegWrite,mem_data,EX_MEM2,EX_MEM4}),
    .en(enable),
    .dout({MEM_WB_MemtoReg,MEM_WB_RegWrite,MEM_WB1,MEM_WB2,MEM_WB3})
);



immediate_extend_unit immediate_extend_u(
    .instruction         (IF_ID2),
    .immediate_extended  (immediate_extended)
);


pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (EX_MEM1_1 ),
   .jump_pc   (EX_MEM1_2 ),
   .zero_flag (EX_MEM_Zflag ),
   .branch    (EX_MEM_Branch    ),
   .jump      (EX_MEM_jump      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

forwarding_unit #()
   forwarding_unit(
    .clk     (clk),
    .ID_EX_Rs1    (ID_EX_Rs1),
    .ID_EX_Rs2   (ID_EX_Rs2),
    .EX_MEM_Rd   (EX_MEM4),
    .MEM_WB_Rd   (MEM_WB3),
    .MEM_WB_RegWrite   (MEM_WB_RegWrite),
    .EX_MEM_RegWrite   (EX_MEM_RegWrite),
    .mux_con_1(mux_con_1),
    .mux_con_2(mux_con_2)
);

wire [63:0] mux_out_1_a;
wire [63:0] mux_out_2_a;
wire [63:0] mux_out_1_b;
wire [63:0] mux_out_2_b;
mux_2 #(
   .DATA_W(64)
) alu_mux_1_1 (
   .input_a  (regfile_wdata),
   .input_b  (ID_EX2),
   .select_a (mux_con_1[1]),
   .mux_out  (mux_out_1_a)
);


mux_2 #(
   .DATA_W(64)
) alu_mux_1_2 (
   .input_b  (mux_out_1_a),
   .input_a  (EX_MEM2),
   .select_a (mux_con_1[0]),
   .mux_out  (mux_out_1_b)
);

mux_2 #(
   .DATA_W(64)
) alu_mux_2_1 (
   .input_b  (ID_EX3),
   .input_a  (regfile_wdata),
   .select_a (mux_con_2[1]),
   .mux_out  (mux_out_2_a)
);


mux_2 #(
   .DATA_W(64)
) alu_mux_2_2 (
   .input_b  (mux_out_2_a),
   .input_a  (EX_MEM2),
   .select_a (mux_con_2[0]),
   .mux_out  (mux_out_2_b)
);

/*
hazard_detection #(
) hazard_detection(
   .ID_EX_Mem_Read (),
   .ID_EX_Rd(),
   .IF_ID_Rs1(),
   .IF_ID_Rs2(),
   .pick_bubble()

);


mux_2 #(
   .DATA_W(7)
) Haz_det_mux (
   .input_b  (), // Bubble
   .input_a  (), // control line
   .select_a (), // Pick Bubble 0 if bubble, 1 if want control line
   .mux_out  () // into ID EX stage
);

*/


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
   .addr     (EX_MEM2        ),
   .wen      (EX_MEM_MemWrite),
   .ren      (EX_MEM_MemRead ),
   .wdata    (EX_MEM3        ),
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
   .reg_write(MEM_WB_RegWrite   ),
   .raddr_1  (IF_ID2[19:15]),
   .raddr_2  (IF_ID2[24:20]),
   .waddr    (MEM_WB3 ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);

alu_control alu_ctrl(
   .func7_5_0        (ID_EX5[4:3]),
   .func3          (ID_EX5[2:0]),
   .alu_op         (ID_EX_ALUOp ),
   .alu_control    (alu_control       )
);

mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (ID_EX4),
   .input_b (mux_out_2_b ),
   .select_a(ID_EX_ALUSrc       ),
   .mux_out (alu_operand_2     )
);

alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (mux_out_1_b ),
   .alu_in_1 (alu_operand_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);

mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (MEM_WB1     ),
   .input_b  (MEM_WB2     ),
   .select_a (MEM_WB_MemtoReg),
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
