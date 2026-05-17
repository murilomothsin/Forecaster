# Forecaster

A weather forecast app built with Rails 8.1 and the OpenWeather API. Search by zip code or city name to see current conditions and a 5-day forecast.

## Requirements

- Ruby 4.0.4
- Rails 8.1.3
- SQLite 3.8+

## Setup

```bash
git clone https://github.com/murilomothsin/Forecaster
cd Forecaster
bundle install
bin/rails db:setup
```

### OpenWeather API Key

The app uses Rails credentials to store the API key.

1. Get a free API key at [openweathermap.org/api](https://openweathermap.org/api)

2. Open the credentials file:

> * If you don't have the master.key for the project run `rm config/credentials.yml.enc` to remove the old credentials, rails will create a new `config/master.key` and a `config/credentials.yml.enc` one when you edit the file *

```bash
EDITOR="vim" bin/rails credentials:edit
```

3. Add your key under the `open_weather` namespace:

```yaml
open_weather:
  api_key: your_api_key_here
```

4. Save and close the editor (for vim editor, press ESC and then `:wq`). The encrypted `config/credentials.yml.enc` will be updated automatically.

> **Note:** The `config/master.key` file is required to decrypt credentials. It is git-ignored by default. Share it securely with other developers — never commit it.

## Running the app

```bash
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000).

## Tests

```bash
bundle exec rspec
```
