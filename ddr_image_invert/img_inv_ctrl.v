`timescale 1ns / 1ps

module img_inv_ctrl
    (
        input wire         clk,
        input wire         rst_n,
        output wire        ready,
        input wire [31:0]  saddr,
        input wire [31:0]  daddr,
        input wire [31:0]  btt,
        input wire         start,
        output wire [71:0] m_axis_mm2s_cmd_tdata,
        output wire        m_axis_mm2s_cmd_tvalid,
        output wire [71:0] m_axis_s2mm_cmd_tdata,
        output wire        m_axis_s2mm_cmd_tvalid,
        input wire         s2mm_wr_xfer_cmplt
    );
    
    reg [2:0] state_reg, state_next;
    
    always @(posedge clk)
    begin
        if (!rst_n)
        begin
            state_reg <= 0;
        end
        else
        begin
            state_reg <= state_next;
        end
    end
    
    always @(*)
    begin
        state_next = state_reg;
        case (state_reg)
            0: // Wait for start from PS
            begin
                if (start)
                begin
                    state_next = 1;
                end
            end
            1: // Send S2MM instruction
            begin
                state_next = 2;
            end
            2: // Send MM2S instruction
            begin
                state_next = 3;
            end
            3: // Wait until S2MM transfer is completed
            begin
                if (s2mm_wr_xfer_cmplt)
                begin
                    state_next = 0; // Back to idle
                end
            end
        endcase
    end
    
    assign ready = (state_reg == 0) ? 1 : 0;
    
    assign m_axis_s2mm_cmd_tdata = {8'b00000000, daddr, 1'b0, 1'b1, 6'b000000, 1'b1, btt[22:0]}; // S2MM instruction
    assign m_axis_s2mm_cmd_tvalid = (state_reg == 1) ? 1 : 0; // Send S2MM instruction
    assign m_axis_mm2s_cmd_tdata = {8'b00000000, saddr, 1'b0, 1'b1, 6'b000000, 1'b1, btt[22:0]}; // MM2S instruction
    assign m_axis_mm2s_cmd_tvalid = (state_reg == 2) ? 1 : 0; // Send MM2S instruction
    
endmodule
