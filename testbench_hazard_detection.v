`timescale 1ns / 1ps


module testbench_hazard_detection();


wire    PC_stall;  
wire    IF_ID_stall;
wire    IF_ID_flush;
wire    ID_EX_flush;
wire  [31:0] PC_add ;
  
reg ID_EX_MEMread;
reg [4:0] ID_EX_Rd;
reg [4:0] IF_ID_RsA;
 reg [4:0] IF_ID_RsB;
  reg [31:0] New_PC_add;
 reg branch;
  
  Hazard_detection_unit tb (
      .ID_EX_MEMread (ID_EX_MEMread),
      .ID_EX_Rd      (ID_EX_Rd),
      .IF_ID_RsA     (IF_ID_RsA),
      .IF_ID_RsB     (IF_ID_RsB),
      .New_PC_add    (New_PC_add),
      .branch        (branch),
      .PC_stall      (PC_stall),
      .IF_ID_stall   (IF_ID_stall),
      .IF_ID_flush   (IF_ID_flush),
      .ID_EX_flush   (ID_EX_flush),
      .PC_add        (PC_add)
  );
  
  initial
  begin 
  
  // if no load or control hazard occur 
  ID_EX_MEMread=0;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd1;
  IF_ID_RsB=5'd1;
  New_PC_add=32'hDEADBEEF;
  branch=0;
  
  #1
  
  $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);
  
  #5 
  // if load hazard exist on operand A
   ID_EX_MEMread=1;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd7;
  IF_ID_RsB=5'd1;
  New_PC_add=32'hDEADBEEF;
  branch=0;
  #1
    $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);

#5 

 // reseting the output signals by assigning no hazard 
  ID_EX_MEMread=0;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd1;
  IF_ID_RsB=5'd1;
  New_PC_add=32'hDEADBEEF;
  branch=0;
  
  #1
    $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);
#5
  // if load hazard exist on operand B
   ID_EX_MEMread=1;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd1;
  IF_ID_RsB=5'd7;
  New_PC_add=32'hDEADBEEF;
  branch=0;
  #1
    $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);

#5 
 // reseting the output signals by assigning no hazard 
  ID_EX_MEMread=0;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd1;
  IF_ID_RsB=5'd1;
  New_PC_add=32'hDEADBEEF;
  branch=0;
  
  #1
    $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);
#5
  // if no load hazard but control hazard 
   ID_EX_MEMread=1;
  ID_EX_Rd=5'd7;
  IF_ID_RsA=5'd1;
  IF_ID_RsB=5'd1;
  New_PC_add=32'hDEADBEEF;
  branch=1;
  #1
    $display("time=%t PC_stall=%b IF_ID_stall=%b IF_ID_flush=%b ID_EX_flush=%b PC_add=%h",$time ,PC_stall,IF_ID_stall,IF_ID_flush,ID_EX_flush,PC_add);
#5 $finish;
 end
  
 
 

  
endmodule
