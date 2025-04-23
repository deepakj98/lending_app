# README
* This project is about lending, where there is an admin with wallet of 1000000. There can be multiple users that can be created from registration form and will have initial amount in the wallet as 10000. User can request a loan at a particular rate of interest. The admin can approve or reject or propose adjustiment. For loan that is open (accepted) there will be interest calculated every 5 minutes and will be reflected on the dashboard. 

* clone the repository
`git clone https://github.com/deepakj98/lending_app.git`
bundle install

* create database
rails db:create

* run migration
rails db:migrate

* create admin
rails db:seed

* run the server
  bin/rails server

* run the sidekiq server
  bundle exec sidekiq

Note:
* For user authentication `Devise` is used in the app
* For scheduling the job `Sidekiq` is used and `sidekiq-scheduler` is used to schedule it for every 5 minutes
* ...
# lending_app
