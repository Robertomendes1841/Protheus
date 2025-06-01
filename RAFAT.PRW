#INCLUDE "TOTVS.CH"
#INCLUDE "Topconn.ch"
#Include "Protheus.ch"
#Include "Report.ch"  


**********************
User Function RAFAT()
**********************

Private oReport   := Nil
Private oSecCab	  := Nil
Private cPerg 	  := "RAEST36"

do while .t.
    if !ReportDef() ; return ; endif
    oReport:PrintDialog()
enddo

Return Nil


**************************
Static Function ReportDef()
**************************

Local cArquivo := "RAFAT"+dtos(date())+strtran(time(),":","")

Local cTit := "Análise Faturamento"

oReport := TReport():New(subs(cArquivo,1,7),cTit , , {|oReport| PrintReport(oReport)},"Total Faturado, Média, Curva ABC" )

oReport:SetLandscape(.t.)    // paisagem

oReport:cFontBody := 'Courier New'
oReport:SetLineHeight(40)   // espaçamento linhas
oReport:nFontBody := 08     // tamanho da fonte

oReport:SetColSpace(0)

oReport:oPage:setPaperSize(1)  // Legal 8 1/2 x 14 in

oSecCab := TRSection():New( oReport , "Análise de Faturamento", {"QRY","SB1"} )

TRCell():New( oSecCab, "A1_NOME"      , "QRY","Cliente")
TRCell():New( oSecCab, "NUMERO_NOTAS" , "QRY","Nr de Notas")
TRCell():New( oSecCab, "TOT_FAT"      , "QRY","Total Faturado")
TRCell():New( oSecCab, "MEDIA_MES"    , "QRY","Média Mensal")
TRCell():New( oSecCab, "TICKET_MEDIO" , "QRY","Ticket Médio")
TRCell():New( oSecCab, "CURVA_ABC"      , "QRY","Saldo")

TRFunction():New(oSecCab:Cell("TOT_FAT"),   ,"SUM")    // Total Geral

Return .t.


***************************
Static Function PrintReport(oReport)
***************************
Local cQuery     := ""

cQuery     := "SELECT B1_COD,B1_DESC,B1_GRUPO,SUM(B2_QATU) B2_QATU FROM "+RetSQLName("SB1")+" A " + CRLF
cQuery     += "INNER JOIN  "+RetSQLName("SB2")+"  B ON B2_FILIAL = '" + xfilial("SB2") + "' AND B2_COD = B1_COD AND B.D_E_L_E_T_ = ' ' " + CRLF
cQuery     += "WHERE B1_FILIAL= '" + xfilial("SB1") + "' AND A.D_E_L_E_T_ = ' ' " + CRLF
cQuery     += "AND Z9_PRODUTO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "+ CRLF
cQuery     += "GROUP BY B1_COD,B1_DESC,B1_GRUPO " + CRLF
cQuery     += "ORDER BY B1_COD " + CRLF


cQuery     := "with compras_ultimos_90_dias as(
cQuery     += "SELECT F2_CLIENTE,A1_NOME,COUNT(*) AS NUMERO_NOTAS, SUM(D2_TOTAL) TOTAL_FATURADO FROM SF2100 A
cQuery     += "INNER JOIN SA1100 B ON A1_FILIAL=' ' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND B.D_E_L_E_T_= ' '
cQuery     += "INNER JOIN SD2100 C ON D2_FILIAL='02' AND D2_DOC = F2_DOC AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA = F2_LOJA AND C.D_E_L_E_T_= ' '
cQuery     += "WHERE F2_FILIAL='02' AND F2_EMISSAO >= CONVERT(CHAR(10), GETDATE()-90,112) AND F2_TIPO ='N' AND F2_DUPL <> ' ' AND A.D_E_L_E_T_= ' '
cQuery     += "GROUP BY F2_CLIENTE,A1_NOME
cQuery     += "),
cQuery     += " Total_Faturado as(
cQuery     += "SELECT SUM(D2_TOTAL) TOT_FAT_ITEM FROM SF2100 A
cQuery     += "INNER JOIN SD2100 C ON D2_FILIAL='02' AND D2_DOC = F2_DOC AND D2_CLIENTE=F2_CLIENTE AND D2_LOJA = F2_LOJA AND C.D_E_L_E_T_= ' '
cQuery     += "WHERE F2_FILIAL='02' AND F2_EMISSAO >= CONVERT(CHAR(10), GETDATE()-90,112) AND F2_TIPO ='N' AND F2_DUPL <> ' ' AND A.D_E_L_E_T_= ' '
cQuery     += ")
cQuery     += "SELECT A1_NOME,NUMERO_NOTAS,format(TOTAL_FATURADO , 'C', 'pt-br') AS TOT_FAT,format(TOTAL_FATURADO / 3 , 'C', 'pt-br') AS MEDIA_MES,format(TOTAL_FATURADO / NUMERO_NOTAS , 'C', 'pt-br') AS TICKET_MEDIO,
cQuery     += "FORMAT(TOTAL_FATURADO / (SELECT TOT_FAT_ITEM FROM Total_Faturado) * 100, 'N3' )+'%' as CURVA_ABC
cQuery     += "FROM compras_ultimos_90_dias 
cQuery     += "WHERE NUMERO_NOTAS >= 5
cQuery     += "ORDER BY TOTAL_FATURADO DESC


If Select("QRY") > 0 ; QRY->(DbClosearea()) ; EndIf

TcQuery cQuery New Alias "QRY"

oSecCab:Print()

Return Nil