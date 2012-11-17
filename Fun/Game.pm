package Fun::Game;

use strict;
use warnings;
use DBI;

sub new {
    my ( $class, %opts ) = @_;
    my $self = {};
    return bless $self, $class;
}

sub set_sentence {
    my ( $self, %opts ) = @_;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=gamedb'
    );
    my $sth = $dbh->prepare(
        "insert into game values( null, \"$opts{sentence}\" );"
    );
    $sth->execute;
    $dbh->disconnect;
}

sub check_sentence {
    my ( $self, %opts ) = @_;
    my $right_guesses;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=gamedb'
    );
    my $sentence_list = $dbh->selectall_arrayref(
        'select sentence from game;', { Slice => {} }
    );
    $dbh->disconnect;
    my @sentence;
    foreach my $answer ( @{$sentence_list} ) {
        push @sentence, $answer->{sentence};
    }
    my @letter_array = split( '', $sentence[0] );
    my $letter_string;
    foreach my $letter ( @letter_array ) {
        if ( $letter eq $opts{guess} ) {
            return $letter;
            last;
        }
    }
    return 'wrong';
}

sub solve_puzzle {
    my ( $self, %opts ) = @_;
    my $key;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=gamedb'
    );
    my $sentence = $dbh->selectall_arrayref(
        'select sentence from game;', { Slice => {} }
    );
    foreach my $answer ( @{$sentence} ) {
        $key .= $answer->{sentence};
    }
    return 'winner' if $opts{solve} eq $key;
    return 'loser' if $opts{solve} ne $key;
}

sub restart {
    my ( $self, %opts ) = @_;
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=gamedb'
    );
    my $sth = $dbh->prepare(
        "delete from game;"
    );
    $sth->execute;
    $dbh->disconnect;
}

1;
