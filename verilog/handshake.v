// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module handshake(clk, reset, send_data, rx_req, rx_ack, rx_data, tx_ack, tx_req, received_data);

parameter data_bw = 20;

input clk, reset;
input send_data;

input rx_req;
input [data_bw-1:0] rx_data;
output reg rx_ack;

input tx_ack;
output reg tx_req;
output reg [data_bw-1:0] received_data;


localparam [1:0] // 4 states are required for TX
  IDLE_TX 	= 2'b00,
  SEND_TX 	= 2'b01, 
  WAIT_ACK 	= 2'b10,
  END_TX 	  = 2'b11;

localparam 
  IDLE_RX = 1'b0,
  GET_RX  = 1'b1;

reg [1:0] tx_state;
reg [1:0] rx_state;

reg [1:0] next_tx_state;
reg [1:0] next_rx_state; 

always @(*) begin 
  case(rx_state)
    IDLE_RX: begin
      rx_ack <= 0;
      if (rx_req) next_rx_state <= GET_RX;
      else next_rx_state <= IDLE_RX;
    end
    GET_RX: begin
      rx_ack <= 1;            
      if (rx_req) next_rx_state <= GET_RX;
      else next_rx_state <= IDLE_RX;
    end
    default: begin
      rx_ack <= 0;
      next_rx_state <= IDLE_RX;
    end
  endcase
end

always @(*) begin 
  case(tx_state)
    IDLE_TX: begin
      tx_req <=0;
      if (send_data) next_tx_state <= SEND_TX;
      else next_tx_state <= IDLE_TX;
    end
    SEND_TX: begin 
      tx_req <= 1;
      next_tx_state <= WAIT_ACK;
    end
    WAIT_ACK: begin
      tx_req <=1;
      if (tx_ack) next_tx_state <= END_TX;
      else next_tx_state <= WAIT_ACK;
    end
    END_TX: begin 
      tx_req <= 0;
      if (tx_ack) next_tx_state <= END_TX;
      else next_tx_state <= IDLE_TX;
    end
    default: begin 
      tx_req <= 0;
      next_tx_state <= IDLE_TX;
    end
  endcase
end

always @(posedge clk) begin
  if (reset) begin
    rx_state <= IDLE_RX;
    tx_state <= IDLE_TX;
  end
  else begin
    rx_state <= next_rx_state;
    tx_state <= next_tx_state;
    if(rx_ack) received_data <= rx_data;
  end
end

endmodule
