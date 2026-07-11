import type { Metadata } from "next";
import PreferencesProvider from "@/components/PreferencesProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Music Video History Library",
  description:
    "A curated archive of historically, technically, and culturally significant music videos.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ja" suppressHydrationWarning>
      <body>
        <PreferencesProvider>{children}</PreferencesProvider>
      </body>
    </html>
  );
}
