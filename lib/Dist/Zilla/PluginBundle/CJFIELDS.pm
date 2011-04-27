package Dist::Zilla::PluginBundle::CJFIELDS;

# ABSTRACT: Build your modules like CJFIELDS

use Moose 1.0;
use Moose::Util::TypeConstraints;
#use MooseX::Types::URI qw(Uri);
#use MooseX::Types::Email qw(EmailAddress);
use MooseX::Types::Moose qw(Bool Str ArrayRef);
#use MooseX::Types::Structured 0.20 qw(Map Dict Optional);
use namespace::autoclean;

extends qw(Dist::Zilla::PluginBundle::FLORA);

has '+authority'    => ( default     => 'cpan:CJFIELDS');

has '+github_user'  => ( default     => 'cjfields' );

has '_filtered'  => (
    is          => 'ro',
    isa         => ArrayRef[Str],
    default     => sub {[]},
    handles     => {
        add_filtered    => 'push',
        filtered_plugins => 'elements'
        }
);

sub _add_filtered {shift->add_filtered(shift)}

has 'create_readme' => (
    isa         => Bool,
    is          => 'ro',
    trigger     => sub { my ($self, $val) = @_; $self->add_filtered('ReadMe') if $val},
    default     => 1
);

has 'use_module_build'  => (
    isa         => Bool,
    is          => 'ro',
    trigger     => sub { my ($self, $val) = @_; $self->add_filtered('MakeMaker') if $val },
);

has 'use_next_release'  => (
    isa         => Bool,
    is          => 'ro',
);

override 'configure' => sub {
    my $self = shift;
    
    my @filtered = $self->filtered;
    
    if (@filtered) {
        $self->add_bundle('@Filter' => {-bundle   => '@Basic', 
                                        -remove   => \@filtered});
    } else {
        $self->add_bundle('Basic');
    }
    
    $self->add_plugins(qw(
                       MetaConfig
                       MetaJSON
                       PkgVersion
                       PodSyntaxTests
                       NoTabsTests
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
    $self->add_plugins('PodCoverageTests') if $self->pod_coverage_tests;
    $self->add_plugins('AddPrereqs') if $self->add_prereqs;
};

__PACKAGE__->meta->make_immutable;

1;
