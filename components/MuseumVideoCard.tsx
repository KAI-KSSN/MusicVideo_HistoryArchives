import Link from "next/link";
import type { MusicVideo } from "@/types/music-video";

export default function MuseumVideoCard({
  video,
}: {
  video: MusicVideo;
}) {
  const thumbnail = video.youtubeId
    ? `https://i.ytimg.com/vi/${video.youtubeId}/hq720.jpg`
    : "";

  return (
    <article
      className="museum-card"
      style={
        {
          "--work-accent": video.primaryColor,
          "--work-accent-dark": video.secondaryColor,
        } as React.CSSProperties
      }
    >
      <Link className="museum-card-link" href={`/videos/${video.slug}`}>
        <div
          className="museum-card-image"
          style={{
            backgroundImage: thumbnail
              ? `linear-gradient(
                  180deg,
                  rgba(0, 0, 0, 0.03) 22%,
                  rgba(0, 0, 0, 0.8)
                ),
                url(${thumbnail})`
              : `linear-gradient(
                  135deg,
                  ${video.primaryColor},
                  ${video.secondaryColor}
                )`,
          }}
        >
          {!thumbnail && (
            <div className="museum-card-placeholder">
              <span>{video.artist}</span>
              <strong>{video.title}</strong>
            </div>
          )}

          <div className="museum-card-overlay">
            <p className="museum-card-artist">{video.artist}</p>
            <h2>{video.title}</h2>

            <div className="museum-card-overlay-meta">
              <span>{video.year || "Year TBC"}</span>
              <span>
                {video.director
                  ? `Dir. ${video.director}`
                  : "Director TBC"}
              </span>
            </div>
          </div>
        </div>

        <div className="museum-caption">
          <div className="museum-caption-index">
            <span>{video.scope === "Domestic" ? "JP" : "INT"}</span>
            <span>{video.year || "—"}</span>
          </div>

          <div className="museum-caption-copy">
            <p>
              {video.shortSummary ||
                video.selectionBasis ||
                "This work is currently being researched for inclusion in the archive."}
            </p>

            <dl>
              {video.productionCompany && (
                <>
                  <dt>Production</dt>
                  <dd>{video.productionCompany}</dd>
                </>
              )}

              {video.vfxProduction && (
                <>
                  <dt>VFX</dt>
                  <dd>{video.vfxProduction}</dd>
                </>
              )}

              {video.genre && (
                <>
                  <dt>Genre</dt>
                  <dd>{video.genre}</dd>
                </>
              )}

              {video.award && (
                <>
                  <dt>Selected</dt>
                  <dd>{video.award}</dd>
                </>
              )}
            </dl>

            <span className="museum-card-enter">View work ↗</span>
          </div>
        </div>
      </Link>
    </article>
  );
}
