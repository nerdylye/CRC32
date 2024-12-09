module crc32_tb;
  logic clk;
  logic reset;
  logic input_valid;
  logic [31:0] data_in;
  logic [31:0] crc32_out;
  logic output_valid;

  // Instantiate the CRC32 module
  crc32 uut (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .input_valid(input_valid),
    .crc32_out(crc32_out),
    .output_valid(output_valid)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
  end

  // Test stimulus
  initial begin
    // Initial reset
    reset = 1;
    input_valid = 0;
    #10 reset = 0; // De-assert reset after 10ns

    for (int i=0 ; i<101 ; i++) begin
      input_valid = 1;
      data_in = 32'h12345678 + i;
      #10;
    end
    input_valid = 0;
    #50 $finish;
  end

  // Monitor CRC output
  initial begin
    $monitor("Time: %0t | crc32_out = %h | output_valid = %b", $time, crc32_out, output_valid);
  end
endmodule

