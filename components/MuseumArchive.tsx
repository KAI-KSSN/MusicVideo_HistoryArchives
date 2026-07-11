"use client";

import { useMemo, useState } from "react";
import MuseumVideoCard from "@/components/MuseumVideoCard";
import type { MusicVideo } from "@/types/music-video";

const INITIAL_COUNT = 24;

function unique(values: string[]) {
  return [...new Set(values.filter(Boolean))].sort((a, b) =>
    a.localeCompare(b, "ja"),
  );
}

export default function MuseumArchive({
  videos,
}: {
  videos: MusicVideo[];
}) {
  const [query, setQuery] = useState("");
  const [scope, setScope] = useState("");
  const [decade, setDecade] = useState("");
  const [director, setDirector] = useState("");
  const [genre, setGenre] = useState("");
  const [visibleCount, setVisibleCount] = useState(INITIAL_COUNT);

  const decades = unique(
    videos.map((video) => (video.decade ? `${video.decade}s` : "")),
  );
  const directors = unique(videos.map((video) => video.director));
  const genres = unique(videos.map((video) => video.genre));

  const filtered = useMemo(() => {
    const normalizedQuery = query.trim().toLocaleLowerCase("ja");

    return videos.filter((video) => {
      const searchable = [
        video.title,
        video.artist,
        video.director,
        video.productionCompany,
        video.vfxProduction,
        video.genre,
        video.award,
        video.selectionBasis,
      ]
        .join(" ")
        .toLocaleLowerCase("ja");

      return (
        (!normalizedQuery || searchable.includes(normalizedQuery)) &&
        (!scope || video.scope === scope) &&
        (!decade || `${video.decade}s` === decade) &&
        (!director || video.director === director) &&
        (!genre || video.genre === genre)
      );
    });
  }, [videos, query, scope, decade, director, genre]);

  const visible = filtered.slice(0, visibleCount);

  function resetFilters() {
    setQuery("");
    setScope("");
    setDecade("");
    setDirector("");
    setGenre("");
    setVisibleCount(INITIAL_COUNT);
  }

  return (
    <>
      <section className="museum-intro">
        <div className="museum-intro-title">
          <p className="museum-kicker">Music Video History Library</p>
          <h1>
            Moving images,
            <br />
            held in context.
          </h1>
        </div>

        <div className="museum-intro-note">
          <p>
            A curated archive of music videos essential to the history,
            language, and practice of moving-image culture.
          </p>

          <div className="museum-intro-stats">
            <span>{videos.length.toLocaleString()} works in research</span>
            <span>Japan / International</span>
          </div>
        </div>
      </section>

      <section className="museum-controls">
        <label className="museum-search">
          <span>Search</span>
          <input
            value={query}
            onChange={(event) => {
              setQuery(event.target.value);
              setVisibleCount(INITIAL_COUNT);
            }}
            placeholder="Title, artist, director, production..."
          />
        </label>

        <div className="museum-filter-row">
          <select
            value={scope}
            onChange={(event) => setScope(event.target.value)}
          >
            <option value="">All regions</option>
            <option value="Domestic">Japan</option>
            <option value="International">International</option>
          </select>

          <select
            value={decade}
            onChange={(event) => setDecade(event.target.value)}
          >
            <option value="">All decades</option>
            {decades.map((value) => (
              <option key={value}>{value}</option>
            ))}
          </select>

          <select
            value={director}
            onChange={(event) => setDirector(event.target.value)}
          >
            <option value="">All directors</option>
            {directors.map((value) => (
              <option key={value}>{value}</option>
            ))}
          </select>

          <select
            value={genre}
            onChange={(event) => setGenre(event.target.value)}
          >
            <option value="">All genres</option>
            {genres.map((value) => (
              <option key={value}>{value}</option>
            ))}
          </select>

          <button type="button" onClick={resetFilters}>
            Reset
          </button>
        </div>
      </section>

      <section className="museum-collection" id="collection">
        <header className="museum-section-header">
          <div>
            <p className="museum-kicker">Collection</p>
            <h2>Selected works</h2>
          </div>

          <div className="museum-section-count">
            <span>{filtered.length.toLocaleString()}</span>
            <small>of {videos.length.toLocaleString()}</small>
          </div>
        </header>

        <div className="museum-grid">
          {visible.map((video, index) => (
            <MuseumVideoCard
              key={video.id}
              video={video}
              index={index + 1}
            />
          ))}
        </div>

        {visible.length < filtered.length && (
          <button
            className="museum-load-more"
            type="button"
            onClick={() =>
              setVisibleCount((current) => current + INITIAL_COUNT)
            }
          >
            <span>Load more</span>
            <span>{filtered.length - visible.length} remaining</span>
          </button>
        )}
      </section>
    </>
  );
}
