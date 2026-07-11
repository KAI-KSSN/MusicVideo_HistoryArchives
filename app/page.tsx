import MuseumArchive from "@/components/MuseumArchive";
import SiteHeader from "@/components/SiteHeader";
import { videos } from "@/lib/videos";

export default function Home() {
  return (
    <main>
      <SiteHeader />
      <MuseumArchive videos={videos} />
    </main>
  );
}
