module axis_mult
    (
        // ### Clock and reset signals #########################################
        input  wire        aclk,
        input  wire        aresetn,
        // ### AXI4-stream slave signals #######################################
        output wire        s_axis_tready,
        input wire [31:0]  s_axis_tdata,
        input wire         s_axis_tvalid,
        input wire         s_axis_tlast,
        // ### AXI4-stream master signals ######################################
        input wire         m_axis_tready,
        output wire [31:0] m_axis_tdata,
        output wire        m_axis_tvalid,
        output wire        m_axis_tlast
    );
    
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tlast = s_axis_tlast;
    
    mult_core mult_core_0
    (
        .a(s_axis_tdata),
        .r(m_axis_tdata)    
    );
   
endmodule
