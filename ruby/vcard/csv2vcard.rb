#!/usr/bin/env ruby

require 'rubygems'
require 'csv'
require 'vpim/vcard'


CSV.foreach('convert.csv') do |row|
  agreement = row[0]
  ve = row[1]
  first_name = row[3]
  last_name = row[2]
  office_address = row[4]
  work_address = row[5]
  work_address_more = row[6]
  postal_code = row[7]
  work_city = row[8]
  work_phone = row[9]
  email = row[10]

  card = Vpim::Vcard::Maker.make2 do |maker|
    maker.name do |n|
      n.given = first_name if first_name
      n.family = last_name if last_name
    end

    maker.add_addr do |addr|
      addr.preferred = true
      addr.location = 'work'
      addr.street = work_address if work_address
      addr.extended = work_address_more if work_address_more
      addr.locality = work_city if work_city
      addr.postalcode = postal_code if postal_code
    end

    maker.add_addr do |addr|
      addr.location = 'office'
      addr.street =  office_address if office_address
    end

    maker.add_tel(work_phone) { |t| t.location = 'work'; t.preferred = true } if work_phone
    maker.add_email(email) { |t| t.location = 'work'; t.preferred = true } if email
    note = ""
    note << "N° D'AGREMENT=#{agreement}" if agreement
    note << " VE=#{agreement}" if ve
    maker.add_note(note) unless note.empty?
  end

  puts card

end

