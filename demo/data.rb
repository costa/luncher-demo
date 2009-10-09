# Populates the demo data (and returns as an array to save)
[
Place.new(:name => 'Your Restaurant Here'),
Place.new(:name => 'Your Cafe There'),
p = Place.new(:name => 'Luncher Drive-In'),
p.lunches.new(:time => DateTime.parse('13:15'),
              :person => 'Costa', :note => "cheers!")
]
