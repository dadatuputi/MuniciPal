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
    # How many courts do we know of?
    Court.count # => 84

    # Does the court support online payments?
    Court.first.supports_online_payments? # => true
    
    # What do courts use to accept online payments?
    Court.pluck(:online_payment_provider).each_with_object(Hash.new(0)) { |provider, hash| hash[provider] += 1 } # => {"iPayCourt"=>24, "IPG"=>12, nil=>25, "Collector Solutions"=>1, "Ncourt"=>21, "Municipal Online Payments"=>1}
    
    # How many citations are in the CSV file?
    Citation.count # => 1000

    # How many violations have a warrant?
    Violation.where(warrant_status: true).count # => 243

    # What's the average time between citation date and court date?
    durations = Citation.where("court_date IS NOT NULL AND citation_date IS NOT NULL").pluck(:court_date, :citation_date).map { |a, b| a - b }
    (durations.sum / durations.count).to_f # => 12.36 days
    
    # How many people are in the system
    Person.count # => 806
    
    # How many citations does a person have?
    Person.find(576).citations.count # => 3
    
    # How many warrants does a person have?
    Person.find(576).warrants.count # => 2
    ```


### Contributing

1. Clone the repo (see above)

2. Create a topic branch for your work (from a fresh copy of `master`)

    ```
    git checkout master
    git pull origin master
    bundle exec rake db:migrate db:seed
    git checkout -b add-cool-feature
    ```

3. Add the feature and commit it

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
