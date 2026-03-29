package spi_inputs_pkg;
    class spi_inputs;
        rand logic [7:0] din;
        rand logic rst_n;
        randc logic [7:0] address_c;
        rand logic [7:0] address;
        constraint c {
            rst_n dist {1:=95 , 0:=5};
        }
        
        covergroup cvr_gp;
            add_cp: coverpoint address;
            din_cp: coverpoint din{
                bins walking_ones [] = {8'b10000000,8'b01000000,8'b00100000,8'b00010000,8'b00001000,8'b00000100,8'b00000010,8'b00000001};
            }
        endgroup


        function new();
            cvr_gp = new;
        endfunction


        function sample_data();
            cvr_gp.sample;
        endfunction
    endclass
endpackage