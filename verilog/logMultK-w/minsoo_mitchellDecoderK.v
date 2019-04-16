`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2018 04:06:23 PM
// Design Name: 
// Module Name: minsoo_mitchellDecoderK
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


module minsoo_mitchellDecoderK
    #(
        parameter
        N = 8,
        LOG_N = 3,
        K = 5,
        LOG_K = 3 
    )
    (
        input [LOG_N+K:0] res,
        output [2*N-1:0] z
    );
    

    wire [LOG_N:0] charac = res[LOG_N+K:K];
    wire [K:0] mantissa = {1'b1,res[K-1:0]};

    wire [N+K-1:0] shiftL_op = {{(N-1){1'b0}},mantissa};
    wire [N-1:0] shiftR_op = {mantissa, {(N-K-1){1'b0}}}; 
    wire [N+K-1:0] shiftL;
    wire [N-1:0] shiftR; 
    wire [LOG_N-1:0] shamtL = charac[LOG_N-1:0];
    wire [LOG_N-1:0] shamtR = ~charac[LOG_N-1:0];
    
    assign shiftL = shiftL_op << shamtL;
    
//    barrelShifter
//    #(
//        .N(N+K),
//        .LOG_N(LOG_N+1)
//    )
//    barrel_shiftL(
//        .x(shiftL_op),
//        .shiftAm(shamtL),
//        .shX(shiftL)
//    );
    
    barrelShifterR
    #(
        .N(N),
        .LOG_N(LOG_N)
     )
     barrel_shiftR(
        .x(shiftR_op),
        .shiftAm(shamtR),
        .shX(shiftR)     
     );


    assign z[2*N-1:N] = {N{charac[LOG_N]}} & shiftL[N+K-1:K];
    assign z[N-1:N-K] = (charac[LOG_N])? shiftL[K-1:0] : shiftR[N-1: N-K];
    assign z[N-K-1:0] = (charac[LOG_N])? {(N-K){1'b0}} : shiftR[N-K-1:0];
     
    
endmodule
