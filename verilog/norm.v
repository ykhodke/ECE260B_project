// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module norm (clk, in, out, sum_out, syncd_sum_in, sync_sum, div, wr, o_full, reset, o_ready);

parameter bw = 8;
parameter width = 1;
parameter sum_bw = 2*bw + 4; //bw+log_2(16)

input  clk, reset;

input wr;
input div;
input sync_sum;

input [bw-1:0] in;
input [sum_bw-1:0] syncd_sum_in;

output o_full;
output o_ready;
output [2*bw-1:0] out;
output [sum_bw-1:0] sum_out;

reg [sum_bw-1:0] sum_q;
reg [sum_bw:0] cumm_sum;
reg [2*bw-1:0] out_q;


wire [bw-1:0] fifo_out;
wire empty;
wire full;
wire out_temp;

assign out = out_q;
assign out_temp = {fifo_out} / sum_q;
assign sum_out = sum_q;


fifo_top #(.bw(bw), .width(width)) fifo_top_instance (
  .clk(clk),
  .rd(div), //Add the correct variable / value in the bracket
  .wr(wr),
  .in(in),
  .out(fifo_out),
  .reset(reset)
);

always @ (posedge clk) begin
  if (reset) begin
    sum_q <= 0;
    out_q <= 0;
  end
  else begin
    // wr to increment sum, sync_sum for sum_c0 + sum_c1, div for division
    if (wr) sum_q <= sum_q + in;
    else if (sync_sum) cumm_sum <= syncd_sum_in + sum_q;
    else if (div) out_q <= out_temp;
  end
end

endmodule
