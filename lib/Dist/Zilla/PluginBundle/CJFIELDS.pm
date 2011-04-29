package Dist::Zilla::PluginBundle::CJFIELDS;

# ABSTRACT: Build your modules like CJFIELDS (not sure that's a recommendation)

use Moose 1.0;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Bool Str HashRef Any);
use namespace::autoclean;

extends qw(Dist::Zilla::PluginBundle::FLORA);

sub BUILD {
    my $self = shift;
    $self->_set_config_plugin( map { $_ => {} } qw(
        MetaConfig
        MetaJSON
        PkgVersion
        PodSyntaxTests
        NoTabsTests
        CompileTests
        NextRelease
        )
    );
}

has '+authority'    => ( default     => 'cpan:CJFIELDS');

has '+github_user'  => ( default     => 'cjfields' );

has 'create_readme' => (
    isa         => Bool,
    is          => 'ro',
    default     => 1,
    trigger     => sub {
        my ($self, $val) = @_;
        if (!$val) {
            $self->_set_filter_plugin('Readme');
        }
        $val
    }
);

has 'use_module_build'  => (
    isa         => Bool,
    is          => 'ro',
    default     => sub {
        my $self = shift;
        $self->_set_filter_plugin('MakeMaker', 1);
        $self->_set_config_plugin('ModuleBuild',{});
        1;
    },
    trigger     => sub {
        my ($self, $val) = @_;
        if ($val) {
            $self->_set_filter_plugin('MakeMaker',1);
            $self->_set_config_plugin('ModuleBuild',{});
        }
        $val
    }
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
    default     => 0,
    lazy        => 1,
    trigger     => sub {
        my ($self, $val) = @_;
        if ($val) {
            Carp::croak() if $self->use_module_build;
            $self->_set_filter_plugin('MakeMaker',1);
        }
        $val
    }
);

has '_plugins_filtered' => (
    traits      => ['Hash'],
    isa         => HashRef[Bool],
    is          => 'bare',
    init_arg    => undef,
    handles     => {
        '_set_filter_plugin' => 'set',
        '_filtered_plugins'  => 'keys'
    }
);

has '_plugins_added' => (
    traits      => ['Hash'],
    isa         => HashRef[Any],
    is          => 'bare',
    init_arg    => undef,
    handles     => {
        '_set_config_plugin'     => 'set',
        '_config_plugin_map'     => 'kv'
    }
);

override 'configure' => sub {
    my $self = shift;

    Carp::croak("Can't set both skip_build and use_module_build")
        if $self->skip_build && $self->use_module_build;

    # these need to be moved into a trigger or builder or somethin'
    my @filtered = $self->_filtered_plugins;

    if (@filtered) {
        $self->add_bundle('@Filter' => {-bundle   => '@Basic',
                                        -remove   => \@filtered});
    } else {
        $self->add_bundle('@Basic');
    }

    $self->add_plugins($self->_config_plugin_map);

    # these have to be set last-minute b/c they rely on secondary attributes
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
};

__PACKAGE__->meta->make_immutable;

1;
