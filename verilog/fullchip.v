// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, sum_out, mem_in, out, inst, reset, rx_ack, rx_req, tx_ack, tx_req, tx_sum_in);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk; 
input  [pr*bw-1:0] mem_in; 
input  [16:0] inst; 
input  reset;

//handshake things
input [bw_psum+3:0] tx_sum_in; //sum recieved from the other core
input rx_req;
output rx_ack;

input tx_ack;
output tx_req;
//
output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
  .clk(clk),
  .sum_out(sum_out),
  .mem_in(mem_in),
  .out(),
  .inst(inst),
  .reset(reset),
  .rx_ack(rx_ack),
  .rx_req(rx_req),
  .tx_ack(tx_ack),
  .tx_req(tx_req),
  .tx_sum_in(tx_sum_in)
);


endmodule
