# Hour counter

Useful for creating invoices for time marked out in calendars. It is currently very tailored to my use case, but could be made more general without _too_ much effort.

## Usage

1. Create new Credentials.
    1. Visit the [Google Developer Console](https://console.developers.google.com).
    1. Create a new project.
    1. Enable the [Google Calendar API](https://console.developers.google.com/apis/api/calendar-json.googleapis.com/overview).
    1. Click "Go to Credentials".
    1. For "Where will you be calling the API from?", select "Other UI".
    1. For "What data will you be accessing?", select "User data".
1. "Download JSON", and save as `client_secrets.json` in this repo.
1. Run `bundle install`.
1. Run `bundle exec ruby artichoke_hours.rb`.
