# Claim processing system

## Prerequisites

* Ruby 3.0.1
* PostgreSQL >= 9.0

## Configuration

1. Install gems:
   ```
   $ bundle install
   ```
2. Create a database config file from the template:
   ```
   $ cp config/database.yml.template config/database.yml
   ```
3. Set the `username` and `password` variables using
   your PostgreSQL credentials.
4. Database setup:
   ```
   $ rake db:setup
   ```
5. Run the migrations:
   ```
   $ rake db:migrate
   ```
6. Run the server:
   ```
   $ rails s
   ```

You should now be able to open the application in your browser by visiting http://localhost:3000/.

## Environment variables

* CLAIM_ELIGIBILITY_API_URL - claim eligibility API endpoint

In order to set the environment variables for the development environment,
you can create a file `.env` in the main project directory (it should be listed in `.gitignore`)
and set them there like this:

```
ENV_VARIABLE_NAME=value
```
