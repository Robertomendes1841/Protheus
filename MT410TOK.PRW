

************************
User Function MT410TOK() 
************************
Local lRet := .t.

// Se alterou a condição de pagamento, verifica se está abaixo da média de dias

if M->C5_TIPO = "N" .and. (INCLUI .or. isincallstack("A410COPIA") .or. ( ALTERA .and. M->C5_CONDPAG <> SC5->C5_CONDPAG ) .and. M->C5_CONDPAG <> SA1->A1_COND )
    lRet := fVldACond(M->C5_CONDPAG , SA1->A1_COND )
endif

return lRet



************************
Static Function fVldACond(cCond1,cCond2)   // Valida Alteração da Condição de Pagamento
************************
Local lRet      := .t.
Local cChave    := "                  "
Local cChaveLIB := "LIBERA PRAZO MAIOR"
Local aAreaSE4  := SE4->(getArea())
Local aMediaC1  := aMediaC2 := {} 
Local nMediaC1  := nMediaC2 := 0
Local nX        := 0 

dbselectArea("SE4") ; dbsetorder(01)  
dbseek( xFilial("SE4") + cCond1 ) ; aMediaC1 := StrTokArr2( alltrim(SE4->E4_COND) , "," )

for nX := 1 to len(aMediaC1)
     nMediaC1 += val( aMediaC1[nX] )
next	 

nMediaC1 /= len(aMediaC1)

dbseek( xFilial("SE4") + cCond2 ) ; aMediaC2 := StrTokArr2( alltrim(SE4->E4_COND) , "," )

for nX := 1 to len(aMediaC2)
     nMediaC2 += val( aMediaC2[nX] )
next	 

nMediaC2 /= len(aMediaC2)

if nMediaC1 > nMediaC2
    Aviso("Prazo médio informado superior ao cadastro do cliente ! ",;
          "O Prazo médio da condição de pagamento informada é superior ao limite !" + CRLF + CRLF + ;
          "Informando a chave LIBERA PRAZO MAIOR o pedido será salvo e um e-mail" + CRLF + CRLF + ;
          "será enviado aos envolvidos no processo para posterior análise")
	
	cChave := FWInputBox("Informe a chave para liberação !" , cChave )

	if upper(cChave) <>  cChaveLIB ; msgStop("<h2> Pedido não poderá ser salvo !</h2>" , "Chave de liberação inválida!") ; endif

    femLibAcPr(cCond1,cCond2,nMediaC1,nMediaC2)
 
endif

RestArea(aAreaSE4)
return lRet 



************************
Static Function femLibAcPr(cCond1,cCond2,nMediaC1,nMediaC2)   // Email aviso de pedido lançado com prazo maior que o cadastrado na SA1
************************
Local cPara    := "financeiro@teste.com.br"

Local cAssunto := "Condição acima do prazo - Pedido de Vendas"

Local cCorpo   := "Número do Pedido " + M->C5_NUM + CRLF + CRLF + "Cliente " + SA1->A1_NOME + CRLF + CRLF + ;
                  "Condição de Pagamento informada no Pedido " + cCond1 + " Prazo Médio " + str(nMediaC1,3) + " dias " + CRLF + CRLF + ;
				  "Condição de Pagamento Cadastro do Cliente " + cCond2 + " Prazo Médio " + str(nMediaC2,3) + " dias "


fEnviaMail(cPara,cAssunto,cCorpo)

return






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