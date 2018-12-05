**Resumo**

Desenvolver uma forma de monitorar os eventos ocorridos no Software de Automação Industrial **Concept** da Schneider.

O Concept(software de programação de PLC's da Série Quantum, Momemtum e Atrium) não possui uma **ferramenta/sistema** que monitore as alterações feitas no controladores, o que torna o gerenciamento das mudanças impossível.


**Desenvolvimento**

O Concept quando é aberto é gerado um arquivo com a extensão ***.log*** com o formato de dados do dia atual. Caso o Concept não seja aberto nenhum arquivo é gerado.

O que foi visto é que o este arquivo ***.log*** poderia ser aberto através, por exemplo, pelo Notepad++ o que poderia ser ajudar na verificação dos eventos. Isto ajuda bastante mas não
fica algo centralizado. Como o arquivo do Concept é local, ou seja, para cada máquina que possui o Concept instalado um arquivo é gerado, caso necessite rastrear um evento se houver 100
máquina são 100 arquivos a serem analisados. Isso torna uma tarefa não muito produtiva.

O primeiro passo para poder minimizar este trabalhou foi o desenvolvimento de uma planilha no excel usando VBA que, na prática, 'abre' estes arquivos e busca das marcações que consideramos que foi 
uma alteração e retorna nas colunas do excel:

<img src="https://github.com/dedynobre/Gerenciando-Eventos-do-Concept/blob/master/images/conc-01.jpg"/></br>

A base para este desenvolvimento é um arquivo ***.bat** que 'busca' os logs de todas as máquinas que possui o Concept instalado e centraliza em um local específico na rede para que o cógido
Excel possa utilizá-lo.

Logo após feito este desenvolvimento a rotina de verificação de eventos melhorou e houve ganho de produtividade.

Este procedimento auxilia muito na verificação dos eventos só que tem alguns detalhes:
>* 1 - Necesside de rodar uma .bat para poder centralizar os arquivos de logs.
>* 2 - Os eventos não são verificados de forma automática e em tempo real. Com isso não tem acompanhamento quando o evento foi realizado.
>* 3 - Desta forma trabalha-se com eventos no passado. Isto funciona mas em caso de notificação não se aplica.
