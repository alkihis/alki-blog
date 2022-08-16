---
title: Le futur de JavaScript (vu de 2022) - Nouveautés en pagaille
date: 2022-08-16 18:17:03
slug: futur-javascript-nouveautes-pagaille
tags:
  - JavaScript
  - Futur
  - '2022'
categories:
  - Évolutions de langage
  - JavaScript
---

## Introduction

Comme vu dans [l'article précédent](/articles/futur-javascript-introduction), le processus pour bénéficier d'une nouvelle fonctionnalité dans l'univers JavaScript est assez long et pénible.

Pour débuter doucement avec les différentes avancées à venir dans le langage, nous allons regarder des "petits" ajouts un à un !

N'hésitez pas à utiliser la table de matières (à droite sur ordinateur) pour naviguer dans la partie qui peut vous intéresser.

## Assertions lors d'`import` et chargement de JSON sur navigateur

- [Lien](https://github.com/tc39/proposal-import-assertions)
- Stage : 3
- Implémentations :
  - Chrome : 91
  - Node.js : 17.5

Régulièrement, un développeur peut avoir besoin de charger un fichier JSON situé localement (= sur le serveur) dans son environnement JavaScript.
Pour cela, deux manières cohabitent en fonction du type d'application.

### Node.js

En Node.js, il est tout à fait possible de charger le fichier "tel quel", comme un module standard.

```ts
const jsonFile = require('./package.json') // ok !
```

L'alternative consiste à charger le fichier directement depuis le disque, manuellement.
C'est généralement l'alternative préférée, si le fichier est amené à changer au cours de la vie du processus et pour ne pas le confondre avec un module.

```ts
import { promises as fs } from 'fs'

const jsonFile = JSON.parse(await fs.readFile('./package.json', 'utf-8'))
```

### Navigateur

Sur navigateur, dans l'écosystème actuel, deux possibilités cohabitaient.

La première, universelle, est de charger le fichier en AJAX/Fetch puis de le parser.

```ts
const jsonFile = await fetch('/api/package.json').then(r => r.json())
```

Le principal inconvéniant est d'avoir un "arrêt" du code via `await`, ce qui peut être gênant si le contenu du fichier est censé être lu dès la racine du module.

La seconde nécessite un transpileur tel Webpack pour fonctionner.
Il est possible d'utiliser directement `import`. Attention, ceci ne fonctionne pas nativement !
Cette méthode pré-compile le fichier au moment de la génération du bundle ; donc si le fichier change sur le serveur, le projet devra être recompilé pour voir les modifications.

```ts
import jsonFile from './package.json'
```

### L'arrivée des modules JSON

L'idée d'unifier l'approche Node/navigateur pour l'import de fichier JSON est arrivée en [proposal](https://github.com/tc39/proposal-json-modules) il y a quelques temps de cela.

Celle-ci a permis de développer une syntaxe ré-utilisable à l'avenir avec d'autres types de fichiers (WebAssembly par exemple) et présente l'avantage d'être cross-platform.

```ts
import jsonFile from './package.json' assert { type: 'json' }
```

- Sur navigateur, un appel HTTP sera fait à l'adresse indiqué et **si le résultat est de type JSON**, alors le contenu sera parsé et stocké dans la variable `jsonFile`.
L'assertion présente l'avantage de protéger d'un potentiel lien vérolé qui enverrait du code JavaScript (qui serait aussi un import valide !) à la place d'un simple JSON.
Ainsi, le navigateur est certain de ne pas exécuter du code sans que le développeur l'ait prévu.

- Sur Node.js, un appel au disque (si le chemin est local) ou un appel HTTP (si le chemin est externe) est réalisé, puis importé en tant que module.

## `Array.prototype.group` et `Array.prototype.groupToMap`

- [Lien](https://github.com/tc39/proposal-array-grouping)
- Stage : 3
- Implémentations :
  - Chrome : 100 (derrière un drapeau)
  - Firefox : 98 (derrière un drapeau)

Cette proposition est une volonté de faciliter une opération très courante : le groupage d'éléments d'un tableau.

```ts
const inventory = [
  { name: 'asparagus', type: 'vegetables', quantity: 5 },
  { name: 'bananas',  type: 'fruit', quantity: 0 },
  { name: 'goat', type: 'meat', quantity: 23 },
  { name: 'cherries', type: 'fruit', quantity: 5 },
  { name: 'fish', type: 'meat', quantity: 22 },
]

const inventoryByType = inventory.group(item => item.type)
// {
//   vegetables: [{ name: 'asparagus', type: 'vegetables', quantity: 5 }],
//   fruit: [{ name: 'bananas',  type: 'fruit', quantity: 0 }, { name: 'cherries', type: 'fruit', quantity: 5 }],
//   meat: [{ name: 'goat', type: 'meat', quantity: 23 }, { name: 'fish', type: 'meat', quantity: 22 }],
// }
```

La méthode `.groupToMap` fait la même chose, mais la clé (la valeur de retour du callback) peut être autre chose qu'une clé d'objet, puisque les éléments sont placés dans un objet `Map` plutôt qu'un objet classique.

Une implémentation rudimentaire pourrait être celle-ci :
```ts
Array.prototype.group = function <T, K extends string | number | symbol>(
  this: T[],
  callback: (element: T, index: number, array: T[]) => K,
  thisArg?: any,
): { [TKey: K]: T[] } {
  const grouped = Object.create(null)

  for (let i = 0; i < this.length; i++) {
    const key = callback.call(thisArg !== undefined ? thisArg : this, this[i], i, this)

    if (key in grouped) {
      grouped[key].push(this[i])
    } else {
      grouped[key] = [this[i]]
    }
  }

  return grouped
}
```

## Méthodes supplémentaires pour tableaux

- [Lien](https://github.com/tc39/proposal-change-array-by-copy)
- Stage : 3
- Implémentations : Aucune

Depuis des temps immémoriaux, il existe en JS une floppée de méthodes sur les tableaux, dont certaines bien pratiques, pour trier ou inverser le-dit tableau.

Souci de ces méthodes (si vous ne le saviez pas !), elles modifient le tableau d'origine !
Cela peut sembler trivial, mais la quasi-intégralité des méthodes sur les `string` ou `Array` notamment crééent une copie de l'objet original.

Le but de cette proposition est d'apporter une version "immutable-friendly" de ces méthodes n'agissant pas comme les autres.
Originellement, cette proposal dérive des `Tuple` (qui seront traités une autre fois), mais elle a fait son bout de chemin seule.

Les méthodes suivantes sont concernées :
- `.reverse()` -> `.toReversed()`
- `.sort(comparer)` -> `.toSorted(comparer)`
- `.splice(start, deleteCount, ...items)` -> `.toSpliced(start, deleteCount, ...items)`

et une nouvelle méthode, `.with(index, newValue)`.

Petite piqure de rappel et explications pour chacune d'entre elles !

### `.reverse()`

Celle-ci est plutôt évidente ! Elle permet d'inverser l'ordre du tableau **en cours**.
La nouvelle alternative `.toReversed()` permet de créer une copie "à l'envers".

```ts
const arr = [1, 2, 3]

// .reverse() renvoie une référence vers le tableau en cours
const arrReversed = arr.reverse() // [3, 2, 1]
arr // [3, 2, 1] // le tableau d'origine a été modifié
arr === arrReversed // true

const immutable = [1, 2, 3]
const reversed = immutable.toReversed() // [3, 2, 1]
immutable // [1, 2, 3] // toujours l'original
immutable === reversed // false => instances différentes

// Exemple d'implémentation naive
Array.prototype.toReversed = function () { return [...this].reverse() }
```

### `.sort()`

L'avantage de `.sort` est *bien évidemment*, de pouvoir trier un tableau. Mais plus important, de pouvoir trier sans se poser la question de l'algorithme de tri ! Ce choix est à la charge du moteur JavaScript (V8, par exemple, utilise [TimSort](https://v8.dev/blog/array-sort#timsort)).

Nous avons maintenant la possibilité d'utiliser `.toSorted()`, qui génère une copie triée du tableau d'origine.

Pour rappel, en JavaScript, on trie avec une fonction de comparaison prenant deux paramètres `a` et `b`, dont la valeur de retour (qui est un nombre) peut avoir trois significations :
- Si strictement inférieur à 0, l'élément `a` sera placé avant `b`
- Si égal à 0, `a` sera placé au même emplacement par rapport à `b` (si il était avant il restera avant lui, si il était après il restera après lui ; on appelle ça un tri stable)
- Si strictement supérieur à 0, l'élément `a` sera placé après `b`

```ts
const items = [2, 3, 1]
items.sort((a, b) => a - b) // [1, 2, 3]
items // [1, 2, 3]

const immutable = [2, 3, 1]
immutable.toSorted((a, b) => a - b) // [1, 2, 3]
immutable // [2, 3, 1]

// Exemple d'implémentation naive
Array.prototype.toSorted = function (compareFn) { return [...this].sort(compareFn) }
```

### `.splice()`

`.splice` est peu utilisée (par rapport à d'autres), elle permet d'ajouter/supprimer des éléments du tableau (sans le réassigner).
*Attention, contrairement aux autres méthodes, `.splice` ne renvoie pas le tableau d'origine. À la place, elle renvoie un tableau contenant les éléments supprimés par l'appel.*

Autrement dit, étant donné un `index` donné (qui sera le point de départ du traitement), on peut **supprimer des éléments**...

```ts
const items = [1, 2, 3]

// Depuis l'index 1 (inclus), supprime 1 élément du tableau
const deleted = items.splice(/* startIndex */ 1, /* numberOfItemsToDelete */ 1)

items // [1, 3]
deleted // [2]
```

...on peut également rajouter des éléments "au milieu" d'un tableau...

```ts
const items = [1, 2, 3]

// Depuis l'index 1 (inclus), ajoute 2 éléments au tableau (4 et 5)
items.splice(/* startIndex */ 1, /* numberOfItemsToDelete */ 0, /* ...itemsToAdd */ 4, 5)

items // [1, 4, 5, 2, 3]
```

...ou les deux en même temps.

```ts
const items = [1, 2, 3]

// Depuis l'index 1 (inclus), ajoute 2 éléments au tableau (4 et 5), et on en supprime 1
items.splice(/* startIndex */ 1, /* numberOfItemsToDelete */ 1, /* ...itemsToAdd */ 4, 5)

items // [1, 4, 5, 3]
```

Sans grande surpise (normalement), vous comprendrez que `.toSpliced` fait la même chose mais en renvoyant une copie modifiée plutôt que changer l'original.
On perdra donc le retour des éléments potentiellement supprimés (obtenables tout aussi facilement, puisque vous avez toujours l'original sous la main !).

```ts
const items = [1, 2, 3]

items.toSpliced(1, 1) // [1, 3]
items.toSpliced(1, 0, 4, 5) // [1, 4, 5, 2, 3]
items.toSpliced(1, 1, 4, 5) // [1, 4, 5, 3]
items // [1, 2, 3]

// Exemple d'implémentation naive
Array.prototype.toSpliced = function (...args) {
  const copy = [...this]
  copy.splice(...args)
  return copy
}
```

Si vous voulez mon avis, je trouve `.splice` trop énignmatique dans ses paramètres. C'est à mon sens une fonction qui mériterait *soit* d'être séparée en deux (`.add` et `.delete` par exemple), *soit* d'utiliser un objet en paramètre (exemple en dessous).

```ts
// Ceci est FICTIONNEL
interface ISpliceParams<T> {
  startsAt?: number // defaults to 0
  delete?: number // defaults to 0
  add?: T[] // defaults to empty array
}

// utilisé tel quel, l'appel est déjà plus clair
items.splice({ startsAt: 1, delete: 1, add: [4, 5] })
```

### `.with()`

Petite nouvelle, la méthode `.with` permet de créer une copie d'un tableau avec seulement un élément spécifique modifié.
C'est la version "immutable-friendly" de `array[index] = item` finalement.

Initialement proposée pour les `Tuple` (car ils sont purement immuables), il a été proposé de l'ajouter sur les tableaux à des fins d'uniformité.

```ts
const items = [1, 2, 3]
items[1] = 4
items // [1, 4, 3]

const immutable = [1, 2, 3]
// .with(atIndex, newValueForIndex)
immutable.with(1, 4) // [1, 4, 3]
immutable // [1, 2, 3]

// Exemple d'implémentation naive
Array.prototype.with = function (atIndex, newValueForIndex) {
  const copy = Array(this.length)

  for (let i = 0; i < this.length; i++) {
    copy[i] = i === atIndex ? newValueForIndex : this[i]
  }

  return copy
}
```

## Et après...

D'autres aventures nous attendent encore dans le monde de la spécification du langage ECMAScript :
[Décorateurs (stage 3)](https://github.com/tc39/proposal-decorators), nouveau système de gestion de la date [(Temporal, stage 3)](https://github.com/tc39/proposal-temporal), des [meilleurs itérateurs (stage 2)](https://github.com/tc39/proposal-iterator-helpers), ou encore de vraies structures immuables [(Record & Tuple, stage 2)](https://github.com/tc39/proposal-record-tuple) seront de la partie.

Tous ces sujets seront abordés une prochaine fois !
