import "./styles.css";

export const metadata = {
  title: "UnitedOps",
  description: "Airline operations dashboard for ECS DevOps practice"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
