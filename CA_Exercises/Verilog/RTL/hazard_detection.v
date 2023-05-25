// module: Control
// Function: Generates the control signals for each one of the datapath resources

module hazard_detection(
      input  wire ID_EX_Mem_Read,
      input  wire ID_EX_Rd,
      input  wire [4:0] IF_ID_Rs1,
      input  wire [4:0] IF_ID_Rs2,
      output reg  pick_bubble

   );

   always@(*)begin

   if(ID_EX_Mem_Read && (ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))
    pick_bubble <= 1'b0;
   else
    pick_bubble <= 1'b1;

   end




endmodule

