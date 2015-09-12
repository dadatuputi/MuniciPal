# MuniciPal

### Getting Started

1. Clone the repo

```
git clone git@github.com:elBradford/MuniciPal.git
cd MuniciPal
```

2. Download gems

```
bundle
```

3. Interact with the data in the console

```
bundle exec rails c
```

```ruby
# How many citations are in the CSV file?
Citation.count # => 1000

# How many violations have a warrant?
Violation.where(warrant_status: true).count # => 243

# What's the average time between citation date and court date?
durations = Citation.where("court_date IS NOT NULL AND citation_date IS NOT NULL").pluck(:court_date, :citation_date).map { |a, b| a - b }
(durations.sum / durations.count).to_f # => 12.36 days

```
