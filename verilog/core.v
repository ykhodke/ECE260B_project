// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, mem_in, out, inst, reset, rx_ack, rx_req, tx_ack, tx_req, tx_sum_in);

parameter bw = 8;
parameter pr = 16;
parameter col = 8;
parameter bw_psum = 2*bw+4;

//handshake things
input [bw_psum+3:0] tx_sum_in; //sum recieved from the other core
input rx_req;
output rx_ack;

input tx_ack;
output tx_req;
//

output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;

input clk, reset;
input [pr*bw-1:0] mem_in;
input [16:0] inst;

wire  ofifo_rd;
wire  [col-1:0] fifo_wr;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;

wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] pmem_out;

wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [3:0] qkmem_add;
wire  [3:0] pmem_add;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr;

// custom declarations
reg [2:0] sel_norm_mux;
reg start_sel_cnt, start_sel_cnt_q;

reg tx_ack_q;

reg  send_data;
reg  send_data_q;
wire send_data_2p;

wire [bw_psum+3:0] syncd_sum_in;

wire [bw_psum-1:0] norm_in;
wire [2*bw_psum-1:0] norm_out;

reg norm_div;
reg norm_div_q;

wire norm_sync_sum;
wire norm_wr;
wire norm_o_full;
wire norm_o_ready;
wire norm_o_empty;
//

assign ofifo_rd   = inst[16];
assign qkmem_add  = inst[15:12];
assign pmem_add   = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = fifo_out;

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
  .in(mac_in), 
  .clk(clk), 
  .reset(reset), 
  .inst(inst[7:6]),     
  .fifo_wr(fifo_wr),     
  .out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
  .reset(reset),
  .clk(clk),
  .in(array_out),
  .wr(fifo_wr),
  .rd(ofifo_rd),
  .o_valid(fifo_valid),
  .out(fifo_out)
);


sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
  .CLK(clk),
  .D(mem_in),
  .Q(qmem_out),
  .CEN(!(qmem_rd||qmem_wr)),
  .WEN(!qmem_wr), 
  .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
  .CLK(clk),
  .D(mem_in),
  .Q(kmem_out),
  .CEN(!(kmem_rd||kmem_wr)),
  .WEN(!kmem_wr), 
  .A(qkmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
  .CLK(clk),
  .D(pmem_in),
  .Q(pmem_out),
  .CEN(!(pmem_rd||pmem_wr)),
  .WEN(!pmem_wr), 
  .A(pmem_add)
);

always @(posedge clk) begin
  if(reset) begin
    sel_norm_mux <= 0;
    start_sel_cnt <= 0;
  end
  else if(pmem_rd) begin
    start_sel_cnt <= 1'b1;
  end
  else if((~pmem_rd) & start_sel_cnt) begin
    if(sel_norm_mux == 3'b111) begin
      sel_norm_mux <= 3'b0;
      start_sel_cnt <= 1'b0;
    end
    else begin
      sel_norm_mux <= sel_norm_mux + 3'b1;
    end
  end
end

always @(posedge clk) begin
  start_sel_cnt_q <= start_sel_cnt;
end

always @(posedge clk) begin
  if (reset) begin
    send_data <= 1'b0;
  end
  else begin
    if ( ~(start_sel_cnt) & start_sel_cnt_q ) send_data <= 1'b1;
    else begin
      send_data_q <= send_data;
      send_data <= 1'b0;
    end 
  end
end

assign send_data_2p = send_data_q | send_data;

assign norm_wr = start_sel_cnt;

fifo_mux_8_1 #(.bw(bw_psum), .simd(1)) mux_norm_load0 (
  .in0(pmem_out[1*bw_psum-1 : 0*bw_psum]), 
  .in1(pmem_out[2*bw_psum-1 : 1*bw_psum]),
  .in2(pmem_out[3*bw_psum-1 : 2*bw_psum]),
  .in3(pmem_out[4*bw_psum-1 : 3*bw_psum]),
  .in4(pmem_out[5*bw_psum-1 : 4*bw_psum]),
  .in5(pmem_out[6*bw_psum-1 : 5*bw_psum]),
  .in6(pmem_out[7*bw_psum-1 : 6*bw_psum]),
  .in7(pmem_out[8*bw_psum-1 : 7*bw_psum]),
  .sel(sel_norm_mux),
  .out(norm_in)
);

norm #(.bw(bw_psum), .sum_bw(bw_psum+4), .width(1)) norm_core0  (
  .clk(clk), 
  .in(norm_in), 
  .out(norm_out),
  .sum_out(sum_out),
  .syncd_sum_in(syncd_sum_in),
  .sync_sum(norm_sync_sum),
  .div(norm_div_q), 
	.wr(norm_wr), 
  .o_full(norm_o_full), 
  .reset(reset), 
  .o_ready(norm_o_ready),
  .o_empty(norm_o_empty)
);

handshake #(.data_bw(bw_psum+4)) handshake_inst(
  .clk(clk),
  .reset(reset),
  .send_data(send_data_2p),
  .rx_req(rx_req),
  .rx_ack(rx_ack),
  .rx_data(tx_sum_in),
  .tx_ack(tx_ack),
  .tx_req(tx_req),
  .received_data(syncd_sum_in)
);

always @(posedge clk) begin
  tx_ack_q <= tx_ack;
  norm_div <= norm_sync_sum;
  if (norm_o_empty & norm_div_q) begin
    norm_div_q <= 1'b0;
  end
  else begin
    norm_div_q <= norm_div;
  end
end

assign norm_sync_sum = tx_ack_q & (~tx_ack);


//////////// For printing purpose ////////////
always @(posedge clk) begin
  if(pmem_wr)
    //$display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
end



endmodule
