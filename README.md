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


### Contributing

1. Clone the repo (see above)

2. Create a topic branch for your work

```
git checkout -b add-cool-feature
```

3. Code

4. Push your work to GitHub

```
git push origin add-cool-feature
```

5. Create a Pull Request

Reload this page. GitHub will show a message about the branch you pushed and you can click a button to create a pull request. Do that and then send a message to our team about the Pull Request in Slack.



### Deploying

This is hosted on Heroku here: http://municipal-app.herokuapp.com/

To deploy to Heroku:

1. One-time Setup

```
git remote add heroku git@heroku.com:municipal-app.git
```

2. Doing a deploy (from the `master` branch)

```
git push heroku master
```
