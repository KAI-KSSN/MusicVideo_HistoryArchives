import { notFound } from "next/navigation";
import LocalizedEditorial from "@/components/LocalizedEditorial";
import SiteHeader from "@/components/SiteHeader";
import { getVideoBySlug, videos } from "@/lib/videos";

type Props = {
  params: Promise<{ slug: string }>;
};

export function generateStaticParams() {
  return videos.map((video) => ({ slug: video.slug }));
}

export default async function VideoDetailPage({ params }: Props) {
  const { slug } = await params;
  const video = getVideoBySlug(slug);

  if (!video) notFound();

  const thumbnail = video.youtubeId
    ? `https://i.ytimg.com/vi/${video.youtubeId}/maxresdefault.jpg`
    : "";

  return (
    <main
      className="work-page"
      style={
        {
          "--work-accent": video.primaryColor,
          "--work-accent-dark": video.secondaryColor,
        } as React.CSSProperties
      }
    >
      <SiteHeader detail />

      <section className="work-hero">
        <div
          className="work-hero-image"
          style={{
            backgroundImage: thumbnail
              ? `linear-gradient(180deg, transparent 40%, rgba(0,0,0,.82)), url(${thumbnail})`
              : `linear-gradient(135deg, ${video.primaryColor}, ${video.secondaryColor})`,
          }}
        >
          <div className="work-hero-overlay">
            <p>{video.artist}</p>
            <h1>{video.title}</h1>
            <div>
              <span>{video.year || "Year TBC"}</span>
              <span>
                {video.director
                  ? `Directed by ${video.director}`
                  : "Director TBC"}
              </span>
            </div>
          </div>
        </div>
      </section>

      <section className="work-caption">
        <div className="work-caption-index">
          <span>{video.scope === "Domestic" ? "Japan" : video.region}</span>
          <span>{video.genre}</span>
        </div>

        <div className="work-caption-primary">
          <p className="museum-kicker">Object information</p>
          <dl>
            <dt>Artist</dt>
            <dd>{video.artist}</dd>

            <dt>Title</dt>
            <dd>{video.title}</dd>

            <dt>Year</dt>
            <dd>{video.year || "Researching"}</dd>

            <dt>Director</dt>
            <dd>{video.director || "Researching"}</dd>

            {video.productionCompany && (
              <>
                <dt>Production</dt>
                <dd>{video.productionCompany}</dd>
              </>
            )}

            {video.vfxProduction && (
              <>
                <dt>VFX Production</dt>
                <dd>{video.vfxProduction}</dd>
              </>
            )}

            {video.award && (
              <>
                <dt>Selected</dt>
                <dd>{video.award}</dd>
              </>
            )}
          </dl>

          {video.referenceUrl && (
            <a
              className="work-watch-link"
              href={video.referenceUrl}
              target="_blank"
              rel="noreferrer"
            >
              Watch / Reference ↗
            </a>
          )}
        </div>
      </section>

      <section className="work-caption work-editorial">
        <div className="work-caption-index">
          <span>Editorial</span>
        </div>

        <div className="work-caption-primary">
          <p className="museum-kicker">Editorial</p>

          <dl>
            <dt>Why it matters</dt>
            <dd>
              <LocalizedEditorial
                localized={video.whyItMattersI18n}
                fallback={video.whyItMatters || video.selectionBasis}
                emptyJa="この作品が映像史において持つ意味を現在調査しています。"
                emptyEn="The historical significance of this work is currently being researched."
              />
            </dd>

            <dt>Historical context</dt>
            <dd>
              <LocalizedEditorial
                localized={video.historicalContextI18n}
                fallback={video.historicalContext}
                emptyJa="公開当時の映像文化、制作背景、後世への影響を調査中です。"
                emptyEn="Its historical context, production culture, and influence are currently being researched."
              />
            </dd>

            <dt>Key innovation</dt>
            <dd>
              <LocalizedEditorial
                localized={video.keyInnovationI18n}
                fallback={video.keyInnovation}
                emptyJa="技法および制作上の革新性を、出典とともに確認しています。"
                emptyEn="Its technical and production innovations are being verified with sources."
              />
            </dd>
          </dl>
        </div>
      </section>

      <footer className="work-footer">
        <span>Research status: {video.researchStatus}</span>
        <a href="/">Return to collection</a>
      </footer>
    </main>
  );
}
