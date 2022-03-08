#!/usr/bin/env raku

use Games::Wordle;

subset Number of Str where !.defined || (.Int.so && .Int > 0);

unit sub MAIN (Number :$number);

my Games::Wordle $wordle.=new: |do :number(.Int) with $number;

"Wordle $wordle.number()\nEnter your guess:".say;

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
		''.say;
		exit;
	}
}

"\n$wordle.answer()\n\n$wordle.result()".say;
