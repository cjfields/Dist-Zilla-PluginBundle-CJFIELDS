package Dist::Zilla::PluginBundle::CJFIELDS;

use Moose 2.0;
use namespace::autoclean;
use Dist::Zilla;

with 'Dist::Zilla::Role::PluginBundle::Easy';

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Dist::Zilla::PluginBundle::CJFIELDS - my Dist::Zilla plugins

=head1 SYNOPSIS

In dist.ini:

   [@CJFIELDS]

=head1 DESCRIPTION

My L<Dist::Zilla> plugin bundle.  Probably replicates a few others out there,
if so it'll probably be relegated to the scrap heap.  But hey, I at least
am learning to use Dist::Zilla, amiright?

=head1 DEPENDENCIES

To Be Added...

=head1 AUTHOR

Chris Fields  C<< <cjfields at bioperl dot org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011 Chris Fields (cjfields at bioperl dot org). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
