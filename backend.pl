#!/usr/bin/env perl

use strict;
use warnings;
use Mojolicious::Lite;
use Fun::Game;

get '/home' => sub {
    my $self = shift;
    $self->render( 'home' );
};

get '/set/sentence' => sub {
    my $self        = shift;
    my $sentence    = $self->param( 'sentence' );
    my $user        = Fun::Game->new;
    $user->set_sentence( sentence => $sentence );
    $self->render( text => $sentence );
};

get '/check/guess' => sub {
    my $self       = shift;
    my $guess      = $self->param( 'guess' );
    my $user       = Fun::Game->new;
    my $result     = $user->check_sentence( guess => $guess );
    $self->render( text => $result );
};

get '/solve' => sub {
    my $self = shift;
    my $solve = $self->param( 'solve' );
    my $user = Fun::Game->new;
    my $response = $user->solve_puzzle(
        solve => $solve
    );
    $self->render( text => $response );
};

get '/homejs' => sub {
    my $self  = shift;
    $self->render( 'homejs' );
};

get '/restart' => sub {
    my $self = shift;
    my $user = Fun::Game->new;
    $user->restart;
    $self->render( text => 'table destroyed' );
};

app->start;


__DATA__

@@ homejs.html.ep

jQuery(document).ready(function() {
    function restart () {
        jQuery.get('http://localhost:3000/restart', function() {} );
    }
    function check_tries(tries) {
        if ( tries == 0 ) {
            alert( 'you lost' );
            restart();
            window.location.reload();
        }
    }
    var topic = prompt('Topic: ');
    var sentence = prompt('Sentence: ');
    var tries = 6;
    restart();
    jQuery('#guess').focus();
    jQuery('#topic').append(topic);
    jQuery('#tries').append(tries+' ');
    jQuery.get('http://localhost:3000/set/sentence?sentence='+sentence,
    function(response) {
        var letters = response.split( '' );
        var letter_count = response.length;
        for (var i = 0;i < letter_count;i++) {
            if ( letters[i] == ' ' ) {
                jQuery('#sentence').append( '</br>' );
            }
            else {
                jQuery('#sentence').append(
                    '<input disabled="disabled" class="'+letters[i]+'" style="width: 15px" maxlength="1" type="text"></input>'
                );
            }
        }
    });
    jQuery('#submit').click(function() {
        var guess = jQuery('#guess').val();
        jQuery.get('http://localhost:3000/check/guess?guess='+guess,
        function(letter) {
            jQuery('.'+letter).removeAttr('disabled')
                .val(letter)
                .attr('disabled', 'disabled');
            jQuery('#guess').focus();
            jQuery('#guess').val('');
            if ( letter == 'wrong' ) {
                jQuery('#guess').val('');
                jQuery('#guess').focus();
            }
        });
        tries -= 1;
        jQuery('#tries').append(tries+' ');
        check_tries(tries);
    });
    jQuery('#submit_solve').click(function() {
        var solve = jQuery('#solve').val();
        jQuery.get('http://localhost:3000/solve?solve='+solve,
        function(response) {
            if ( response == 'winner' ) {
                alert(response);
                window.location.reload();
            }
            else {
                alert('No. Nothing could be any further from the answer');
                tries -= 1;
                jQuery('#tries').append(tries+' ');
                jQuery('#solve').val('');
                check_tries(tries);
                jQuery('#guess').focus();
            }
        });
    });
    jQuery('#restart').click(function() {
        restart();
        window.location.reload();
    });
});

@@ home.html.ep

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>MojoVicious</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <!-- TODO: add bootstrap or boottheme generated css file beow -->
    <link href="/boottheme.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
      .sidebar-nav {
        padding: 9px 0;
      }
    </style>
    <link href="http://twitter.github.com/bootstrap/assets/css/bootstrap-responsive.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Fav and touch icons -->
    <link rel="shortcut icon" href="../assets/ico/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png">
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="/home">MojoVicious</a>
          <div class="nav-collapse collapse">
            <p class="navbar-text pull-right">
              Logged in as <a href="#" id="user_disp" class="navbar-link">Username</a>
            </p>
            <ul class="nav">
              <li class="active"><a href="#">Home</a></li>
              <li id="sign_in"><a href="#">Sign-In</a></li>
              <li><a href="mailto:james.albert72@gmail.com" target="_blank">Contact</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span9">
          <div class="hero-unit">
            <h1>Hangman</h1>
            <p>test your hangman skills</p>
          </div>
          <div class="row-fluid">
            <div class="span4">
              <h2>Hangman</h2>
                <div>number of tries</div><p id="tries"> </p>
                <h5 id="topic"></h5>
                <input maxlength="1" id="guess" type="text"></input>
                <button id="submit" type="button">Guess</button></br>
                <input id="solve" type="text"></input>
                <button id="submit_solve" type="button">Solve</button>
                <div id="sentence"></div>
                <button id="restart" type="button">Restart</button>
                <div id="tips"></div>
            </div><!--/span-->
          </div><!--/row-->
        </div><!--/span-->
      </div><!--/row-->

      <hr>

      <footer>
        <p>&copy; James Albert 2012</p>
      </footer>

    </div><!--/.fluid-container-->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
    <script src="https://raw.github.com/carhartl/jquery-cookie/master/jquery.cookie.js"></script>
    <script src="http://twitter.github.com/bootstrap/assets/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/MochiKit-1.4.2/lib/MochiKit/MochiKit.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Base.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Layout.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/Canvas.js"></script>
    <script type="text/javascript" src="/plotkit-0.9.1/PlotKit/SweetCanvas.js"></script>
    <script src="/homejs"></script>
  </body>
</html>
