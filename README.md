# Ground Truth Generator v2.0

Programa desenvolvido em MATLAB para segmentação e geração de máscaras **Ground Truth**.

## Prerequisites

MATLAB Runtime R2015a ou superior.

link para download: https://www.mathworks.com/products/compiler/matlab-runtime.html

## Running

Para executar o **GT Generator** basta abrir o arquivo **GTGenerator.m** no MATLAB e executá-lo.

--------- MENU

O **Menu** está dividido em duas partes, Segmentação e Imagem.

--------------- Segmentação

Três ferramentas de segmentação estão disponíveis: 'Pontos', 'Polígono' e 'Mão Livre'.

Pontos:
	Esta ferramenta consiste em um método de segmentação interativo.
	Cliques com o botão esquerdo do mouse demarcam a região de interesse (foreground).
	Cliques com o botão direito do mouse demarcam o fundo (background);

	A barra deslizante regula a importância da posição espacial dos pixels. Para um valor
	igual a **zero**, apenas as cores dos píxels são levadas em consideração na segmentação.

Polígono:
	Ferramenta manual que consiste na construção de um polígono demarcando a região de interesse.
	Vértices do polígono são adicionados dando cliques do mouse.

Mão Livre:
	Como o nome sugere esta é uma ferramenta de desenho mão livre. A demarcação ocorre enquanto
	o botão do mouse estiver pressionado.

* obs: com excessão da ferramenta 'Pontos' as outras só permitem marcar um único objeto na imagem.

--------------- Imagem

O menu da imagem possui quatro botões: Importar, Anterior (<), Próximo (>) e Salvar.

Os botões de navegação (<) e (>) permitem uma fácil navegação entre as imagens de uma mesma pasta.