unless User.exist? 'official'
  raise Exception.new("No user named 'official'!  Create one first!")
end

def create_event(id, title, author, start_time, end_time, description, official)
  event = Event.create(_id: id, title: title, author: author, description: description, start_time: start_time, end_time: end_time, official: official)
  unless event.valid?
    puts "Errors for event #{title}: #{event.errors.full_messages}"
    return event
  end
  event.save!
  event
end

cal_filename = "db/seeds/all.ics"
# fix bad encoding from sched.org
cal_text = File.read(cal_filename)
cal_text = cal_text.gsub(/\;/, "\\;")
File.delete(cal_filename + ".tmp")
File.open(cal_filename + ".tmp", "w") { |file| file << cal_text }

cal_file = File.open(cal_filename + ".tmp")
cals = Icalendar.parse(cal_file)
cal = cals.first

cal.events.each { |event|
  if !event.dtstart.nil?
    event.dtstart = event.dtstart.utc
  end
  if !event.dtend.nil?
    event.dtend = event.dtend.utc
  end

  puts "-------------------------"
  categories = event.categories[0].split(", ")
  existing = nil
  begin
    existing = Event.find(event.uid)
    existing.author = "official"
    existing.start_time = event.dtstart
    existing.end_time = event.dtend
    existing.title = event.summary
    existing.description = event.description
    existing.location = event.location
    existing.official = !categories.include?('SHADOW CRUISE')
    unless event.valid?
      puts "Errors for event #{existing.title}: #{existing.errors.full_messages}"
      next
    end
    puts "saving event #{existing._id}: #{existing.title}"
    existing.save!
  rescue Mongoid::Errors::DocumentNotFound => dnf
    puts "event does not exist: #{event.uid}: #{event.summary}"
    create_event(event.uid, event.summary, "official", event.dtstart.utc, event.dtend, event.description, !categories.include?('SHADOW CRUISE'))
  end
}