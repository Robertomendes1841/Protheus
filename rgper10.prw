#include "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "AP5MAIL.CH"

/*/
+-—————————————————————————————————————————————————————————————————————————-+
| Funcao    | RGPER10                                                       |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Autor     | Roberto Mendes Rodrigues                  | Data | 13/10/2020 |
+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
| Descricao | Email para Aniversariantes do Mês|
+-———————————-+-——————————-+-——————————————————————————————————————————————-+ /*/


* Aniversario e Aniversário de Empresa !!!


***********************
User Function RGPER10(aParam)
***********************

Local cQuery
Local ncont := 0

Private lJOB   := If(aParam==Nil,.f.,.t.)

MV_PAR01 := subs(dtos(dDataBase+1),7,2)+subs(dtos(dDataBase+1),5,2)   // MM/DD  Mês e dia do Aniversário

if lJob
   WFPREPENV(aParam[1],aParam[2],"RGPER10")
endif


cQuery := "SELECT RA_NOME, RA_EMAIL,RA_DDDCELU DDD,RA_NUMCELU FONE FROM SRA100 WHERE RIGHT(RA_NASC,4) = '"+subs(MV_PAR01,3,2)+subs(MV_PAR01,1,2)+"' AND "
cQuery += "RA_DEMISSA = ' ' AND D_E_L_E_T_ <> '*' " 

TCQUERY cQuery NEW ALIAS "TRB" 

dbSelectArea("TRB") ; dbGoTop()


do while !TRB->(eof())
   
   if empty(TRB->RA_EMAIL) .or. !"@" $ TRB->RA_EMAIL  .or. " " $ alltrim(TRB->RA_EMAIL)  // Se está vazio, não tem @ ou tem espaços em branco, pula
      TRB->(dbskip()) ; loop
   endif   

   if fEnvMail(TRB->RA_NOME,rtrim(TRB->RA_EMAIL) )
      ncont++
   endif

   TRB->(dbskip())
enddo

TRB->(dbclosearea())

if !lJob
    if nCont >0 ; msginfo(rtrim(str(ncont))+" email(s) enviado(s)")
    else        ; msgStop("" ,"Não há aniversariantes neste Dia/Mês !")
    endif
endif

Return NIL



********************************* 
Static Function fEnvMail(cNome,cEmail)
*********************************

Local cRecebe   := cCorpoArq := cMsg := caMsg := ""  

Local xRet   

cRecebe   := cEmail


if "TESTE" $ upper(GetEnvServer()) .or. "HARPIA" $ upper(GetEnvServer())
     cRecebe   := "seuemail@seudominio.com.br" 
endif

cCorpoArq := "https://seusite.com.br/aniversariantes/FelizAniversario.png"

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
 
//  Imagem no corpo do email 
cMsg := "<html>" 
cMsg += "<body>"
cMsg += "<img src='"+cCorpoArq+"'  alt='folder aniversario'  height='820' width='750'>"
cMsg += "<table width='100%' border='0' cellspacing='0' cellpadding='3'>"
cMsg += "<tr><td width='100%'><font face='Arial, Helvetica, sans-serif'>Email enviado pelo RPA Protheus - .</font></tr></td>"
cMsg += "<tr><td width='100%'><font face='Arial, Helvetica, sans-serif'></font></tr></td>"
cMsg += "</table>"
cMsg += "<p>&nbsp;</p></body></html>"

oMailServer := TMailManager():new()
oMailServer:SetUseSSL( .F. )
oMailServer:SetUseTLS( .T. )
xRet := oMailServer:Init("" ,cServer, cAccount,cPassword, nPortPOP, nPortSMTP )

if xRet <> 0
  caMsg := "Could not initialize SMTP server:"  + oMailServer:GetErrorString( xRet )
  conout( caMsg +  cServer + cAccount + cPassword) 
  return .f.
endif

xRet := oMailServer:SetSmtpTimeOut( 60 )
if xRet <> 0
    caMsg := "Could not set " + cProtocol + " timeout to 60"
    conout( caMsg )
    return .f.
endif

// conecta
xRet := oMailServer:SmtpConnect()
if xRet <> 0
  caMsg := "Could not connect on SMTP server:"  + oMailServer:GetErrorString( xRet )
  conout( caMsg )
  return .f.
endif

// authenticate on the SMTP server (if needed)
//xRet := oMailServer:SmtpAuth( cAccount, cPassword,cAccount,587 )
xRet := oMailServer:SmtpAuth(cAccount, cPassword)
if xRet <> 0
   caMsg := "Could not authenticate on SMTP server:"  + oMailServer:GetErrorString( xRet )
   conout( caMsg )
   oMailServer:SMTPDisconnect()
  return .f.
endif 

oMsg := TMailMessage():new()
oMsg:Clear()

oMsg:MsgBodyType( "html" )
oMsg:cFrom := cAccount
oMsg:cTo      := cRecebe  
oMsg:cSubject := "Hoje é o seu dia, que dia mais feliz, Parabéns !!!" 

oMsg:cBody    := cMsg 

// oMsg:cBCC  := "seuemail@seudominio.com.br"    // Caso queira receber Cópia Oculta

// caso queira enviar com anexo informe aqui a pasta e nome do arquivo
 
// "\treport\AnexosMD\FelizAniversario\FelizAniversario.png"
//xRet := oMsg:AttachFile(cAnexo) 


// Para solicitar confirmação de envio
//oMsg:SetConfirmRead( .T. )

//if xRet < 0
//   caMsg := "Não consegui anexar o arquivo !" 
//   conout( caMsg )
//   return .f.
//endif

// envio do email
xRet := oMsg:Send( oMailServer )
if xRet <> 0
   caMsg := "Could not send message:"  + oMailServer:GetErrorString( xRet )
   conout( caMsg )
  return .f.
endif

// desconecta
xRet := oMailServer:SMTPDisconnect()
if xRet <> 0
   caMsg := "Could not disconnect from SMTP server:"  + oMailServer:GetErrorString( xRet )
   conout( caMsg )
endif

Return .t.



