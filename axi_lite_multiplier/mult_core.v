module mult_core
    (
        input wire [31:0]  a,
        output wire [31:0] r    
    );
    
    assign r = a * 8;
    
endmodule
