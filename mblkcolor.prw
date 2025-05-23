//Bibliotecas
#Include "Protheus.ch"
 
 //Constantes
#Define CLR_RGB_BRANCO        RGB(254,254,254)    //Cor Branca em RGB
#define CLR_HGRAY      12632256                   // RGB( 192, 192, 192 ) 

*+-—————————————————————————————————————————————————————————————————————————-+
*| Funcao    | MBlkColor                                                     |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
*| Autor     | Roberto Mendes Rodrigues                  | Data | 12/11/2018 |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
*| Descricao | Para realçar nos Browses registros Bloqueados                 |
*+———————————+———————————————————————————————————————————————————————————————+
 

User Function MBlkColor()
    Local aRet := {}    //Se deixar assim tem o retorno padrão
 
    //Adicionando as cores
    aAdd(aRet, (CLR_RGB_BRANCO)   ) //Cor do texto
    aAdd(aRet, (CLR_HGRAY)) //Cor de fundo
Return aRet



// #Define CLR_RGB_VERMELHO      RGB(255,000,000)    //Cor Vermelha em RGB
// #Define CLR_RGB_PRETO         RGB(000,000,000)    //Cor Preta em RGB
 
 
//  //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ// 
// //                        Low Intensity colors 
// //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ// 

// #define CLR_BLACK             0               // RGB(   0,   0,   0 ) 
// #define CLR_BLUE        8388608               // RGB(   0,   0, 128 ) 
// #define CLR_GREEN        32768               // RGB(   0, 128,   0 ) 
// #define CLR_CYAN        8421376               // RGB(   0, 128, 128 ) 
// #define CLR_RED             128               // RGB( 128,   0,   0 ) 
// #define CLR_MAGENTA     8388736               // RGB( 128,   0, 128 ) 
// #define CLR_BROWN        32896               // RGB( 128, 128,   0 ) 
// #define CLR_LIGHTGRAY CLR_HGRAY 

// //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ// 
// //                      High Intensity Colors 
// //ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ// 

// #define CLR_GRAY        8421504               // RGB( 128, 128, 128 ) 
// #define CLR_HBLUE      16711680               // RGB(   0,   0, 255 ) 
// #define CLR_HGREEN        65280               // RGB(   0, 255,   0 ) 
// #define CLR_HCYAN      16776960               // RGB(   0, 255, 255 ) 
// #define CLR_HRED            255               // RGB( 255,   0,   0 ) 
// #define CLR_HMAGENTA   16711935               // RGB( 255,   0, 255 ) 
// #define CLR_YELLOW        65535               // RGB( 255, 255,   0 ) 
// #define CLR_WHITE      16777215               // RGB( 255, 255, 255 ) 
 

