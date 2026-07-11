import MuseumArchive from "@/components/MuseumArchive";
import SiteHeader from "@/components/SiteHeader";
import { getPublishedWorks } from "@/lib/archive";

export default async function Home() {
  const videos = await getPublishedWorks();

  return (
    <main>
      <SiteHeader />
      <MuseumArchive videos={videos} />
    </main>
  );
}
