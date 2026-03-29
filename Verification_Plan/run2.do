vlib work
vlog project_ram.v mem_tb.sv +cover
vsim -voptargs=+acc work.mem_tb -cover
add wave *
coverage save spi_ram.ucdb -du work.spi_ram -onexit
run -all
quit -sim
vcover report spi_ram.ucdb -details -annotate -all -output coverage_rpt2.txt