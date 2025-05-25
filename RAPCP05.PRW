#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

/*/
+-—————————————————————————————————————————————————————————————————————————-+
| Funcao    | RAPCP05                                                       |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Autor     | Roberto Mendes Rodrigues                  | Data | 06/08/2019 |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Descricao | Simulação de Produção na MATRIZ                               |
|           | Com Base na estrutura                                         |
+-———————————-+-——————————-+-——————————————————————————————————————————————-+ /*/


*********************
user Function RAPCP05()
*********************

Local oSay1
Local oSay2
Private cGetProd     := Space(8)
Private oGetDesProd
Private cGetDesProd  := Space(40)
Private oGetUM
Private cGetUM       := Space(02)

Private oGetQuant
Private nGetQuant := 0

Private nB1_QB := 0

Static oDlg

DEFINE MSDIALOG oDlg TITLE "Simulação de Produção" FROM 000, 000  TO 300, 800 COLORS 0, 16777215 PIXEL Style 128

   oDlg:lEscClose     := .F.

    @ 059, 006 SAY oSay1 PROMPT "Produto:"           SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 057, 049 MSGET oGetProd    VAR cGetProd        SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SB1"           VALID fDescProd(cGetProd)
    @ 057, 100 MSGET oGetDesProd VAR cGetDesProd     SIZE 175, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .f.
    @ 057, 290 MSGET oGetDesProd VAR cGetUM          SIZE 010, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .f.

    @ 079, 006 SAY oSay2 PROMPT "Quantidade:"        SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 077, 049 MSGET oGetQuant    VAR nGetQuant      SIZE 040, 010 OF oDlg COLORS 0, 16777215 PICTURE "99,999,999" PIXEL  VALID fQuant(nGetQuant)

    @ 112, 350 BUTTON oButton1 PROMPT "&Gerar Simulação" SIZE 045, 012 OF oDlg                PIXEL ACTION fGeraSim()
    @ 112, 305 BUTTON oButton2 PROMPT "Sai&r"            SIZE 037, 012 OF oDlg                PIXEL ACTION fSair()

ACTIVATE MSDIALOG oDlg CENTERED

Return()


************************
Static Function fGeraSim()
************************

Local oFont8
Local oFont8n
Local oFont9
Local oFont9n
Local oFont10
Local oFont10n
Local oFont16
Local oFont16n
Local oFont24
Local oBrush
Local oPrint
Local nLin

Local aBitmap  := { "lgrl" + cEmpAnt + ".bmp" }  //Logo da empresa


if cEmpAnt+cFilAnt="1004"
    cEP_6501  := padr(getMV("EP_6501"),len(SG1->G1_COD))      // Código do produto MP- MILHO =  20130009
    cEP_650C  := padr(getMV("EP_650C"),len(SC2->C2_PRODUTO))   // Código do produto PA- CANJICA =  20130014/0021
    cEP_650D  := getMV("EP_650D")   // Fator de Divisão consumo de Canjica = 0.75 (para cada 1000 KG de Amido eu consumo 1000 / 0.75 )
                                    // Pacco alterou para 0.83 em 10/01/2022
endif

Private aSaldos := {}
Private nSaldo  := 0

oFont8   := TFont():New("Arial",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
oFont8n  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)

oFont10  := TFont():New("Arial",9,14,.F.,.F.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Arial",9,12,.F.,.F.,5,.T.,5,.T.,.F.)
oFont9n  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oBrush := TBrush():New("",4)

nB1_QB := iif(SB1->B1_QB=0,1,SB1->B1_QB)

dbSelectArea("SG1")
SG1->(dbSetOrder(1))
if !SG1->(dbSeek(xFilial("SG1") + cGetProd))
   MsgStop("Não localizada !!!","Estrutura do produto")
   return
endif

oPrint:= TMSPrinter():New( "SIMULAÇÃO DE PRODUÇÃO "+u_fsiglafil() )


oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova pÃ¡gina


//----------------------------//
//Imprime logo da empresa     //
//----------------------------//

oPrint:SayBitmap(050,100,aBitMap[1],362,140)

nLin:=290
oPrint:Say  (nLin+10,0060,"SIMULAÇÃO DE PRODUÇÃO DO PRODUTO     "+cGetProd+"  "+alltrim(cGetDesProd)+"   "+trans(nGetQuant,"999,999,999")+" "+cGetUM, oFont8n)

nLin+=200

oPrint:Say  (nLin   ,0060,"Código"      , oFont9n)
oPrint:Say  (nLin   ,0260,"Produto"     , oFont9n)
oPrint:Say  (nLin   ,1450,"UM"          , oFont9n)
oPrint:Say  (nLin   ,1850,"Necessidade" , oFont9n,,,,1)
oPrint:Say  (nLin   ,2150,"Saldo Atual" , oFont9n,,,,1)
oPrint:Say  (nLin   ,2440,"Saldo Final" , oFont9n,,,,1)
nLin+=100

while !SG1->(eof()) .and. SG1->G1_COD = cGetProd

    if subs(SG1->G1_COMP,1,3)="MOD" .or. SG1->G1_INI > ddataBase .or. SG1->G1_FIM < ddataBase
         SG1->(dbskip()) ; loop
    endif

    dbSelectArea("SB1")
    dbSetOrder(1)
    If dbSeek(xFilial("SB1") + SG1->G1_COMP)

		aSaldos := CalcEst(SB1->B1_COD,SB1->B1_LOCPAD, dDataBase+1)
		nSaldo  := aSaldos[1]

		oPrint:Say  (nLin   ,0060,SG1->G1_COMP , oFont9n)
		oPrint:Say  (nLin   ,0260,SB1->B1_DESC , oFont9n)
		oPrint:Say  (nLin   ,1450,SB1->B1_UM      , oFont9n)

		oPrint:Say  (nLin   ,1850,trans(nGetQuant * SG1->G1_QUANT / nB1_QB ,'@e 999,999,999.9999'), oFont9n,,,,1) // Matriz trabalha com gramas

		oPrint:Say  (nLin   ,2150,trans(nSaldo  ,			'@e 999,999.9999'), oFont9n,,,,1)

		if (nSaldo - (nGetQuant * SG1->G1_QUANT) / nB1_QB ) < 0
		     oPrint:Say  (nLin   ,2440,trans((nSaldo - (nGetQuant * SG1->G1_QUANT) / nB1_QB) ,'@e 999,999.9999'), oFont10n,,CLR_HRED,,1)
		else
		     oPrint:Say  (nLin   ,2440,trans((nSaldo - (nGetQuant * SG1->G1_QUANT) / nB1_QB) ,'@e 999,999.9999'), oFont9n,,,,1)
		endif
		nLin+=090
		
    endif
    SG1->(dbskip())
 
enddo 


oPrint:EndPage() // Finaliza a pÃ¡gina

oPrint:Preview()  // Visualiza antes de imprimir



***********************
Static Function fSair()
***********************

oDlg:End()
return()


******************************
Static Function fDescProd(cCod)
******************************
Local lRet := .t.

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1") + cCod)
	cGetDesProd := SB1->B1_DESC
	cGetUM      := SB1->B1_UM
	oGetDesProd:Refresh()

Elseif !empty(cCod)
	MsgStop("Produto não encontrado!")
	lRet := .f.
EndIf

Return(lRet)

******************************
Static Function fQuant(nQuant)
******************************

if nQuant > 99999999
     MsgStop("Quantidade maxima 99,999,999")
     Return .f.
endif
