import spi_inputs_pkg::*;
module SPI_tb;
    parameter TESTS = 10000;
    logic MISO,MOSI;
    logic rst_n;
    logic SS_n;
    logic [1:0] rd_wr;
    logic [7:0] dout;
    int error_counts=0;
    int correct_counts=0;
    logic [7:0] dout_expected;
    bit rand_c_address;
    bit clk;
    logic [7:0] add,dd;
    logic [7:0] mem [logic [7:0]];
    spi_inputs inputs = new;
    logic [7:0] address_array [];
    logic [7:0] data_to_write_array [];
    always #5 clk = ~clk;
    spi_wrapper dut(.*);
    

    task check_result();
        if(dout !== dout_expected) begin
            $display("%t: error incorrect result",$time);
            error_counts = error_counts+1;
        end
        else
            correct_counts = correct_counts +1;
    endtask

    task golden_model([7:0] address);
        if(!rst_n)
            dout_expected = 0;
        else
            dout_expected = mem[address];
    endtask


    task stimulus_gen();
        address_array = new[TESTS];
        data_to_write_array = new[TESTS];
        for(int i=0 ; i<TESTS ; i++) begin
            assert(inputs.randomize());
            address_array[i] = inputs.address;
            mem[inputs.address] = inputs.din;
            data_to_write_array[i] = inputs.din;
        end
        
    endtask 

    task send_data([7:0] address,din);
        MOSI = 0;
        SS_n=0;
        rd_wr = 2'b00;
        @(negedge clk);
        for(int i =1; i>=0; i--) begin
            @(negedge clk);
            MOSI = rd_wr[i];
        end
        for(int i =7; i>=0; i--) begin
            @(negedge clk);
            MOSI = address[i];
        end
        @(negedge clk);
        SS_n=1;
        @(negedge clk);
        SS_n=0;
        MOSI=0;
        @(negedge clk);
        rd_wr = 2'b01;
        for(int i =1; i>=0; i--) begin
            @(negedge clk);
            MOSI = rd_wr[i];
        end
        for(int i =7; i>=0; i--) begin
            @(negedge clk);
            MOSI = din[i];
        end
        @(negedge clk);
        SS_n=1;
    endtask


    task receive_data([7:0] address);
        MOSI = 1;
        SS_n=0;
        @(negedge clk);
        rd_wr = 2'b10;
        for(int i =1; i>=0; i--) begin
            @(negedge clk);
            MOSI = rd_wr[i];
        end
        for(int i =7; i>=0; i--) begin
            @(negedge clk);
            MOSI = address[i];
        end
        @(negedge clk);
        SS_n=1;
        @(negedge clk);
        SS_n = 0;
        MOSI=1;
        @(negedge clk);
        rd_wr = 2'b11;
        for(int i =1; i>=0; i--) begin
            @(negedge clk);
            MOSI = rd_wr[i];
        end
        for(int i =7; i>=0; i--) begin
            @(negedge clk);
        end
        @(negedge clk);
        @(negedge clk);
        for(int i =7; i>=0; i--) begin
            @(negedge clk);
            dout[i] = MISO;
        end
        SS_n=1;
    endtask

    task do_reset();
		rst_n=0;
		@(negedge  clk);
		if(MISO !==0) begin
			error_counts = error_counts+1;
			$display("%t : Error: from Reset task", $time);
		end
		else
			correct_counts = correct_counts+1;
		rst_n =1;
	endtask


    initial begin
        SS_n = 1;
        rst_n = 1;
        //inputs.address_c.rand_mode(0);        
        stimulus_gen;
        #1;
        do_reset();
        //write then read this write
        for(int i=0;i<TESTS;i++) begin
            assert(inputs.randomize());
            add = address_array[i];
            dd = data_to_write_array[i];
            rst_n = inputs.rst_n;
            send_data(address_array[i],data_to_write_array[i]);
            @(negedge clk);
            if(!rst_n)
                dout_expected=0;
            else
                dout_expected = data_to_write_array[i];
            receive_data(address_array[i]);
            @(negedge clk);
            check_result();
			inputs.sample_data();
        end
        //inputs.address_c.rand_mode(1); 
        //inputs.address.rand_mode(0); 
        //rand_c_address =1;
        #1;
        stimulus_gen;
        #1;
        do_reset();
        for(int i=0;i<TESTS;i++) begin
            add = address_array[i];
            dd = data_to_write_array[i];
            send_data(address_array[i],data_to_write_array[i]);
            @(negedge clk);
        end

        for(int i=0;i<TESTS;i++) begin
            add = address_array[i];
            dd = data_to_write_array[i];
            dout_expected = mem[address_array[i]];
            receive_data(address_array[i]);
            @(negedge clk);
            check_result();
			inputs.sample_data();
        end
        $display("\n************At the end*************\nError Counts = %0d",error_counts);
        $display("Correct Counts = %0d\n***********************************\n",correct_counts);
        #5 $stop;

    end

    
endmodule