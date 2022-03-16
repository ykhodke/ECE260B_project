module dual_core (clk, reset, mem_in, inst);

parameter num_core = 2;
parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input clk, reset;

input [2*pr*bw-1:0] mem_in;
input [16:0] inst;

wire [bw_psum+3:0] sum_out_0;
wire [bw_psum+3:0] sum_out_1;

wire tx0_req_rx1_req;
wire rx1_ack_tx0_ack;

wire tx1_req_rx0_req;
wire rx0_ack_tx1_ack;

fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance_0 (
  .clk(clk),
  .sum_out(sum_out_0),
  .mem_in(mem_in[pr*bw-1:0]),
  .out(),
  .inst(inst),
  .reset(reset),
  .rx_ack(rx0_ack_tx1_ack),
  .rx_req(tx1_req_rx0_req),
  .tx_ack(rx1_ack_tx0_ack),
  .tx_req(tx0_req_rx1_req),
  .tx_sum_in(sum_out_1)
);

fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance_1 (
  .clk(clk),
  .sum_out(sum_out_1),
  .mem_in(mem_in[2*pr*bw-1:pr*bw]),
  .out(),
  .inst(inst),
  .reset(reset),
  .rx_ack(rx1_ack_tx0_ack),
  .rx_req(tx0_req_rx1_req),
  .tx_ack(rx0_ack_tx1_ack),
  .tx_req(tx1_req_rx0_req),
  .tx_sum_in(sum_out_0)
);


endmodule