// Simple 5-Stage Pipelined RISC-V Core (RV32I subset)
// Supports basic arithmetic, logic, and a simple branch.
// Note: This example is simplified for educational purposes.

module riscv_core (
    input  wire         clk,
    input  wire         reset
);

  // Program Counter
  reg [31:0] pc;

  // Instruction Memory (256 words)
  reg [31:0] imem [0:255];
  // Data Memory (256 words)
  reg [31:0] dmem [0:255];

  // Register File: 32 registers (x0 is hardwired to 0)
  reg [31:0] regs [0:31];

  // Pipeline Registers
  // IF/ID
  reg [31:0] if_id_pc;
  reg [31:0] if_id_instr;
  // ID/EX
  reg [31:0] id_ex_pc;
  reg [31:0] id_ex_rs1;
  reg [31:0] id_ex_rs2;
  reg [31:0] id_ex_imm;
  reg [4:0]  id_ex_rd;
  reg [2:0]  id_ex_funct3;
  reg        id_ex_regWrite;
  // EX/MEM
  reg [31:0] ex_mem_pc;
  reg [31:0] ex_mem_alu_out;
  reg [31:0] ex_mem_rs2;
  reg [4:0]  ex_mem_rd;
  reg        ex_mem_regWrite;
  // MEM/WB
  reg [31:0] mem_wb_pc;
  reg [31:0] mem_wb_data;
  reg [4:0]  mem_wb_rd;
  reg        mem_wb_regWrite;

  // Internal signals for decoding
  wire [6:0] opcode;
  wire [4:0] rs1, rs2, rd;
  wire [2:0] funct3;
  wire [6:0] funct7;
  assign opcode  = if_id_instr[6:0];
  assign rd      = if_id_instr[11:7];
  assign funct3  = if_id_instr[14:12];
  assign rs1     = if_id_instr[19:15];
  assign rs2     = if_id_instr[24:20];
  assign funct7  = if_id_instr[31:25];

  //===========================================================================
  // Initialization
  //===========================================================================
  integer i;
  initial begin
    // Initialize PC
    pc = 0;
    // Initialize register file (x0 always 0)
    regs[0] = 0;
    for(i = 1; i < 32; i = i + 1)
      regs[i] = 0;
    // Initialize instruction memory with a simple test program:
    //  0: addi x1, x0, 5     // x1 = 5
    //  1: addi x2, x0, 10    // x2 = 10
    //  2: add  x3, x1, x2    // x3 = x1 + x2
    //  3: beq  x0, x0, -4    // infinite loop (branch to itself)
    imem[0] = 32'h00500093; // addi x1,x0,5  (opcode:0010011)
    imem[1] = 32'h00a00113; // addi x2,x0,10 (opcode:0010011)
    imem[2] = 32'h002081b3; // add  x3,x1,x2 (opcode:0110011, funct3=000, funct7=0000000)
    imem[3] = 32'he7dff06f; // beq  x0,x0,-4 (opcode:1100011)
    for (i = 4; i < 256; i = i + 1)
      imem[i] = 32'b0;
    // Initialize data memory to 0
    for (i = 0; i < 256; i = i + 1)
      dmem[i] = 32'b0;
  end

  //===========================================================================
  // IF Stage: Instruction Fetch
  //===========================================================================
  reg [31:0] instr;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 0;
    end else begin
      // Fetch instruction (word-aligned: use pc[9:2] for 256-word memory)
      instr <= imem[pc[9:2]];
      // Latch IF/ID pipeline registers
      if_id_pc    <= pc;
      if_id_instr <= instr;
      // Increment PC by 4 (word-aligned)
      pc <= pc + 4;
    end
  end

  //===========================================================================
  // ID Stage: Instruction Decode
  //===========================================================================
  always @(posedge clk) begin
    // For immediate-type instructions (e.g., ADDI), sign-extend bits [31:20]
    id_ex_imm <= {{20{if_id_instr[31]}}, if_id_instr[31:20]};
    // Read registers from register file
    id_ex_rs1 <= regs[rs1];
    id_ex_rs2 <= regs[rs2];
    id_ex_rd  <= rd;
    id_ex_pc  <= if_id_pc;

    // Simple control signal generation:
    // For opcode 0010011 (OP-IMM) and 0110011 (OP), we enable register write.
    if (opcode == 7'b0010011 || opcode == 7'b0110011)
      id_ex_regWrite <= 1;
    else
      id_ex_regWrite <= 0;

    // Pass funct3 for use in ALU operation selection
    id_ex_funct3 <= funct3;
  end

  //===========================================================================
  // EX Stage: Execute (ALU operations)
  //===========================================================================
  reg [31:0] alu_out;
  always @(posedge clk) begin
    // Default ALU operation is addition.
    // If opcode is OP-IMM (0010011), use immediate; if OP (0110011), use second register.
    if (id_ex_regWrite) begin
      if (id_ex_funct3 == 3'b000) begin
        // For subtraction in OP (0110011) with funct7 bit 5 high, perform subtraction.
        if (opcode == 7'b0110011 && funct7[5])
          alu_out <= id_ex_rs1 - id_ex_rs2;
        else
          alu_out <= id_ex_rs1 + (opcode == 7'b0010011 ? id_ex_imm : id_ex_rs2);
      end
      else if (id_ex_funct3 == 3'b111) begin
        alu_out <= id_ex_rs1 & (opcode == 7'b0010011 ? id_ex_imm : id_ex_rs2);
      end
      else if (id_ex_funct3 == 3'b110) begin
        alu_out <= id_ex_rs1 | (opcode == 7'b0010011 ? id_ex_imm : id_ex_rs2);
      end
      else begin
        alu_out <= 0;  // Other operations can be added here.
      end
    end else begin
      alu_out <= 0;
    end

    // Latch EX/MEM pipeline registers
    ex_mem_pc         <= id_ex_pc;
    ex_mem_alu_out    <= alu_out;
    ex_mem_rs2        <= id_ex_rs2;
    ex_mem_rd         <= id_ex_rd;
    ex_mem_regWrite   <= id_ex_regWrite;
  end

  //===========================================================================
  // MEM Stage: Memory Access
  //===========================================================================
  reg [31:0] mem_data;
  always @(posedge clk) begin
    // For this simple design, we assume no load/store instructions are used.
    // So, if there were a load (opcode 0000011), we would read from dmem.
    // Here we simply pass the ALU result.
    mem_data <= ex_mem_alu_out;
    
    // Latch MEM/WB pipeline registers
    mem_wb_pc       <= ex_mem_pc;
    mem_wb_data     <= mem_data;
    mem_wb_rd       <= ex_mem_rd;
    mem_wb_regWrite <= ex_mem_regWrite;
  end

  //===========================================================================
  // WB Stage: Write Back
  //===========================================================================
  always @(posedge clk) begin
    // Write back to register file (x0 is hardwired to zero)
    if (mem_wb_regWrite && (mem_wb_rd != 0))
      regs[mem_wb_rd] <= mem_wb_data;
  end

endmodule
