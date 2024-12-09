module crc32(
  input logic clk,
  input logic reset,                  // Reset signal
  input logic [31:0] data_in,         // 32-bit inputs (total 3232 bits)
  input logic input_valid,            // Valid signal
  output logic [31:0] crc32_out,      // 32-bit CRC output
  output logic output_valid           // Valid output signal
);

  logic [31:0] crc32_val;
  integer count;

  localparam CRC32POL = 32'hEDB88320; // Ethernet CRC-32 Polynomial, reversed bits

  // Sequential block triggered by clock or reset
  always_ff @(posedge clk or posedge reset) begin
    // reset initial values and count
    if (reset) begin
      crc32_val <= 32'hffffffff;  // Reset CRC value
      count <= 0;
      crc32_out <= 32'h0;
      output_valid <= 0;
    end else begin
      if (count < 101 && input_valid) begin
        crc32_val <= genCRC32(crc32_val, data_in); // Update CRC value
        count <= count + 1;
      end else if (count == 101) begin
        crc32_out <= crc32_val ^ 32'hffffffff;  // Invert final result
        output_valid <= 1;                      // Output is valid
        count <= 0;                             // Reset count for next block of data
      end
    end
  end

  // Function to compute CRC32 for a single 32-bit input
  function automatic logic [31:0] genCRC32(
    input logic [31:0] crc_val,        // Current CRC value
    input logic [31:0] databyte_stream // Single 32-bit input
  );
    logic [7:0] byte_array [3:0];     // Array to split each 32-bit value into 8-bit bytes
    logic [31:0] next_crc_val = crc_val;

    // Split the 32-bit input into four 8-bit bytes
    byte_array[0] = databyte_stream[31:24]; // MSB
    byte_array[1] = databyte_stream[23:16]; // Next byte
    byte_array[2] = databyte_stream[15:8];  // Next byte
    byte_array[3] = databyte_stream[7:0];   // LSB

    // Process each byte
    for (int k = 0; k < 4; k++) begin
      logic [7:0] data = byte_array[k];
      // Process each bit from LSB to MSB
      for (int j = 0; j < 8; j++) begin
        if (next_crc_val[0] != data[0]) begin
          next_crc_val = (next_crc_val >> 1) ^ CRC32POL;
        end else begin
          next_crc_val >>= 1;
        end
        data >>= 1; // Shift data to process the next bit
      end
    end
    return next_crc_val;
  endfunction : genCRC32

endmodule

