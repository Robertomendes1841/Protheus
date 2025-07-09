
#Include "Protheus.ch"
#include "topconn.ch"


************************
User Function AfterLogin()
************************
//Se estiver instanciado no Objeto 

If Type("oApp:oMainWnd:cTitle") == "C" .and. 'Provisão de Férias' $ oApp:oMainWnd:cTitle    // Não achei P.E. na rotina por isto coloquei aqui !!!
   u_cFConFerVc() 
EndIf 


retrn NIL



************************
User Function cFConFerVc()  // Consulta Férias Vencidas
************************

Local cQuery := ctxtLog := cPara := ""

local cAssunto := "Proximidade de Vencimento da Segunda Férias"



cQuery := "SELECT 'EMPRESA X' EMPRESA,  RA_FILIAL ,RA_NOME,RA_MAT,CONVERT(CHAR(10),CAST(RT_DATABAS AS DATETIME),103) PER_AQ_DE,CONVERT(CHAR(10),CAST(RF_DATAFIM AS DATETIME),103) PER_AQ_ATE,CONVERT(CHAR(10),"

cQuery += "dateadd(year,1,RF_DATAFIM),103) DT_LIMITE, "

cQuery += "CONVERT(CHAR(10),CAST(RA_ADMISSA AS DATETIME),103) ADMISSAO,MAX(RT_DATACAL) RT_DATACAL,RF_DATAFIM FROM SRT100 A "

cQuery += "INNER JOIN SRA100 B ON RA_FILIAL+RA_MAT = RT_FILIAL+RT_MAT AND B.RA_DEMISSA=' ' and RA_SITFOLH NOT IN ('A','D') AND B.D_E_L_E_T_=' ' "

cQuery += "LEFT OUTER JOIN SRF100 C ON RF_FILIAL+RF_MAT = RT_FILIAL+RT_MAT AND RF_DATABAS = RT_DATABAS  AND C.D_E_L_E_T_=' ' "

cQuery += "AND RF_FILIAL+RF_MAT NOT IN (SELECT RH_FILIAL+RH_MAT FROM SRH100 D WHERE RH_FILIAL+RH_MAT = RT_FILIAL+RT_MAT AND (RH_DATABAS=RT_DATABAS-1 OR RH_DATABAS=RT_DATABAS) AND D.D_E_L_E_T_=' ') " // não tem recibo

cQuery += "WHERE RT_DFERANT+RT_DFERVEN  > 0 AND RT_DATACAL = (SELECT MAX(RT_DATACAL) FROM SRT100 WHERE RT_FILIAL=A.RT_FILIAL AND D_E_L_E_T_=' ')AND RF_DATAFIM IS NOT NULL AND RT_VERBA='911' AND "

cQuery += "dateadd(year,1,RF_DATAFIM) < dateadd(MONTH,6,GETDATE()) AND A.D_E_L_E_T_=' ' "

cQuery += "GROUP BY  RA_FILIAL ,RA_NOME,RA_MAT,RF_DATAFIM,RF_DATAFIM,RA_ADMISSA ,RT_DATABAS "

cQuery += "order by RF_DATAFIM "



TcQuery cQuery New Alias "TEMPFER"   

  

 

ctxtLog += "                                                 Atenção !!! " + CRLF + CRLF

ctxtLog += "                           Colaboradores a vencer a segunda aquisição de Férias nos próximos 6 meses." + CRLF + CRLF

ctxtLog += "Unidade Matricula Nome                                       Periodo de Aquisição           Data Limite" + CRLF + CRLF



do while !TEMPFER->(eof())

   ctxtLog += u_fsiglafil(TEMPFER->EMPRESA+TEMPFER->RA_FILIAL)+"     "+ TEMPFER->RA_MAT+"    "+ TEMPFER->RA_NOME+"            "+ TEMPFER->PER_AQ_DE+" "+ TEMPFER->PER_AQ_ATE+"            "+ TEMPFER->DT_LIMITE + CRLF + CRLF

   TEMPFER->(dbskip())

enddo

 

showlog(ctxtLog)



ctxtLog := "<html>"

ctxtLog += "<head>"

ctxtLog += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"

ctxtLog += "<title>AVISVFER</title>"

ctxtLog += "<meta http-equiv='Content-Type' content='text/html'; charset='iso-8859-1'>"

ctxtLog += "<style>"

ctxtLog += "table {border-collapse: collapse;width:100%;}"

ctxtLog += "tr,td,th{border: 1px solid; }"

ctxtLog += "th                    {background-color: Red;font-size: 105%;}"

ctxtLog += "</style>"

ctxtLog += "</head>"

ctxtLog += "<body>"



ctxtLog +=  "<h2>Colaboradores a vencer a segunda aquisição de Férias nos próximos 6 meses.</h2>"

ctxtLog     +=  "<table>"

ctxtLog +=  "<tr>"

ctxtLog +=  "<th>Unidade</th>"

ctxtLog +=  "<th>Matricula</th>"

ctxtLog +=  "<th>Nome</th>"

ctxtLog +=  "<th>Periodo de Aquisição</th>"

ctxtLog +=  "<th>Data Limite</th>"

ctxtLog +=  "</tr>"

    

TEMPFER->(dbgotop())        

    

While TEMPFER->(!EoF()) 

    ctxtLog +=  "<tr>"

    ctxtLog +=  "<td>"+TEMPFER->RA_MAT+"</td>"

    ctxtLog +=  "<td>"+TEMPFER->RA_NOME+"</td>"

    ctxtLog +=  "<td Align='center'>"+TEMPFER->PER_AQ_DE+" - "+ TEMPFER->PER_AQ_ATE+"</td>"

    ctxtLog +=  "<td Align='center'>"+TEMPFER->DT_LIMITE+"</td>"

    ctxtLog +=  "</tr>"     

    TEMPFER->(DbSkip()) 

EndDo



ctxtLog     +=  "</table>"

ctxtLog +=  "<p>*Alerta Emitido por : "+UsrFullName(__cUserID)+"</p>"

ctxtLog +=  "<br>"

ctxtLog +=  "<br>"



cPara := "seuemail@seuprovedor.com.br"

 

u_fEnviaMail(cPara,cAssunto,ctxtLog)



TEMPFER->(dbclosearea())



return NIL