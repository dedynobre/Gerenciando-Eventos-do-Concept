# Monitorando Eventos do Software Concept(Schneider)

## Resumo

Desenvolver uma forma de monitorar os eventos ocorridos no Software de Automação Industrial **Concept** da Schneider.

O Concept(software de programação de PLC's da Série Quantum, Momemtum e Atrium) não possui uma **ferramenta/sistema** que monitore as alterações feitas no controladores, o que torna o gerenciamento das mudanças impossível.


## Desenvolvimento

O Concept quando é aberto é gerado um arquivo com a extensão ***.log*** com o formato de dados do dia atual. Caso o Concept não seja aberto nenhum arquivo é gerado.

O que foi visto é que o este arquivo ***.log*** poderia ser aberto através, por exemplo, pelo Notepad++ o que poderia ser ajudar na verificação dos eventos. Isto ajuda bastante mas não
fica algo centralizado. Como o arquivo do Concept é local, ou seja, para cada máquina que possui o Concept instalado um arquivo é gerado, caso necessite rastrear um evento se houver 100
máquina são 100 arquivos a serem analisados. Isso torna uma tarefa não muito produtiva.

O primeiro passo para poder minimizar este trabalhou foi o desenvolvimento de uma planilha no excel usando VBA que, na prática, 'abre' estes arquivos e busca das marcações que consideramos que foi 
uma alteração e retorna nas colunas do excel:

<img src="https://github.com/dedynobre/Gerenciando-Eventos-do-Concept/blob/master/images/conc-01.jpg"/></br>

A base para este desenvolvimento é um arquivo **.bat** que 'busca' os logs de todas as máquinas que possui o Concept instalado e centraliza em um local específico na rede para que o cógido
Excel possa utilizá-lo.

Logo após feito este desenvolvimento a rotina de verificação de eventos melhorou e houve ganho de produtividade.

Este procedimento auxilia muito na verificação dos eventos só que tem alguns detalhes:
```
1) Necessidade de rodar uma .bat para poder centralizar os arquivos de logs.
2) Os eventos não são verificados de forma automática e em tempo real.
3) Desta forma trabalha-se com eventos no passado. Isto funciona mas em caso de notificação não se aplica.
```

Logo após estes resultados foi levantado a necessidade do monitoramento dos eventos em tempo real, ou seja, para cada novo evento realizado em algum controlador que seja enviado uma notificação
informando os mesmos dados que consta nos relatório do Excel.

A questão seria: qual plataforma utilizar para monitorar os eventos em tempo real?

Após estudos foi identificado o [NodeRed](https://nodered.org/) como uma plataforma bastante prática e poderosa que atenderia muito bem as necessidades do projeto.

Iniciamos o projeto com algumas perguntas básicas:
+ Qual a frequência de verificação dos arquivos de log?
+ Qual seria o meio de envio das notificações?
+ Os eventos encontrados serão gravados em algum banco de dados externo?

Respondendo as essas perguntas chegamos na seguinte conclusão:
+ A frenquência de verificação dos arquivos de logs será de 3 segundos.
+ As notificações seriam enviadas via Telegram devido a facilidade de integração com o NodeRed. Tem a opção de email também mas não seria tão eficiente quanto o Telegram.
+ Além das notificações via Telegram os eventos serão enviados para um banco de dados MS SQL Server que será a base para o relatório do Excel.

## Arquivo de Logs
Como falado anteriormente o Concept, quando aberto, gera um arquivo com este formato: ```**anomesdia.log**```, por exemplo **20181207.log**.
Este arquivo tem a seguinte estrutura:

<img src="https://github.com/dedynobre/monitorando-eventos-do-concept/blob/master/images/conc-02.jpg"/></br>

Como podemos perceber, o arquivo é divido em colunas:

+ **Coluna 01** => mostra a data do evento
+ **Coluna 02** => mostra o horário do evento
+ **Coluna 03** => identifica o software(Concept)
+ **Coluna 04** => identificar o nome do projeto do controlador
+ **Coluna 05** => identifica o nome do usuário
+ **Coluna 06** => identifica as ações realizadas pelo usuário

O arquivo de log é bem completo que mostra desde uma linha deletado até se o usuário abriu e fechou o software.
Nesse arquivo de log existe alguns eventos que não são importantes no momento de monitorar as ações do usuario como por exemplo, o que foi mencionado acima, hora que o software foi aberto e fechado.
Após vários testes foi conclúido que algumas ações deixam claro que foi executado pelo usuário, são elas:

* Disable
* Deleted
* Written
* Set
* Enable

Caso a **Coluna 04** contenha os textos listado acima entende-se foi que executado algo considerado como force dentro do controlado.

## NodeRed

O NodeRed está rodando em uma máquina com Sistema Operacional **Windows Server 2008 R2**, podendo rodar também com máquinas Linux e Mac,  mais detalhes [Clique Aqui](https://nodered.org/).
Como para este projeto o NodeRed já estava configurado, foi dado início ao desenvolvimento.
Basicamente, além dos componentes nativos do NodeRed, foi instalado os seguintes nodes adicioanais:

+ **Telegram**:
  - Utilizado para envio das notificações caso algum item seja alterado - [Detalhes](https://flows.nodered.org/node/node-red-contrib-telegrambot).
  
+ **MSSQL**:
  - Utilizado para armazenar os eventos em um banco de dados MS SQL Server - [Detalhes](https://flows.nodered.org/node/node-red-contrib-mssql).
  
A estrutura do NodeRed ficou da seguinte forma:

<img src="https://github.com/dedynobre/monitorando-eventos-do-concept/blob/master/images/conc-03.jpg"/></br>


## Detalhes

Vamos detelhar cada item(node) identificado na imagem acima:

+ **Frequencia de Monitoramento**:
  - **Inject**: este *node* tem como objetivo enviar uma mensagem(payload) a cada x tempo. No nosso caso está sendo considerado um tempo de **2 segundos**, ou seja, a cada 2 segundos ele envia
    um payload que será processado pelo node seguinte.
	
  - **Function**: neste *node* pode ser escrito qualquer script utilizando a linguagem *javascript* como sintaxe principal. Neste caso ele está formatando a data para podermos montar o formato do
    arquivo de log que falamos anteriormente, que tem sua saída definido no item ***msg.payload***:
	```javascript
	var dt = new Date(msg.payload);
	var hrs = {
	mes:	 dt.getMonth() + 1,
	dia:     dt.getDate(),
	ano:	 dt.getFullYear(),
	hora:	 dt.getHours(),
	minuto:  dt.getMinutes(),
	segundo: dt.getMilliseconds()
	}
	if (hrs.mes > 9){
    	hrs.mes = hrs.mes;
    } else {
        hrs.mes = "0"+hrs.mes;
    }
	if (hrs.dia > 9){
		hrs.dia = hrs.dia;
    } else {
		hrs.dia = "0"+hrs.dia;
    }
	msg.payload = hrs.ano.toString()+hrs.mes.toString()+hrs.dia.toString()+".log";
	return msg;
	```