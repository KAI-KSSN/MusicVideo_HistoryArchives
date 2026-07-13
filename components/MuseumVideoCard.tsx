"use client";

import Link from "next/link";
import { usePreferences } from "@/components/PreferencesProvider";
import type { MusicVideo } from "@/types/music-video";

export default function MuseumVideoCard({
  video,
}: {
  video: MusicVideo;
}) {
  const { language } = usePreferences();
  const fallbackThumbnail = video.youtubeId
    ? `https://i.ytimg.com/vi/${video.youtubeId}/hqdefault.jpg`
    : "";
  const thumbnail =
    video.thumbnailUrl ||
    fallbackThumbnail;

  const tags = [
    video.genre,
    video.scope === "Domestic" ? "Japan" : "International",
    video.decade ? `${video.decade}s` : "",
    video.award ? "Selected" : "",
  ].filter(Boolean) as string[];

  const localizedSummary = video.shortSummaryI18n;
  const summary =
    (language === "ja"
      ? localizedSummary?.ja || localizedSummary?.en
      : localizedSummary?.en || localizedSummary?.ja) ||
    video.shortSummary ||
    video.selectionBasis ||
    (language === "ja"
      ? "この作品の紹介文は現在準備中です。"
      : "This work is currently being researched for inclusion in the archive.");

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
                  rgba(0, 0, 0, 0.02) 18%,
                  rgba(0, 0, 0, 0.16) 48%,
                  rgba(0, 0, 0, 0.86) 100%
                ),
                url("${thumbnail}"),
                url("${fallbackThumbnail}")`
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

        <div className="museum-caption museum-caption-with-tags">
          <div className="museum-caption-copy">
            <p>
              {summary}
            </p>

            {tags.length > 0 && (
              <div
                className={`museum-tag-preview ${
                  tags.length > 3 ? "has-overflow-hint" : ""
                }`}
              >
                <div className="museum-tag-preview-track">
                  {tags.map((tag) => (
                    <span key={tag}>{tag}</span>
                  ))}
                </div>
              </div>
            )}

            <span className="museum-card-enter">
              {language === "ja" ? "作品を見る" : "View work"} ↗
            </span>
          </div>
        </div>
      </Link>
    </article>
  );
}
