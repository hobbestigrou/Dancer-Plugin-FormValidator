package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::FormValidator;

get '/' => sub {
    return 'Hello world';
};

post '/contact' => sub {
    if ( my $results = dfv('profile_contact') ) {
        return 'The form is validate';
    }
    else {
        return $results;
    }
};

post '/other_contact' => sub {
    my $results = form_validator_error('profile_contact');

    if ( ! $results ) {
        return 'The form is validate';
    }
    else {
        return $results;
    }
};

1;
