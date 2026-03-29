vlib work
vlog project_ram.v project_spi.v SPI_inputs_pkg.sv SPI_tb.sv spi_wrapper.v +cover
vsim -voptargs=+acc work.SPI_tb -cover
add wave *
coverage save spi_wrapper.ucdb -du work.spi_wrapper -onexit
run -all
quit -sim
vcover report spi_wrapper.ucdb -details -annotate -all -output coverage_rpt1.txt