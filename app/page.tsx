import MVArchive from "@/components/MVArchive";
import videos from "@/data/videos.json";
import type { MusicVideo } from "@/types/music-video";
export default function Home(){return <MVArchive videos={videos as MusicVideo[]} />}
