# fpga clock
create_clock      -period "50.0 MHz" [get_ports FPGA_CLK1_50]

# create unused clock constraint for HPS I2C and usb1
# to avoid misleading unconstraint clock reporting in TimeQuest
create_clock      -period "1 MHz"   [get_ports HPS_I2C0_SCLK]
create_clock      -period "1 MHz"   [get_ports HPS_I2C1_SCLK]
create_clock      -period "48 MHz"  [get_ports HPS_USB_CLKOUT]


# 25 MHz USB Blaster
create_clock      -name   {altera_reserved_tck} -period 40    {altera_reserved_tck}
set_input_delay   -clock  altera_reserved_tck   -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay   -clock  altera_reserved_tck   -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay  -clock  altera_reserved_tck   3             [get_ports altera_reserved_tdo]

# optional PLLs
derive_pll_clocks
derive_clock_uncertainty


# set false path to/from FPGA IO
set_false_path -from  [get_ports {SW[*]}] -to *
set_false_path -from * -to [get_ports {LED[*]}] 

# set false path from HPS IO, 
# to remove unconstrained path warnings from timequest
# (won't affect routing bc its hard silicon)
set_false_path -from [get_ports {SW[*]}] 
set_false_path -to [get_ports {LED[*]}]
set_false_path -to [get_ports {HPS_ENET_GTX_CLK}]
set_false_path -to [get_ports {HPS_ENET_TX_DATA[*]}]
set_false_path -from [get_ports {HPS_ENET_MDIO}] -to *
set_false_path -from [get_ports {HPS_ENET_RX_CLK}] -to *
set_false_path -from [get_ports {HPS_ENET_RX_DATA[*]}] -to *
set_false_path -from [get_ports {HPS_ENET_RX_DV}] -to *
set_false_path -from [get_ports {HPS_I2C0_SDAT}] -to *
set_false_path -from [get_ports {HPS_I2C1_SDAT}] -to *
set_false_path -from [get_ports {HPS_SD_CMD}] -to *
set_false_path -from [get_ports {HPS_SD_DATA[*]}] -to *
set_false_path -from [get_ports {HPS_SPIM_MISO}] -to *
set_false_path -from [get_ports {HPS_UART_RX}] -to *
set_false_path -from [get_ports {HPS_USB_CLKOUT}] -to *
set_false_path -from [get_ports {HPS_USB_DATA[*]}] -to *
set_false_path -from [get_ports {HPS_USB_DIR}] -to *
set_false_path -from [get_ports {HPS_USB_NXT}] -to *
set_false_path -from * -to [get_ports {HPS_ENET_MDC}]
set_false_path -from * -to [get_ports {HPS_ENET_MDIO}]
set_false_path -from * -to [get_ports {HPS_ENET_TX_EN}]
set_false_path -from * -to [get_ports {HPS_I2C0_SCLK}]
set_false_path -from * -to [get_ports {HPS_I2C0_SDAT}]
set_false_path -from * -to [get_ports {HPS_I2C1_SCLK}]
set_false_path -from * -to [get_ports {HPS_I2C1_SDAT}]
set_false_path -from * -to [get_ports {HPS_SD_CLK}]
set_false_path -from * -to [get_ports {HPS_SD_CLK}]
set_false_path -from * -to [get_ports {HPS_SD_CMD}]
set_false_path -from * -to [get_ports {HPS_SD_DATA[*]}]
set_false_path -from * -to [get_ports {HPS_SPIM_MOSI}]
set_false_path -from * -to [get_ports {HPS_SPIM_SS}]
set_false_path -from * -to [get_ports {HPS_UART_TX}]
set_false_path -from * -to [get_ports {HPS_USB_DATA[*]}]
set_false_path -from * -to [get_ports {HPS_USB_STP}]
