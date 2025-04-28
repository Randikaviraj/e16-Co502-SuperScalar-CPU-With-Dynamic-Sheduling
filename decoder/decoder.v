module moduleName (
    input clock,
    input reset.
    input clear,
    input stall,
    input [127:0] instructions,
    input [127:0] pcs,
    output reg  [4:0] rd_0,
    output reg  [4:0] rd_1,
    output reg  [4:0] rd_2,
    output reg  [4:0] rd_3;
    output reg  [4:0] rs_0,
    output reg  [4:0] rs_1,
    output reg  [4:0] rs_2,
    output reg  [4:0] rs_3;
    output reg  [4:0] rt_0,
    output reg  [4:0] rt_1,
    output reg  [4:0] rt_2,
    output reg  [4:0] rt_3;
    output reg  [2:0] command_0,
    output reg  [2:0] command_1,
    output reg  [2:0] command_2,
    output reg  [2:0] command_3,
    output reg  [31:0] imm_0,
    output reg  [31:0] imm_1,
    output reg  [31:0] imm_2,
    output reg  [31:0] imm_3,
    output reg  [5:0] control_signal_0,
    output reg  [5:0] control_signal_1,
    output reg  [5:0] control_signal_2,
    output reg  [5:0] control_signal_3,
    output reg        sel_imm_0,
    output reg        sel_imm_1,
    output reg        sel_imm_2,
    output reg        sel_imm_3,
    output reg [31:0] target_pc_0,
    output reg [31:0] target_pc_1,
    output reg [31:0] target_pc_2,
    output reg [31:0] target_pc_3,
    output reg jump_branch_predict_0,
    output reg jump_branch_predict_1,
    output reg jump_branch_predict_2,
    output reg jump_branch_predict_3,
    output reg [31:0] jump_branch_predict_pc_0,
    output reg [31:0] jump_branch_predict_pc_1,
    output reg [31:0] jump_branch_predict_pc_2,
    output reg [31:0] jump_branch_predict_pc_3,
    output wire [127:0] out_pcs
);

reg [127:0] decode_stage_reg_instructions;
reg [127:0] decode_stage_reg_pcs;
wire [31:0] instruction_0, instruction_1, instruction_2, instruction_3;
wire [31:0] pc_0, pc_1, pc_2, pc_3;
wire [31:0] pc_4_0, pc_4_1, pc_4_2, pc_4_3;
wire [31:0] branch_pc_0, branch_pc_1, branch_pc_2, branch_pc_3;
wire [5:0] opcode_0, opcode_1, opcode_2, opcode_3;
wire [4:0] shamt_0,shamt_1,shamt_2,shamt_3;
wire [5:0] funct_0,funct_1,funct_2,funct_3;


assign instruction_0 = decode_stage_reg_instructions[31:0];
assign instruction_1 = decode_stage_reg_instructions[63:32];
assign instruction_2 = decode_stage_reg_instructions[95:64];
assign instruction_3 = decode_stage_reg_instructions[127:96];

assign opcode_0 = instruction_0[31:26];
assign opcode_1 = instruction_1[31:26];
assign opcode_2 = instruction_2[31:26];
assign opcode_3 = instruction_3[31:26];

assign pc_0 = decode_stage_reg_pcs[31:0];
assign pc_1 = decode_stage_reg_pcs[63:32];
assign pc_2 = decode_stage_reg_pcs[95:64];
assign pc_3 = decode_stage_reg_pcs[127:96];

assign pc_4_0 = pc_0 + 4;
assign pc_4_1 = pc_1 + 4;
assign pc_4_2 = pc_2 + 4;
assign pc_4_3 = pc_3 + 4;

assign branch_pc_0 = pc_4_0 + {14{instruction_0[15]},instruction_0[15:0],2{1b0}};
assign branch_pc_1 = pc_4_1 + {14{instruction_1[15]},instruction_1[15:0],2{1b0}};
assign branch_pc_2 = pc_4_2 + {14{instruction_2[15]},instruction_2[15:0],2{1b0}};
assign branch_pc_3 = pc_4_3 + {14{instruction_3[15]},instruction_3[15:0],2{1b0}};

assign shamt_0 = instruction_0[10:6];
assign shamt_1 = instruction_1[10:6];
assign shamt_2 = instruction_2[10:6];
assign shamt_3 = instruction_3[10:6];

assign funct_0 = instruction_0[5:0];
assign funct_1 = instruction_1[5:0];
assign funct_2 = instruction_2[5:0];
assign funct_3 = instruction_3[5:0];


always @(posedge clock) begin
    if (reset) begin
        decode_stage_reg_instructions <= 128'd0;
        decode_stage_reg_pcs <= 128'd0;
    end else if (!stall && clear) begin
        decode_stage_reg_instructions <= 128'd0;
        decode_stage_reg_pcs <= 128'd0;
    end else if (!stall) begin
        decode_stage_reg_instructions <= instructions;
        decode_stage_reg_pcs <= pcs;
    end
end

assign out_pcs = decode_stage_reg_pcs;

always @(*) begin
    case (opcode_0)
        6'b000000: begin
            rd_0 = instruction_0[15:11];
            rs_0 = instruction_0[25:21];
            rt_0 = instruction_0[20:16];
            imm_0 = {27'd0,instruction_0[10:6]};
            control_signal_0 = funct_0;
            target_pc_0 = pc_4_0;
            if ((!funct_0[5]) && (!funct_0[4]) && (!funct_0[3])  && (!funct_0[2])) begin
                sel_imm_0 = 1'b1;
            end else begin
                sel_imm_0 = 1'b0;
            end
            if ((!funct_0[5]) && (!funct_0[4]) && funct_0[3]) begin
                command_0 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            end else begin
                command_0 = 3'b001;
            end
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001000: begin //addi
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{instruction_0[15]},instruction_0[15:0]};
            control_signal_0 = 6'b100000;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001001: begin //addiu
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{1'b0},instruction_0[15:0]};
            control_signal_0 = 6'b100000;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b0001100: begin //andi
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{1'b0},instruction_0[15:0]};
            control_signal_0 = 6'b100100;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001101: begin //ori
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{1'b0},instruction_0[15:0]};
            control_signal_0 = 6'b100101;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001110: begin //xori
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{1'b0},instruction_0[15:0]};
            control_signal_0 = 6'b100110;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001111: begin //lui
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {instruction_0[15:0],16{1'b0}};
            control_signal_0 = 6'b111111;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b100011: begin //lw
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{instruction_0[15]},instruction_0[15:0]};
            control_signal_0 = 6'd0;
            sel_imm_0 = 1'b1;
            command_0 = 3'b011; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b101011: begin //sw
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{instruction_0[15]},instruction_0[15:0]};
            control_signal_0 = 6'd0;
            sel_imm_0 = 1'b1;
            command_0 = 3'b111; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b000100: begin //beq
            rd_0 = 5'd0;
            rs_0 = instruction_0[25:21];
            rt_0 = instruction_0[20:16];
            target_pc_0 = branch_pc_0;
            imm_0 = 32'd0;
            control_signal_0 = 6'd1;
            sel_imm_0 = 1'b0;
            command_0 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b000101: begin //bne
            rd_0 = 5'd0;
            rs_0 = instruction_0[25:21];
            rt_0 = instruction_0[20:16];
            target_pc_0 = branch_pc_0;
            imm_0 = 32'd0;
            control_signal_0 = 6'd2;
            sel_imm_0 = 1'b0;
            command_0 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001010: begin //slti
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{instruction_0[15]},instruction_0[15:0]};
            control_signal_0 = 6'b101010;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b001011: begin //sltiu
            rd_0 = instruction_0[20:16];
            rs_0 = instruction_0[25:21];
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = {16{1'b0},instruction_0[15:0]};
            control_signal_0 =  6'b101010;
            sel_imm_0 = 1'b1;
            command_0 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        end
        6'b000010: begin //j
            rd_0 =  5'd0;
            rs_0 =  5'd0;
            rt_0 = 5'd0;
            target_pc_0 = {instruction_0[[31:28]],instruction_0[25:0],2{1'b0}};
            imm_0 = 32'd0;
            control_signal_0 =  6'd3;
            sel_imm_0 = 1'b0;
            command_0 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b1;
            jump_branch_predict_pc_0 = {instruction_0[[31:28]],instruction_0[25:0],2{1'b0}};
        end
        6'b000011: begin //jal
            rd_0 =  5'd0;
            rs_0 =  5'd0;
            rt_0 = 5'd0;
            target_pc_0 = {instruction_0[[31:28]],instruction_0[25:0],2{1'b0}};
            imm_0 = pc_4_0;
            control_signal_0 =  6'd4;
            sel_imm_0 = 1'b1;
            command_0 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b1;
            jump_branch_predict_pc_0 = {instruction_0[[31:28]],instruction_0[25:0],2{1'b0}};
        end
        default:
            rd_0 =  5'd0;
            rs_0 =  5'd0;
            rt_0 = 5'd0;
            target_pc_0 = 32'd0;
            imm_0 = 32'd0;
            control_signal_0 =  6'd0;
            sel_imm_0 = 1'b0;
            command_0 = 3'b000; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_0 = 1'b0;
            jump_branch_predict_pc_0 = 32'd0;
        
    endcase
end


always @(*) begin
    case (opcode_1)
        6'b000000: begin
            rd_1 = instruction_1[15:11];
            rs_1 = instruction_1[25:21];
            rt_1 = instruction_1[20:16];
            imm_1 = {27'd0,instruction_1[10:6]};
            control_signal_1 = funct_1;
            target_pc_1 = pc_4_1;
            if ((!funct_1[5]) && (!funct_1[4]) && (!funct_1[3])  && (!funct_1[2])) begin
                sel_imm_1 = 1'b1;
            end else begin
                sel_imm_1 = 1'b0;
            end
            if ((!funct_1[5]) && (!funct_1[4]) && funct_1[3]) begin
                command_1 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            end else begin
                command_1 = 3'b001;
            end
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001000: begin //addi
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{instruction_1[15]},instruction_1[15:0]};
            control_signal_1 = 6'b100000;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001001: begin //addiu
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{1'b0},instruction_1[15:0]};
            control_signal_1 = 6'b100000;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b0001100: begin //andi
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{1'b0},instruction_1[15:0]};
            control_signal_1 = 6'b100100;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001101: begin //ori
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{1'b0},instruction_1[15:0]};
            control_signal_1 = 6'b100101;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001110: begin //xori
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{1'b0},instruction_1[15:0]};
            control_signal_1 = 6'b100110;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001111: begin //lui
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {instruction_1[15:0],16{1'b0}};
            control_signal_0 = 6'b111111;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b100011: begin //lw
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{instruction_1[15]},instruction_1[15:0]};
            control_signal_1 = 6'd0;
            sel_imm_1 = 1'b1;
            command_1 = 3'b011; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b101011: begin //sw
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{instruction_1[15]},instruction_1[15:0]};
            control_signal_1 = 6'd0;
            sel_imm_1 = 1'b1;
            command_1 = 3'b111; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b000100: begin //beq
            rd_1 = 5'd0;
            rs_1 = instruction_1[25:21];
            rt_1 = instruction_1[20:16];
            target_pc_1 = branch_pc_1;
            imm_1 = 32'd0;
            control_signal_1 = 6'd1;
            sel_imm_1 = 1'b0;
            command_1 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b000101: begin //bne
            rd_1 = 5'd0;
            rs_1 = instruction_1[25:21];
            rt_1 = instruction_1[20:16];
            target_pc_1 = branch_pc_1;
            imm_1 = 32'd0;
            control_signal_1 = 6'd2;
            sel_imm_1 = 1'b0;
            command_1 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001010: begin //slti
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{instruction_1[15]},instruction_1[15:0]};
            control_signal_1 = 6'b101010;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b001011: begin //sltiu
            rd_1 = instruction_1[20:16];
            rs_1 = instruction_1[25:21];
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = {16{1'b0},instruction_1[15:0]};
            control_signal_1 =  6'b101010;
            sel_imm_1 = 1'b1;
            command_1 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        end
        6'b000010: begin //j
            rd_1 =  5'd0;
            rs_1 =  5'd0;
            rt_1 = 5'd0;
            target_pc_1 = {instruction_1[[31:28]],instruction_1[25:0],2{1'b0}};
            imm_1 = 32'd0;
            control_signal_1 =  6'd3;
            sel_imm_1 = 1'b0;
            command_1 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b1;
            jump_branch_predict_pc_1 = {instruction_1[[31:28]],instruction_1[25:0],2{1'b0}};
        end
        6'b000011: begin //jal
            rd_1 =  5'd0;
            rs_1 =  5'd0;
            rt_1 = 5'd0;
            target_pc_1 = {instruction_1[[31:28]],instruction_1[25:0],2{1'b0}};
            imm_1 = pc_4_1;
            control_signal_1 =  6'd4;
            sel_imm_1 = 1'b1;
            command_1 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b1;
            jump_branch_predict_pc_1 = {instruction_1[[31:28]],instruction_1[25:0],2{1'b0}};
        end
        default:
            rd_1 =  5'd0;
            rs_1 =  5'd0;
            rt_1 = 5'd0;
            target_pc_1 = 32'd0;
            imm_1 = 32'd0;;
            control_signal_1 =  6'd0;
            sel_imm_1 = 1'b0;
            command_1 = 3'b000; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_1 = 1'b0;
            jump_branch_predict_pc_1 = 32'd0;
        
    endcase
end

always @(*) begin
    case (opcode_2)
        6'b000000: begin
            rd_2 = instruction_2[15:11];
            rs_2 = instruction_2[25:21];
            rt_2 = instruction_2[20:16];
            imm_2 = {27'd0,instruction_2[10:6]};
            control_signal_2 = funct_2;
            target_pc_2 = pc_4_2;
            if ((!funct_2[5]) && (!funct_2[4]) && (!funct_2[3])  && (!funct_2[2])) begin
                sel_imm_2 = 1'b1;
            end else begin
                sel_imm_2 = 1'b0;
            end
            if ((!funct_2[5]) && (!funct_2[4]) && funct_2[3]) begin
                command_2 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            end else begin
                command_2 = 3'b001;
            end
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001000: begin //addi
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{instruction_2[15]},instruction_2[15:0]};
            control_signal_2 = 6'b100000;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001001: begin //addiu
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{1'b0},instruction_2[15:0]};
            control_signal_2 = 6'b100000;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b0001100: begin //andi
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{1'b0},instruction_2[15:0]};
            control_signal_2 = 6'b100100;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001101: begin //ori
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{1'b0},instruction_2[15:0]};
            control_signal_2 = 6'b100101;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001110: begin //xori
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{1'b0},instruction_2[15:0]};
            control_signal_2 = 6'b100110;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001111: begin //lui
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {instruction_0[15:0],16{1'b0}};
            control_signal_2 = 6'b111111;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b100011: begin //lw
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{instruction_2[15]},instruction_2[15:0]};
            control_signal_2 = 6'd0;
            sel_imm_2 = 1'b1;
            command_2 = 3'b011; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b101011: begin //sw
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{instruction_2[15]},instruction_2[15:0]};
            control_signal_2 = 6'd0;
            sel_imm_2 = 1'b1;
            command_2 = 3'b111; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b000100: begin //beq
            rd_2 = 5'd0;
            rs_2 = instruction_2[25:21];
            rt_2 = instruction_2[20:16];
            target_pc_2 = branch_pc_2;
            imm_2 = 32'd0;
            control_signal_2 = 6'd1;
            sel_imm_2 = 1'b0;
            command_2 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b000101: begin //bne
            rd_2 = 5'd0;
            rs_2 = instruction_2[25:21];
            rt_2 = instruction_2[20:16];
            target_pc_2 = branch_pc_2;
            imm_2 = 32'd0;
            control_signal_2 = 6'd2;
            sel_imm_2 = 1'b0;
            command_2 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001010: begin //slti
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{instruction_2[15]},instruction_2[15:0]};
            control_signal_2 = 6'b101010;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b001011: begin //sltiu
            rd_2 = instruction_2[20:16];
            rs_2 = instruction_2[25:21];
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = {16{1'b0},instruction_2[15:0]};
            control_signal_2 =  6'b101010;
            sel_imm_2 = 1'b1;
            command_2 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        end
        6'b000010: begin //j
            rd_2 =  5'd0;
            rs_2 =  5'd0;
            rt_2 = 5'd0;
            target_pc_2 = {instruction_2[[31:28]],instruction_2[25:0],2{1'b0}};
            imm_2 = 32'd0;
            control_signal_2 =  6'd3;
            sel_imm_2 = 1'b0;
            command_2 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b1;
            jump_branch_predict_pc_2 = {instruction_2[[31:28]],instruction_2[25:0],2{1'b0}};
        end
        6'b000011: begin //jal
            rd_2 =  5'd0;
            rs_2 =  5'd0;
            rt_2 = 5'd0;
            target_pc_2 = {instruction_2[[31:28]],instruction_2[25:0],2{1'b0}};
            imm_2 = pc_4_2;
            control_signal_2 =  6'd4;
            sel_imm_2 = 1'b1;
            command_2 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b1;
            jump_branch_predict_pc_2 = {instruction_2[[31:28]],instruction_2[25:0],2{1'b0}};
        end
        default:
            rd_2 =  5'd0;
            rs_2 =  5'd0;
            rt_2 = 5'd0;
            target_pc_2 = 32'd0;
            imm_2 = 32'd0;
            control_signal_2 =  6'd0;
            sel_imm_2 = 1'b0;
            command_2 = 3'b000; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_2 = 1'b0;
            jump_branch_predict_pc_2 = 32'd0;
        
    endcase
end

always @(*) begin
    case (opcode_3)
        6'b000000: begin
            rd_3 = instruction_3[15:11];
            rs_3 = instruction_3[25:21];
            rt_3 = instruction_3[20:16];
            imm_3 = {27'd0,instruction_3[10:6]};
            control_signal_3 = funct_3;
            target_pc_3 = pc_4_3;
            if ((!funct_3[5]) && (!funct_3[4]) && (!funct_3[3])  && (!funct_3[2])) begin
                sel_imm_3 = 1'b1;
            end else begin
                sel_imm_3 = 1'b0;
            end
            if ((!funct_3[5]) && (!funct_3[4]) && funct_3[3]) begin
                command_3 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            end else begin
                command_3 = 3'b001;
            end
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001000: begin //addi
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{instruction_3[15]},instruction_3[15:0]};
            control_signal_3 = 6'b100000;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001001: begin //addiu
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{1'b0},instruction_3[15:0]};
            control_signal_3 = 6'b100000;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b0001100: begin //andi
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{1'b0},instruction_3[15:0]};
            control_signal_3 = 6'b100100;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001101: begin //ori
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{1'b0},instruction_3[15:0]};
            control_signal_3 = 6'b100101;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001110: begin //xori
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{1'b0},instruction_3[15:0]};
            control_signal_3 = 6'b100110;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001111: begin //lui
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {instruction_3[15:0],16{1'b0}};
            control_signal_3 = 6'b111111;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b100011: begin //lw
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{instruction_3[15]},instruction_3[15:0]};
            control_signal_3 = 6'd0;
            sel_imm_3 = 1'b1;
            command_3 = 3'b011; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b101011: begin //sw
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{instruction_3[15]},instruction_3[15:0]};
            control_signal_3 = 6'd0;
            sel_imm_3 = 1'b1;
            command_3 = 3'b111; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b000100: begin //beq
            rd_3 = 5'd0;
            rs_3 = instruction_3[25:21];
            rt_3 = instruction_3[20:16];
            target_pc_3 = branch_pc_3;
            imm_3 = 32'd0;
            control_signal_3 = 6'd1;
            sel_imm_3 = 1'b0;
            command_3 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b000101: begin //bne
            rd_3 = 5'd0;
            rs_3 = instruction_3[25:21];
            rt_3 = instruction_3[20:16];
            target_pc_3 = branch_pc_3;
            imm_3 = 32'd0;
            control_signal_3 = 6'd2;
            sel_imm_3 = 1'b0;
            command_3 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001010: begin //slti
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{instruction_3[15]},instruction_3[15:0]};
            control_signal_3 = 6'b101010;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b001011: begin //sltiu
            rd_3 = instruction_3[20:16];
            rs_3 = instruction_3[25:21];
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = {16{1'b0},instruction_3[15:0]};
            control_signal_3 =  6'b101010;
            sel_imm_3 = 1'b1;
            command_3 = 3'b001; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        end
        6'b000010: begin //j
            rd_3 =  5'd0;
            rs_3 =  5'd0;
            rt_3 = 5'd0;
            target_pc_3 = {instruction_3[[31:28]],instruction_3[25:0],2{1'b0}};
            imm_3 = 32'd0;
            control_signal_3 =  6'd3;
            sel_imm_3 = 1'b0;
            command_3 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b1;
            jump_branch_predict_pc_3 = {instruction_3[[31:28]],instruction_3[25:0],2{1'b0}};
        end
        6'b000011: begin //jal
            rd_3 =  5'd0;
            rs_3 =  5'd0;
            rt_3 = 5'd0;
            target_pc_3 = {instruction_3[[31:28]],instruction_3[25:0],2{1'b0}};
            imm_3 = pc_4_3;
            control_signal_3 =  6'd4;
            sel_imm_3 = 1'b1;
            command_3 = 3'b010; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b1;
            jump_branch_predict_pc_3 = {instruction_3[[31:28]],instruction_3[25:0],2{1'b0}};
        end
        default:
            rd_3 =  5'd0;
            rs_3 =  5'd0;
            rt_3 = 5'd0;
            target_pc_3 = 32'd0;
            imm_3 = 32'd0;
            control_signal_3 =  6'd0;
            sel_imm_3 = 1'b0;
            command_3 = 3'b000; // command  1 is for R type alu ops, 2 is for jump/branch, 3 for load, 7 for store 0 is for default
            jump_branch_predict_3 = 1'b0;
            jump_branch_predict_pc_3 = 32'd0;
        
    endcase
end

endmodule