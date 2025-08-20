module shifter_module (
    input  wire [31:0] data_in,   // parola di input
    input  wire [4:0]  shamt,     // numero di posizioni da shiftare
    input  wire        dir,       // 0 = sinistra, 1 = destra
    output wire [31:0] data_out   // risultato
);

    assign data_out = (dir == 1'b0) ? (data_in << shamt) : (data_in >> shamt);

endmodule