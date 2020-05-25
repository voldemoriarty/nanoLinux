# fpga clock
create_clock      -period "50.0 MHz" [get_ports FPGA_CLK1_50]

# create unused clock constraint for HPS I2C and usb1
# to avoid misleading unconstraint clock reporting in TimeQuest
create_clock      -period "1 MHz"   [get_ports HPS_I2C0_SCLK]
create_clock      -period "1 MHz"   [get_ports HPS_I2C1_SCLK]
create_clock      -period "48 MHz"  [get_ports HPS_USB_CLKOUT]
 

# 25 MHz USB Blaster
# create_clock      -name   {altera_reserved_tck} -period 40    {altera_reserved_tck}
# set_input_delay   -clock  altera_reserved_tck   -clock_fall 3 [get_ports altera_reserved_tdi]
# set_input_delay   -clock  altera_reserved_tck   -clock_fall 3 [get_ports altera_reserved_tms]
# set_output_delay  -clock  altera_reserved_tck   3             [get_ports altera_reserved_tdo]

# optional PLLs
derive_pll_clocks
derive_clock_uncertainty


# set false path to/from FPGA IO
set_false_path -from  [get_ports {SW[*]}] -to *
set_false_path -from * -to [get_ports {LED[*]}] 

# set false path from HPS IO, 
# to remove unconstrained path warnings from timequest
# (won't affect routing bc its hard silicon)
set_false_path -from * -to [get_ports {HPS_*}]
set_false_path -from [get_ports {HPS_*}] -to *