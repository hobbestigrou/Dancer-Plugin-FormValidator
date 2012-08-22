package Dancer::Plugin::FormValidator;

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::Plugin;

use Data::FormValidator;
use Module::Load;

#ABSTRACT: Easy validates user input (usually from an HTML form) based on input profile for Dancer applications.

my $settings = plugin_setting;
my $dfv;
my $results;

=method form_validator_error

    form_validator_error('profile_name');
or
    form_validator_error('profile_name', $input);

Validate forms.

    input: (Str): Name of profile
           (HashRef): Data to be validated (optional) if is not present
                      getting params implicitly
    output: (HashRef): Field was missing or invalid

=cut

register form_validator_error => sub {
    $results = _dfv_check(@_);

    if ( $results->has_invalid || $results->has_missing ) {
        if ( $settings->{halt} ) {
            my @errors = keys(%{$results->{missing}});
            my $string;

            $string = scalar(@errors) == 1
                ? "$settings->{msg}->{single} @errors"
                : "$settings->{msg}->{several} @errors";

            return halt($string);
        }
        else {
            return $results->has_missing
                ? _error_return('missing')
                : _error_return('invalid');
        }
    }

    return 0;
};

=method dfv

    dfv('profile_name');
or
    dfv('profile_name', $input);

Validate forms.

    input: (Str): Name of profile
           (HashRef): Data to be validated (optional) if is not present
                      getting params implicitly
    output: A Data::FormValidator::Results object

=cut

register dfv => sub {
    _dfv_check(@_);
};

register_plugin;

sub _error_return {
    my $reason = shift;

    my @errors = keys(%{$results->{$reason}});
    my $errors;
    my $value;

    if ( $results->{profile}->{msgs}->{$reason} ) {
        $value = $results->{profile}->{msgs}->{$reason};
    }
    else {
        $value = $settings->{msg}->{single};
    }

    foreach my $msg_errors (@errors) {
        $errors->{$msg_errors} = $value;
    }

   return $errors;
}

sub _dfv_check {
    my ( $profil, $params ) = @_;

    _init_object_dfv() unless defined($dfv);
    $params //= params;
    $results  = $dfv->check($params, $profil);

    return $results;
}

sub _init_object_dfv {
    my $path_file   = $settings->{profil_file} // 'profile.yml';
    my $profil_file = setting('appdir') . '/' . $path_file;

    my $available_deserializer = {
        json => sub {
            my ( $file ) = @_;

            load JSON::Syck;

            my $data = JSON::Syck::LoadFile($file);
            return $data;
        },
        yml => sub {
            my ( $file ) = @_;

            load YAML::Syck;

            my $data = YAML::Syck::LoadFile($file);
            return $data;
        },
        pl => sub {
            my ( $file )  = @_;

            my $exception;
            my $data;

            {
                local $@;
                $data      = do $file;
                $exception = $@;
            }

            die $exception if $exception;

            return $data;
        },
    };

    $profil_file     =~ m/\.(\w+$)/;
    my $ext          = $1;

    if ( my $deserialize = $available_deserializer->{$ext} ) {
        $dfv = Data::FormValidator->new($deserialize->($profil_file));
    }
    else {
        die "Format $ext $profil_file is not supported", "\n";
    }
}

1;

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::FormValidator;

    get '/contact/form' => sub {
        my $input_hash = {
            Name    => $params->{name},
            Subject => $params->{subject},
            Body    => $params->{body},
        };

        my $error = form_validator_error( 'profile_contact', $input_hash );

        if ( ! $error ) {
            #the user provided complete and validates
            # data it's cool to proceed
        }
    };

    dance;

Example of profile file:

     {
         profile_contact => {
             'required' => [ qw(
                 Name Subject Body
              )],
              msgs => {
                missing => 'Not Here',
              }
         },
     }

=head1 DESCRIPTION

Provides an easy validates user input based on input profile (Data::FormValidator)
keyword within your L<Dancer> application.

=encoding utf8

=head1 CONFIGURATION

     plugins:
         FormValidator:
             profil_file: 'profiles.pl'
             halt: 0
             msg:
                 single: 'Missing field'
                 several: 'Missing fields'

If you don't use halt option, a hashref is return with name of fields for the key and
reason of the value use msgs profile, if you missing specified a msgs in a profil,
msg single is use. The profile file it begins at the application root, accept
multiple format yaml, json or perl.

=head1 CONTRIBUTING

This module is developed on Github at:

L<http://github.com/hobbestigrou/Dancer-Plugin-FormValidator>

Feel free to fork the repo and submit pull requests

=head1 ACKNOWLEDGEMENTS

Alexis Sukrieh and Franck Cuny

=head1 BUGS

Please report any bugs or feature requests in github.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::FormValidator

=head1 SEE ALSO

L<Dancer>
L<Data::FormValidator>

=cut

