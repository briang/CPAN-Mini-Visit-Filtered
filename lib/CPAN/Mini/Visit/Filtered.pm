package CPAN::Mini::Visit::Filtered;

our $VERSION = '0.01_01';

use MooseX::Declare;
use Moose::Util::TypeConstraints;

=head1 NAME

CPAN::Mini::Visit::Filtered - visit unpacked distributions in a filtered CPAN::Mini mirror

=head1 SYNOPSIS

    my $visitor = CPAN::Mini::Visit::Filtered->new(
        action => sub {
            # XXX put something here
        },
        filter => sub { /briang/i },
    );

    $visitor->visit_distributions;

=head1 DESCRIPTION XXX

=head1 RATIONALE XXX

=cut

class CPAN::Mini::Visit::Filtered {
    use MooseX::StrictConstructor;

    use Archive::Extract   qw();
    use Carp               qw();
    use CPAN::DistnameInfo qw();
    use Cwd                qw();
    use File::Find::Rule   qw();
    use File::Spec         qw();
    use File::Temp         qw();
    # CPAN::Mini

=head1 CONSTRUCTOR

new() returns a new CPAN::Mini::Visit::Filtered object. Parameters to new() should be
supplied as key=>value pairs. The following attributes are recognised.

=head1 ATTRIBUTES

Attributes of the CPAN::Mini::Visit::Filtered class are all read-only: they can be set only
when constructing an object. They all have getters, however, that can
be used at any time, though its doubtful that you'll need to.

CPAN::Mini::Visit::Filtered objects have the following attributes:

=head2 action

Once the archive has been unpacked, the coderef stored in action will
be called. The subroutine will be passed a CPAN::DistnameInfo object.

This parameter is mandatory.

=cut

    has qw(action is ro isa CodeRef required 1);

=head2 archive_types

This is a regular expression that matches valid archives. The default
value matches C<< *.tar.gz >>, C<< *.tgz >>, C<< *.tar.bz2 >> and
C<< *.zip >>.

=cut

    has qw(archive_types is ro),
      default => sub { qr{\.(?:tar\.bz2|tar\.gz|tgz|zip)$} };

=head2 cpan_base

This is the base directory where the CPAN::Mini mirror is stored. It
defaults to using the directory defined in your .minicpanrc file.

=cut

    has qw(cpan_base is ro isa Str required 1),
      default => sub {
          require CPAN::Mini;

          my $config_file = CPAN::Mini->config_file({});
          Carp::croak("CPAN::Mini config file not located: $!")
            unless defined $config_file and -e $config_file;
          my %config = CPAN::Mini->read_config({quiet=>1});
          Carp::croak("You haven't defined 'cpan_base' and no 'local' option was found in $config_file")
            unless defined $config{local};
          return $config{local}
      };

=head2 filter

This coderef is called before any archive is unpacked. The intention
is that this callback is used to filter out distributions you have no
interest in.

The subroutine will be passed a CPAN::DistnameInfo object and $_ will
be set to the full path and filename of the file as stored in the
CPAN::Mini mirror. The function should return a true value if you wish
this archive to be processed further.

By default all archives will be included. (With the possible exception
of Acme::*. See L<include_acme>.)

=cut

    has qw(filter is ro isa CodeRef),
      default => sub { sub {1} };

=head2 include_acme

Set this parameter to a true value if you wish to process the modules
from the Acme::* namespace. Traditionally, these modules are all
"jokes", and you may not wish to process them

By default, the Acme distributions will not be included.

=cut

    has qw(include_acme is ro isa Bool default 0);

=head2 unpack_dir

The directory where the distributions will be unpacked.

By default, a temporary directory (as determined by
File::Temp::tempdir) will be allocated for you, and will be deleted
when no longer required.

=cut

    has qw(unpack_dir is ro isa Str),
      default => File::Temp::tempdir(
          File::Spec->catfile(File::Spec->tmpdir, "cmvf-$$-XXXXXXXX"),
          CLEANUP => 1
      );

    # private

    # cache for CPAN::DI object
    has qw(_distinfo    is rw isa CPAN::DistnameInfo writer _set_distinfo);
    has qw(_initial_dir is ro isa Str), default => Cwd::getcwd;

=head1 METHODS

=head2 distinfo

=cut

    method distinfo(Str $archive) {
        return $self->_distinfo
          if defined $self->_distinfo
            && $self->_distinfo->pathname eq $archive;

        return $self->_set_distinfo(CPAN::DistnameInfo->new($archive));
    }

=head2 find_archives

=cut

    method find_archives() {
        my $include_acme = $self->include_acme
          ?  sub { 1 }
          :  sub { $_[0]->dist !~ /^acme-/i };
        my $filter = $self->filter;

        return grep {
            my $info = $self->distinfo($_);
            $include_acme->($info)  &&  $filter->($info)
        } File::Find::Rule->file
          ->name($self->archive_types)
          ->in( File::Spec->catdir($self->cpan_base, qw{authors id}) );
    }

=head2 visit_distributions

=cut

    method visit_distributions() {
        my $dest = $self->unpack_dir;

        for my $archive ($self->find_archives) {
            my $ae = Archive::Extract->new(archive => $archive);
            my $ok = $ae->extract( to => $dest ); # XXX and if it fails???

            my $info = $self->distinfo($archive);

            chdir $self->unpack_dir   or die $!; # XXX
            chdir $info->distvname    or die $!;
            chdir $self->_initial_dir or die $!;

            $self->action->($info);
        }
    }
};

1;

__END__

# XXX Oh noes. They're all blank

=head1 SEE ALSO

=head1 AUTHOR

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=cut
