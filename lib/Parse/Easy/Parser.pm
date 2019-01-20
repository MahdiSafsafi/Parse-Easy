#!/usr/bin/perl

#BEGIN_HEADER
#
# Module Parse/Easy/Parser.pm Copyright (C) 2018-2019 Mahdi Safsafi.
#
# https://github.com/MahdiSafsafi/Parse-Easy
#
# See licence file 'LICENCE' for use and distribution rights.
#
#END_HEADER

package Parse::Easy::Parser;
use strict;
use warnings;
use feature qw(say);
use Data::Dump qw(pp);
use Parse::Easy::Rule;
use Parse::Easy::Term;
use Parse::Easy::NoTerm;
use Parse::Easy::Epsilon;
use Parse::Easy::XObject;
use Parse::Easy::Code;
use Parse::Easy::Parser::Closure;
use Parse::Easy::Parser::Kernel;
use Parse::Easy::Parser::State;
use Parse::Easy::Parser::Exporter;
use Parse::Easy::ReturnType;
use Parse::Easy::Utils qw(sameItems elapsed);
use Parse::Easy::Target::Pascal::Parser;

my $RULE_CLASS        = 'Parse::Easy::Rule';
my $XOBJECT_CLASS     = 'Parse::Easy::XObject';
my $TERM_CLASS        = 'Parse::Easy::Term';
my $NOTERM_CLASS      = 'Parse::Easy::NoTerm';
my $CLOSURE_CLASS     = 'Parse::Easy::Parser::Closure';
my $KERNEL_CLASS      = 'Parse::Easy::Parser::Kernel';
my $STATE_CLASS       = 'Parse::Easy::Parser::State';
my $EXPORTER_CLASS    = 'Parse::Easy::Parser::Exporter';
my $EPSILON_CLASS     = 'Parse::Easy::Epsilon';
my $RETURN_TYPE_CLASS = 'Parse::Easy::ReturnType';

sub new {
	my ($class) = @_;
	my $self = {
		lexer           => undef,
		names           => {},
		axiom           => undef,
		rules           => [],
		allRules        => [],
		firsts          => {},
		follows         => {},
		kernels         => [],
		states          => [],
		tokens          => {},
		counts          => {},
		codes           => [],
		name            => undef,
		rcfile          => undef,
		resfile         => undef,
		binfile         => undef,
		verbosityfile   => undef,
		unitname        => undef,
		classname       => undef,
		unitfile        => undef,
		parentunitname  => 'Parse.Easy.Parser.LR1',
		parentclassname => 'TLR1',
		returnTypes     => [],
		rule2type       => {},
		units           => [],
		ruleNames       => {},
	};
	bless $self, $class;
	$self;
}

sub name {
	my ( $self, $value ) = @_;
	if ( defined $value ) {
		$self->{name}      = $value;
		$self->{classname} = sprintf "T%s", $value;
		$self->{unitname}  = sprintf "%s", $value;
		$self->{unitfile}  = sprintf "%s.%s", $value, 'pas';

		$self->{rcfile}        = sprintf "%s.%s", $value, 'rc';
		$self->{resfile}       = sprintf "%s.%s", $value, 'res';
		$self->{binfile}       = sprintf "%s.%s", $value, 'binary';
		$self->{verbosityfile} = sprintf "%s.%s", $value, 'verbosity';
	}
	$value;
}

sub addUnit {
	my ( $self, $name ) = @_;
	foreach my $unit ( @{ $self->{units} } ) {
		$unit eq $name and return 0;
	}
	push @{ $self->{units} }, $name;
}

sub registerCode {
	my ( $self, $code ) = @_;
	$code->{index} = scalar @{ $self->{codes} };
	push @{ $self->{codes} }, $code;
}

sub addRule {
	my ( $self, $rule ) = @_;
	$rule->{grammar} = $self;
	push @{ $self->{rules} },    $rule;
	push @{ $self->{allRules} }, $rule;
}

sub addInternalRule {
	my ( $self, $rule ) = @_;
	$rule->internal(1);
	$self->addRule($rule);
}

sub parenthesis {
	my ( $self, $rhss ) = @_;
	my $name     = '_rule' . ++$self->{counts}->{_rule};
	my $callback = Parse::Easy::NoTerm->new($name);
	foreach my $rhs (@$rhss) {
		$self->addInternalRule( Parse::Easy::Rule->new( $name, $rhs ) );
	}
	$callback;
}

sub plus {
	my ( $self, $element ) = @_;
	my $name     = '_plus' . ++$self->{counts}->{_plus};
	my $callback = Parse::Easy::NoTerm->new($name);

	my $rule = Parse::Easy::Rule->new( $name, [ $callback, $element ] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	my $action = Parse::Easy::Code->new('TList($1).Add($2); $$ := $1;');
	$self->registerCode($action);
	$rule->{action} = $action;

	$rule = Parse::Easy::Rule->new( $name, [$element] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	$action = Parse::Easy::Code->new('$$ := CreateNewList(); $$.Add($1);');
	$self->registerCode($action);
	$rule->{action} = $action;
	$callback;
}

sub star {
	my ( $self, $element ) = @_;
	my $name     = '_star' . ++$self->{counts}->{_star};
	my $callback = Parse::Easy::NoTerm->new($name);

	my $rule = Parse::Easy::Rule->new( $name, [ $callback, $element ] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	my $action = Parse::Easy::Code->new('TList($1).Add($2); $$ := $1;');
	$self->registerCode($action);
	$rule->{action} = $action;

	$rule = Parse::Easy::Rule->new( $name, [] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	$action = Parse::Easy::Code->new('$$ := CreateNewList();');
	$self->registerCode($action);
	$rule->{action} = $action;
	$callback;
}

sub question {
	my ( $self, $element ) = @_;
	my $name     = '_question' . ++$self->{counts}->{_question};
	my $callback = Parse::Easy::NoTerm->new($name);

	my $rule = Parse::Easy::Rule->new( $name, [$element] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	my $action = Parse::Easy::Code->new('$$ := CreateNewList(); $$.Add($1);');
	$self->registerCode($action);
	$rule->{action} = $action;

	$rule = Parse::Easy::Rule->new( $name, [] );
	$rule->returnType('TList');
	$self->addInternalRule($rule);
	$action = Parse::Easy::Code->new('$$ := nil;');
	$self->registerCode($action);
	$rule->{action} = $action;
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
	$result;
}

sub addActionRule {
	my ( $self, $code ) = @_;
	my $name     = '_action' . ++$self->{counts}->{_action};
	my $callback = Parse::Easy::NoTerm->new($name);
	my $rule     = Parse::Easy::Rule->new( $name, [] );
	$rule->internal(1);
	$rule->{action} = $code;
	$self->registerCode($code);
	$self->addInternalRule($rule);
	$callback;
}

sub findSymbols {
	my ( $self, $name ) = @_;
	my @result = ();
	foreach my $rule ( @{ $self->{allRules} } ) {
		$rule->name() ne $name and next;
		push @result, $rule;
	}
	@result;
}

sub addAugmentedRule {
	my ($self) = @_;
	my $realAxiom = $self->{axiom} // return;
	my $rule = $RULE_CLASS->new( '_axiom', [ $NOTERM_CLASS->new( $realAxiom->{name} ), $TERM_CLASS->new('EOF') ] );
	unshift @{ $self->{rules} },    $rule;
	unshift @{ $self->{allRules} }, $rule;
	$self->{axiom}   = $rule;
	$rule->{grammar} = $self;
	$rule->accept(1);
	$rule;
}

sub fixCode {
	my ( $self, $rule ) = @_;
	return unless ( $rule->{action} );
	my $count = scalar @{ $rule->{items} };
	my $code  = $rule->{action}->{code};
	my @vars  = $code =~ /\$(\d+)/g;
	my @items = @{ $rule->{items} };
	foreach my $item (@vars) {
		my $old     = $item;
		my $element = $items[ $old - 1 ];
		my $type    = 'Pointer';
		if ($element) {
			if ( $element->type() eq 'noterm' ) {
				$type = $self->{rule2type}->{ $element->name() } // 'Pointer';
			}
			elsif ( $element->type() eq 'term' ) {
				$type = 'TToken';
			}
		}
		$type =~ s/^T//;
		my $new = $count - $old;
		$code =~ s/\$\Q$old\E/PValue(Values[Values.Count - 1 - $new])^.As$type/;
	}
	my $type = $rule->returnType() // 'Pointer';
	$type =~ s/^T//;
	$code =~ s/\$\$/ReturnValue^.As$type/g;
	$rule->{action}->{code} = $code;
}

sub registerReturnType {

	# RemoveMe
	my ( $self, $rule ) = @_;
	my $type = $rule->{returnType};
	$type = $RETURN_TYPE_CLASS->new( $type // 'Pointer' );
	$self->{rule2type}->{ $rule->{name} } = $type->{value};
	my $out = undef;
	foreach my $item ( @{ $self->{returnTypes} } ) {
		if ( $item->same($type) ) {
			$out = $item;
			last;
		}
	}
	unless ($out) {
		$type->{index} = scalar @{ $self->{returnTypes} };
		push @{ $self->{returnTypes} }, $type;
	}
	else {
		$type->{index} = $out->{index};
	}
	$rule->{returnType} = $type;
}

sub processRules {
	my ($self) = @_;
	foreach my $rule ( @{ $self->{allRules} } ) {
		$self->{ruleNames}->{ $rule->name() }++;
		!$rule->internal() and $self->{axiom} //= $rule;
		$rule->axiom() and $self->{axiom} = $rule;
		my @items = ();
		for my $i ( 0 .. scalar @{ $rule->{items} } - 1 ) {
			my $item = $rule->{items}->[$i];
			if ( $item->type() eq 'code' ) {
				if ( $i != scalar @{ $rule->{items} } - 1 ) {
					$item = $self->addActionRule($item);
				}
				else {
					$rule->{action} = $item;
					$self->registerCode($item);
					next;
				}
			}
			push @items, $item;
		}
		$rule->{items} = \@items;
		$self->{rule2type}->{ $rule->{name} } = $rule->{returnType} // 'Pointer';
		unless ( scalar @{ $rule->{items} } ) {
			my $item = $EPSILON_CLASS->new('EPSILON');
			push @{ $rule->{items} }, $item;
		}
	}
	$self->addAugmentedRule();
	my $index  = 0;
	my $id     = 0;
	my $tokens = $self->{tokens};
	foreach my $rule ( @{ $self->{allRules} } ) {
		$self->fixCode($rule);
		my $name = $rule->name();
		$rule->index( $index++ );
		exists $tokens->{$name} or $tokens->{$name} = $id++;
		$rule->id( $tokens->{$name} );
		my @items = @{ $rule->{items} };
		foreach my $item (@items) {
			if ( $item->type() eq 'noterm' ) {
				my $itemName = $item->name();
				exists $self->{ruleNames}->{$itemName}
				  or die sprintf "rule '%s' uses undeclared no-terminal '%s'", $name, $itemName;
			}
			elsif ( $item->type() eq 'term' ) {
				my $itemName = $item->name();
				exists $self->{lexer}->{tokens}->{$itemName}
				  or die sprintf "rule '%s' uses undeclared terminal '%s'", $name, $itemName;
			}
		}
	}
}

sub dereference {
	my ( $self, $hash ) = @_;

	# firsts/follows up to this point may contain
	# reference to other rules. so we need to
	# resolve all dependencies.
	# for example:
	# E -> T
	# T -> N
	# N -> term
	# here first(E) = first(T) = first(N) = term.

	# as you can see, rule E has dependencies to others rules(T,N).
	# so for each reference found, we dereference it.
  DEREFERENCE:
	my $notDone = 0;
	foreach my $key ( keys %{$hash} ) {
		my $array      = $hash->{$key};
		my $needUpdate = 0;
		my %seen       = ();
		for ( my $i = 0 ; $i < scalar @$array ; ++$i ) {
			my $item = $array->[$i] // next;
			$item->type() ne 'xobject' and next;
			$seen{$item}++ and next;
			$notDone++;
			$needUpdate++;

			# dereferencing to array:
			$_ && $_->addUniqueTo($array) foreach ( @{ $item->{xobject} } );

			# remove current reference:
			# this must be last statement, so when dereferencing to array
			# we can skip already existed reference and avoid deep requisition.
			$array->[$i] = undef;
		}
		if ($needUpdate) {
			@$array = grep defined, @$array;
			$hash->{$key} = $array;
		}
	}

	# keep dereferencing until there is no reference.
	$notDone && goto DEREFERENCE;
}

sub buildFirsts {
	my ($self) = @_;
	foreach my $rule ( @{ $self->{allRules} } ) {
		my $name  = $rule->name();
		my $array = $self->{firsts}->{$name} //= [];
		my $first = $rule->{items}->[0] // next;
		if ( $first->type() eq 'term' ) {
			$first->addUniqueTo($array);
		}
		elsif ( $first->type() eq 'epsilon' ) {
			$first->addUniqueTo($array);
		}
		else {
			my $holder = $self->{firsts}->{ $first->{name} } //= [];
			my $xobject = $XOBJECT_CLASS->new($holder);
			$xobject->addUniqueTo($array);
		}
	}
	$self->dereference( $self->{firsts} );
}

sub findEpsilonRules {
	my ( $self, $name, $array, $seen ) = @_;
	$seen //= {};
	my @symbols = $self->findSymbols($name);
	foreach my $rule (@symbols) {
		$seen->{$rule}++ and next;
		my $first = $rule->{items}->[0];
		if ( $first->type() eq 'epsilon' ) {
			push @$array, $rule;
		}
		elsif ( $first->type() eq 'noterm' ) {
			$self->findEpsilonRules( $first->{name}, $array, $seen );
		}
	}
}

sub buildFollows {
	my ($self) = @_;
	my $axiom = $self->{axiom} // return;
	$self->{follows}->{ $axiom->{name} } = [ $axiom->{items}->[1] ];

	my @rules = @{ $self->{allRules} };
	foreach my $rule (@rules) {
		my @items    = @{ $rule->{items} };
		my $ruleName = $rule->{name};
		for my $i ( 0 .. scalar @items - 1 ) {
			my $item = $items[$i];
			my $next = $items[ $i + 1 ];
			$item->type() =~ /^(term|epsilon)$/ and next;
			my $name = $item->{name};
			my $array = $self->{follows}->{$name} //= [];
			if ( defined $next ) {
				if ( $next->type() eq 'term' ) {
					$next->addUniqueTo($array);
				}
				elsif ( $next->type() eq 'epsilon' ) {
					die;
				}
				else {
					my $name = $next->{name};

					my @firsts = @{ $self->{firsts}->{$name} };
					foreach my $first (@firsts) {
						if ( $first->type() eq 'epsilon' ) {
							my $holder = $self->{follows}->{$name} //= [];
							my $xobject = $XOBJECT_CLASS->new($holder);
							$xobject->addUniqueTo($array);
							my @epsilons = ();
							$self->findEpsilonRules( $name, \@epsilons );
							foreach my $epsilon (@epsilons) {
								my $holder = $self->{follows}->{ $epsilon->{name} } //= [];
								my $xobject = $XOBJECT_CLASS->new($holder);
								$xobject->addUniqueTo($array);

							}
						}
						else {
							$first->addUniqueTo($array);
						}
					}
				}
			}
			else {

				my $holder = $self->{follows}->{$ruleName} //= [];
				my $xobject = $XOBJECT_CLASS->new($holder);
				$xobject->addUniqueTo($array);
			}

			# ---------------------

			# ---------------------

		}
	}

	$self->dereference( $self->{follows} );
}

sub buildKernels {
	my ($self) = @_;
	$self->{axiom} // return;

	# build starting kernel k0:
	my @closures = ();

	# k0 drivers:
	push @closures, $CLOSURE_CLASS->new( $self->{axiom}, 0 );
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
		my @items    = @{ $closure->{rule}->{items} };
		my $current  = $items[$dotIndex] // next;
		$current->type() ne 'noterm' and next;
		my @symbols = $self->findSymbols( $current->{name} );
		foreach my $symbol (@symbols) {
			my $newClosure = $CLOSURE_CLASS->new( $symbol, 0 );
			$newClosure->addUniqueTo( $kernel->{closures} );
		}
	}
}

sub addTransition {
	my ( $self, $table, $key, $closures ) = @_;
	my $added = 0;
	foreach my $item (@$table) {
		if ( $item->{key}->same($key) ) {
			$added |= $_->addUniqueTo( $item->{closures} ) foreach @$closures;
			return $added;
		}
	}
	push @$table,
	  {
		key      => $key,
		closures => $closures,
	  };
}

sub findKernelByDrivers {
	my ( $self, $closures ) = @_;
	for my $i ( 0 .. scalar @{ $self->{kernels} } - 1 ) {
		my $kernel = $self->{kernels}->[$i];
		sameItems( $kernel->{drivers}, $closures, 0 ) and return $kernel;
	}
	undef;
}

sub buildGotos {
	my ( $self, $kernel ) = @_;
	my @transition = ();
	for ( my $i = 0 ; $i < scalar @{ $kernel->{closures} } ; ++$i ) {
		my $closure  = $kernel->{closures}->[$i];
		my $next     = $closure->nextClosure() // next;
		my $dotIndex = $closure->{dotIndex};
		my $item     = $closure->{rule}->{items}->[$dotIndex] // next;
		$self->addTransition( \@transition, $item, [$next] );
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

sub buildStates {
	my ($self) = @_;
	foreach my $kernel ( @{ $self->{kernels} } ) {
		my $state = $STATE_CLASS->new($kernel);
		push @{ $self->{states} }, $state;
	}
}

sub dumpStates {
	my ( $self, $fh ) = @_;
	printf $fh "States:\n";
	printf $fh "-------\n";
	printf $fh "%s\n", $_->toString() foreach ( @{ $self->{states} } );
	printf $fh "\n\n";
}

sub dumpFirsts {
	my ( $self, $fh ) = @_;
	printf $fh "Firsts:\n";
	printf $fh "-------\n";
	foreach my $name ( sort keys %{ $self->{firsts} } ) {
		my @array = ();
		foreach my $item ( @{ $self->{firsts}->{$name} } ) {
			push @array, $item->toString();
		}
		my $array = join( ', ', @array );
		printf $fh "  %-10s = [%s]\n", $name, $array;
	}
	printf $fh "\n\n";
}

sub dumpFollows {
	my ( $self, $fh ) = @_;
	printf $fh "Follows:\n";
	printf $fh "-------\n";
	foreach my $name ( sort keys %{ $self->{follows} } ) {
		my @array = ();
		foreach my $item ( @{ $self->{follows}->{$name} } ) {
			push @array, $item->toString();
		}
		my $array = join( ', ', @array );
		printf $fh "  %-10s = [%s]\n", $name, $array;
	}
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

	#$self->dumpSummary($fh);
	$self->dumpRules($fh);
	$self->dumpFirsts($fh);
	$self->dumpFollows($fh);
	$self->dumpStates($fh);

	close $fh;
}

sub process {
	my ($self) = @_;
	printf "processing parser:\n";
	printf " - processing rules...\n";
	$self->processRules();
	printf " - building firsts...\n";
	$self->buildFirsts();
	printf " - building follows...\n";
	$self->buildFollows();
	printf " - building kernels...\n";
	$self->buildKernels();
	printf " - building states...\n";
	$self->buildStates();
	printf " - building verbosity...\n";
	$self->buildVerbosity();
	printf " - exporting parser...\n";
	my $exporter = $EXPORTER_CLASS->new($self);
	$exporter->generate();
	printf " - building target file...\n";
	my $output = Parse::Easy::Target::Pascal::Parser->new($self);
	$output->generate();
	printf "\n\n";
}
1;
