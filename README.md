# Sinatra Links

Simple application to illustrate Sinatra + DataMapper with sessions.

Simply allows the sharing and voting of links.

Built on top of Sinatra Application Template by Nick Plante, et al.

## To Deploy to heroku

The Gemfile is a bit different (has postgres dependency) in the
production branch. So, it is easiest to keep that in a separate branch.

Do this if you've changed anything in the master branch:

    $ git checkout production
    $ git merge master
    $ git checkout

Then create the heroku project.

    $ heroku create --stack bamboo-mri-1.9.2 <optional-name>
    $ git push heroku production:master
    $ heroku rake db:migrate

(c) 2011 Stephen A. Goss
