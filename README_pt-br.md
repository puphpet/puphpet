# PuPHPet #

[PuPHPet](https://puphpet.com) - É uma aplicação que auxilia a configurar máquinas virtuais para o desenvolvimento PHP.

[![Build Status](https://travis-ci.org/puphpet/puphpet.png)](https://travis-ci.org/puphpet/puphpet) [![Code Climate](https://codeclimate.com/github/puphpet/puphpet/badges/gpa.svg)](https://codeclimate.com/github/puphpet/puphpet)

##O que é?##

[PuPHPet](https://puphpet.com) é uma aplicação web que permite rapidamente gerar Maquinas Virtuais com 
[Vagrant](http://vagrantup.com) e Controladores com [Puppet](https://puppetlabs.com).

Se você não estiver familiarizado com Vagrant ou Puppet, veja este blog ["Make $ vagrant up yours"](https://jtreminio.com/2013/06/make_vagrant_up_yours/).

## Como? ##

O PHP aciona o frontend, usando o ["framework Symfony2"](http://symfony.com/). As escolhas são setadas em um arquivo que yaml que configura o Puppet manifest com suas configurações personalizadas.

## Por quê? ##

Comecei a utilizar o Vagrant e o Puppet quando simplemente eu queria uma VM com o PHP 5.4 para fazer meu desenvolvimento. Eu poderia até encontrar alguma coisa pré-pronta, mas encontraria com muita sujeira e não era o que eu queria. Portanto decidi criar uma ferramenta, para facilitar a tarefa para outros desenvolvedores, que não querem aprender as DSL do Puppet para criar uma VM instalada e funcionando, possibilitando assim desenvolver em sua linguagem.

## Quem? ##

Originalmente desenvolvido por [Juan Treminio](https://jtreminio.com), PuPHPet ja conta com 80 colaboradores (11/17/2014), com o talentoso [Frank Stelzer](https://twitter.com/frastel) um grande contribuidor. E também fazendo contribuições significativas [Michaël Perrin](http://www.michaelperrin.fr/).

Em meados de Agosto de 2013, foi iniciado o trabalho de desenvolver a v2, a fim de resolver alguns problemas encontrados na v1: dificuldade de adicionar novas funcionalidades, muita lógica PHP controlando o Puppet e dificuldade de alterar um manifest existente.

## Objetivo ##

O principal objetivo do PuPHPet é, eventualmente, substituir ferramentas como o XAMPP, WAMPP, MAMPP e outros servidores tudo-em-um, que criam ambientes de desenvolvimento do seu sistema operacional principal.

O PuPHPet é bom o suficiente para ajudar a criar servidores de produção!

## Requerimentos ##

Para executar o PuPHPet-generated manifests, você precisará instalar a versão 1.6.0 ou [Vagrant](http://downloads.vagrantup.com/) superior. O Vagrant será executado em Windows, OS X e Linux.

## Licença ##

PuPHPet está licenciado sob a [licença MIT](http://opensource.org/licenses/mit-license.php) tudo terceiros Puppet Modules está licenciado sob [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0)
