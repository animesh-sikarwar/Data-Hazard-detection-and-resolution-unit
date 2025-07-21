`timescale 1ns / 1ps

    module Hazard_detection_unit(
    input ID_EX_MEMread,// instruction will read MEM  (Load use)
    input [4:0] ID_EX_Rd,
    input [4:0] IF_ID_RsA,
    input [4:0] IF_ID_RsB,
    input [31:0] New_PC_add,
    input branch,
    
    output reg    PC_stall,          
    output reg    IF_ID_stall,       
    output reg    IF_ID_flush,      
    output reg    ID_EX_flush,       
    output reg [31:0] PC_add  
     );
    always @(*) 
   begin 
    PC_stall=1'b0;
    IF_ID_stall=1'b0;
    IF_ID_flush=1'b0;
    ID_EX_flush=1'b0;
    PC_add =32'd0;
    // load use hazard 
    if(ID_EX_MEMread && (ID_EX_Rd==IF_ID_RsA||ID_EX_Rd==IF_ID_RsB))// ALU instruction after load instruction  
    begin
    
    PC_stall=1'b1;
    IF_ID_stall=1'b1;
    ID_EX_flush=1'b1;
    
    end
    if(branch)begin
    PC_add=New_PC_add;
    IF_ID_flush=1'b1;// taking branch decision at the end of ID stage
    end
    end
    endmodule
