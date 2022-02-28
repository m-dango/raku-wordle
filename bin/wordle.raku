#!/usr/bin/env raku

use Games::Wordle;

my Games::Wordle $wordle.=new;

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
