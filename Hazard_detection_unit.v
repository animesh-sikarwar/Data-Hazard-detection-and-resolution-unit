`timescale 1ns / 1ps

    module Hazard_detection_unit(
    input ID_EX_MEMread,
    input [4:0] ID_EX_rt,
    input [4:0] IF_ID_rs,
    input [4:0] IF_ID_rt,
    input [31:0] pc ,
    input [15:0] immediate,
    input branch_taken,
    output reg ID_EX_flush,
    output reg PC_write,
     output reg IF_ID_write,
    output reg [31:0]BTA
    
    );
    
    wire [31:0] imm32={{16{immediate[15]}},immediate};
    wire [31:0] offset = imm32<<2;// convert word to byte
    reg comparator;
    always @(*) 
    begin 
    PC_write=1'b1;
    IF_ID_write=1'b1;
    ID_EX_flush=1'b0;
    BTA=32'd0;
    
    // load use hazard 
    if(ID_EX_MEMread && (ID_EX_rt==IF_ID_rs||ID_EX_rt==IF_ID_rt))// ALU instruction after load instruction  
    begin
    
    PC_write=1'b0;
    IF_ID_write=1'b0;
    ID_EX_flush=1'b1;
    end
    
    else if(branch_taken)
    begin 
    // branch target address calculation 
    BTA= pc+32'd4+offset;
    
    PC_write=1'b0;
    IF_ID_write=1'b0;
    ID_EX_flush=1'b1;
      end
    end
  endmodule  
    
    
    
    
    
    
    
   
    
    
    
   
              
                 
     


 
   