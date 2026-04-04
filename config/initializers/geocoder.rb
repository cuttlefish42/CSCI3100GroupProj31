Geocoder.configure(
lookup: :google,
  api_key: ENV["GOOGLE_API_KEY"],  # change to yr API Key
  timeout: 10,
  units: :km,
  use_https: true
)