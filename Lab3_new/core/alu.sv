//This is the ALU module of the core, op_code_e is defined in definitions.v file
// Version shown in week 3 classes, as corrected in Friday's class.
// Includes new enum op_mnemonic to make instructions appear literally on waveform.
`include "definitions.sv"

module alu (input  [31:0] rd_i 
           ,input  [31:0] rs_i 
           ,input  instruction_s op_i
           ,output logic [31:0] result_o
           ,output logic jump_now_o);

// Create an enumerated variable which can be used to display the
//  names of the instructions on the waveform viewer.
// ADDU = 5'h0, SUBU = 5'h1, etc.
// You can fill in additional instructions, as desired.
// Note jump at BEQZ (why?) 
  typedef enum logic[4:0] {
    ADDU, SUBU, SLLV, SRAV, SRLV, AND, OR, NOR,
    SLT,  SLTU, MOV, BEQZ = 5'h10, BNEQZ, BGTZ, BLTZ} 
    op_mne;				              // declare type
  op_mne op_mnemonic;	              // declare variable of that type 

always_comb
  begin
    result_o   = 32'd0;               // default or NOP result
    jump_now_o = 1'b0; 				  // default or NOP result

    unique casez (op_i)
      `kADDU:  result_o   = rd_i +  rs_i;
      `kSUBU:  result_o   = rd_i -  rs_i;
      `kSLLV:  result_o   = rd_i << rs_i[4:0];
      `kSRAV:  result_o   = $signed (rd_i)   >>> rs_i[4:0];
      `kSRLV:  result_o   = $unsigned (rd_i) >>  rs_i[4:0]; 
      `kAND:   result_o   = rd_i & rs_i;
      `kOR:    result_o   = rd_i | rs_i;
      `kNOR:   result_o   = ~ (rd_i|rs_i);
      `kSLT:   result_o   = ($signed(rd_i)<$signed(rs_i))     ? 32'd1 : 32'd0;
      `kSLTU:  result_o   = ($unsigned(rd_i)<$unsigned(rs_i)) ? 32'd1 : 32'd0;
      `kBEQZ:  jump_now_o = (rd_i==32'd0)                     ? 1'b1  : 1'b0;
      `kBNEQZ: jump_now_o = (rd_i!=32'd0)                     ? 1'b1  : 1'b0;
      `kBGTZ:  jump_now_o = ($signed(rd_i)>$signed(32'd0))    ? 1'b1  : 1'b0;
      `kBLTZ:  jump_now_o = ($signed(rd_i)<$signed(32'd0))    ? 1'b1  : 1'b0;
      
      `kMOV, `kLW, `kLBU, `kJALR, `kBAR:   
               result_o   = rs_i;
      `kSW, `kSB:    
               result_o   = rd_i;
      default: 
        begin 
          result_o   = 32'd0; 
          jump_now_o = 1'b0; 
        end
    endcase
// every new instruction call updates op_mnemonic
// Note op_i is a struct; op_i.opcode calls opcode element thereof
// op_mne' is a type casting operation (binary to enum here)
	op_mnemonic = op_mne'(op_i.opcode);
  end

endmodule 
