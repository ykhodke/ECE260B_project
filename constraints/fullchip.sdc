
set clock_cycle 1 
set io_delay 0.2 

set setup_multi 2 
set hold_multi 1

set clock_port clk

create_clock -name clk -period $clock_cycle [get_ports $clock_port]

set_multicycle_path -setup $setup_multi -from core_instance/norm_core0/fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to core_instance/norm_core0/out_q_reg[*]
set_multicycle_path -hold $hold_multi -from core_instance/norm_core0/fifo_top_instance/fifo_instance/rd_ptr_reg[*] -to core_instance/norm_core0/out_q_reg[*]

set_false_path -setup -from core_instance/norm_core0/fifo_top_instance/fifo_instance/q*_reg[*] -to core_instance/norm_core0/out_q_reg[*]

set_false_path -setup -from core_instance/norm_core0/sum_q_reg[*] -to core_instance/norm_core0/out_q_reg[*]




set_input_delay  $io_delay -clock $clock_port [all_inputs] 
set_output_delay $io_delay -clock $clock_port [all_outputs]


