package Dist::Zilla::PluginBundle::CJFIELDS;

# ABSTRACT: Build your modules like CJFIELDS

use Moose 1.0;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool Str ArrayRef);
use namespace::autoclean;

extends qw(Dist::Zilla::PluginBundle::FLORA);

has '+authority'    => ( default     => 'cpan:CJFIELDS');

has '+github_user'  => ( default     => 'cjfields' );

has 'create_readme' => (
    isa         => Bool,
    is          => 'ro',
    default     => 1
);

has 'use_module_build'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 1
);

has 'use_next_release'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 1
);

override 'configure' => sub {
    my $self = shift;

    my @filtered;
    push @filtered, 'Readme' if !$self->create_readme;
    push @filtered, 'MakeMaker' if $self->use_module_build;

    if (@filtered) {
        $self->add_bundle('@Filter' => {-bundle   => '@Basic',
                                        -remove   => \@filtered});
    } else {
        $self->add_bundle('@Basic');
    }

    $self->add_plugins(qw(
                       MetaConfig
                       MetaJSON
                       PkgVersion
                       PodSyntaxTests
                       NoTabsTests
                       CompileTests
                       ))
                       ;

    $self->add_plugins(
        [MetaResources => {
            'repository.type'   => $self->repository_type,
            'repository.url'    => $self->repository_url,
            'repository.web'    => $self->repository_web,
            'bugtracker.web'    => $self->bugtracker_url,
            'bugtracker.mailto' => $self->bugtracker_email,
            'homepage'          => $self->homepage_url,
        }],
        [Authority => {
            authority   => $self->authority,
            do_metadata => 1,
        }],
        [EOLTests => {
            trailing_whitespace => 1,
        }],
    );

    $self->add_plugins('ModuleBuild') if $self->use_module_build;
    $self->add_plugins('PodCoverageTests') if !$self->disable_pod_coverage_tests;
    $self->add_plugins('NextRelease') if $self->use_next_release;

    $self->add_plugins('AutoPrereqs') if $self->auto_prereqs;
};

__PACKAGE__->meta->make_immutable;

1;
