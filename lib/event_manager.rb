$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require 'csv'
require 'sunlight/congress'
require 'erb'

class EventAttendees
attr_reader :hash

  def initialize
    puts "EventManager initialized."
    @hash = create_data_hash
    Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
    attendees = read_attendees
    erb_template = create_erb_letter
    parse_attendee_info(attendees, erb_template)
  end

  def create_data_hash
    hash = {"1" => [],
            "2" => [],
            "3" => [],
            "4" => [],
            "5" => [],
            "6" => [],
            "7" => [],
            "8" => [],
            "9" => [],
            "10" => [],
            "11" => [],
            "12" => []
    }
    hash
  end


  def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5,"0")[0..4]
  end

  def clean_phone_number(homephone)
    homephone.delete!("(")
    homephone.delete!(")")
    homephone.delete!("-")
    homephone.delete!(".")
    homephone.delete!(" ")
    if homephone.length == 11
      if homephone[0] == "1"
        homephone.slice!(homephone[0])
      else
        homephone = "0000000000"
      end
    end

    if homephone.length != 10
      homephone = "0000000000"
    end
    homephone
  end

  def registration_dates(reg_dates)
    date = reg_dates.split[0].split("/")
    month = date[0]
    day = date[1]

    time = reg_dates.split[1].split(":")
    hour = time[0]
    date_data = {"MONTH" => month,
                "DAY" => day,
                "HOUR" => hour
                }
    date_data
  end

  def date_data(date_data)
    @hash[date_data["MONTH"]] << date_data
  end

  def data_anaysis
    i = 0
    @hash.each do |a|
      @i = "#{a[i]}"
      @i = a[1]
      i += 1
    end
  end

  def legislators_by_zipcode(zipcode)
    Sunlight::Congress::Legislator.by_zipcode(zipcode)
  end

  def save_thank_you_letters(id, form_letter)
    Dir.mkdir("output") unless Dir.exists? "output"

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
  end

  def read_attendees
    CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
  end

  def create_erb_letter
    ERB.new(File.read('form_letter.erb'))
  end

  def parse_attendee_info(attendees, erb_template)
    attendees.each do |row|
      id = row[0]
      @name = row[:first_name]

      @zipcode = clean_zipcode(row[:zipcode])

      @phone_number = clean_phone_number(row[:homephone])

      registration_dates = registration_dates(row[:regdate])

      date_data(registration_dates)

      @legislators = legislators_by_zipcode(zipcode)

      form_letter = erb_template.result(binding)

      save_thank_you_letters(id, form_letter)
    end
  end
end

event = EventAttendees.new
require "pry"; binding.pry
