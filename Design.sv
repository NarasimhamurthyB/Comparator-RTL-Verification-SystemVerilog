module comparator(
    input wire enable,
    input wire clk,
    input wire reset,
    input wire power_in,
    input wire [31:0] match_counter,
    input wire [31:0] count,
    output reg match_int
);

always @(posedge clk or posedge reset) begin

    if(reset) begin
        match_int <= 0;
    end

    else if(!enable || !power_in) begin
        match_int <= 0;
    end

    else begin
        if(count == match_counter)
            match_int <= 1'b1;
        else
            match_int <= 1'b0;
    end
end
endmodule
