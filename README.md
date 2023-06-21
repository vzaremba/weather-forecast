# Weather Forecast App

This is a simple Ruby on Rails application that retrieves and displays weather forecast information for a given address.

## Requirements

- Ruby 3.0.0
- Rails 7.0.5

## Setup

1. Clone this repository: `git clone https://github.com/vzaremba/weather-forecast.git`
2. Navigate to the project directory: `cd weather-forecast`
3. Install dependencies: `bundle install`
4. Create a file named `.env` at the root of your project and add your OpenWeather API key:

```
OPENWEATHER_API_KEY=your_api_key
```

5. Run `rails dev:cache` to toggle caching.
6. Run the server: `rails server`

## Usage

Visit `http://localhost:3000` in your web browser and enter an address in the form to see the weather forecast for that location.

## Running Tests

Run the test suite with: `bundle exec rspec`
