package Dist::Zilla::PluginBundle::CJFIELDS;

# ABSTRACT: Build your modules like CJFIELDS (not sure that's a recommendation)

use Moose 1.0;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool Str ArrayRef Any);
use namespace::autoclean;

=head1 SYNOPSIS

In dist.ini:

  [@CJFIELDS]
  dist = Distribution-Name
  repository_at = github

=head1 DESCRIPTION

This is the L<Dist::Zilla> configuration I use to build my distributions.
It is an extension of L<Dist::Zilla::PluginBundle::FLORA>, but with a few
configurable filters for my use.

With default settings, it is roughly equivalent to:

  @Basic

  [MetaConfig]
  [MetaJSON]
  [PkgVersion]
  [PodSyntaxTests]
  [PodCoverageTests]
  [NoTabsTests]
  [EOLTests]
  [NextRelease]

  [MetaResources]
  repository.type   = git
  repository.url    = git://github.com/cjfields/${lowercase_dist}
  repository.web    = http://github.com/cjfields/${lowercase_dist}
  bugtracker.web    = http://rt.cpan.org/Public/Dist/Display.html?Name=${dist}
  bugtracker.mailto = bug-${dist}@rt.cpan.org
  homepage          = http://search.cpan.org/dist/${dist}

  [Authority]
  authority   = cpan:CJFIELDS
  do_metadata = 1

  [PodWeaver]
  config_plugin = @FLORA ; using Florian's plugin here

  [AutoPrereqs]

=cut

extends qw(Dist::Zilla::PluginBundle::FLORA);

has '+authority'    => ( default     => 'cpan:CJFIELDS');

has '+github_user'  => ( default     => 'cjfields' );

has 'create_readme' => (
    isa         => Bool,
    is          => 'ro',
    default     => 1,
    trigger     => sub {
        my ($self, $val) = @_;
        if (!$val) {
            
        }
        $val
    }
);

has 'use_module_build'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 1,
);

has 'install_scripts'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 0
);

has 'scripts_dir'   =>(
    isa         => 'Str',
    is          => 'ro',
    default     => 'scripts'
);

has 'skip_build'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 0
);

has 'use_next_release'  => (
    isa         => Bool,
    is          => 'ro',
    default     => 1
);

has '_plugins_tbr'          => (
    traits      => ['Array'],
    isa         => ArrayRef[Str],
    is          => 'bare',
    init_arg    => undef,
    handles     => {
        'filter_plugin'     => 'push',
        'filtered_plugins'  => 'elements'
    }
);

has '_plugins_tba'               => (
    traits      => ['Array'],
    isa         => ArrayRef[Any],
    is          => 'bare',
    init_arg    => undef,
    handles     => {
        'add_config_plugin'     => 'push',
        'config_plugins'  => 'elements'
    }
);

override 'configure' => sub {
    my $self = shift;

    Carp::croak("Can't set both skip_build and use_module_build")
        if $self->skip_build && $self->use_module_build;

    # these need to be moved into a trigger or builder or somethin'
    my @filtered;
    push @filtered, 'Readme' if !$self->create_readme;
    push @filtered, 'MakeMaker' if $self->use_module_build;
    push @filtered, 'MakeMaker', 'ModuleBuild' if $self->skip_build;

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
            trailing_whitespace => !$self->disable_trailing_whitespace_tests,
        }],
    );

    $self->add_plugins(['ExecDir' => {
            scripts => $self->scripts_dir
        }]
        ) if $self->install_scripts;

    $self->is_task
        ? $self->add_plugins('TaskWeaver')
        : $self->add_plugins(
              [PodWeaver => {
                  config_plugin => $self->weaver_config_plugin,
              }],
          );

    # Same as above, these need to be moved into a trigger or builder or somethin'
    $self->add_plugins('NextRelease') if $self->use_next_release;
    $self->add_plugins('ModuleBuild') if $self->use_module_build;
    $self->add_plugins('PodCoverageTests') if !$self->disable_pod_coverage_tests;
    $self->add_plugins('AutoPrereqs') if $self->auto_prereqs;
};

__PACKAGE__->meta->make_immutable;

1;
