CREATE TABLE IF NOT EXISTS flights (
  id SERIAL PRIMARY KEY,
  flight_number TEXT NOT NULL,
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  status TEXT NOT NULL,
  departure_time TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  passenger_name TEXT NOT NULL,
  flight_number TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS checkins (
  id SERIAL PRIMARY KEY,
  booking_id INTEGER NOT NULL,
  passenger_name TEXT NOT NULL,
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO flights (flight_number, origin, destination, status, departure_time)
VALUES
  ('UA100', 'EWR', 'ORD', 'ON_TIME', NOW() + INTERVAL '2 hours'),
  ('UA220', 'SFO', 'DEN', 'BOARDING', NOW() + INTERVAL '45 minutes'),
  ('UA330', 'IAH', 'LAX', 'DELAYED', NOW() + INTERVAL '3 hours')
ON CONFLICT DO NOTHING;
