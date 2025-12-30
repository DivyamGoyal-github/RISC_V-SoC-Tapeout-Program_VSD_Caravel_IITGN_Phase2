module buff_flash_clkrst (
	`ifdef USE_POWER_PINS
		inout VPWR,
		inout VGND,
	`endif
	input[11:0] in_n, 
	input[2:0] in_s, 
	output[11:0] out_s, 
	output[2:0] out_n);

        // SCL180 buffer: Synthesis will map to FS120 buf equivalent
        assign out_s = in_n;
        assign out_n = in_s;
 
endmodule
