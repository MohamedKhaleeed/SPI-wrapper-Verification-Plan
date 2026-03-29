module mem_tb ();
    logic clk=0;
    logic [9:0] din;
    logic [7:0] dout;
    logic rst_n;
    logic tx_valid;
    logic rx_valid;
    logic [7:0] address;
    logic [7:0] data_in;
    always #5 clk=~clk;


    spi_ram dut (.*);


    localparam TESTS = 10000;


    logic [7:0] address_array [];
    logic [7:0] data_to_write_array [];
    logic [7:0] data_read_expect_assoc [int];
    int error_counts=0,correct_counts=0;


    task stimulus_gen();
        address_array = new[TESTS];
        data_to_write_array = new[TESTS];
        for(int i=0 ; i<TESTS ; i++) begin
        address_array[i] = $random;
        data_to_write_array[i] = $random; 
        end        
    endtask
    

    task golden_model();
        for(int i=0 ; i<TESTS ; i++) 
            data_read_expect_assoc[address_array[i]] = data_to_write_array[i];
    endtask


    task do_reset();
		rst_n=0;
		@(negedge  clk);
		if(dout !==0 || tx_valid!==0) begin
			error_counts = error_counts+1;
			$display("%t : Error: from Reset task", $time);
		end
		else
			correct_counts = correct_counts+1;
		rst_n =1;
	endtask


    initial begin
        rx_valid =0;
        din=0;
        stimulus_gen;
        golden_model;
        do_reset();
        
        for(int i=0 ; i<TESTS ; i++) begin
            @(negedge clk);
            check_tx_valid();
            address = address_array[i];
            din = {2'b00,address};
            rx_valid=1;
            #1;
            @(negedge clk);
            check_tx_valid();
            data_in = data_to_write_array[i];
            din = {2'b01,data_in};
            rx_valid=1;
            #1;
            @(negedge clk);
            check_tx_valid();
            rx_valid=0;
        end



        @(negedge clk);
        check_tx_valid();
        for(int i=0 ; i<TESTS ; i++) begin
            @(negedge clk);
            check_tx_valid();
            address = address_array[i];
            din = {2'b10,address};
            rx_valid=1;
            #1;
            @(negedge clk);
            check_tx_valid();
            din = {2'b11,8'b10100011};
            check_result(address);
            rx_valid=0;
            @(negedge clk);
            check_tx_valid();

        end

        do_reset;
        #5


        $display("\n************At the end*************\nError Counts = %0d",error_counts);
        $display("Correct Counts = %0d\n***********************************\n",correct_counts);

        #20 $stop;
        

    end


    task check_result(logic [7:0] Taddress);
        @(negedge clk);
        if(data_read_expect_assoc[Taddress]!==dout || tx_valid==0) begin
            $display("%t: data from Address : %0h is incorrect,,data should be: %0d,,data observed: %0d",$time,Taddress,data_read_expect_assoc[Taddress],dout);
            error_counts = error_counts +1;
        end
        else begin
            correct_counts = correct_counts +1;
        end
    endtask

    task check_tx_valid();
        @(negedge clk);
        if(tx_valid==1) begin
            $display("%t: tx_valid = 1",$time);
            error_counts = error_counts +1;
        end
    endtask
endmodule