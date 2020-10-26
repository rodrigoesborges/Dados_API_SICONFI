#Definindo diretorio de trabalho
setwd("C:\\Users\\Tony\\Documents\\GitHub\\
      Dados_SICONFI")
getwd()
#Pacotes que seráo utilizados
library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyr)

#Consultar a Declaração de contas Anuais – DCA Municípios
  #[Anexo I-C] Balanço Orçamentário – Receitas Orçamentárias
  #[Anexo I-D] Balanço Orçamentário – Despesas Orçamentárias
  #[Anexo I-E] Balanço Orçamentário – Despesas por Função
  #Período: 2010 a 2019
  #Qualquer municipio ou UF, basta usar co codigo do IBGE.

base_url_dca <- "http://apidatalake.tesouro.gov.br/ords/siconfi/tt/dca?"

# parâmetros de consulta 
inicial=2010 # Primeiro ano a ser baixado

final=2019 #Ultimo ano a ser baixado

anos =seq(inicial,final,1)  #anos a serem baixados

num_anexo <-c("DCA-Anexo%20I-C" ,
                   "DCA-Anexo%20I-D" , 
                   "DCA-Anexo%20I-E") #Relatorios a serem baixados

ente <- c(23) #Estado do Ceara #Código do ente segue padrão IBGE.

# Montar a chamada à API
chamada_api_dca = c()
for (i in anos){
  for (j in num_anexo){
    chamada_api_dca <- append(chamada_api_dca , 
                              paste(base_url_dca,
                                    "an_exercicio=",  i , "&",
                                    "no_anexo=", j, "&" , 
                                    "id_ente=", ente, sep = "") ) 

  }
}



#Criar uma funcao para requisitar os dados.
chamada = function(x){
  GET(x)
}

#Fazer a requisicao para todos os anos
dca <- lapply(chamada_api_dca,chamada)
for (i in dca ){
  status_code(i)
}
status_code(dca)
#Criar uma funcao para extrair os dados.
extracao = function(x){
  content(x, as="text" , encoding="UTF-8")
}
#Fazer a extração do conteúdo
dca_txt <- lapply(dca , extracao )

#Transformar os dados de txt para Json.
json = function(x){
  fromJSON (x,
            flatten = FALSE)
}

dca_json <- lapply (dca_txt , json)

#Extrair os dados para um data frame
dados = function(x){
  as.data.frame (x[["items"]])
}

dados_dca = lapply(dca_json , dados)

#Nomear cada linha do objeto criado, que é um data frame, com o nome do banco extraído.
##OBS: lista com nomes deve estar na msm ordem que a lista de data frames
name1 = paste0("dca", anos)
name2 = c ("Receitas_Orcamentarias" ,
           "Despesas_Orcamentarias" , 
           "Despesas_p_Funcao")
name = as.character()
for (i in name1){
  for (j in name2){
    name <- append(name , paste(i , "_" , j))
  }
}
names(dados_dca) <- name 

