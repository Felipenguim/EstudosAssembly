// ------------------- Exemplo 1 -------------------
mov     x0, 0x1111222233334444      // x0 = 0x1111222233334444
mov     w0, 0x55556666              // x0 = 0x0000000055556666
                                    // Ao escrever em w0 (32 bits),
                                    // a arquitetura ARM64 define que os bits superiores (63–32)
                                    // de x0 são automaticamente zerados.
                                    // Portanto, o resultado NÃO é 0x1111222233336666.

// ------------------- Exemplo 2 -------------------
mov     x0, 0x1111222233334444      // x0 = 0x1111222233334444
// (ARM64 não possui subdivisões menores como x86-64 — não há w0h, w0l, etc.)
// Logo, não existe equivalente a "mov ax, 0x7777".
// Só é possível operar em 32 bits (w0) ou 64 bits (x0).

// ------------------- Exemplo 3 -------------------
mov     x0, 0x1111222233334444      // x0 = 0x1111222233334444
eor     w0, w0, w0                  // x0 = 0x0000000000000000
                                    // Assim como em x86-64, qualquer instrução
                                    // que escreva no registrador de 32 bits (w0)
                                    // também zera os bits superiores de x0.
                                    // Por isso o resultado não é 0x1111222200000000,
                                    // e sim completamente 0x0000000000000000.
