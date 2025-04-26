`include "imem.v"

function integer log2ceil;
    input integer value;
    begin
        log2ceil = (value <= 1) ? 1 : $clog2(value-1) + 1;
    end
endfunction

module i_cache #(
    parameter INSTRUCTION_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32,
    parameter INSTRUCTION_SIZE = log2ceil(INSTRUCTION_WIDTH/8)
) (
    input clock,
    input reset,
    input read0,
    output reg busy_wait_port_0,
    output [INSTRUCTION_WIDTH * 4-1:0] instruction_port_0,
    input [ADDRESS_WIDTH-1:0] adress_port_0,
    input read1,
    output reg busy_wait_port_1,
    output [INSTRUCTION_WIDTH * 4-1:0] instruction_port_1,
    input [ADDRESS_WIDTH-1:0] adress_port_1,
);

reg [ADDRESS_WIDTH-3-2-INSTRUCTION_SIZE] tags_set0[0:7];
reg [ADDRESS_WIDTH-3-2-INSTRUCTION_SIZE] tags_set1[0:7];
reg valid_bits_set0[0:7];
reg valid_bits_set1[0:7];
reg latest_bits_set0[0:7];
reg latest_bits_set1[0:7];
reg [INSTRUCTION_WIDTH-1:0] words_set0[0:7][0:3];
reg [INSTRUCTION_WIDTH-1:0] words_set1[0:7][0:3];
reg hit0, hit1;

wire [2:0] index0;
wire [ADDRESS_WIDTH-3-2-INSTRUCTION_SIZE] tag0;
wire [1:0] offset0;

wire [2:0] index1,arbiter;
wire [ADDRESS_WIDTH-3-2-INSTRUCTION_SIZE] tag1;
wire [1:0] offset1;

wire tag_comparison0;
wire tag_comparison1;
wire [INSTRUCTION_WIDTH * 4-1:0] mem_read_data;
wire mem_read;
wire mem_busywait, write_from_mem_port0, write_from_mem_port1;
wire [ADDRESS_WIDTH -1-INSTRUCTION_SIZE-2:0] mem_address;

assign index0 = adress_port_0[ADDRESS_WIDTH-1:ADDRESS_WIDTH-3];
assign tag0 = adress_port_0[ADDRESS_WIDTH-4:INSTRUCTION_SIZE+2];
assign offset0 = adress_port_0[INSTRUCTION_SIZE+1:INSTRUCTION_SIZE];

assign index1 = adress_port_1[ADDRESS_WIDTH-1:ADDRESS_WIDTH-3];
assign tag1 = adress_port_1[ADDRESS_WIDTH-4:INSTRUCTION_SIZE+2];
assign offset1 = adress_port_1[INSTRUCTION_SIZE+1:INSTRUCTION_SIZE];

i_memory #(.INSTRUCTION_WIDTH(INSTRUCTION_WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH)) my_i_memory(clock,reset,mem_read,mem_address,mem_readdata,mem_busywait);

assign tag_comparison0_set0 = (tag0 == tags_set0[index0]);
assign tag_comparison0_set1 = (tag0 == tags_set1[index0]);
assign tag_comparison1_set0 = (tag1 == tags_set0[index1])
assign tag_comparison1_set1 = (tag1 == tags_set1[index1]);


always @(*) begin
    if (( tag_comparison0_set0 && valid_bits_set0[index0]) || ( tag_comparison0_set1 && valid_bits_set1[index0]) ) begin
        hit0 = 1'b1;
    end else begin
        hit0 = 1'b0;
    end
    
end

always @(*) begin
    if (( tag_comparison1_set0 && valid_bits_set0[index1]) || ( tag_comparison1_set1 && valid_bits_set1[index1])) begin
        hit1 = 1'b1;
    end else begin
        hit1 = 1'b0;
    end
    
end

always @(*) begin
    if (tag_comparison0_set0) begin
        instruction_port_0 = {words_set0[index0][3],words_set0[index0][2],words_set0[index0][1],words_set0[index0][0]};
    end else if (tag_comparison0_set1) begin
        instruction_port_0 = {words_set1[index0][3],words_set1[index0][2],words_set1[index0][1],words_set1[index0][0]};
    end
    else begin
        instruction_port_0 = 0;
    end
end

always @(*) begin
    if (tag_comparison1_set0) begin
        instruction_port_1 = {words_set0[index1][3],words_set0[index1][2],words_set0[index1][1],words_set0[index1][0]};
    end else if (tag_comparison1_set1) begin
        instruction_port_1 = {words_set1[index1][3],words_set1[index1][2],words_set1[index1][1],words_set1[index1][0]};
    end
    else begin
        instruction_port_1 = 0;
    end
end

always @(*) begin
    if ((!hit1 && read1) && (!hit0 && read0)) begin
        arbiter = 3'b001;
    end else if ((!hit1 && read1) && (hit0 && read0)) begin
        arbiter = 3'b010;
    end else if ((hit1 && read1) && (!hit0 && read0)) begin
        arbiter = 3'b011;
    end else if ((!hit1 && read1) && ( !read0)) begin
        arbiter = 3'b100;
    end else if ((!read1) && (!hit0 && read0)) begin
        arbiter = 3'b101;
    end else begin
        arbiter = 3'b000;
    end
end

always @(posedge clock) begin
        if (write_from_mem_port0) begin //write data get from instruction memory
            if (latest_bits_set1[index0]) begin
                latest_bits_set0[index0] <= 1;
                latest_bits_set1[index0] <= 0;
                valid_bits_set0[index0] <= 1;
                tags_set0[index0] <= tag0;
                {words_set0[index0][3],words_set0[index0][2],words_set0[index0][1],words_set0[index0][0]} <= mem_readdata;
            end else begin
                latest_bits_set0[index0] <= 0;
                latest_bits_set1[index0] <= 1;
                valid_bits_set1[index0] <= 1;
                tags_set1[index0] <= tag0;
                {words_set1[index0][3],words_set1[index0][2],words_set1[index0][1],words_set1[index0][0]} <= mem_readdata;
            end
            
        end
        if (write_from_mem_port1) begin
            if (latest_bits_set1[index1]) begin
                latest_bits_set0[index1] <= 1;
                latest_bits_set1[index1] <= 0;
                valid_bits_set0[index1] <= 1;
                tags_set0[index1] <= tag1;
                {words_set0[index1][3],words_set0[index1][2],words_set0[index1][1],words_set0[index1][0]} <= mem_readdata;
            end else begin
                latest_bits_set0[index1] <= 0;
                latest_bits_set1[index1] <= 1;
                valid_bits_set1[index1] <= 1;
                tags_set1[index1] <= tag1;
                {words_set1[index1][3],words_set1[index1][2],words_set1[index1][1],words_set1[index1][0]} = mem_readdata;
            end
        end
end

/* Cache Controller FSM Start */

localparam IDLE = 3'b000, PORT0_MEM_ACCESS = 3'b001, PORT1_MEM_ACCESS = 3'b010 ,PORT0_CACHE_WRITE = 3'b011, PORT1_CACHE_WRITE = 3'b100;
reg [2:0] state, next_state;

// combinational next state logic
always @(*) begin
    case (state)
        IDLE: 
            if (arbiter == 3'b001 ) begin
                next_state = PORT0_MEM_ACCESS;               
            end else if (arbiter == 3'b010) begin
                next_state = PORT1_MEM_ACCESS;
            end else if (arbiter == 3'b011 ) begin
                next_state = PORT0_MEM_ACCESS;
            end else if (arbiter == 3'b100 ) begin
                next_state = PORT1_MEM_ACCESS;
            end else if (arbiter == 3'b101 ) begin
                next_state = PORT0_MEM_ACCESS;                
            end else begin
                next_state = IDLE;
            end
        PORT0_MEM_ACCESS:
            if (!mem_busywait) begin
                next_state = PORT0_CACHE_WRITE;
            end else begin
                next_state = PORT0_MEM_ACCESS:
            end
        PORT1_MEM_ACCESS:
            if (!mem_busywait) begin
                next_state = PORT1_CACHE_WRITE;
            end else begin
                next_state = PORT1_MEM_ACCESS:
            end
        PORT0_CACHE_WRITE:
            if (!hit1 && read1) begin
                next_state = PORT1_MEM_ACCESS;
            end else begin
                next_state =IDLE;
            end
        PORT1_CACHE_WRITE:
            next_state = IDLE;
        default:
            next_state = IDLE; 
    endcase
end

// combinational output logic

always @(*) begin
    case (state)
        IDLE:
            begin
                mem_read = 0;
                mem_address = {(ADDRESS_WIDTH-INSTRUCTION_SIZE-2){1'b0}};
                if (!hit0 && read0) begin
                    busy_wait_port_0 = 1;
                end else begin
                    busy_wait_port_0 = 0;
                end
                if (!hit1 && read1) begin
                    busy_wait_port_1 = 1;
                end else begin
                    busy_wait_port_1 = 0;
                end
                write_from_mem_port0 = 0;
                write_from_mem_port1 = 0;
            end
        PORT0_MEM_ACCESS:
            begin
                mem_read = 1;
                mem_address = adress_port_0[ADDRESS_WIDTH-1:INSTRUCTION_SIZE+2];
                busy_wait_port_0 = 1;
                if (!hit1 && read1) begin
                    busy_wait_port_1 = 1;
                end else begin
                    busy_wait_port_1 = 0;
                end
                write_from_mem_port0 = 0;
                write_from_mem_port1 = 0;
            end
        PORT1_MEM_ACCESS:
            begin
                mem_read = 1;
                mem_address = adress_port_1[ADDRESS_WIDTH-1:INSTRUCTION_SIZE+2];
                busy_wait_port_1 = 1;
                if (!hit0 && read0) begin
                    busy_wait_port_0 = 1;
                end else begin
                    busy_wait_port_0 = 0;
                end
                write_from_mem_port0 = 0;
                write_from_mem_port1 = 0;
            end
        PORT0_CACHE_WRITE:
            begin
                mem_read = 0;
                mem_address = {(ADDRESS_WIDTH-INSTRUCTION_SIZE-2){1'b0}};
                busy_wait_port_0 = 1;
                if (!hit1 && read1) begin
                    busy_wait_port_1 = 1;
                end else begin
                    busy_wait_port_1 = 0;
                end
                write_from_mem_port0 = 1;
                write_from_mem_port1 = 0;
            end
        PORT1_CACHE_WRITE:
            begin
                mem_read = 1;
                mem_address = {(ADDRESS_WIDTH-INSTRUCTION_SIZE-2){1'b0}};
                busy_wait_port_1 = 1;
                if (!hit0 && read0) begin
                    busy_wait_port_0 = 1;
                end else begin
                    busy_wait_port_0 = 0;
                end
                write_from_mem_port0 = 0;
                write_from_mem_port1 = 1;
            end
        default:
            begin
                mem_read = 0;
                mem_address = {(ADDRESS_WIDTH-INSTRUCTION_SIZE-2){1'b0}};
                busy_wait_port_1 = 0;
                busy_wait_port_0 = 0;
                write_from_mem_port0 = 0;
                write_from_mem_port1 = 0;
            end 
    endcase
end

// sequential logic for state transitioning 
integer i;
always @(posedge clock) begin
    if(reset)begin
        state = IDLE;
           
        for (i =0 ;i<8 ;i++ ) begin
            valid_bits_set0[i] = 1'b0;
        end
        for (i =0 ;i<8 ;i++ ) begin
            valid_bits_set1[i] = 1'b0;
        end
        for (i =0 ;i<8 ;i++ ) begin
            latest_bits_set0[i] = 1'b0;
        end
        for (i =0 ;i<8 ;i++ ) begin
            latest_bits_set1[i] = 1'b0;
        end

    end
    else
        state <= next_state;
end

/* Cache Controller FSM End */

endmodule