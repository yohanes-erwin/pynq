`timescale 1ns / 1ps

module axis_gcd
    (
        // ### Clock and reset signals #########################################
        input  wire        aclk,
        input  wire        aresetn,
        // ### AXI4-stream slave signals #######################################
        output wire        s_axis_tready,
        input wire [63:0]  s_axis_tdata,
        input wire         s_axis_tvalid,
        input wire         s_axis_tlast,
        // ### AXI4-stream master signals ######################################
        input wire         m_axis_tready,
        output wire [31:0] m_axis_tdata,
        output wire        m_axis_tvalid,
        output wire        m_axis_tlast
    );
    
    reg [3:0] state_reg, state_next;
    reg s_axis_tready_reg, s_axis_tready_next;
    reg s_axis_tlast_reg, s_axis_tlast_next;
    
    reg start_reg, start_next;
    reg [31:0] a_reg, a_next;
    reg [31:0] b_reg, b_next;
    wire ready;
    wire done;
    wire [31:0 ]r;
    
    // GCD core
    gcd_core gcd_core_0
    (
        .clk(aclk),
        .rst_n(aresetn),
        .start(start_reg),
        .a(a_reg),
        .b(b_reg),
        .ready(ready),
        .done(done),
        .r(r)
    );
    
    // State machine register
    always @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_reg <= 0;
            s_axis_tready_reg <= 0;
            s_axis_tlast_reg <= 0;
            start_reg <= 0;
            a_reg <= 0;
            b_reg <= 0;
        end
        else
        begin
            state_reg <= state_next;
            s_axis_tready_reg <= s_axis_tready_next;
            s_axis_tlast_reg <= s_axis_tlast_next;
            start_reg <= start_next;
            a_reg <= a_next;
            b_reg <= b_next;
        end
    end

    // State machine next value    
    always @(*)
    begin
        state_next = state_reg;
        s_axis_tready_next = 0;
        s_axis_tlast_next = s_axis_tlast_reg;
        start_next = 0;
        a_next = a_reg;
        b_next = b_reg;
        case (state_reg)
            0: // Wait for start condition
            begin
                // Input data is available, and output FIFO is able to receive data 
                if (s_axis_tvalid && m_axis_tready)
                begin
                    state_next = 1;
                end
            end
            1: // Read data from AXI stream and write to local register
            begin
                state_next = 2;
                s_axis_tready_next = 1;
                s_axis_tlast_next = s_axis_tlast;
                start_next = 1;
                a_next = s_axis_tdata[31:0];
                b_next = s_axis_tdata[63:32];
            end
            2: // GCD core starts running
            begin
                state_next = 3;
            end
            3: // Wait until GCD is ready
            begin
                // GCD ready condition
                if (ready)
                begin
                    state_next = 0;
                end
            end
        endcase
    end
    
    // Output
    assign s_axis_tready = s_axis_tready_reg;
    assign m_axis_tdata = r;
    assign m_axis_tvalid = done;
    assign m_axis_tlast = s_axis_tlast_reg;
    
endmodule
