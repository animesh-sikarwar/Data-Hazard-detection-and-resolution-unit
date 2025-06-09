`timescale 1ns / 1ps

module data_forwarding_unit(
    input  [4:0] ID_EX_rs,       // source register 1 of instruction in ID/EX pipeline register
    input  [4:0] ID_EX_rt,       // source register 2 of instruction in ID/EX register
    input  [4:0] EX_MEM_rd,      // destination register of instruction currently in EX/MEM stage
    input  [4:0] MEM_WB_rd,      // destination register of instruction currently in MEM/WB stage
    input        EX_MEM_RegWrite, // EX/MEM RegWrite control signal
    input        MEM_WB_RegWrite, // MEM/WB RegWrite control signal
    output reg [1:0] forward_A,   // select vector for ALU input A
    output reg [1:0] forward_B    // select vector for ALU input B
);

    always @(*) begin
  // Default: no bypass
  forward_A = 2'b00;
  forward_B = 2'b00;

  // --- ForwardA logic ---
  if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs))
    forward_A = 2'b10;
  else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs))
    forward_A = 2'b01;

  // --- ForwardB logic ---
  if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt))
    forward_B = 2'b10;
  else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rt))
    forward_B = 2'b01;
end


endmodule
