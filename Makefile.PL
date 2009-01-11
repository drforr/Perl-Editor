use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SExpr-Edit',
    AUTHOR              => 'Jeffrey Goff <drforr@pobox.com>',
    VERSION_FROM        => 'lib/Pane.pm',
    ABSTRACT_FROM       => 'lib/Pane.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'SExpr-Edit-*' },
);
