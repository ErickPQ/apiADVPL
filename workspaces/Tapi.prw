#INCLUDE "protheus.ch"
#INCLUDE "restful.ch"

WSRESTFUL PEDIDO_VENDA DESCRIPTION "Pedido de Venda" FORMAT APPLICATION_JSON

//WSMETHOD GET V1 DESCRIPTION "Busca os Dados de um Pedido" PATH  "/V1/{Filial}/{NumPed}" WSSYNTAX "/V1/{Filial}/{NumPed}" TTALK "V1"
WSMETHOD GET V1 DESCRIPTION "Busca os Dados de um Pedido com intens" PATH  "/V1/{Filial}/{NumPed}" WSSYNTAX "/V1/{Filial}/{NumPed}" TTALK "V1"


END WSRESTFUL

WSMETHOD GET V1 WSSERVICE PEDIDO_VENDA

Local lRet  := .T. //Retorno deve sempre ser lógico onde .T. significa sucesso na requisição
Local cFil  := self:aurlParms[2]
Local cPedido := self:aUrl[3]
Local oJsonRet := JsonObject():new() //json de retorno
local oJsonItem := NIL
Local aItens := {} // Array de itens onde vai ser encapsulado os dados do retorno do GET


DBSELECTAREA( "SC5" )
SC5->(DbSetOrder(1)) // Informa que vamos utilizar o primeiro índice da tabela SC5: PEDIDOS DE VENDA

if SC5 -> (DBSEEK(cFil + cPedido )) // BUSCA NO BANCO DE DADOS PELOS PARÂMETROS DE FILIAL E PEDIDO

oJsonRet['filial'] := SC5->C5_FILIAL
oJsonRet['pedido'] := SC5->C5_NUM
oJsonRet['codCliente'] := SC5->C5_CLIENTE
oJsonRet['lojaCliente'] := SC5->C5_LOJACLI

DBSELECTAREA( "SC6" )
SC6->(DbSetOrder(1))

if SC6 -> (DbSeek (cFil + cPedido))

    While SC6 -> C6_FILIAL == cFil .And. SC6->C6_NUM == cPedido .And. SC6->(!Eof())

    oJsonItem := JsonObject():New()

    oJsonRet['codigo'] := SC6->C6_CODIGO
    oJsonRet['descricao'] := SC6->C6_DESCRI
    oJsonRet['quantidade'] := SC6->C6_QTDVEN
    oJsonRet['valorUnitario'] := SC6->C6_PRCVEN
    oJsonItem['total'] := SC6->C6_VALOR

    AAdd(aItens, oJsonItem)
    FreeObj(oJsonItem)

    ENDDO

    oJsonRet['items'] :=aItens

    lRet := .T.
    self.SetResponse(oJsonRet:toJson())

    Else 
        lRet := .F.
        SetRestFault(1,;
        "Pedido não encontrado",;
        .T.,;
        400,;
        "Falha na busca pelos itens do pedido.")
    ENDIF

else
    lRet= .F.
    SetRestFault(1,;
    "Pedido não encontrado",;
    .T.,;
    400,;
    "informe uma filial e número de pedido existentes no Protheus.")
ENDIF

RETURN lRet
    
    
    


        




//lRet := .T.
//self:SetResponse(oJsonRet:toJson()) // devolve as informações do oJsonRet que digitamos acima



Return lRet

