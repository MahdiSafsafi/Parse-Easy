#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Lexer.pm Copyright (C) 2018 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Lexer;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Rule;
use Parse::Easy::Lexer::Kernel;
use Parse::Easy::Lexer::State;
use Parse::Easy::Lexer::Closure;
use Parse::Easy::Utils qw(sameItems elapsed);
use Time::HiRes;
use Parse::Easy::Target::Pascal::Lexer;
use Parse::Easy::Lexer::Compiler;
use Set::IntSpan;
use List::Util qw(min max uniq);

my $KERNEL_CLASS  = 'Parse::Easy::Lexer::Kernel';
my $STATE_CLASS   = 'Parse::Easy::Lexer::State';
my $CLOSURE_CLASS = 'Parse::Easy::Lexer::Closure';

sub new {
	my ($class) = @_;
	my $self = {
		names           => {},
		counts          => {},
		internalRules   => [],
		rules           => [],
		allRules        => [],
		fragments       => [],
		kernels         => [],
		states          => [],
		codes           => [],
		sections        => [],
		currentSections => [],
		sectionsIndex   => {},
		tokens          => {},
		ruleNames       => {},
		name            => undef,
		rcfile          => undef,
		resfile         => undef,
		binfile         => undef,
		verbosityfile   => undef,
	};
	bless $self, $class;
	$self->currentSections( ['SECTION_DEFAULT'] );
	$self;
}

sub name {
	my ( $self, $value ) = @_;
	if ( defined $value ) {
		$self->{name}          = $value;
		$self->{rcfile}        = sprintf "%s.%s", $value, 'rc';
		$self->{resfile}       = sprintf "%s.%s", $value, 'res';
		$self->{binfile}       = sprintf "%s.%s", $value, 'binary';
		$self->{verbosityfile} = sprintf "%s.%s", $value, 'verbosity';
	}
	$value;
}

sub registerSection {
	my ( $self, $section ) = @_;
	foreach my $item ( @{ $self->{sections} } ) {
		$item->{name} eq $section and return 0;
	}
	push @{ $self->{sections} },
	  my $item = {
		name  => $section,
		index => scalar @{ $self->{sections} },
	  };
	$self->{sectionsIndex}->{$section} = $item->{index};
}

sub currentSections {
	my ( $self, $list ) = @_;
	defined $list or return $self->{currentSections};
	if ( $list != $self->{sections} ) {
		foreach my $section (@$list) {
			push @{ $self->{sections} }, $section
			  unless grep { /^\Q$section\E$/ } @{ $self->{sections} };
		}
	}
	$self->{currentSections} = $list;
}

sub addRule {
	my ( $self, $rule ) = @_;
	if ( $rule->internal ) {
		push @{ $self->{internalRules} }, $rule;
	}
	elsif ( $rule->fragment ) {
		push @{ $self->{fragments} }, $rule;
	}
	else {
		push @{ $self->{rules} }, $rule;
	}
	push @{ $self->{allRules} }, $rule;
	$rule->{sections} = $self->currentSections();
}

sub addInternalRule {
	my ( $self, $rule ) = @_;
	$rule->internal(1);
	$self->addRule($rule);
}

sub parenthesis {
	my ( $self, $rhss ) = @_;
	my $name     = '_RULE' . ++$self->{counts}->{_RULE};
	my $callback = Parse::Easy::NoTerm->new($name);
	foreach my $rhs (@$rhss) {
		$self->addInternalRule( Parse::Easy::Rule->new( $name, $rhs ) );
	}
	$callback;
}

sub plus {
	my ( $self, $element ) = @_;
	my $name     = '_PLUS' . ++$self->{counts}->{_PLUS};
	my $callback = Parse::Easy::NoTerm->new($name);
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [ $element, $callback ] ) );
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [$element] ) );
	$callback;
}

sub star {
	my ( $self, $element ) = @_;
	my $name     = '_STAR' . ++$self->{counts}->{_STAR};
	my $callback = Parse::Easy::NoTerm->new($name);
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [ $element, $callback ] ) );
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [] ) );
	$callback;
}

sub question {
	my ( $self, $element ) = @_;
	my $name     = '_QUESTION' . ++$self->{counts}->{_QUESTION};
	my $callback = Parse::Easy::NoTerm->new($name);
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [$element] ) );
	$self->addInternalRule( Parse::Easy::Rule->new( $name, [] ) );
	$callback;
}

sub ebnf {
	my ( $self, $element, $type ) = @_;
	my $result = undef;
	if ( $type & 1 ) {
		$result = $self->plus($element);
	}
	elsif ( $type & 2 ) {
		$result = $self->star($element);
	}
	elsif ( $type & 4 ) {
		$result = $self->question($element);
	}
	$type & 0x10 and $result = $self->question($result);
	$result;
}

sub findSymbols {
	my ( $self, $name ) = @_;
	my @result = ();
	foreach my $rule ( @{ $self->{allRules} } ) {
		$rule->{name} eq $name and push @result, $rule;
	}
	wantarray ? @result : \@result;
}

sub registerCode {
	my ( $self, $code ) = @_;
	$code->{index} = scalar @{ $self->{codes} };
	push @{ $self->{codes} }, $code;
}

sub processRules {
	my ($self) = @_;
	foreach my $rule ( @{ $self->{allRules} } ) {
		my @unpacked = ();
		$self->{ruleNames}->{ $rule->name() }++;
		for my $i ( 0 .. scalar @{ $rule->{items} } - 1 ) {
			my $item = $rule->{items}->[$i];
			if ( $item->type() eq 'control' ) {
				if ( $item->name() eq 'START' ) {
					$rule->start(1);
				}
				elsif ( $item->name() eq 'END' ) {
					$rule->end(1);
				}
				next;
			}
			if ( $item->type() eq 'literal' ) {
				my @sets = $item->toCharSets();
				push @unpacked, @sets;
				next;
			}
			elsif ( $item->type() eq 'code' ) {
				if ( $i == scalar @{ $rule->{items} } - 1 ) {
					$rule->{action} = $item;
					$self->registerCode($item);
					next;
				}
				else {
					warn sprintf "rule '%s' uses action in the middle.", $rule->name();
					next;

					# ImproveMe or RemoveMe
					my $name = '_ACTION_RULE' . ++$self->{counts}->{_ACTION_RULE};
					my $newRule = Parse::Easy::Rule->new( $name, [] );
					$newRule->{action} = $item;
					$self->registerCode($item);
					my $callback = Parse::Easy::NoTerm->new($name);
					$self->addInternalRule($newRule);
					push @unpacked, $callback;
					next;
				}
			}
			push @unpacked, $item;
		}

		$rule->{items} = \@unpacked;
		my @sections = @{ $rule->{sections} };
		@sections = map { $self->{sectionsIndex}->{$_} } @sections;
		my $set = Set::IntSpan->new();
		$set->U($_) foreach (@sections);
		$rule->{sections}   = $set;
		$rule->{anysection} = @sections == @{ $self->{sections} };
	}
	my $tokens = $self->{tokens};
	my $id     = 0;
	$tokens->{EOF} = $id++;
	for my $i ( 0 .. @{ $self->{rules} } - 1 ) {
		my $rule = $self->{rules}->[$i];
		$rule->index($i);
		if ( !( $rule->fragment || $rule->internal ) ) {
			my $name = $rule->name();
			exists $tokens->{$name} or $tokens->{$name} = $id++;
			$rule->id( $tokens->{$name} );
		}
	}
	foreach my $rule ( @{ $self->{allRules} } ) {
		$rule->internal() and next;
		foreach my $item ( @{ $rule->{items} } ) {
			if ( $item->type() eq 'noterm' ) {
				my $itemName = $item->name();
				exists $self->{ruleNames}->{$itemName}
				  or die sprintf "rule '%s' uses undeclared terminal '%s'", $rule->name(), $itemName;
			}
		}
	}
}

sub buildKernels {
	my ($self) = @_;

	# build starting kernel k0:
	my @closures = ();

	# k0 drivers:
	push @closures, $CLOSURE_CLASS->new( $_, 0, $_->{items} ) foreach ( @{ $self->{rules} } );
	my $k0 = $KERNEL_CLASS->new( $self, \@closures );

	# as long as there is a new kernel added
	# we build closures and gotos.
	for ( my $i = 0 ; $i < scalar @{ $self->{kernels} } ; ++$i ) {
		my $kernel = $self->{kernels}->[$i];
		$self->buildClosures($kernel);
		$self->buildGotos($kernel);
	}
}

sub buildClosures {
	my ( $self, $kernel ) = @_;

	# we keep processing until there is no new-closure.

	for ( my $i = 0 ; $i < scalar @{ $kernel->{closures} } ; ++$i ) {

		# for each starting closure, we add all closures that derives from it
		# until we see a terminal.

		my $closure  = $kernel->{closures}->[$i];
		my $dotIndex = $closure->{dotIndex};
		my @items    = @{ $closure->{items} };
		my $current  = $items[$dotIndex] // next;
		$current->type() ne 'noterm' and next;
		my @nexts   = @items[ $dotIndex + 1 .. $#items ];
		my @symbols = $self->findSymbols( $current->{name} );
		foreach my $symbol (@symbols) {

			# for each rule, create a new-closure
			# and add the remaining closure's items to the end of the new-closure's items.
			# in that way when this rule is terminated, engine will continue to
			# the original point (closure dotIndex).
			my @newItems = @{ $symbol->{items} };
			scalar @nexts and push @newItems, @nexts;
			my $newClosure = $CLOSURE_CLASS->new( $closure->{rule}, 0, \@newItems );
			$newClosure->addUniqueTo( $kernel->{closures} );
		}
	}
}

sub findKernelByDrivers {
	my ( $self, $closures ) = @_;
	for my $i ( 0 .. scalar @{ $self->{kernels} } - 1 ) {
		my $kernel = $self->{kernels}->[$i];
		sameItems( $kernel->{drivers}, $closures, 0 ) and return $kernel;
	}
	undef;
}

sub updateTransition {
	my ( $self, $table ) = @_;
	@$table = grep { !$_->{key}->empty() } @$table;
}

sub addTransition {
	my ( $self, $table, $newkey, $closures ) = @_;
	my $added = 0;

	# must clone or all next closures will be affected.
	$newkey = $newkey->clone();
	for my $i ( 0 .. scalar @$table - 1 ) {
		my $item = $table->[$i];
		my $key  = $item->{key};
		if ( $key->same($newkey) ) {

			# nothing to do ... same range. we just add new closures
			# to the existing one.
			$added |= $_->addUniqueTo( $item->{closures} ) foreach (@$closures);
			return $added;
		}
		my $interSection = $key->interSection($newkey);
		if ( !$interSection->empty() ) {

			# there is an intersection between two keys.
			# we remove that intersection from both keys
			# and we add it as a new key.
			# closures = closuresOf(key1) + closuresOf(key2).
			$key->D($interSection);
			$newkey->D($interSection);
			my @interSectionClosures = @{ $item->{closures} };
			$added |= $_->addUniqueTo( \@interSectionClosures ) foreach (@$closures);
			$added |= $self->addTransition( $table, $interSection, \@interSectionClosures );

			# add remaining range (out of the intersection) as a new key:
			$newkey->empty() or $added |= $self->addTransition( $table, $newkey, $closures );
			return $added;
		}
	}

	# new key => add it.
	push @$table,
	  {
		key      => $newkey,
		closures => $closures,
	  };
}

sub buildGotos {
	my ( $self, $kernel ) = @_;
	my @transition = ();
	for ( my $i = 0 ; $i < scalar @{ $kernel->{closures} } ; ++$i ) {
		my $closure  = $kernel->{closures}->[$i];
		my $next     = $closure->nextClosure() // next;
		my $dotIndex = $closure->{dotIndex};
		my @items    = @{ $closure->{items} };
		my $item     = $items[$dotIndex] // next;

		# skip all no-term, since their effective will come later.
		$item->type() eq 'noterm' and next;
		$self->addTransition( \@transition, $item, [$next] );
		$self->updateTransition( \@transition );
	}
	for my $i ( 0 .. scalar @transition - 1 ) {
		my $item     = $transition[$i];
		my $key      = $item->{key};
		my $closures = $item->{closures};

		# check if closures exist in some kernel
		# if so, we use the existing kernel.
		# this is important as this solve the infinite recursion
		# when using some ebnf operator such +.
		my $target = $self->findKernelByDrivers($closures)
		  || $KERNEL_CLASS->new( $self, $closures );
		$kernel->addGoTo( $key, $target, $closures );
	}
}

sub findState {
	my ( $self, $target ) = @_;
	foreach my $state ( @{ $self->{states} } ) {
		$state->same($target) and return $state;
	}
	undef;
}

sub buildStates {
	my ($self) = @_;
	for my $i ( 0 .. scalar @{ $self->{kernels} } - 1 ) {
		my $kernel   = $self->{kernels}->[$i];
		my $newState = $STATE_CLASS->new($kernel);

		# if our state already exist, we use the old one
		# this avoid adding a new state.
		my $state = $self->findState($newState);
		unless ($state) {
			$state = $newState;
			$state->index( scalar @{ $self->{states} } );
			push @{ $self->{states} }, $state;
		}

		# link state/kernel ... we need that to convert kernel to state.
		$kernel->{state} = $state;
		$state->{kernel} = $kernel;
	}
	for my $i ( 0 .. scalar @{ $self->{states} } - 1 ) {
		my $state  = $self->{states}->[$i];
		my %reduce = ();
		foreach my $goto ( @{ $state->{gotos} } ) {

			# convert target kernel to target state:
			$goto->{target} = $goto->{target}->{state};
			my $index = $goto->{target}->{index};
			push @{ $reduce{$index} }, $goto;
		}
		my @gotos = ();

		# if charsets target the same state
		# we merge them together and we form
		# one big range.
		foreach my $index ( sort keys %reduce ) {
			my $array = $reduce{$index};

			# use the first item as template:
			my $first = $array->[0];
			my $key   = $first->{key};
			$key->U( $array->[$_]->{key} ) for ( 1 .. scalar @$array - 1 );
			push @gotos, $first;
		}
		$state->{gotos} = \@gotos;
	}
}

sub dumpSummary {
	my ( $self, $fh ) = @_;
	printf $fh "Summary:\n";
	printf $fh "--------\n";
	printf $fh "Number of fragments      : %d.\n", scalar @{ $self->{fragments} };
	printf $fh "Number of user rules     : %d.\n", scalar @{ $self->{rules} };
	printf $fh "Number of internal rules : %d.\n", scalar @{ $self->{internalRules} };
	printf $fh "Number of kernels        : %d.\n", scalar @{ $self->{kernels} };
	printf $fh "Number of States         : %d.\n", scalar @{ $self->{states} };
	printf $fh "\n\n";
}

sub dumpKernels {
	my ( $self, $fh ) = @_;
	printf $fh "Kernels:\n";
	printf $fh "--------\n";
	printf $fh "%s\n", $_->toString() foreach ( @{ $self->{kernels} } );
	printf $fh "\n\n";
}

sub dumpStates {
	my ( $self, $fh ) = @_;
	printf $fh "States:\n";
	printf $fh "-------\n";
	printf $fh "%s\n", $_->toString() foreach ( @{ $self->{states} } );
	printf $fh "\n\n";
}

sub dumpRules {
	my ( $self, $fh ) = @_;
	printf $fh "Rules:\n";
	printf $fh "-------\n";
	printf $fh "%s\n", $_->toString() foreach ( @{ $self->{allRules} } );
	printf $fh "\n\n";
}

sub buildVerbosity {
	my ($self) = @_;
	my $file = $self->{verbosityfile};
	open my $fh, '>:encoding(UTF-8)', $file or die "unable to create file '$file'";
	$self->dumpSummary($fh);
	$self->dumpRules($fh);

	#$self->dumpKernels($fh);
	$self->dumpStates($fh);

	close $fh;
}

sub processSections {
	my ($self) = @_;
	my @sections = @{ $self->{sections} };
	$self->{sections} = [];
	$self->registerSection($_) foreach (@sections);
}

sub process {
	my ($self) = @_;
	printf "processing lexer:\n";
	printf " - processing sections and rules...\n";
	$self->processSections();
	$self->processRules();
	printf " - building kernels...\n";
	$self->buildKernels();
	printf " - building states...\n";
	$self->buildStates();
	printf " - building verbosity...\n";
	$self->buildVerbosity();
	printf " - compiling lexer...\n";
	my $compiler = Parse::Easy::Lexer::Compiler->new($self);
	$compiler->compile();
	printf " - building target file...\n";
	my $output = Parse::Easy::Target::Pascal::Lexer->new($self);
	$output->generate();
	printf "\n\n";
}
1;
