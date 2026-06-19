const services = [
  {
    name: "Flight Service",
    url: `${process.env.NEXT_PUBLIC_FLIGHT_API_URL ?? ""}/flights`,
    method: "GET"
  },
  {
    name: "Booking Service",
    url: `${process.env.NEXT_PUBLIC_BOOKING_API_URL ?? ""}/bookings`,
    method: "GET"
  },
  {
    name: "Check-In Service",
    url: `${process.env.NEXT_PUBLIC_CHECKIN_API_URL ?? ""}/checkins`,
    method: "POST"
  },
  {
    name: "Notification Service",
    url: `${process.env.NEXT_PUBLIC_NOTIFICATION_API_URL ?? ""}/notifications`,
    method: "POST"
  }
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
              <p>{service.method} {service.url}</p>
            </div>
            {service.method === "GET" ? (
              <a href={service.url} target="_blank" rel="noreferrer">
                Open
              </a>
            ) : (
              <span className="method">API</span>
            )}
          </article>
        ))}
      </section>
    </main>
  );
}
