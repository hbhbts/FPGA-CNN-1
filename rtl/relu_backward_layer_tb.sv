`timescale 1ns/1ns

module relu_backward_layer_tb();

	parameter CYCLE = 2;
	parameter NEG_SLOPE = 0.0;
	parameter WIDTH = 8;
	
	parameter NUM_TESTS 	= 8;
	parameter MEM_SIZE		= NUM_TESTS*2*WIDTH; 

	reg clk, reset;
	logic [31:0] in_vec [WIDTH-1:0];
	logic [31:0] out_vec [WIDTH-1:0];
	reg [31:0] mem [MEM_SIZE];
	
	initial begin
		clk = 0;
		$readmemh("/home/b/FPGA-CNN/test/test_data/relu_backward_test_data.hex", mem);
	end
	
	//forever cycle the clk
	always begin
		#(CYCLE) clk = ~clk;
		
	end

	relu_backward_layer #(.WIDTH(8), .NEGATIVE_SLOPE(NEG_SLOPE) )
							relu( .clk(clk), .reset(reset), .in_vec(in_vec), .out_vec(out_vec) );

	int i, j;
	initial begin
		reset = 0;
		//read the test data generated by Python into memory
		#20000000;
		
		//for all test cases
		for (i = 0; i < 6*WIDTH; i = i+(2*WIDTH)) begin
			//for each value in input vector
			for (j = 0; j < WIDTH; j++) begin
				//use value from file as input to module
				in_vec[j] = mem[i+j];
			end
			//wait for it...
			#1000;
			//for each value in output vector (same size as input)
			for (j = 0; j < WIDTH; j++) begin
				//check output of module against value calculated by Python
				$display("b: %h\tm:%h", out_vec[j], mem[i+j+WIDTH]);
				assert( out_vec[j] == mem[i+j+WIDTH] );
			end
			
		end
		$display("############################################\n");
		$display("All tests passed!\n");
		$display("############################################\n");
	end
endmodule

