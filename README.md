[![Actions Status](https://github.com/m-dango/raku-wordle/workflows/test/badge.svg)](https://github.com/m-dango/raku-wordle/actions)

NAME
====

Games::Wordle - Wordle in Raku

SYNOPSIS
========

```raku
use Games::Wordle;

my Games::Wordle $wordle.=new;

until $wordle.result {
    with prompt '> ' -> $in {
        with $wordle.guess($in) {
            .join.say
        }
        else {
            .exception.message.say
        }
    }
    else {
        exit;
    }
}

"\n$wordle.result()".say;
```

DESCRIPTION
===========

Games::Wordle is a Raku implementation of the game Wordle, hosted by The New York Times at [https://www.nytimes.com/games/wordle/index.html](https://www.nytimes.com/games/wordle/index.html)

Games::Wordle uses the same word list and daily answers as the NYT version by default. You may also customize the game by providing your own answer, list of valid inputs, or number of guesses via the `new` method with the options `:answer`, `:valid-inputs`, and `:guess-limit`. The tiles can also be changed with the `:correct-tile`, `:present-tile`, and `:absent-tile` options.

The class is intended to be flexible, allowing for constructing Wordle variants with options via the `new` method.

AUTHOR
======

Daniel Mita <noreply@dango.space>

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Daniel Mita

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

