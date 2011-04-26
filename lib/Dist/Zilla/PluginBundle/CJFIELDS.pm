package Dist::Zilla::PluginBundle::CJFIELDS;

# ABSTRACT: Build your modules like CJFIELDS

use Moose 2.0;
use namespace::autoclean;

# for now this just extends FLORA's PluginBundle, but I'll likely strip this
# down for my own purposes

extends qw(Dist::Zilla::Plugin::FLORA);

has '+authority'    => (default => 'cpan:CJFIELDS');

has '+github_user'  => ( default => 'cjfields');

__PACKAGE__->meta->make_immutable;

1;
