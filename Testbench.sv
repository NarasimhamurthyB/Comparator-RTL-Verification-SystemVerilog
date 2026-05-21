class common;
	static int num=6;
endclass

mailbox gen2drv  = new();
mailbox mon2scb  = new();
mailbox mon2cov  = new();

class transaction;
	rand bit enable;
	rand bit power_in;
	rand bit [31:0] match_counter;
	rand bit [31:0] count;
	rand bit equal_case;
	bit match_int;
  
    constraint c1 { enable == 1; }
    constraint c2 { power_in == 1; }
  
	// 50% equal and 50% non-equal
	constraint c3 {
    	equal_case dist {1 := 50, 0 := 50};
	}

	// If equal_case = 1 -> equal values
	constraint c4 {
    	if(equal_case)
        	match_counter == count;
    	else
        	match_counter != count;
	}
  
endclass

class generator;
	transaction tx;
  
	task run();
		repeat(common::num)begin
		tx=new();
        if(!tx.randomize())
    	$display("Randomization Failed");
		gen2drv.put(tx);
		end
 	endtask
endclass

interface cmp_if(input reg clk,reset);
	logic enable;
	logic power_in;
	logic [31:0]match_counter;
	logic [31:0]count;
	logic match_int;
  
clocking drv_cb@(posedge clk);
	default input #0 output #1;
	output enable,power_in,match_counter,count;
	input match_int;
endclocking

clocking mon_cb@(posedge clk);
	default input #0;
	input enable,power_in,match_counter,count,match_int;
endclocking
endinterface

class driver;
	transaction tx;
	virtual cmp_if vif;

	function new();
		vif=top.pif;
	endfunction

	task run();
		repeat(common::num)begin
        gen2drv.get(tx); 
        @(vif.drv_cb);
		vif.drv_cb.enable <= tx.enable;
		vif.drv_cb.power_in <= tx.power_in;
		vif.drv_cb.match_counter <=tx.match_counter;
		vif.drv_cb.count <=tx.count;
		end
 	endtask
endclass

class monitor;
	transaction tx;
	virtual cmp_if vif;

	function new();
    	vif=top.pif;
	endfunction

	task run();
		repeat(common::num)begin
		tx=new();
   		@(vif.mon_cb);
		tx.enable = vif.mon_cb.enable;
		tx.power_in = vif.mon_cb.power_in;
		tx.match_counter = vif.mon_cb.match_counter;
		tx.count = vif.mon_cb.count;
		tx.match_int = vif.mon_cb.match_int;
		mon2scb.put(tx);
        mon2cov.put(tx);
		end
	endtask
endclass

class scoreboard;

	transaction tx;
	bit ref_match;
  
	int pass_count = 0;
	int fail_count = 0;

	task run();
	repeat(common::num) begin
    	mon2scb.get(tx);
    	if(tx.enable && tx.power_in)
        	ref_match = (tx.match_counter == tx.count);
    	else
			ref_match = 0;

		if(ref_match == tx.match_int) begin
			pass_count++;
			$display("TEST PASSED");
			$display("match_counter = %0d, count = %0d, ref_match = %0d, match_int = %0d",
					  tx.match_counter,
					  tx.count,
					  ref_match,
					  tx.match_int);
		end

		else begin
			fail_count++;
			$display("TEST FAILED");
			$display("match_counter = %0d, count = %0d, ref_match = %0d, match_int = %0d",
					  tx.match_counter,
					  tx.count,
					  ref_match,
					  tx.match_int);

		end
      
	end
		$display("=================================");
		$display("TOTAL PASS COUNT = %0d", pass_count);
		$display("TOTAL FAIL COUNT = %0d", fail_count);
		$display("=================================");
	endtask
endclass


class coverage;

	transaction tx;
	covergroup comparator_cg;
		enable_cp : coverpoint tx.enable {
			bins enable_on  = {1};
			bins enable_off = {0};
		}

		power_cp : coverpoint tx.power_in {
			bins power_on  = {1};
			bins power_off = {0};
		}

		equal_cp : coverpoint (tx.match_counter == tx.count) {
			bins equal_case     = {1};
			bins not_equal_case = {0};
		}

		match_int_cp : coverpoint tx.match_int {
			bins interrupt_on  = {1};
			bins interrupt_off = {0};
		}
	endgroup

	function new();
		comparator_cg = new();
	endfunction

	task run();
	repeat(common::num) begin
		mon2cov.get(tx);
		comparator_cg.sample();
      
	end
      
		$display("=================================");
		$display("FUNCTIONAL COVERAGE = %0.2f %%",
			  comparator_cg.get_coverage());
		$display("=================================");
	endtask
endclass

class agent;
	generator gen;
	driver drv;
	monitor mon;
  
  		task run();
			gen=new();
			drv=new();
			mon=new();
				fork
					gen.run();
					drv.run();
					mon.run();
				join
		endtask
  
endclass

class environment;
	agent agn;
	scoreboard scb;
	coverage cov;
  
		task run();
    		agn=new();
			scb=new();
  			cov=new();
				fork
    				agn.run();
					scb.run();
      				cov.run();
				join
		endtask
  
endclass

module top;
	reg clk,reset;
	environment env;
	cmp_if pif(clk,reset);

	comparator dut(.enable(pif.enable),
					   .power_in(pif.power_in),
					   .clk(pif.clk),
                       .reset(pif.reset),
					   .match_counter(pif.match_counter),
					   .count(pif.count),
					   .match_int(pif.match_int));

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		reset = 1;
		reset_signals();
		repeat(2) @(posedge clk);
		reset = 0;
		env = new();
		env.run();
	end

	task reset_signals();
		pif.enable = 0;
		pif.power_in = 0;
		pif.match_counter = 0;
		pif.count = 0;
	endtask

    initial begin
    	$dumpfile("dump.vcd");
    	$dumpvars(0,top);
    end

	initial begin
		#1200;
		$finish;
	end
endmodule
