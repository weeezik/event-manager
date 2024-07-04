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