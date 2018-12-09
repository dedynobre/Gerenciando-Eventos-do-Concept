# Monitorando Eventos do Software Concept(Schneider)

## Resumo

Desenvolver uma forma de monitorar os eventos ocorridos no Software de Automação Industrial **Concept** da Schneider.

O Concept(software de programação de PLC's da Série Quantum, Momemtum) não possui uma **ferramenta/sistema** que monitore as alterações feitas no controladores, o que torna o gerenciamento das mudanças impossível.


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
+ **Coluna 06** => identifica as ações realizadas pelo usuário. Dependendo do tamanho do texto esta coluna pode se tranformar em mais outra 
totalizando 07 colunas.

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


1. **Inject**: 
	+ este *node* tem como objetivo enviar uma mensagem(payload) a cada x tempo. No nosso caso está sendo considerado um tempo de **2 segundos**, ou seja, a cada 2 segundos ele envia
	um payload que será processado pelo node seguinte.

2. **Function**: 
	+ neste *node* pode ser escrito qualquer script utilizando a linguagem *javascript* como sintaxe principal. Neste caso ele está formatando a data para podermos montar o formato do
    arquivo de log que falamos anteriormente e que é gerado diariamente, que tem sua saída definido no item ***msg.payload***:
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
	+ (3) **Function**: mesmo função do item anterior. Neste item ele tem como objetivo trabalhar a mensagem enviada pela função anterior(onde é formatado a data com extensao do arquivo de log)
	e concatenar com o nome da máquina, ficando assim ***\\\nomedamaquina\concept\20181207.log***:
	```javascript
	var refdata = msg.payload;
	var maq = "\\\\nomedamaquina"+"\\"+"Concept"+"\\";
	var caminho = maq+refdata;
	msg.filename = caminho;
	return msg;
	```
4. **File In**: 
	+ tem o objetivo de 'abrir' um determinado arquivo. Ele tem a opção de especificar o nome direto na sua interface de configuração ou então passar um parâmetro que é ***msg.filename*** 
	que contém o caminho do arquivo. Quando o nome do arquivo não sofre alteração de nome podemos espeficiar diretamente na sua interface. Como nosso arquivo é criado dinamicamente em função do 
	dia, temos criar funções(descritas nos itens 2 e 3) para poder fornecer o nome do arquivo. O item 3 fica claro o parâmetro **msg.filename**.
	Configuração do node ***File In***:
	<img src="https://github.com/dedynobre/monitorando-eventos-do-concept/blob/master/images/conc-04.jpg"/></br>
5. **CSV**: 
	+ converte o arquivo de log em um arquivo csv. Como foi mencioanado em cima, o arquivo de log é basicamente formado por colunas então, a conversão do arquivo de log em um arquivo csv
	é para facilitar a extração da informações contidas nessa coluna. Com isso é possivel fazer comparações de cada coluna e buscar uma string qualquer contida dentra daquela coluna. Esse node tem 
	como saída uma mensagem no parâmetro ***msg.payload***.
6. **Function**: 
	+ essa função, basicamente, verifica se nas colunas específicas possuem strings que são consideradas modificações(conforme lista informada anteriormente):
	```javascript
	var a = msg.payload.length;
	var s;
	var k;
	var r;
	var p;
	var t1;
	var t2;
	var t3;
	var t4;
	var j = 0;
	var b = [];
	var hr1;
	var hr2;
	var hr3;
	var txt1;
	var txt2;
	var txt3;
	for(s = 0; s < a; s++){
		if (msg.payload[s].col5 === undefined){
			txt1 = "";
		} else { txt1 = msg.payload[s].col5; }
		if (msg.payload[s].col6 === undefined){
			txt2 = "";
		} else { txt2 = msg.payload[s].col6; }
		if (msg.payload[s].col7 === undefined){
			txt3 = "";
		} else { txt3 = msg.payload[s].col7; }    
		hr1 = msg.payload[s].col1;
		hr2 = hr1.split(" > Concept");
		k = msg.payload[s].col4;
		t1 = k.indexOf('Disable');
		t2 = k.indexOf('Deleted');
		t3 = k.indexOf('Written');
		t4 = k.indexOf('Set');
		r = k.indexOf('Enable');
		if ((t1 > 0) || (t2 > 0) || (t3 > 0) || (t4 > 0)) { p = 0; }
		if (r > 0) { p = 1; }
		if ((t1 > 0) || (r > 0) || (t2 > 0) || (t3 > 0) || (t4 > 0)){
			j = j + 1;
			b[j] = {
				status : p,
				horario : hr2,
				projeto  : msg.payload[s].col2,
				usuario : msg.payload[s].col3,
				desc    : msg.payload[s].col4 + " " + txt1 + " " +  txt2 + " " + txt3
			  }
		}
	}
	msg.payload = b;
	return msg;
	```
+ (7) **RBE**: 
	+ este node só tem valor na saída quando há uma alteração na sua entrada. Se notarmos, o script acima sempre fica monitorando as linhas dos arquivo de log e checa se ele tem 
	as string consideradas como modificações. Caso existe ele escreve as colunas que queremos no ***payload***. Como esta verificação é feita a cada 2 segundos, então a cada 2 segundos ele iria
	disparar uma notificação pois existe uma mudança. É ai que entra o node ***RBE***, se eu tenho um valor novo a saída é disparada e é enviada para node seguinte. Se não tenho valor novo ele 
	mantém a saída sem ação.
8. **Function**: 
	+ esta função formata o texto para ser enviado, via Telegram para o(s) destinatário(s):
	```javascript
	var b = msg.payload.length - 1;
	var a = msg.payload;
	var st;
	if (a[b].status === 0){
		st = "*Alteração Realizada*";
	}
	if (a[b].status === 1){
		st = "*Alteração Normalizada*"; 
	}
	var texto = "";
	texto += "\n";
	texto += "Data/Hora: ";
	texto += a[b].horario;
	texto += "\n";
	texto += "Projeto: ";
	texto += a[b].projeto;
	texto += "\n";
	texto += "Usuario: ";
	texto += a[b].usuario;
	texto += "\n";
	texto += "Descrição: ";
	texto += a[b].desc;
	msg.payload = {
		content : texto,
		type : 'message',
		chatId : -1001497128083

	}
	var dt = a[b].horario[0];
	var data = dt.split(" ")[0];
	var hora = dt.split("/")[1];
	var dia;
	var mes;
	var ano;
	var horario = dt.split(" ")[1];
	dia  = data.split("/")[0];
	mes  = data.split("/")[1];
	ano  = data.split("/")[2];
	var dt2 = ano + "-"+mes+'-'+dia+ " "+horario;
	msg.topic = {
		data : dt2,
		local : "(SE-23)",
		projeto : a[b].projeto,
		usuario : a[b].usuario,
		descricao : a[b].desc

	};
	return msg;
	```
	O parâmetro ***msg.payload*** define estrutura de mensagem para envio via Telegram. O parâmetro ***msg.topic*** define a estrutura de mensagem para envia de dados para banco de dados.
9. **Telegram**: 
	+ Configuração do ***bot** para envio das mensagens. Mais detalhes sobre criação de um ***bot*** [Clique Aqui!](https://medium.com/tht-things-hackers-team/10-passos-para-se-criar-um-bot-no-telegram-3c1848e404c4).
10. **Function**: 
	+ recebe a mensagem do item 08 através do parâmetro ***msg.topic*** e formata para envio dos eventos para banco de dados:
	```javascript
	data = msg.topic.data;
	data = new Date(data).toISOString().slice(0, 19).replace('T', ' ')
	local = msg.topic.local;
	projeto = msg.topic.projeto;
	usuario = msg.topic.usuario;
	descricao = msg.topic.descricao.split("'");
	pld =       "INSERT INTO [Concept].[dbo].[Eventos] "
	pld = pld + "(dataHora, local, projeto, usuario, descricao) "
	pld = pld + "VALUES ('" + data + "', '" + local + "', '" + projeto + "', '" + usuario + "', '" + descricao + "')"
	msg.payload = pld;
	return msg;
	```
11. **MSSQL**: 
	+ node para gerenciar as informações do banco de dados. As queries podem ser passadas diretamente na interface de configuração ou passadas via ***node functions***. Optamos
	por usar o node funtions:
	<img src="https://github.com/dedynobre/monitorando-eventos-do-concept/blob/master/images/conc-04.jpg"/></br>
	
## Conclusão

Com todas estas configurações concluimos que ***todas*** as alterações realizadas nos controladores, independente da máquina, será controlado. Como mostrado e se encontra configurado as 
notificações(Via Telegram) e também os eventos são gravados em um banco de dados externo que serve de base para o relatório mostrado no início.
As vezes as notificações não são utilizas por ser consideradas desnecessárias mas deixamos configurado para poder deixar registrado o quando o NodeRed pode ajudar no gerenciamento dos eventos
ocorridos nos controladores.

## Help

Caso precisem de ajuda, deixe seu questionamento [Aqui](https://github.com/dedynobre/monitorando-eventos-do-concept/issues).
	