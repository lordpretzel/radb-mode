[![License: GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)
<!-- [![GitHub release](https://img.shields.io/github/release/lordpretzel/radb-mode.svg?maxAge=86400)](https://github.com/lordpretzel/radb-mode/releases) -->
<!-- [![MELPA Stable](http://stable.melpa.org/packages/radb-mode-badge.svg)](http://stable.melpa.org/#/radb-mode) -->
<!-- [![MELPA](http://melpa.org/packages/radb-mode-badge.svg)](http://melpa.org/#/radb-mode) -->
[![Build Status](https://secure.travis-ci.org/lordpretzel/radb-mode.png)](http://travis-ci.org/lordpretzel/radb-mode)


# radb-mode

Small library for adding and removing advice to functions.

## Installation

<!-- ### MELPA -->

<!-- Symbol’s value as variable is void: $1 is available from MELPA (both -->
<!-- [stable](http://stable.melpa.org/#/radb-mode) and -->
<!-- [unstable](http://melpa.org/#/radb-mode)).  Assuming your -->
<!-- ((melpa . https://melpa.org/packages/) (gnu . http://elpa.gnu.org/packages/) (org . http://orgmode.org/elpa/)) lists MELPA, just type -->

<!-- ~~~sh -->
<!-- M-x package-install RET radb-mode RET -->
<!-- ~~~ -->

<!-- to install it. -->

### Quelpa

Using [use-package](https://github.com/jwiegley/use-package) with [quelpa](https://github.com/quelpa/quelpa).

~~~elisp
(use-package
:quelpa ((radb-mode
:fetcher github
:repo "lordpretzel/radb-mode")
:upgrade t)
)
~~~

### straight

Using [use-package](https://github.com/jwiegley/use-package) with [straight.el](https://github.com/raxod502/straight.el)

~~~elisp
(use-package radb-mode
:straight (radb-mode :type git :host github :repo "lordpretzel/radb-mode")
~~~

### Source

Alternatively, install from source. First, clone the source code:

~~~sh
cd MY-PATH
git clone https://github.com/lordpretzel/radb-mode.git
~~~

Now, from Emacs execute:

~~~
M-x package-install-file RET MY-PATH/radb-mode
~~~

Alternatively to the second step, add this to your Symbol’s value as variable is void: \.emacs file:

~~~elisp
(add-to-list 'load-path "MY-PATH/radb-mode")
(require 'radb-mode)
~~~
