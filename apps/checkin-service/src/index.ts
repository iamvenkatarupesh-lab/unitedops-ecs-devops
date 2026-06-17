import cors from "cors";
import express from "express";
import pg from "pg";

const { Pool } = pg;

const app = express();
const port = Number(process.env.PORT ?? 4003);
const serviceName = process.env.SERVICE_NAME ?? "checkin-service";
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
    CREATE TABLE IF NOT EXISTS checkins (
      id SERIAL PRIMARY KEY,
      booking_id INTEGER NOT NULL,
      passenger_name TEXT NOT NULL,
      checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
}

app.get("/health", (_req, res) => {
  res.json({
    service: serviceName,
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

app.post("/checkins", async (req, res, next) => {
  try {
    const bookingId = Number(req.body.bookingId ?? 1);
    const passengerName = String(req.body.passengerName ?? "Demo Passenger");

    if (!pool) {
      res.status(201).json({ id: Date.now(), bookingId, passengerName, status: "CHECKED_IN" });
      return;
    }

    const result = await pool.query(
      `
        INSERT INTO checkins (booking_id, passenger_name)
        VALUES ($1, $2)
        RETURNING
          id,
          booking_id AS "bookingId",
          passenger_name AS "passengerName",
          checked_in_at AS "checkedInAt"
      `,
      [bookingId, passengerName]
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
