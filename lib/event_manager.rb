require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

require_relative 'clean_zipcode'
require_relative 'clean_phone_numbers'
require_relative 'legislators_by_zipcode'
require_relative 'save_thank_you_letter'

def find_all_hours(date, sign_up_hours)
  sign_up_hours << date
  sign_up_hours
end

def most_often_signup_hour (sign_up_hours)
  no_repeats_hours = sign_up_hours.uniq.sort
  occurence_values = []
  no_repeats_hours.each do |unique_hour|
    occurence_value = sign_up_hours.count(unique_hour)
    occurence_values << occurence_value
  end

  highest_occurence_value = occurence_values.max
  most_often_hours = sign_up_hours.filter do |unique_hour|
    highest_occurence_value == sign_up_hours.count(unique_hour)
  end
  most_often_hours.uniq
end

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

puts 'Event Manager Initialized! 😉'

sign_up_hours = []
all_dates = []

contents = CSV.open('event_attendees.csv',
                    headers: true,
                    header_converters: :symbol)

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  phone_number = clean_phone_numbers(row[:homephone])

  individual_sign_up_hour = row[:regdate][-5..-4].to_i

  find_all_hours(individual_sign_up_hour, sign_up_hours)

  
  all_dates << Date.strptime(row[:regdate], '%m/%d/%y').wday
  
 
  # puts "#{name}, #{phone_number}, #{legislators}, #{id}"
  
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
  
end
value_day_hash = 
  {0 => "Sunday",
  1 => "Monday",
  2 => "Tuesday",
  3 => "Wednesday",
  4 => "Thursday",
  5 => "Friday",
  6 => "Saturday"}
puts "Most common day(s) of week to sign-up: #{value_day_hash[most_often_signup_hour(all_dates)[0].to_i]}"
puts "Most common hour(s) of the day to sign-up: #{most_often_signup_hour(sign_up_hours)}"


