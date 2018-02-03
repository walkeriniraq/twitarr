def create_official_event(title, author, start_time, end_time, description)
  event = Event.create(title: title, description: description, start_time: start_time, end_time: end_time, official: true)
  unless event.valid?
    puts "Errors for event #{title}: #{event.errors.full_messages}"
    return event
  end
  event.save!
  event
end

Event.delete_all
if Event.count == 0
  create_official_event 'Depart Orlando (Port Canaveral)', 'ranger', Time.new(2016, 2, 21, 16, 30), nil, nil
  create_official_event 'CocoCay, Bahamas', 'ranger', Time.new(2016, 2, 22, 7), Time.new(2016, 2, 22, 16), 'Surrounded by the gentle, translucent waters of the Bahamas chain lies the secluded island of CocoCay&reg;, an eco-certified private destination. Reserved exclusively for cruise ship guests, this 140-acre tropical paradise was awarded a Gold-Level Eco-Certification by Sustainable Travel International&trade; for its environmentally friendly activities and tours. With its white-sand beaches and spectacular surroundings, CocoCay is a wonderland of adventures. Explore new aquatic facilities, nature trails and a ton of great places to just sit back, relax and enjoy a tropical drink.'
  create_official_event 'Charlotte Amalie, St. Thomas', 'ranger', Time.new(2016, 2, 24, 12), Time.new(2016, 2, 24, 19), 'Beyond the glitz of its famous shopping district, St. Thomas enchants with a fascinating history and natural scenery. Explore the island\'s diverse heritage in Charlotte Amalie, or splash your way around at vibrant reefs or a gorgeous beach.'
  create_official_event 'Philipsburg, St. Maarten', 'ranger', Time.new(2016, 2, 25, 8), Time.new(2016, 2, 25, 17), 'When the Spanish closed their colonial fort on St. Maarten in 1648, a few Dutch and French soldiers hid on the island and decided to share it. Soon after, the Netherlands and France signed a formal agreement to split St. Maarten in half, as it is today. Philipsburg displays its Dutch heritage in its architecture and landscaping. The island offers endless stretches of beach, beautiful landscapes and great shopping.'
  create_official_event 'Arrive Orlando (Port Canaveral)', 'ranger', Time.new(2016, 2, 28, 6), nil, nil
end
