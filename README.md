Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

# Project Setup and Database Connection

## Step-by-Step Guide to Run the Project and Connect to PostgreSQL

### 1. Install Required Software
- **Ruby**: Ensure you have Ruby installed. The project specifies Ruby version `3.3.7`.
- **Rails**: Install Rails if not already installed.
- **PostgreSQL**: Install PostgreSQL on your system.

### 2. Update the Gemfile
Replace the SQLite gem with the PostgreSQL gem:
```ruby
# Comment out or remove the SQLite gem
# gem "sqlite3", "~> 1.4"

# Add the PostgreSQL gem
gem "pg", "~> 1.2"
```

### 3. Install Gems
Run the following command to install the necessary gems:
```bash
bundle install
```

### 4. Configure Database
Update the `config/database.yml` file to configure PostgreSQL. Here is a basic example:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  username: your_postgres_username
  password: your_postgres_password
  host: localhost

development:
  <<: *default
  database: your_project_name_development

test:
  <<: *default
  database: your_project_name_test

production:
  <<: *default
  database: your_project_name_production
  username: your_production_username
  password: <%= ENV['YOUR_DATABASE_PASSWORD'] %>
```

### 5. Create and Migrate the Database
Run the following commands to create and migrate the database:
```bash
rails db:create
rails db:migrate
```

### 6. Set Up Environment Variables
If you have any environment variables (e.g., database passwords), ensure they are set up in a `.env` file or your system environment.

### 7. Start the Rails Server
Run the following command to start the Rails server:
```bash
rails server
```

### 8. Access the Application
Open a web browser and go to `http://localhost:3000` to access the application.

### Additional Notes
- Ensure that PostgreSQL is running on your system before starting the Rails server.
- Adjust the database configuration in `database.yml` according to your PostgreSQL setup.
- If you encounter any issues, check the logs for error messages and ensure all dependencies are correctly installed.
#   n o m i d a  
 