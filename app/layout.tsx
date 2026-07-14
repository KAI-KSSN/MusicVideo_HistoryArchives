import type { Metadata } from "next";
import PreferencesProvider from "@/components/PreferencesProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Music Video History Library",
  description:
    "A curated archive of historically, technically, and culturally significant music videos.",
  robots: {
    index: false,
    follow: false,
    nocache: true,
    googleBot: {
      index: false,
      follow: false,
      noimageindex: true,
    },
  },
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
