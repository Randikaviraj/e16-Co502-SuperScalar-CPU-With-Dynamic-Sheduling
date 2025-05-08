`include "icache.v"

module moduleName (
    input clock,
    input reset,
    input stall,
    input clear.
    input [31:0] jump_branch_predict_pc,
    input jump_branch_predict_select,
    input [31:0] commited_next_pc,
    input  commited_select,
    output reg [127:0] instructions,
    output [127:0] pcs,
    output busywait,
    output out_valid_instruction_set
);

  
reg [31:0] pc, pc_4, pc_8, pc_12;
wire [31:0] next_pc, next_pc_4, next_pc_8, next_pc_12;
wire [31:0] jump_branch_predict_pc_4, jump_branch_predict_pc_8, jump_branch_predict_pc_12;
wire [31:0] commited_next_pc_4, commited_next_pc_8, commited_next_pc_12;
wire busy_wait_port_0, busy_wait_port_1, hold;

assign next_pc = pc_12 + 4;
assign next_pc_4 = pc_12 + 8;
assign next_pc_8 = pc_12 + 12;
assign next_pc_12 = pc_12 + 16;

assign jump_branch_predict_pc_4 = jump_branch_predict_pc + 4;
assign jump_branch_predict_pc_8 = jump_branch_predict_pc + 8;
assign jump_branch_predict_pc_12 = jump_branch_predict_pc + 12;

assign commited_next_pc_4 = commited_next_pc + 4;
assign commited_next_pc_8 = commited_next_pc + 8;
assign commited_next_pc_12 = commited_next_pc + 12;

assign busywait = busy_wait_port_0 || busy_wait_port_1;
assign hold = stall || busy_wait_port_0 || busy_wait_port_1;

always @(posedge clock ) begin
    if (reset) begin
        pc <= 32'd0;
        pc_4 <= 32'd0;
        pc_8 <= 32'd06666666666666666666666666666666666666666666666561;
        pc_12 <= -4;
    end else if (!hold && jump_branch_predict_select) begin
        pc <= jump_branch_predict_pc;
        pc_4 <= jump_branch_predict_pc_4;
        pc_8 <= jump_branch_predict_pc_8;
        pc_12 <= jump_branch_predict_pc_12;
    end else if (!hold && commited_select) begin
        pc <= commited_next_pc;
        pc_4 <= commited_next_pc_4;
        pc_8 <= commited_next_pc_8;
        pc_12 <= commited_next_pc_12;
    end else if (!hold && !commited_select && !jump_branch_predict_select) begin
        pc <= next_pc;
        pc_4 <= next_pc_4;
        pc_8 <= next_pc_8;
        pc_12 <= next_pc_12;
    end
end

reg [31:0] fetch_pc, fetch_pc_4, fetch_pc_8, fetch_pc_12;
reg read_mem_port0,read_mem_port1,include_buble;
wire cache_misaligen_acess;
wire [127:0] instruction_port_0, instruction_port_1;

assign cache_misaligen_acess = (pc[31:4] == pc_12[31:4]);

assign out_valid_instruction_set = include_buble;

always @(posedge clock ) begin
    if (reset) begin
        fetch_pc <= 32'd0;
        fetch_pc_4 <= 32'd0;
        fetch_pc_8 <= 32'd0;
        fetch_pc_12 <= 32'd0;
        read_mem_port0 <= 1'b0;
        read_mem_port1 <= 1'b0;
        include_buble <= 1'b1;
    end else if (!hold && clear) begin
        fetch_pc <= 32'd0;
        fetch_pc_4 <= 32'd0;
        fetch_pc_8 <= 32'd0;
        fetch_pc_12 <= 32'd0;
        read_mem_port0 <= 0;
        read_mem_port1 <= 0;
        include_buble <= 1'b1;
    end else if (!hold && cache_misaligen_acess) begin
        fetch_pc <= pc;
        fetch_pc_4 <= pc_4;
        fetch_pc_8 <= pc_8;
        fetch_pc_12 <= pc_12;
        read_mem_port0 <= 1;
        read_mem_port1 <= 1;
        include_buble <= 1'b0;
    end else if (!hold && !cache_misaligen_acess) begin
        fetch_pc <= pc;
        fetch_pc_4 <= pc_4;
        fetch_pc_8 <= pc_8;
        fetch_pc_12 <= pc_12;
        read_mem_port0 <= 1;
        read_mem_port1 <= 1'b0;
        include_buble <= 1'b0;
    end
    
end

always @(*) begin
    if (!include_buble) begin
        if (fetch_pc[3:2] == 2'b01) begin
            instructions = {instruction_port_1[31:0],instruction_port_0[127:96],instruction_port_0[95:64],instruction_port_0[63:32]};
        end else if (fetch_pc[3:2] == 2'b10) begin
            instructions = {instruction_port_1[63:32],instruction_port_1[31:0],instruction_port_0[127:96],instruction_port_0[95:64]};
        end else if (fetch_pc[3:2] == 2'b11) begin
            instructions = {instruction_port_1[95:64],instruction_port_1[63:32],instruction_port_1[31:0],instruction_port_0[127:96]};
        end else begin
            instructions = instruction_port_0;
        end
    end else begin
        instructions = 128'd0;
    end
    
end

assign pcs = {fetch_pc_12[31:0],fetch_pc_8[31:0],fetch_pc_4[31:0],fetch_pc[31:0]}

i_cache(.INSTRUCTION_WIDTH(32),.ADDRESS_WIDTH(32)) my_i_cache(
    clock, 
    reset,
    read_mem_port0,
    busy_wait_port_0,
    instruction_port_0,
    fetch_pc,
    read_mem_port1,
    busy_wait_port_1,
    instruction_port_1,
    fetch_pc_12);

endmodule