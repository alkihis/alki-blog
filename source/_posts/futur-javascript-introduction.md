---
title: Le futur de JavaScript (vu de 2022) - Introduction
date: 2022-08-14 15:03:08
slug: futur-javascript-introduction
tags:
  - JavaScript
  - Futur
  - '2022'
categories:
  - Évolutions de langage
  - JavaScript
---

## Aborder l'avenir

Dans l'itération précédente de ce blog, en 2019/2020, nous avions parcouru des nouveautés autour de l'écosystème JavaScript, en particulier la spécification du langage lui-même (standardisé par l'ECMA).

Ce que je propose aujourd'hui, c'est de se relancer dans une série traitant de ce qui est *à venir* dans l'univers JS.

Dans un premier lieu, les évolutions les plus fondamentales sont celles intrinsèques au langage, qui seront universellement répliqués dans tous les moteurs et plateformes à terme.

Parlons d'abord de ces nouveautés là, d'accord ?
Mais pour les évoquer, il faut commencer par définir *comment* JavaScript est amené à évoluer.

## Faire évoluer un langage par la spécification

Chaque langage de programmation choisit son propre de chemin pour le guider vers sa version suivante.

Python, par exemple, évolue avec un système de [PEP](https://peps.python.org/pep-0000/) (la plus connue étant sans doute [PEP 8](https://peps.python.org/pep-0008/)), une sorte de recueil de lois écrits par les contributeurs majoritaires et validées par le "dictateur bienveillant à vie" Guido van Rossum (son créateur).
Ces lois dictent comment et quand le langage doit évoluer, et comment il doit être utilisé.

JavaScript, après sa chaotique naissance dans les années 90, a choisi un chemin différent.
Sa référence d'implémentation est un ensemble de textes parsemé de termes abstraits décrivant en pseudo-code comment chaque partie du langage doit être lue et exécutée.

Si des détails sont laissés en pleine liberté de l'implémentation, il y a des références précises sur, par exemple, quel est le chemin emprunté par `String.prototype.slice` étant donné ses paramètres pour en arriver à son résultat final.

Ce processus est réalisé par l'écriture de spécifications décrivant des changements ou des nouveautés apportées de manière abstraite.
Ces documents sont produits par des développeurs, académiciens, implémenteurs (ou plus), faisant pour la majorité partie du groupe [TC39](https://tc39.es/) de l'[ECMA](https://www.ecma-international.org/).

Sans trop rentrer dans le détail, l'ECMA International est une organisation qui édite entre autres l'ECMAScript, aka la version "officielle" du langage JavaScript prise
pour référence par les navigateurs web.
Elle est également en charge de bien d'autres sujets en informatique, comme la spécification du Dart.

### Implémenter une nouvelle fonctionnalité à l'ECMAScript

Pour déposer une "idée" de fonctionnalité, vous devez donc faire partie de ce comité TC39. Après cela, vous êtes libres de créer votre propre entrée sur la liste des [Proposals du TC39](https://github.com/tc39/proposals).

Une "Proposal" peut être une simple description de la fonctionnalité voulue, mais devra nécessairement être étoffée pour passer toutes les étapes la menant à sa standardisation.

Il y a 5 étapes ("Stages") dans le processus de standardisation.

#### Étape 0 : L'idée vient d'arriver

La "Stage 0" est la première étape de votre proposition.
Elle n'a pas encore été présentée au comité (lorsqu'il se réunit), ou elle n'était pas suffisamment complète (exemples, cas d'usages, implémentation basique, etc.) pour passer à l'étape suivante.

#### Étape 1 : Exploration du problème soulevé

Si l'idée mérite l'attention du comité, elle peut être explorée plus en détail. C'est le "Stage 1" du processus.
C'est généralement le plus long, car c'est le moment de soulever le conflit avec l'existant, les limites de l'idée ou des éventuels problèmes d'implémentation.

Il n'est pas rare que des propositions restent plusieurs années à l'étape 1 : par manque de temps des contributeurs de détailler toutes les difficultés ou conflits, ou simplement car elle est en conflit avec d'autres propositions plus importantes.

#### Étape 2 : Draft de spécification

Si les gros contours de votre problème sont bien cernés, il est temps d'écrire un Draft de spécification : votre propre proposition du document "officiel" décrivant tout ce qu'il y a à ajouter/modifier et comment tout cela est amené à fonctionner.

Cette étape nécessite un gros effort des contributeurs appartenant à des entreprises développant des moteurs de navigateurs pour être un succès.
Si ce n'est pas le cas, il n'est pas rare que la proposition se retrouve bloquée en phase 2.

#### Étape 3 : Finalisation de la spécification

Lors du passage en "Stage 3", tous les points bloquants sont levés. Il peut rester des détails non-impactant (comme des détails d'implémentation ou des ajustements de type), mais rien qui empêche de bundler une pré-implémentation dans un moteur JS commercial.

Lorsque la spécification est bouclée **et que au moins 3 moteurs différents implémententent la nouveauté**, la proposition passe à l'étape finale, l'étape 4.

#### Étape 4 : Implementé

Le passage en étape 4 signifie que votre idée est intégrée à la spécification officielle et que les principaux navigateurs ont bundlé la nouveauté.

### Et maintenant ?

Ce processus est lent et très dépendant du temps libre de développeurs majeurs du secteur.
Il se peut donc qu'il stagne ou soit prompt à des poussées très "immédiates" (rien ne se passe pendant 6 mois, puis 3 nouveautés arrivent d'un coup).

Généralement, comptez à minima 3 à 4 ans pour qu'une proposition passe à travers tout le processus. Encore plus si elle change significativement le langage (`BigInt`, décorateurs, `async/await`...).

## Alors, les nouveautés !

Dans cet article, nous avons d'abord vu tout le processus. Maintenant qu'il est bien compris, nous sommes prêts à aborder plusieurs évolutions **encore en discussion**.
Et ça, ce sera pour l'article d'après.

[Article suivant : Nouveautés en pagaille](/articles/futur-javascript-nouveautes-pagaille)
