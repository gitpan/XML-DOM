use ExtUtils::MakeMaker;

@extras = ();

push(@extras,
     ABSTRACT_FROM => 'DOM.pm',
     AUTHOR        => 'Enno Derksen (enno@att.com) and Clark Cooper (coopercl@sch.ge.com)')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);

WriteMakefile(
              NAME	=> 'XML::DOM',
              dist      => {COMPRESS => 'gzip', SUFFIX => '.gz'},
              VERSION_FROM => 'DOM.pm',
              PREREQ_PM => { XML::Parser => '2.16' },
	      PM => { 'DOM.pm' => '$(INST_LIBDIR)/DOM.pm',
		      'DOM/UTF8.pm' => '$(INST_LIBDIR)/XML/UTF8.pm'},
	      @extras
             );

