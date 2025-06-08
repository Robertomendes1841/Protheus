

#INCLUDE "TOTVS.CH"
#INCLUDE "Topconn.ch"
#Include "Protheus.ch"
#Include "Report.ch"  

*+-—————————————————————————————————————————————————————————————————————————-+
*| Funcao    | APTPROD                                                       |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
*| Autor     | Roberto Mendes Rodrigues                  | Data | 08/06/2025 |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
*| Descricao | Apontamento Ordem de Produção                                 |
*+-—————————-+-—————————————————————————————————————————————————————————————-+



********************** 
User Function APTPROD()
**********************
Local oSay,oGroup1
Local nCol :=0

Private oGet,oGet1,oGetB1,oButton
Private nLin := nColIni := 0 

Private oFont11   := TFont():New( "Arial Black" , 11 ,22 )
Private oFont11CN := TFont():New( "Courier New" , 10 ,22,,.t. )

Private oFont09N  := TFont():New( "Courier New" , 09 ,18,,.t. )

Private nHRes    :=	oMainWnd:nClientWidth
Private aSize    := MsAdvSize()             //5 -> Coluna final dialog (janela). | 6 -> Linha final dialog (janela). | 7 -> Linha inicial dialog (janela).

Private cCodBar  := space(len("C2_NUM"))    // Não use criavar aqui pois pode haver um inicializador padrão...
Private cB1_DESC := criavar("B1_DESC")

M->C2_EMISSAO := dDataBase
M->C2_QUANT   := criavar("C2_QUANT")

Private lProcATOM   := "ATOM"  $ Upper(GetRmtInfo()[7])  .or. "CELERON(R)" $ Upper(GetRmtInfo()[7]) 

If Select("TMPBRW") <> 0 ;	TMPBRW->(dbCloseArea()) ; EndIf

aCampos := {{"OK"      ,"C",01,0},;
            {"OP"      ,"C",06,0},;
            {"COD"     ,"C",15,0},;
            {"DESC"    ,"C",55,0},;
            {"QUANT"   ,"N",05,0},;
            {"EMISSAO" ,"D",08,0} }

cArqTrb1 := CriaTrab(aCampos,.t.) 
cArqInd1 := CriaTrab(NIL,.f.)
dbUseArea(.t.,,cArqTrb1,"TMPBRW",.t.,.f.)

********************************************
* Array com os dados do cabecalho do browse* 
********************************************

Private aCpos := {}

aadd(aCpos,{"OP"     ,"Ordem Produção" ,        ,"06"})
aadd(aCpos,{"COD"     ,"Produto"       ,        ,"08"})
aadd(aCpos,{"DESC"    ,"Descricao"     ,        ,"55"})
aadd(aCpos,{"QUANT"   ,"Qtdade"        ,        ,"12","02"})
aadd(aCpos,{"EMISSAO" ,"Emissao"       ,        ,"08"})

DEFINE MSDIALOG oDlg TITLE "Apontamento de Produção"  FROM aSize[7] , 000 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL Style 128

    oDlg:lEscClose     := .F. 

	//------------------------------------------------------------------------------//
	//Testa resolução utilizada se for horizontal maior que 1440 dimensiona a tela  //
	//------------------------------------------------------------------------------//
	
        If nHRes < 1380

           //--------------------------------------------------//
           //Tratamento para versão 12 tem um cabeçalho maior  //
           //--------------------------------------------------//
        
           nReduz := 0.97
           aSize[6] := Int(aSize[6] * nReduz) 
           aSize[5] := Int(aSize[5] * nReduz) 
	   nColIni := 05 
        ElseIf nHRes >= 1380 .And. nHRes < 1700 
	   nReduz := 0.90
	   aSize[6] := Int(aSize[6] * nReduz)
	   aSize[5] := Int(aSize[5] * nReduz)
	   nColIni := 35 
	ElseIf nHRes >= 1700 .And. nHRes < 1900 
	   nReduz := 0.85
	   aSize[6] := Int(aSize[6] * nReduz)
	   aSize[5] := Int(aSize[5] * nReduz)
	nColIni := 55 
           ElseIf nHRes >= 1900
           nReduz := 0.81 
	   aSize[6] := Int(aSize[6] * nReduz)
	   aSize[5] := Int(aSize[5] * nReduz) 
	   nColIni := 75 
	EndIf 
    
    nColIni := 200 
    if lProcATOM 
       nColIni -= 180 
    endif 
 
    nCol := nColIni 
	
    nLin += 10   

    @ nLin-05, ncol -10 GROUP oGroup1 TO nLin+430, aSize[5]-650 + iif(lProcATOM,50,0) OF oDlg COLOR 0, 16777215 PIXEL

    @ nLin  ,nCol  SAY oSay PROMPT "Cod. Barras: "     SIZE 090, 008 FONT oFont11CN OF oDlg COLORS 16711680, 16777215 PIXEL 
    ncol += 80
    @ nLin+1,nCol  MSGET oGet1 VAR cCodBar             SIZE 050,006 valid NovoItem() OF oDlg COLORS 0, 16777215 PIXEL FONT oFont11
 
    nLin += 40 
    nCol := nColIni
    @ nLin, ncol SAY oSay  PROMPT FWX3Titulo("C2_PRODUTO")                          SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN
    ncol += 80
    @ nLin-2, ncol MSGET oGet VAR M->C2_PRODUTO                                     SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN when .F.

    ncol += 100
    @ nLin, ncol SAY oSay  PROMPT FWX3Titulo("B1_DESC")                             SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN
    ncol += 80
    @ nLin-2, ncol MSGET oGetB1 VAR cB1_DESC                                        SIZE 300, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN when .F.

    nLin += 40 
    nCol := nColIni
    @ nLin, ncol SAY oSay  PROMPT FWX3Titulo("C2_EMISSAO")                           SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN
    ncol += 80
    @ nLin-2, ncol MSGET oGet VAR M->C2_EMISSAO                                      SIZE 065, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN 
 
    ncol += 100
    @ nLin, ncol SAY oSay  PROMPT FWX3Titulo("C2_QUANT")                             SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN
    ncol += 80
    @ nLin-2, ncol MSGET oGet VAR M->C2_QUANT      pict "999999999"                  SIZE 065, 010 OF oDlg COLORS 0, 16777215 PIXEL Font oFont11CN 
 
    nLin := aSize[6] - 330   
    ncol := aSize[5] - 900 

    @ nLin, ncol+70 BUTTON oButton PROMPT "&Apontar Produção"     SIZE 060, 022  PIXEL ACTION fAptPro() OF oDlg

    @ nLin, ncol+140     BUTTON oButton PROMPT "Sai&r"            SIZE 060, 022  PIXEL font oFont09n ACTION oDlg:end()    OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

return NIL 


*************************
Static Function fAptPro()  
*************************

if fAptOP()
   RecLock("TMPBRW",.t.)
	TMPBRW->OK      := "O"  
	TMPBRW->COD     := M->C2_PRODUTO
	TMPBRW->OP      := cCodBar
	TMPBRW->DESC    := cB1_DESC
	TMPBRW->QUANT   := M->C2_QUANT
	TMPBRW->EMISSAO := dDatabase 
   TMPBRW->(MsUnLock())

   @ nLin-200 + iif(lProcATOM,100,0) ,nColIni TO nLin-020 + iif(lProcATOM,10,0) ,nColIni+650 -  iif(lProcATOM,100,0) BROWSE "TMPBRW" ENABLE "TMPBRW->OK <> 'O'"   FIELDS aCpos OBJECT oTela 

   TMPBRW->(dbgotop())

   M->C2_PRODUTO := criavar("C2_PRODUTO")   
   cB1_DESC      := criavar("B1_DESC")
   cCodBar       := space(len("C2_NUM")) 

   oTela:oBrowse:Refresh()
   oTela:oBrowse:Reset()
   oGet1:SetFocus()
else
   msgStop("","Não foi possível apontar a ordem de produção!")	
endif

return .t.


*************************
Static Function fAptOP()  
*************************

Local cTPMov     := "050"   // Informar aqui o seu Tipo de Movimentação

Local lRet       := .t.
Local cDoc       := ""
Local cOP        := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
Local aVetor

Private lMsErroAuto := .f.

if M->C2_QUANT > SC2->C2_QUANT
   msgStop("<h2>que o total da ordem de produção!</h2>","A quantidade a apontar não deve ser maior")
   return .f.
elseif  M->C2_QUANT > SC2->C2_QUANT .and. !msgYesNo("Deseja apontar o total da ordem de produção?")
   return .f.
endif

cDoc := getsxenum("SD3","D3_DOC")      // Pega proximo D3_DOC disponível

aVetor := { {"D3_OP"	   , cOP           , NIL},;
            {"D3_TM"	   , cTPMov	   , NIL},;
            {"D3_EMISSAO"  , M->C2_EMISSAO , NIL},;
            {"D3_DOC"	   , cDoc          , NIL},;
            {"D3_QUANT"    , M->C2_QUANT   , NIL }}

MSExecAuto({|x, y| mata250(x, y)}, aVetor, 3 )

If lMsErroAuto
   lRet := .f.
   MsgStop("Problema na inclusão. Erro será mostrado em seguida, enviar ao Administrador!")
   MostraErro()
Endif

confirmsx8()   // confirma o uso do D3_DOC

Return(lRet)




**************************
Static function NovoItem()  
**************************

If Empty(cCodBar) ; Return(.t.) ; EndIf

dbSelectArea("SC2") 
dbSetOrder(01)
if !SC2->( dBseek( xfilial("SC2") + cCodBar ))  // posiciona na OP a ser apontada
    MsgStop( "<h2>não encontrada  !</h2>","OP " +   cCodBar)
    cCodBar := space(len("C2_NUM")) 
    oGet1:setFocus()
    Return(.t.)
EndIf 

if !empty(SC2->C2_DATRF)
    MsgStop( "<h2>já foi encerrada !</h2>","OP " +   cCodBar)
    cCodBar := space(len("C2_NUM")) 
    oGet1:setFocus()
    Return(.t.)
endif

dbSelectArea("SB1")  
dbSetOrder(1)
dbSeek(xFilial("SB1") + SC2->C2_PRODUTO) 

cB1_DESC := SB1->B1_DESC 
 
M->C2_PRODUTO := SC2->C2_PRODUTO

oGet:Refresh() 
oGetB1:Refresh()

return .t.

