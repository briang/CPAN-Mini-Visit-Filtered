use strict;
use warnings;

require 5.00601;

use Module::Build;

my $builder = Module::Build->new(
    build_requires   => {
        'Archive::Extract'             => '0',
        'CPAN::DistnameInfo'           => '0',
        'Carp'                         => '0',
        'Cwd'                          => '0',
        'File::Find::Rule'             => '0',
        'File::Spec'                   => '0',
        'File::Temp'                   => '0',
        'Moose::Util::TypeConstraints' => '0',
        'MooseX::Declare'              => '0',
        'MooseX::StrictConstructor'    => '0',
        'Test::More'                   => '0',
    },
    configure_requires  => {
        'Module::Build' => '0',
    },
    create_makefile_pl => 'traditional',
    create_readme      => 1,
    license            => 'perl',
    meta_merge         => {
        resources      => {
            repository => 'http://github.com/briang/CPAN-Mini-Visit-Filtered',
        }
    },
    module_name => 'CPAN::Mini::Visit::Filtered',
    requires    => {
        'Moose' => '0',
    },
);

$builder->create_build_script();
