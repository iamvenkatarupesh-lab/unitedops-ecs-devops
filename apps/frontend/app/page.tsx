const services = [
  { name: "Flight Service", url: process.env.NEXT_PUBLIC_FLIGHT_API_URL ?? "http://localhost:4001" },
  { name: "Booking Service", url: process.env.NEXT_PUBLIC_BOOKING_API_URL ?? "http://localhost:4002" },
  { name: "Check-In Service", url: process.env.NEXT_PUBLIC_CHECKIN_API_URL ?? "http://localhost:4003" },
  { name: "Notification Service", url: process.env.NEXT_PUBLIC_NOTIFICATION_API_URL ?? "http://localhost:4004" }
];

export default function Home() {
  return (
    <main className="shell">
      <section className="header">
        <div>
          <p className="eyebrow">UnitedOps</p>
          <h1>Airline Operations Dashboard</h1>
        </div>
        <span className="badge">ECS Fargate Project</span>
      </section>

      <section className="grid">
        {services.map((service) => (
          <article className="service" key={service.name}>
            <div>
              <h2>{service.name}</h2>
              <p>{service.url}</p>
            </div>
            <a href={`${service.url}/health`} target="_blank" rel="noreferrer">
              Health
            </a>
          </article>
        ))}
      </section>
    </main>
  );
}
