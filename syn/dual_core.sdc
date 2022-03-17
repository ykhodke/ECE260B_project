
set clock_cycle 1.0
set io_delay 0.2 

set clock_port clk

create_clock -name clk -period $clock_cycle [get_ports $clock_port]

set_input_delay $io_delay -clock $clock_port [all_inputs]
set_output_delay $io_delay -clock $clock_port [all_outputs]


#set_multicycle_path -setup 2 -from fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to out_q_reg[*]
#set_multicycle_path -hold  1 -from fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to out_q_reg[*]
#
#set_false_path -from fifo_top_instance/fifo_instance/q*_reg[*] -to out_q_reg[*]
##set_false_path -from fifo_top_instance/fifo_instance/q*_reg[*] -to out_q_reg[*]
#
#set_false_path -from sum_q_reg[*] -to out_q_reg[*]
#set_false_path -from fifo_top_instance/fifo_instance/sum_q_reg[*] -to out_q_reg[*]

#set_output_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports all_outputs]


#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[0]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[1]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[2]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[3]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[4]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {out[5]}]
#
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {x[0]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {x[1]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {x[2]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {x[3]}]
#
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {z[0]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {z[1]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {z[2]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {z[3]}]
#
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {y[0]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {y[1]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {y[2]}]
#set_input_delay -clock [get_clocks clk] -add_delay -max $io_delay [get_ports {y[3]}]
#
