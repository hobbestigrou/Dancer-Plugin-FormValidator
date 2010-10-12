package Dancer::Plugin::FormValidator;

use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin;
use Data::FormValidator;

=head1 NAME

Dancer::Plugin::FormValidator - easy validates user input (usually from an HTML form) 
based on input profile for Dancer applications.

=cut

our $VERSION = '0.1';

my $settings = plugin_setting;

register form_validator_error => sub {
    my ( $profil, $input_hash ) = @_;
    
    my $dfv = Data::FormValidator->new($settings->{profil_file});
    
    my $results = $dfv->check($input_hash, $profil);

    if ( $results->has_invalid || $results->has_missing ) { 
        my @errors = keys(%{$results->{missing}});
        my $string;

        if ( scalar(@errors) == 1 ) {
            $string = "$settings->{msg}->{single} @errors";
        }
        else {
            $string = "$settings->{msg}->{several} @errors";
        }
        
        return halt($string)
    }

    return 0;
};

register_plugin;

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::FormValidator;

    get '/contact/form' => sub {
        my $input_hash = {
            Name    = $params->{name};
            Subject = $params->{subject};
            Body    = $params->{body};
        };

        my $error = form_validator_error( 'profil_contact', $input_hash );

        if ( ! $error ) {
            #the user provided complete and validates
            # data it's cool to proceed
        }
    };
    
    dance;


=head1 DESCRIPTION

Provides an easy validates user input based on input profile (Data::FormValidator)
keyword within your L<Dancer> application.

=head1 CONFIGURATION

     plugins:
         FormValidator:
             profil_file: '/path/to/profiles.pl'
             msg: 
                 single: 'Missing field'
                 several: 'Missing fields'

=head1 AUTHOR

Natal Ngétal, C<< <hobbestigrou@erakis.im> >>

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

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Natal Ngétal.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 SEE ALSO

L<Dancer>
L<Data::FormValidator>

=cut 

1;
