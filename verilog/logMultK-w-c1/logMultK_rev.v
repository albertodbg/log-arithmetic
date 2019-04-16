`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2018 05:01:13 PM
// Design Name: 
// Module Name: logMultK_rev
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module logMultK_rev
    #(
        parameter
        N = 8,
        LOG_N = 3,
        LOG_LOG_N = 2,
        K = 5,
        LOG_K = 3
    )
    (
        input [N-1:0] a,
        input [N-1:0] b,
        output [2*N-1:0] z
    );

    wire a_ms;
    wire b_ms;
    wire z_sign;
    wire [N-1:0] a_c1;
    wire [N-1:0] b_c1;
    wire [N-1:0] a_lod;
    wire [N-1:0] b_lod;
    wire [LOG_N-1:0] a_enc;
    wire [LOG_N-1:0] b_enc;
    wire [LOG_N-1:0] a_shamt;
    wire [LOG_N-1:0] b_shamt;
    wire [N-2:0] a_aux;
    wire [N-2:0] b_aux;
    wire [N-2:0] a_sh;
    wire [N-2:0] b_sh;
    wire [2*N-1:0] z_aux;
    wire [2*N-1:0] z_aux_c1;
    wire notZero_a;
    wire notZero_b;
    wire notZero;
    wire [LOG_N+K-1:0] op1;
    wire [LOG_N+K-1:0] op2;
    wire [LOG_N+K:0] res;


    assign a_ms = a[N-1];
    assign b_ms = b[N-1];
    assign a_c1 = (a_ms)? ~a : a;
    assign b_c1 = (b_ms)? ~b : b;
    assign z_sign = a_ms ^ b_ms;
    assign z_aux_c1 = (z_sign)? ~z_aux : z_aux;



    lod 
    #(
        .N(N),
        .LOG_N(LOG_N)
     )
     lone_a (
        .d(a_c1),
        .z(a_lod)
     );

    lod 
    #(
        .N(N),
        .LOG_N(LOG_N)
     )
     lone_b (
        .d(b_c1),
        .z(b_lod)
     );

    encoder
    #(
        .N(N),
        .LOG_N(LOG_N)
    )
	enc_a(
	    .x(a_lod),
		.enc(a_enc)
	);

    encoder
    #(
        .N(N),
        .LOG_N(LOG_N)
    )
	enc_b(
	    .x(b_lod),
		.enc(b_enc)
	);

    assign a_shamt = ~a_enc;
    assign b_shamt = ~b_enc;

    assign a_aux = a_c1[N-2:0];
    assign b_aux = b_c1[N-2:0];


    generate

        if (N <= 16) begin
            assign a_sh = a_aux << a_shamt;
            assign b_sh = b_aux << b_shamt;
        end
        else begin
            barrelShifter
            #(
                .N(N-1),
                .LOG_N(LOG_N)
            )
            bsh_a(
                .x(a_aux),
                .shiftAm(a_shamt),
                .shX(a_sh)
            );

            barrelShifter
            #(
                .N(N-1),
                .LOG_N(LOG_N)
            )
            bsh_b(
                .x(b_aux),
                .shiftAm(b_shamt),
                .shX(b_sh)
            );
        end
    endgenerate

    assign op1 = {a_enc, a_sh[N-2:N-K-1]};
    assign op2 = {b_enc, b_sh[N-2:N-K-1]};
    assign res = op1 + op2;


    minsoo_mitchellDecoderK
    #(
        .N(N),
        .LOG_N(LOG_N),
        .K(K),
        .LOG_K(LOG_K)
    )
    decod(
        .res(res),
        .z(z_aux)
    );

    
    orTree
    #(
        .N(LOG_N),
        .LOG_N(LOG_LOG_N)
    )
    ot_a(
        .x(a_enc),
        .z(notZero_a)
    );
    orTree
    #(
        .N(LOG_N),
        .LOG_N(LOG_LOG_N)
    )
    ot_b(
        .x(b_enc),
        .z(notZero_b)
    );

    assign notZero = (notZero_a | a[0] | a_ms) & (notZero_b | b[0] | b_ms);
    assign z = z_aux_c1 & {2*N{notZero}};

endmodule
