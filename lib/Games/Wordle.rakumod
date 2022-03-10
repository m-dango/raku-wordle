my role X::Games::Wordle is Exception {}

my class X::Games::Wordle::InvalidGuess does X::Games::Wordle {
	has $.guess is required;
	has Str $.reason;

	method message {
		“｢$.guess｣ is not a valid guess.{ “ $_” with $.reason }”
	}
}

my class X::Games::Wordle::GameOver does X::Games::Wordle {
	method message {
		'Game over.';
	}
}

class Games::Wordle:ver<0.0.3> {
	has Int    $.number = Date.today - Date('2021-06-19');
	has Str    $.answer;
	has        @.valid-inputs is Set;
	has UInt:D $.guess-limit = 6;

	has Pair:D @!guesses;
	has Bool:D $!finished = False;
	has Bool:D $!solved   = False;

	has $.correct-tile = '🟩';
	has $.present-tile = '🟨';
	has $.absent-tile  = '⬜';

	submethod TWEAK {
		if $!answer {
			$!number = Nil;
		}
		orwith %?RESOURCES<answers.txt> {
			given .lines -> @lines {
				given +@lines {
					$!number = $!number % $_ || $_;
				}
				$!answer = @lines[$!number - 1];
			}
		}
		else {
			$!answer = 'CAMEL';
			$!number = Nil;
		}
		$!answer.=uc;

		@!valid-inputs :=
			( $!answer ∪ (@!valid-inputs || %?RESOURCES<words.txt>.lines) )
			.keys
			.map({ $^word.chars == $!answer.chars ?? $word.uc !! Empty })
			.Set;
	}

	method Str {
		return @!guesses.gist;
	}

	proto method guess ( Str:D $guess ) {
		if $!finished or @!guesses >= $!guess-limit {
			return fail X::Games::Wordle::GameOver.new;
		}

		if $guess ne $guess.uc {
			return self.&samewith($guess.uc);
		}

		return {*};
	}

	multi method guess ( $guess where *.chars != $.answer.chars --> Failure ) {
		X::Games::Wordle::InvalidGuess.new( :$guess, :reason("Expected guess length is $!answer.chars().") ).fail;
	}

	multi method guess ( $guess where * ∉ $.valid-inputs --> Failure ) {
		X::Games::Wordle::InvalidGuess.new( :$guess, :reason('Guess does not match valid inputs.') ).fail;
	}

	multi method guess ( $guess ) {
		my @tiles;
		if $guess eq $.answer {
			@tiles     = $.correct-tile xx $.answer.chars;
			$!finished = True;
			$!solved   = True;
		}
		else {
			my @remains is BagHash;
			my @answer-chars = $.answer.comb;
			my @guess-chars  = $guess.comb;
			for @answer-chars.pairs {
				if .value eq @guess-chars[.key] {
					@tiles[.key] = $.correct-tile;
				}
				else {
					@remains{.value}++;
				}
			}

			for ^$guess.chars -> $i {
				if !@tiles[$i].defined {
					my $char = @guess-chars[$i];
					if $char ∈ @remains {
						@tiles[$i] = $.present-tile;
					}
					else {
						@tiles[$i] = $.absent-tile;
					}
					@remains{$char}--;
				}
			}
		}

		@!guesses.push($guess => @tiles.List);

		if @!guesses >= $.guess-limit {
			$!finished = True;
		}

		return @tiles.List;
	}

	method hard-mode ( --> False ) {}

	method result {
		if $!finished {
			return "Wordle { $!number // '#' } { $!solved ?? +@!guesses !! 'X' }/$!guess-limit"
				~ "{ '*' if $.hard-mode }\n"
				~ @!guesses.map(*.value.join).join("\n");
		}
		return Nil;
	}
}

=begin pod

=head1 NAME

Games::Wordle - Wordle in Raku

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

Games::Wordle is a Raku implementation of the game Wordle, hosted by The New York Times at L<https://www.nytimes.com/games/wordle/index.html>

Games::Wordle uses the same word list and daily answers as the NYT version by default.
You may also customize the game by providing your own answer, list of valid inputs, or number of guesses
via the C<new> method with the options C<:answer>, C<:valid-inputs>, and C<:guess-limit>.
The tiles can also be changed with the C<:correct-tile>, C<:present-tile>, and C<:absent-tile> options.

The class is intended to be flexible, allowing for constructing Wordle variants with options via the `new` method.

=head1 AUTHOR

Daniel Mita <noreply@dango.space>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Daniel Mita

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
