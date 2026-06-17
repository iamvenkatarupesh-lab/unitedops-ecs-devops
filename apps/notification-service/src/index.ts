import cors from "cors";
import express from "express";

const app = express();
const port = Number(process.env.PORT ?? 4004);
const serviceName = process.env.SERVICE_NAME ?? "notification-service";

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    service: serviceName,
    status: "healthy",
    timestamp: new Date().toISOString()
  });
});

app.post("/notifications", (req, res) => {
  const event = {
    id: Date.now(),
    channel: req.body.channel ?? "email",
    recipient: req.body.recipient ?? "demo@example.com",
    message: req.body.message ?? "Your UnitedOps flight update is ready.",
    createdAt: new Date().toISOString()
  };

  console.log("notification_event", event);
  res.status(202).json(event);
});

app.listen(port, () => {
  console.log(`${serviceName} listening on port ${port}`);
});
