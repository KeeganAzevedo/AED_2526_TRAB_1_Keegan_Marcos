// Helpers privados (só neste .c)
static int in_bounds(const Image I, int u, int v) {
    return u >= 0 && v >= 0 && u < ImageGetWidth(I) && v < ImageGetHeight(I);
}

Image ImageCopy(const Image src) {
    if (!src) return NULL;

    const int W = ImageGetWidth(src);
    const int H = ImageGetHeight(src);
    const int LUTn = ImageGetLUTSize(src);

    // cria imagem destino com mesmas dims e LUT
    Image dst = ImageCreate(W, H, LUTn);           // usa o construtor do teu TAD
    if (!dst) return NULL;

    // 1) copiar LUT
    for (int i = 0; i < LUTn; ++i) {
        RGB c = ImageGetLUTColor(src, i);          // ou equivalente
        if (!ImageSetLUTColor(dst, i, c)) {        // trata retorno conforme a tua API
            ImageDestroy(dst);                     // evita leaks
            return NULL;
        }
    }

    // 2) copiar matriz de índices (deep copy)
    for (int v = 0; v < H; ++v) {
        for (int u = 0; u < W; ++u) {
            int idx = ImageGetPixelIndex(src, u, v); // ler índice da LUT
            ImageSetPixelIndex(dst, u, v, idx);      // escrever no novo buffer
        }
    }

    return dst;
}





// --- Contador de comparações (visível nos testes/relatório) ---
static size_t g_eq_pixel_comparisons = 0;
void ImageEqResetCounter(void) { g_eq_pixel_comparisons = 0; }
size_t ImageEqGetCounter(void) { return g_eq_pixel_comparisons; }

// --- Função principal ---
int ImageIsEqual(const Image a, const Image b) {
    // Pré-condições triviais
    if (!a || !b) return 0;

    const int Wa = ImageGetWidth(a),  Ha = ImageGetHeight(a);
    const int Wb = ImageGetWidth(b),  Hb = ImageGetHeight(b);

    // Se dimensões diferirem, são diferentes (não conta comparações de pixel)
    if (Wa != Wb || Ha != Hb) return 0;

    // Varrer por linhas (melhor para cache)
    for (int v = 0; v < Ha; ++v) {
        for (int u = 0; u < Wa; ++u) {
            // 1 comparação de pixel
            ++g_eq_pixel_comparisons;
            if (ImageGetPixelIndex(a, u, v) != ImageGetPixelIndex(b, u, v)) {
                return 0; // short-circuit no primeiro mismatch (melhor caso)
            }
        }
    }
    return 1; // iguais (pior caso em nº de comparações)
}
