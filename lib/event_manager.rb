require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

template_letter = File.read('form_letter.html')

def clean_zipcode(zipcode)
  zipcode = "00000" if zipcode.nil?
  new_zip = zipcode.prepend("00000")[-5..-1]
end

def clean_phone_numbers(phone_number)
  new_number = phone_number.gsub(/[()-,.-]/, '').gsub(" ", "")
  if new_number.size < 10 || new_number.size > 11
    "Invalid number."
    elsif new_number.size == 10
       new_number
    elsif new_number.size == 11 && new_number.start_with?("1")
      new_number[1..-1]
    else
      "Invalid number."
    end 
end

def legislators_by_zipcode (zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials

    legislator_names = legislators.map do |legislator|
      legislator.name
    end

    legislators_string = legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end


puts 'Event Manager Initialized! 😉'

contents = CSV.open('event_attendees.csv', 
headers: true, 
header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  phone_number = clean_phone_numbers(row[:homephone])

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)

  puts "#{name}: #{phone_number}"
end
