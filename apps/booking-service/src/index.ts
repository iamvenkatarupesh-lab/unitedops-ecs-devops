import cors from "cors";
import express from "express";
import pg from "pg";

const { Pool } = pg;

const app = express();
const port = Number(process.env.PORT ?? 4002);
const serviceName = process.env.SERVICE_NAME ?? "booking-service";
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
    CREATE TABLE IF NOT EXISTS bookings (
      id SERIAL PRIMARY KEY,
      passenger_name TEXT NOT NULL,
      flight_number TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  await pool.query(`
    INSERT INTO bookings (passenger_name, flight_number, status)
    SELECT 'Demo Passenger', 'UA100', 'CONFIRMED'
    WHERE NOT EXISTS (SELECT 1 FROM bookings)
  `);
}

app.get("/health", (_req, res) => {
  res.json({
    service: serviceName,
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

app.get("/bookings", async (_req, res, next) => {
  try {
    if (!pool) {
      res.json([{ id: 1, passengerName: "Demo Passenger", flightNumber: "UA100", status: "CONFIRMED" }]);
      return;
    }

    const result = await pool.query(`
      SELECT
        id,
        passenger_name AS "passengerName",
        flight_number AS "flightNumber",
        status,
        created_at AS "createdAt"
      FROM bookings
      ORDER BY created_at DESC
    `);
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.post("/bookings", async (req, res, next) => {
  try {
    const passengerName = String(req.body.passengerName ?? "Demo Passenger");
    const flightNumber = String(req.body.flightNumber ?? "UA100");

    if (!pool) {
      res.status(201).json({ id: Date.now(), passengerName, flightNumber, status: "CONFIRMED" });
      return;
    }

    const result = await pool.query(
      `
        INSERT INTO bookings (passenger_name, flight_number, status)
        VALUES ($1, $2, $3)
        RETURNING
          id,
          passenger_name AS "passengerName",
          flight_number AS "flightNumber",
          status,
          created_at AS "createdAt"
      `,
      [passengerName, flightNumber, "CONFIRMED"]
    );
    res.status(201).json(result.rows[0]);
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
