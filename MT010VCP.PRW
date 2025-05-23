


*+-—————————————————————————————————————————————————————————————————————————-+
*| Funcao    | MT010VCP                                                      |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+
*| Autor     | Roberto Mendes Rodrigues                  | Data | 22/05/2025 |
*+-—————————-+-—————————————————————————————————————————-+-————-+-——————————-+


**********************
User Function MT010VCP  // Ponto de Entrada com objetivo de informar os campos da tabela SB1 que serão utilizados na visualização do cadastro de produtos
**********************

Local aCampos:= {}
Local _aGrupo  := PswRet()
Local _cDepto  := Upper(Alltrim(_aGrupo[1,12]))
Local _cDeptoPerm := "CONTABILIDADE-TI-COMPRAS-"         // Departamentos permitidos

// Retira todos os campos que tem consulta padrão para que não naveguem entre as tabelas acessando informações pessoais de clientes, fornecedores, usuários, colaboradores.....

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SB1")
While !Eof() .And. SX3->X3_ARQUIVO == "SB1"

	If !(SX3->X3_CAMPO $ "B1_FILIAL") .and. cNivel >= SX3->X3_NIVEL .and. X3Uso(SX3->X3_USADO) .and. ( empty(SX3->X3_F3) .or. _cDepto $ _cDeptoPerm )
		AADD(aCampos,SX3->X3_CAMPO)
	endIf

	DbSkip()

EndDo


return aCampos
