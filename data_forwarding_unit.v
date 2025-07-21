`timescale 1ns / 1ps

module data_forwarding_unit(
    input  [4:0] ID_EX_rsA,       // source  register A of instruction in ID/EX pipeline register
    input  [4:0] ID_EX_rsB,       // source register B of instruction in ID/EX register
    input  [4:0] EX_MEM_Rd,      // destination register of instruction currently in EX/MEM stage
    input  [4:0] MEM_WB_Rd,      // destination register of instruction currently in MEM/WB stage
    input        EX_MEM_RegWrite, // EX/MEM RegWrite control signal to indicate write operation 
    input        MEM_WB_RegWrite, // MEM/WB RegWrite control signal to indicate write operation 
    output reg [1:0] forward_A,   // select line for 1st ALU operand  A
    output reg [1:0] forward_B    // select line for 2nd ALU operand B
);
    //
    // forwarding logic to use mux to select the operand from ID/EX , EX/MEM,MEM/WB pipeline register
    always @(*) begin
 
  forward_A = 2'b00;// select operand from ID/EX reg
  forward_B = 2'b00;

  // Logic to forward data for operand A 
  if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_rsA))
    forward_A = 2'b01; // 01 indicates to select data from EX_MEM pipeline register
  else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_rsA))
    forward_A = 2'b10;//10 transfer data from MEM_WB register 

  // Logic to forward data for operand B
  if (EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_rsB))
    forward_B = 2'b01;
  else if (MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_rsB))
    forward_B = 2'b10;
end


endmodule
