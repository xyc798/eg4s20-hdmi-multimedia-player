create_clock -name clk_50m -period 20.000 -waveform {0.000 10.000} [get_ports {clk_50m}]
create_clock -name pixel_clk -period 40.000 -waveform {0.000 20.000} [get_nets {pixel_clk}] -add
create_clock -name serial_clk -period 8.000 -waveform {0.000 4.000} [get_nets {serial_clk}] -add
set_clock_groups -exclusive -group [get_clocks {pixel_clk}] -group [get_clocks {serial_clk}]