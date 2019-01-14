require 'google/apis/calendar_v3'
require 'googleauth/stores/file_token_store'
require 'time'

Calendar = Google::Apis::CalendarV3 # Alias the module

calendar_id = 'primary'
START_AT = DateTime.new(2018, 1, 2).iso8601
END_AT = DateTime.now.iso8601

# https://developers.google.com/calendar/quickstart/ruby#step_3_set_up_the_sample
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'client_secrets.json'.freeze
# token.yaml stores the user's access and refresh tokens, and is created automatically when the authorization flow completes for the first time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

def create_service
  service = Calendar::CalendarService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize
  service
end

puts '-------------------'

service = create_service
total_hours = 0
next_page = nil
begin
  response = service.list_events(
    calendar_id,
    q: 'Artichoke',
    time_min: START_AT,
    time_max: END_AT,
    page_token: next_page
  )

  response.items.each do |event|
    # for some reason, dates for all-day events are a different attribute
    start_at = event.start.date || event.start.date_time
    end_at = event.end.date || event.end.date_time

    if event.start.date
      # don't count full-day events
      duration_hours = 0
    else
      duration_days = end_at - start_at
      duration_hours = (duration_days * 24).to_f
    end

    if event.summary.match(/rehearsal|tech/)
      total_hours += duration_hours
    else
      puts [
        event.summary.ljust(30),
        start_at.strftime('%b %-d').ljust(12),
        "#{duration_hours} hours"
      ].join
    end
  end

  next_page = response.next_page_token
end while next_page

total_rehearsals = total_hours / 2
puts "Total rehearsals: #{total_rehearsals}"
