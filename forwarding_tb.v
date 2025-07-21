`timescale 1ns / 1ps


module forwarding_tb();

reg  [4:0] ID_EX_rsA;      
    reg  [4:0] ID_EX_rsB;      
    reg  [4:0] EX_MEM_Rd;      
    reg  [4:0] MEM_WB_Rd;      
    reg        EX_MEM_RegWrite; 
    reg        MEM_WB_RegWrite; 
    wire  [1:0] forward_A;   
    wire  [1:0] forward_B;
    
   data_forwarding_unit tb1 (
    .ID_EX_rsA        (ID_EX_rsA),
    .ID_EX_rsB        (ID_EX_rsB),
    .EX_MEM_Rd        (EX_MEM_Rd),
    .MEM_WB_Rd        (MEM_WB_Rd),
    .EX_MEM_RegWrite  (EX_MEM_RegWrite),
    .MEM_WB_RegWrite  (MEM_WB_RegWrite),
    .forward_A        (forward_A),
    .forward_B        (forward_B)
);

initial 
begin
// no data forwarding required by default ALU recieves data from ID/EX stage 
ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd2;
MEM_WB_Rd=5'd3;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=0; 
 #1
  
  $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
  
  #5
  // data forwarding for register A from EX_MEM register
  ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd7;
MEM_WB_Rd=5'd3;
EX_MEM_RegWrite=1;
 MEM_WB_RegWrite=0;
 #1
 $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
 #5
 
 //reseting output signal by provinding no forwarding
 ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd2;
MEM_WB_Rd=5'd3;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=0; 
 #1
  
  $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
  
  #5
  // data forwarding for register A from MEM/WB register
  ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd4;
MEM_WB_Rd=5'd7;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=1;
 #1
 $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
 #5
 
 //reseting output signal by provinding no forwarding
 ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd2;
MEM_WB_Rd=5'd3;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=0; 
 #1
  
  $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
  
  // data forwarding for register B from MEM/WB stage
  ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd7;
MEM_WB_Rd=5'd1;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=1;
 #1
 $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
 #5
 
 //reseting output signal by provinding no forwarding
 ID_EX_rsA=5'd7;
ID_EX_rsB=5'd1;
EX_MEM_Rd=5'd2;
MEM_WB_Rd=5'd3;
EX_MEM_RegWrite=0;
 MEM_WB_RegWrite=0; 
 #1
  
  $display("time=%t forward_A=%b forward_B=%b ",$time ,forward_A,forward_B);
 #5 $finish; 
      
end
endmodule
