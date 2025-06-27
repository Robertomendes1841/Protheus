#include "protheus.ch"
#include "Ap5Mail.ch"


/*
+-—————————————————————————————————————————————————————————————————————————-+
| Funcao    | MT120F                                                        |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Autor     | Roberto Mendes Rodrigues                  | Data | 05/03/2020 |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Descricao | Ponto Entrada após a gravação do pedido de compras            |
|           | para enviar email ao Solicitante                              |
+-—————————-+-—————————————————————————————————————————————————————————————-+
/*


*********************
User Function MT120F()
*********************
Local cPedido     :=  PARAMIXB  // filial + pedido
Local cItensUSU   := ""
Local aItens      := {}
Local cUsersC1    := ""
Local cUserC1At   := ""
Local nX ,nNX
Local cAreaSB1    := SB1->(getArea())
Local cAreaSC7    := SC7->(getArea())

SB1->(dbsetorder(1))
SC7->(dbsetorder(1))

dBselectArea('SC7') ; dbSetOrder(1) ; dbSeek(cPedido)  // cPedido =  filial + pedido

do while !SC7->(eof()) .and. cPedido == SC7->C7_FILIAL + SC7->C7_NUM 

   if !empty(posicione("SC1",1,xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,"C1_USER")) .and.;                                      // Se tem Solicitação de Compras e
      empty(posicione("SY1",3,xFilial("SY1")+SC1->C1_USER,"Y1_COD") )                                                              // não foi feita por um comprador

      aadd(aItens,{SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC , trans(SC1->C1_QUANT,"@E 99,999,999.9999") , rtrim(SC7->C7_PRODUTO)+" - "+rtrim(SC7->C7_DESCRI) , SC1->C1_USER  } )

      if !SC1->C1_USER $ cUsersC1
         cUsersC1 += SC1->C1_USER 
      endif  
   endif	     

   SC7->(dbskip())       
enddo   

aItens := aSort( aItens,,,{|x,y| x[4] > y[4]})  // Orderna por Cod do Usuário

for nX = 1 to len(aItens)

        cItensUSU := "<html>"
        cItensUSU += "<head>"
        cItensUSU += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        cItensUSU += "<title>AVISVLM</title>"
        cItensUSU += "<meta http-equiv='Content-Type' content='text/html'; charset='iso-8859-1'>"
        cItensUSU += "<style>"
        cItensUSU += "table {border-collapse: collapse;width:100%;}"
        cItensUSU += "tr,td,th{border: 1px solid; }"
        cItensUSU += "th {background-color: Lime;font-size: 105%;}"
        cItensUSU += "</style>"
        cItensUSU += "</head>"
        cItensUSU += "<body>"
        cItensUSU += "<h4>Atendimento de Solicitação de Compras.</h4>"
        cItensUSU +=  "<table>"
        cItensUSU += "<tr>"
        cItensUSU += "<th>Solic Compras</th>"
        cItensUSU += "<th>Produto</th>" 
        cItensUSU += "<th>Quantidade</th>" 
        cItensUSU += "</tr>"

        cUserC1At := aItens[nX][4]                // Codigo Usuário Atual
        for nNX = nX to len(aItens)               // Faz enquanto for o mesmo Usuário   
            cItensUSU += "<tr>" 
            cItensUSU += "<td >"+aItens[nNX][1]+"</td>"
            cItensUSU += "<td >"+aItens[nNX][3]+"</td>"
            cItensUSU += "<td Align='right'>"+aItens[nNX][2]+"</td>"
            cItensUSU += "</tr>"        

            nX ++
       	    
            if nNX < len(aItens) .and. cUserC1At <> aItens[nNX+1][4] ; exit ; endif    // Se o Proximo usuário for diferente do Atual, sai  

        next

	 cItensUSU +=  "</table>"

        cItensUSU += "<br>"
        cItensUSU += "<br>"
        cItensUSU += "Pedido lançado por "+UsrFullName(__cUserid)+"."
        cItensUSU += "<br>"
        cItensUSU += "<br>"

        fEnvMail2("Atendimento de Solicitação de Compras, Pedido "+subs(cPedido,3,len(SC7->C7_NUM))+" - "+u_fsiglafil() , cItensUSU , cUserC1At )  // envia o email com os itens da SC do usuário Atual

next	  


Return



**************************************
Static Function fEnvMail2(cAssunto,cMsg,cUsersC1)
**************************************
Local cPara := alltrim(UsrRetMail(cUsersC1)) + ";"+alltrim(UsrRetMail(__CUserId))

fEnviaMail(cPara,cAssunto,cMsg)

Return()




********************************* 
Static Function fEnvMail(cPara,cAssunto,cCorpo)
*********************************

Local cErrorMsg  := ""  

Local xRet   

if "TESTE" $ upper(GetEnvServer())                   // Se rodar na base teste, envia apenas para este email,,, "para fazer teste enviando apenas pra você"
     cPara   := "seuemail@seudominio.com.br" 
endif

Private cServer   := "smtp.office365.com"
Private cAccount  := "seuemail@seudominio.com.br"
Private cPassword := "SUASENHA"
Private nPortPOP  := 995
Private nPortSMTP := 587

if os parâmetros estão cadastrados na SX6 pega de lá 
    cServer   := Substr(Alltrim(GetMv("MV_RELSERV")),1,Len(Alltrim(GetMv("MV_RELSERV")))-4)
    cAccount  := Alltrim(GetMv("MV_RELACNT"))
    cPassword := Alltrim(GETMV("MV_RELPSW"))
    nPortSMTP := Val(Right(Alltrim(GetMv("MV_RELSERV")),3))
endif	
 
oMailServer := TMailManager():new()
oMailServer:SetUseSSL( .F. )
oMailServer:SetUseTLS( .T. )
xRet := oMailServer:Init("" ,cServer, cAccount,cPassword, nPortPOP, nPortSMTP )

if xRet <> 0
  cErrorMsg  := "Could not initialize SMTP server:"  + oMailServer:GetErrorString( xRet )
  conout( cErrorMsg  +  cServer + cAccount + cPassword) 
  return .f.
endif

xRet := oMailServer:SetSmtpTimeOut( 60 )
if xRet <> 0
    cErrorMsg  := "Could not set " + cProtocol + " timeout to 60"
    conout( cErrorMsg  )
    return .f.
endif

// conecta
xRet := oMailServer:SmtpConnect()
if xRet <> 0
  cErrorMsg  := "Could not connect on SMTP server:"  + oMailServer:GetErrorString( xRet )
  conout( cErrorMsg  )
  return .f.
endif

// authenticate on the SMTP server (if needed)
//xRet := oMailServer:SmtpAuth( cAccount, cPassword,cAccount,587 )
xRet := oMailServer:SmtpAuth(cAccount, cPassword)
if xRet <> 0
   cErrorMsg  := "Could not authenticate on SMTP server:"  + oMailServer:GetErrorString( xRet )
   conout( cErrorMsg  )
   oMailServer:SMTPDisconnect()
  return .f.
endif 

oMsg := TMailMessage():new()
oMsg:Clear()

oMsg:MsgBodyType( "html" )
oMsg:cFrom := cAccount
oMsg:cTo      := cPara
oMsg:cSubject := cAssunto

oMsg:cBody    := cCorpo

// oMsg:cBCC  := "seuemail@seudominio.com.br"    // Caso queira receber Cópia Oculta

// Para solicitar confirmação de envio
//oMsg:SetConfirmRead( .T. )


// envio do email
xRet := oMsg:Send( oMailServer )
if xRet <> 0
   cErrorMsg  := "Could not send message:"  + oMailServer:GetErrorString( xRet )
   conout( cErrorMsg  )
  return .f.
endif

// desconecta
xRet := oMailServer:SMTPDisconnect()
if xRet <> 0
   cErrorMsg  := "Could not disconnect from SMTP server:"  + oMailServer:GetErrorString( xRet )
   conout( cErrorMsg  )
endif

Return .t.

