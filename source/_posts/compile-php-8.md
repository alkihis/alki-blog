---
title: Compiler, installer et découvrir PHP 8 sur macOS / Debian
date: 2022-08-14 12:53:53
tags:
  - PHP
categories:
  - Tutoriels
  - PHP
---

Vous avez envie de tester les nouvelles features de PHP un peu en avance par rapport à tout le monde ?

Voici un rapide tuto pour installer PHP 8 depuis la source (GitHub), très simplement ; que ce soit pour macOS ou des dérivés de Debian (comme Ubuntu).
Juste après ça, c'est parti pour tester rapidement toutes les features de PHP :D

## Préparation pour macOS

Pour macOS, vous aurez besoin du package manager [brew](https://brew.sh/index_fr) avant de continuer. Lorsqu'il sera installé, revenez ici.

```bash
# Installez bison, re2c et les autres et n'oubliez pas de les inclure dans le path
brew install bison re2c libiconv sqlite3 make cmake gcc
echo 'export PATH="/usr/local/opt/bison/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/usr/local/opt/libiconv/bin:$PATH"' >> ~/.zshrc
```

## Préparation pour les Debian-like

Même cinéma que pour macOS, mais là plus simplement vu que l'on passe par le gestionnaire de paquets par défaut de l'OS.

```bash
sudo apt install build-essential libzip-dev autoconf re2c bison libxml2-dev libsqlite3-dev
```

## Cloner et compiler

Les choses sérieuses commencent.
Tout d'abord, clonez le repo et rentrez dedans.

```bash
cd ~
git clone https://github.com/php/php-src.git
cd php-src
```

Lancez la configuration, puis compilez.
```bash
./buildconf

### ATTENTION : pour macOS
./configure --prefix=/usr/local/opt/php/php8 --enable-opcache --with-zlib --enable-sockets --without-pear --with-iconv=/usr/local/opt/libiconv
### Et pour DEBIAN/UBUNTU
./configure --prefix=/opt/php/php8 --enable-opcache --with-zlib --enable-sockets --without-pear

# Remplacez 8 par votre nombre de CPU
make -j8
```

Si vous voulez lancer les tests unitaires, faites un `make test`. Oui, certains vont fails, c'est "normal".

## Installer le binaire

Sur macOS, un `make install` suffit. **PHP sera installé dans `/usr/local/opt/php/php8`**.

Sur Linux, réalisez un `sudo make install`. **PHP sera installé dans `/opt/php/php8`**.

## Vérifier l'installation

C'est très simple, exécutez simplement **`{chemin_installation}/bin/php -v`**, par exemple :
```
$ /usr/local/opt/php/php8/bin/php -v
PHP 8.1.0-dev (cli) (built: Nov 16 2020 21:28:56) ( NTS )
Copyright (c) The PHP Group
Zend Engine v4.1.0-dev, Copyright (c) Zend Technologies
```

## Votre premier script PHP compatible

Faisons un tour rapide des nouveautés importantes de PHP 8, voulez-vous ?

Commencez par créer un fichier PHP vide, et en avant.

```bash
# N'oubliez pas d'ajuster le chemin en fonction de votre système
echo 'alias php8="/usr/local/opt/php/php8/bin/php"' >> ~/.zshrc
zsh
cd
echo '<?php ' > test_php8.php
code test_php8.php
```

### Promotion de variables dans le constructeur

Désormais, vous pouvez définir des propriétés d'instance directement dans les paramètres du constructeur.
C'est très pratique pour remplacer l'idium suivant :

```php
class User {
  protected string $name;

  public function __construct(
    string $name,
  ) {
    $this->name = $name;
  }
}
```

en

```php
class User {
  public function __construct(
    protected string $name,
  ) {}
}

$user = new User('Hello');
var_dump($user);
```

Exécutez le code pour vérifier...
```bash
$ php8 test_php8.php
object(User)#1 (1) {
  ["name":protected]=>
  string(5) "Hello"
}
```

### Type `mixed` accepté en annotation

Avant en PHP, lorsque vous vouliez signifier qu'une variable prend différents types, vous étiez obligé de simplement *pas annoter* le type.
Mais rien n'indiquait si c'était un oubli ou simplement que votre variable/argument était "n'importe quoi" !

Cette annotation, `mixed`, était déjà utilisée dans la documentation de PHP.

```php
class User {
  public mixed $data;

  public function __construct() {
    // Définition obligatoire
    $this->data = [];
  }
}
```

**Cependant**, si une autre nouveauté est plus intéressant qu'utiliser `mixed` quand vous attendez plusieurs types. Et cette nouveauté, c'est...

### Union types

Oui ! Les unions de type arrivent enfin sur PHP. Vous pouvez désormais spécifier qu'un argument/propriété est d'un ou plusieurs types.
Auparavant, vous étiez forcé de laisser l'annotation vide pour éviter les erreurs de compilation (ou la coercion, dans certains cas).

La syntaxe est la même qu'en TypeScript, notamment : `Type1 | Type2 | Type3 | ...`

```php
class User {
  public function __construct(
    public float | int $height
  ) {}
}

$user = new User(180);
echo 'Oh, mon utilisateur mesure ' . ($user->height) . "cm !\n";
var_dump($user);

$user->height += .3;
echo 'Désormais, il mesure ' . ($user->height) . "cm.\n";
var_dump($user);
```

Ce script affiche la sortie suivante :
```bash
$ php8 test_php8.php
Oh, mon utilisateur mesure 180cm !
object(User)#1 (1) {
  ["height"]=>
  int(180)
}
Désormais, il mesure 180.3cm.
object(User)#1 (1) {
  ["height"]=>
  float(180.3)
}
```

### Paramètres nommés

Feature phare de certains langage "modernes" (Python en fait un de ses points majeurs), les paramètres nommés sont une manière de passer des arguments dans le désordre.
Un exemple valant mieux qu'une longue phrase, vous avez sûrement déjà rencontré le cas suivant :

```php
function myComplexFunction(
  string $name,
  int $multipler = 3,
  float $complexifier = 1.0,
  ?array $callable_data = [],
) {
  // Do something very complex...
}

// Vous avez envie de spécifier $callable_data mais pas de toucher aux paramètres
// par défaut $multipler et $complexifier... Pourtant, vous êtes obligé de le faire :
myComplexFunction(
  'Hello World!',
  3, // Vous ne pouvez pas mettre null ici, sinon ça plante
  1.0, // de même ici
  [
    1, 3, 5, 1
  ],
);
```

Mais désormais, c'est **terminé** ! En PHP, tous les arguments sont désormais nommables par défaut.
Vous pouvez faire donc ça :

```php
myComplexFunction(
  'Hello World!',
  callable_data: [1, 3, 5, 1],
);
```

La syntaxe est donc `nom_argument: valeur`, à spécifier **après tous les paramètres positionnels** de votre appel.

### Attributs

Sans doute la plus **GROSSE** feature de PHP 8.0.
Vous les utilisez déjà (peut-être) avec votre framework/Doctrine, les annotations/attributs dans les commentaires de votre code (précisément, dans la doc-string).

PHP 8 ajoute une manière native de traiter ces annotations avec ce qu'on appelle les attributs, sous la forme `#[AttrName]` (comme en Rust).

Je ne vais pas détailler *comment* créer un attribut ici, ça serait vraiment plus long.
Sachez vous pouvez spécifier **plusieurs** attributs avec cette syntaxe (séparés par une virgule), et vous pouvez "appeler" les attributs comme une fonction.

Les attributs peuvent être positionnés **sur une classe**, **sur une propriété**, **sur une fonction/méthode** et sur un **paramètre de fonction**.
Un peu partout où c'est utile, donc !

```php
use App\Attributes\PropAttribute;
use App\Attributes\FuncAttribute;
use App\Attributes\ParamAttribute;

#[ORM\Entity(), ORM\Table("baz")]
class Example {
  #[PropAttribute]
  public const FOO = 'foo';

  #[PropAttribute]
  public $x;

  #[FuncAttribute]
  public function foo(#[ParamAttribute] $bar) { }
}
```

### Opérateur de safe-navigation

Nouveau venu du `JavaScript` courant 2020, il fait également son arrivée dans PHP.
Il permet d'accéder à des propriétés / méthodes en vérifiant au préalable que celle-ci ne vaut pas `null`.

```php
$startDate = $booking->getStartDate();
$dateAsString = $startDate ? $startDate->asDateTimeString() : null;

// Qui peut être remplacé par...
$dateAsString = $booking->getStartDate()?->asDateTimeString();

// Egalement disponible avec les propriétés
$dateAsString = $booking->startDate?->asDateTimeString();
```

Si l'appel à `getStartDate` renvoie `null`, alors la suite ne sera pas interprétée et ne lancera donc pas d'erreur.
A la place, `null` est directement stocké dans la variable.

### L'expression simili-pattern-matching

PHP 8.0 introduit une nouvelle structure de contrôle, `match` qui n'est en fait **pas** du pattern-matching contrairement à ce que son nom laisse penser.

C'est un réalité un `switch` déguisé avec `return` automatique. Très pratique, il correspond au code suivant :
```php
const TYPE_1 = '1';
const TYPE_2 = '2';
const TYPE_3 = '3';
const TYPE_NONE = null;

$type = 1;

$typeAsConst = (function () use ($type) {
  switch ($type) {
    case 1: return TYPE_1;
    case 2: return TYPE_2;
    case 3: return TYPE_3;
    default: return TYPE_NONE;
  }
})();

// Exactement la même chose que
$typeAsConst = match ($type) {
  1 => TYPE_1,
  2 => TYPE_2,
  3 => TYPE_3,
  default => TYPE_NONE,
};
```

ce qui est nettement plus propre.

### Nouvelles fonctions manipulant les chaînes de caractères

Enfin, dernière nouveauté, plus petite celle-ci.
Il s'agit de trois fonctions facilitant la manipulation des `string`, évitant d'utiliser des fonctions plus complexes pour des cas simples :

- `str_contains` pour éviter `strpos` qui est assez error-prone
- `str_starts_with` pour éviter `preg_match('/^pattern/')`
- `str_ends_with` pour éviter `preg_match('/pattern$/')`

L'utilisation est très simple :
```php
str_contains('words', 'word'); // true
// à la place de
strpos('words', 'word') !== false; // true

// Celles-ci sont très simples à comprendre :
str_starts_with('Hello World!', 'Hell'); // true
str_ends_with('Hello World!', '!'); // true
```

## Résumé

Nous avons vu comment compiler et utiliser PHP 8 depuis la source, puis on a abordé les nouveautés les plus évidentes à prendre en main.

Mais ce n'est pas tout ! Voici une petite liste non-exaustive des autres nouveautés de la version majeure :
- Le [JIT](https://wiki.php.net/rfc/jit), qui assurera de meilleures performances à l'avenir
- Le type de retour [`static`](https://wiki.php.net/rfc/static_return_type)
- `throw` devient une [expression](https://wiki.php.net/rfc/throw_expression)
- L'arrivée des [`WeakMap`](https://wiki.php.net/rfc/weak_maps)
- L'utilisation possible de [`::class`](https://wiki.php.net/rfc/class_name_literal_on_object) sur les objets
- Les `catch` ne créant pas de [variable locale](https://wiki.php.net/rfc/non-capturing_catches)
- L'autorisation des [virgules de fin de liste de paramètres de fonction](https://wiki.php.net/rfc/trailing_comma_in_parameter_list)
- L'interface [`Stringable`](https://wiki.php.net/rfc/stringable)
- L'utilisation de [`TypeError` dans les fonctions natives](https://wiki.php.net/rfc/consistent_type_errors) quand le type des paramètres sont incorrects
- Le changement de la [précédence de l'opérateur de concaténation](https://wiki.php.net/rfc/concatenation_precedence)
- Le changement du parsing [des chaînes numériques](https://wiki.php.net/rfc/saner-numeric-strings) et de leur [comparaison](https://wiki.php.net/rfc/string_to_number_comparison) avec des nombres

Merci d'avoir lu cet article, et à la prochaine fois !

