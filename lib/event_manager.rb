require 'csv'
require 'google/apis/civicinfo_v2'

template_letter = File.read('form_letter.html')

def clean_zipcode(zipcode)
  zipcode = "00000" if zipcode.nil?
  new_zip = zipcode.prepend("00000")[-5..-1]
end

def legislators_by_zipcode (zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
      )
    legislators = legislators.officials

    legislator_names = legislators.map do |legislator|
      legislator.name
    end

    legislators_string = legislator_names.join(", ")

  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end


puts 'Event Manager Initialized! 😉'

contents = CSV.open('event_attendees.csv', 
headers: true, 
header_converters: :symbol)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  puts "Name: #{name} Zip: #{zipcode} Reps: #{legislators}"
end
