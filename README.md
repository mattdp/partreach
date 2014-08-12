To setup:

$ git clone https://github.com/mattdp/partreach.git
$ bundle install
$ psql
postgres=# CREATE ROLE railsapp WITH CREATEDB LOGIN;
postgres=# \q
$ rake db:create
$ rake db:migrate