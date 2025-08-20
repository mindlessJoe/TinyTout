//-----------------------------------------------------------------------------
//
// Title       : extender_module
// Design      : MIPS_PROCESSOR
// Author      : mandin
// Company     : UNIVAQ
//
//-----------------------------------------------------------------------------
//
// File        : C:/Users/bobla/Documents/HDLDesign/Tesina_PSEI/MIPS_PROCESSOR/src/extender.v
// Generated   : Tue Aug  5 16:30:58 2025
// From        : Interface description file
// By          : ItfToHdl ver. 1.0
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

	//{{ Section below this comment is automatically maintained
//    and may be overwritten
//{module {extender_module}}

module extender_module ( immediate ,world );

input [15:0] immediate;
wire [15:0] immediate;
output [31:0] world;
wire [31:0] world;

//}} End of automatically maintained section

// Enter your statements here //

assign world = {{16{immediate[15]}}, immediate};

endmodule
