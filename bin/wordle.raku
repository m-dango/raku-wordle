#!/usr/bin/env raku

use Games::Wordle;

multi MAIN (Int:D $number) { samewith(:$number) }

multi MAIN (
	IntStr :n(:$number), #= Specify which daily Wordle to attempt.
) {
	my Games::Wordle $wordle.=new(
		|(:$number if $number.defined && $number.chars),
	);

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
}
