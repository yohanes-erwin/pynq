module axis_img_inv
    (
        // ### Clock and reset signals #########################################
        input  wire       aclk,
        input  wire       aresetn,
        // ### AXI4-stream slave signals #######################################
        output wire       s_axis_tready,
        input wire [7:0]  s_axis_tdata,
        input wire [0:0]  s_axis_tkeep,
        input wire        s_axis_tvalid,
        input wire        s_axis_tlast,
        // ### AXI4-stream master signals ######################################
        input wire        m_axis_tready,
        output wire [7:0] m_axis_tdata,
        output wire [0:0] m_axis_tkeep,
        output wire       m_axis_tvalid,
        output wire       m_axis_tlast
    );
    
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata = 255 - s_axis_tdata;
    assign m_axis_tkeep = s_axis_tkeep;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tlast = s_axis_tlast;
    
endmodule