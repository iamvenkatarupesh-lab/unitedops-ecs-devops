import cors from "cors";
import express from "express";
import pg from "pg";

const { Pool } = pg;

const app = express();
const port = Number(process.env.PORT ?? 4001);
const serviceName = process.env.SERVICE_NAME ?? "flight-service";
const databaseUrl = process.env.DATABASE_URL;

app.use(cors());
app.use(express.json());

const pool = databaseUrl
  ? new Pool({
      connectionString: databaseUrl,
      ssl: {
        rejectUnauthorized: false
      }
    })
  : null;

async function initializeDatabase() {
  if (!pool) {
    return;
  }

  await pool.query(`
    CREATE TABLE IF NOT EXISTS flights (
      id SERIAL PRIMARY KEY,
      flight_number TEXT NOT NULL,
      origin TEXT NOT NULL,
      destination TEXT NOT NULL,
      status TEXT NOT NULL,
      departure_time TIMESTAMPTZ NOT NULL
    )
  `);

  await pool.query(`
    INSERT INTO flights (flight_number, origin, destination, status, departure_time)
    SELECT * FROM (VALUES
      ('UA100', 'EWR', 'ORD', 'ON_TIME', NOW() + INTERVAL '2 hours'),
      ('UA220', 'SFO', 'DEN', 'BOARDING', NOW() + INTERVAL '45 minutes'),
      ('UA330', 'IAH', 'LAX', 'DELAYED', NOW() + INTERVAL '3 hours')
    ) AS seed(flight_number, origin, destination, status, departure_time)
    WHERE NOT EXISTS (SELECT 1 FROM flights)
  `);
}

app.get("/health", (_req, res) => {
  res.json({
    service: serviceName,
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

app.get("/flights", async (_req, res, next) => {
  try {
    if (!pool) {
      res.json([
        { flightNumber: "UA100", origin: "EWR", destination: "ORD", status: "ON_TIME" },
        { flightNumber: "UA220", origin: "SFO", destination: "DEN", status: "BOARDING" }
      ]);
      return;
    }

    const result = await pool.query(`
      SELECT
        flight_number AS "flightNumber",
        origin,
        destination,
        status,
        departure_time AS "departureTime"
      FROM flights
      ORDER BY departure_time
    `);
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error(error);
  res.status(500).json({ error: "Internal server error" });
});

initializeDatabase()
  .then(() => {
    app.listen(port, () => {
      console.log(`${serviceName} listening on port ${port}`);
    });
  })
  .catch((error) => {
    console.error("database_initialization_failed", error);
    process.exit(1);
  });
