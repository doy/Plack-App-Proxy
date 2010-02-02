use strict;
use warnings;
use Plack::App::Proxy;
use Plack::Middleware::Proxy::Reproxy;
use Test::More;
use t::Runner;

test_proxy(
  proxy => sub {
      Plack::Middleware::Proxy::Reproxy->wrap(
          Plack::App::Proxy->new(remote => "http://$_[0]:$_[1]/"),
      ),
  },
  app   => sub {
      my $env = shift;
      if ($env->{PATH_INFO} eq '/reproxied') {
          return [ 200, [], [ "Reproxied!" ] ];
      } else {
          return [ 200, [ "X-Reproxy-URL" => "http://$env->{HTTP_HOST}/reproxied" ], [ "Hi" ] ];
      }
  },
  client => sub {
    my $cb = shift;
    my $req = HTTP::Request->new(GET => "http://localhost/");
    my $res = $cb->($req);
    is $res->content, 'Reproxied!';
  },
);

done_testing;
