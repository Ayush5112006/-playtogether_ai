import type { Metadata, Viewport } from 'next';
import { Space_Grotesk, Outfit } from 'next/font/google';
import './globals.css';

const spaceGrotesk = Space_Grotesk({
  subsets: ['latin'],
  variable: '--font-space',
  display: 'swap',
});

const outfit = Outfit({
  subsets: ['latin'],
  variable: '--font-outfit',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'PlayTogether AI — Fire TV Edition',
  description: 'One TV. One Remote. Every Generation Plays. AI-Powered Adaptive Family Trivia for Amazon Fire TV.',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'black-translucent',
    title: 'PlayTogether AI',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: 'cover',
  themeColor: '#070812',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`dark bg-[#070812] ${spaceGrotesk.variable} ${outfit.variable}`} style={{ backgroundColor: '#070812', color: '#f8fafc' }}>
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover, user-scalable=no" />
        <meta name="theme-color" content="#070812" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
        <meta name="color-scheme" content="dark" />
        <link rel="manifest" href="/manifest.json" />
      </head>
      <body
        className="bg-[#070812] text-slate-100 antialiased overflow-hidden select-none font-outfit"
        style={{ backgroundColor: '#070812', color: '#f8fafc', margin: 0, padding: 0 }}
      >
        {children}
      </body>
    </html>
  );
}

