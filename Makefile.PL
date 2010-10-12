use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Dancer::Plugin::FormValidator',
    AUTHOR        => q{Natal Ngétal <hobbestigrou@erakis.im>},
    VERSION_FROM  => 'lib/Dancer/Plugin/FormValidator.pm',
    ABSTRACT_FROM => 'lib/Dancer/Plugin/FormValidator.pm',
    PREREQ_PM => {
        'Test::More'          => 0,
        'Dancer'              => 1.175,
        'Data::FormValidator' => 0,
    },
);
