module ctrl (clk, reset, inst_in, inst_out, inst_wr, inst_mem_full, start_ex, mem_in, mem_out);

parameter num_core = 2;
parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;
parameter INST_MEM_SIZE = 4'b111;

input clk, reset;

input start_ex;
input inst_wr;
input [3:0] inst_mem_add;
input [16:0] inst_in;

input [pr*bw-1:0] mem_in;

output reg inst_mem_full;
output reg [16:0] inst_out;
output reg [pr*bw-1:0] mem_out;

//instruction memory
reg [16:0] inst_mem [15:0];


reg inst_mem_wr_addr;
reg inst_mem_rd_addr;

wire inst_rd;

// dual_core #(.num_cores(num_core), .col(col), .bw(bw), .bw_psum(bw_psum), .pr(pr)) dual_core_isntance (
//   .clk(clk),
//   .reset(reset),
//   .mem_in(mem_out),
//   .inst(inst_out)
// );

always @(posedge clk) begin
  if(reset) begin
    inst_mem_wr_addr <= 4'b0;
    inst_mem_full <= 1'b0;
  end
  else begin
    if (inst_wr && (inst_mem_wr_addr != INST_MEM_SIZE)) begin
      inst_mem[inst_mem_wr_addr] <= inst_in;
      inst_mem_wr_addr <= inst_mem_wr_addr + 4'b1;
    end
    else if (inst_mem_wr_addr == INST_MEM_SIZE) begin
      inst_mem_full <= 1'b1;
    end
  end
end

always @(posedge clk) begin
  if (reset) begin
    inst_mem_rd_addr <= 4'b0;
  end
  else begin
    
  end
end






output




endmodule