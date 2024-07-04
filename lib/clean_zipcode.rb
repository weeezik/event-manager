def clean_zipcode(zipcode)
  zipcode = "00000" if zipcode.nil?
  new_zip = zipcode.prepend("00000")[-5..-1]
end