import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "Music Video History Library", description: "Curated music video archive." };
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="ja"><body>{children}</body></html>}
