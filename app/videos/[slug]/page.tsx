import { notFound } from "next/navigation";
import Link from "next/link";
import LocalizedEditorial from "@/components/LocalizedEditorial";
import SiteHeader from "@/components/SiteHeader";
import WorkKnowledgeSections from "@/components/WorkKnowledgeSections";
import { getPublishedWorkBySlug, getPublishedWorks } from "@/lib/archive";
import { getWorkKnowledgeGraph } from "@/lib/knowledge-graph";

type Props = {
  params: Promise<{ slug: string }>;
};

export async function generateStaticParams() {
  const videos = await getPublishedWorks();
  return videos.map((video) => ({ slug: video.slug }));
}

export default async function VideoDetailPage({ params }: Props) {
  const { slug } = await params;
  const [video, knowledgeGraph] = await Promise.all([
    getPublishedWorkBySlug(slug),
    getWorkKnowledgeGraph(slug),
  ]);

  if (!video) notFound();

  const winningResults = new Set([
    "winner",
    "peoples_voice_winner",
    "grand_prix",
    "gold",
    "silver",
    "bronze",
    "black_pencil",
    "yellow_pencil",
    "graphite_pencil",
    "wood_pencil",
    "excellence_award",
  ]);
  const wins = (video.awards ?? []).filter((result) => winningResults.has(result.result));
  const nominations = (video.awards ?? []).filter((result) => result.result === "nominee");
  const awardSelections = (video.awards ?? []).filter(
    (result) => !winningResults.has(result.result) && result.result !== "nominee",
  );
  const festivalSelections = (video.recognitions ?? []).filter((result) =>
    ["festival_selection", "jury_selection"].includes(result.recognitionType),
  );
  const editorialRecognitions = (video.recognitions ?? []).filter((result) =>
    ["editorial_selection", "platform_recognition"].includes(result.recognitionType),
  );

  const formatAward = (result: (typeof wins)[number]) => {
    const outcomeLabels: Record<string, string> = {
      winner: "Winner",
      peoples_voice_winner: "People's Voice Winner",
      grand_prix: "Grand Prix",
      gold: "Gold",
      silver: "Silver",
      bronze: "Bronze",
      black_pencil: "Black Pencil",
      yellow_pencil: "Yellow Pencil",
      graphite_pencil: "Graphite Pencil",
      wood_pencil: "Wood Pencil",
      excellence_award: "Excellence Award",
      nominee: "Nominee",
      finalist: "Finalist",
      shortlist: "Shortlist",
      honorable_mention: "Honorable Mention",
      official_selection: "Official Selection",
      other: "Other verified result",
    };
    const outcome = outcomeLabels[result.result] ?? result.result.replaceAll("_", " ");
    return `${result.awardName} — ${result.categoryName} (${result.awardYear}) · ${outcome}`;
  };

  const formatRecognition = (result: (typeof festivalSelections)[number]) =>
    `${result.programName}${result.categoryName ? ` — ${result.categoryName}` : ""} (${result.recognitionYear})`;

  const fallbackThumbnail = video.youtubeId
    ? `https://i.ytimg.com/vi/${video.youtubeId}/hqdefault.jpg`
    : "";
  const thumbnail = video.thumbnailUrl || fallbackThumbnail;

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
              ? `linear-gradient(180deg, transparent 40%, rgba(0,0,0,.82)), url("${thumbnail}"), url("${fallbackThumbnail}")`
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

            {wins.length > 0 && (
              <>
                <dt>Awards</dt>
                <dd className="work-award-list">
                  {wins.map((award) => (
                    <span key={`${award.awardSlug}-${award.categoryName}-${award.awardYear}-${award.result}`}>
                      {formatAward(award)}
                    </span>
                  ))}
                </dd>
              </>
            )}

            {nominations.length > 0 && (
              <>
                <dt>Nominations</dt>
                <dd className="work-award-list">
                  {nominations.map((award) => (
                    <span key={`${award.awardSlug}-${award.categoryName}-${award.awardYear}`}>
                      {formatAward(award)}
                    </span>
                  ))}
                </dd>
              </>
            )}

            {awardSelections.length > 0 && (
              <>
                <dt>Award Selections</dt>
                <dd className="work-award-list">
                  {awardSelections.map((award) => (
                    <span key={`${award.awardSlug}-${award.categoryName}-${award.awardYear}-${award.result}`}>
                      {formatAward(award)}
                    </span>
                  ))}
                </dd>
              </>
            )}

            {festivalSelections.length > 0 && (
              <>
                <dt>Festival Selections</dt>
                <dd className="work-award-list">
                  {festivalSelections.map((recognition) => (
                    <span key={`${recognition.programSlug}-${recognition.recognitionYear}-${recognition.result}`}>
                      {formatRecognition(recognition)}
                    </span>
                  ))}
                </dd>
              </>
            )}

            {editorialRecognitions.length > 0 && (
              <>
                <dt>Editorial Recognition</dt>
                <dd className="work-award-list">
                  {editorialRecognitions.map((recognition) => (
                    <span key={`${recognition.programSlug}-${recognition.recognitionYear}-${recognition.result}`}>
                      {formatRecognition(recognition)}
                    </span>
                  ))}
                </dd>
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

      <WorkKnowledgeSections
        technologies={knowledgeGraph.technologies}
        visualLanguages={knowledgeGraph.visualLanguages}
      />

      {(video.sources?.length ?? 0) > 0 && (
        <section className="work-caption work-sources">
          <div className="work-caption-index">
            <span>Sources</span>
          </div>

          <div className="work-caption-primary">
            <p className="museum-kicker">Sources</p>

            <dl>
              {video.sources?.map((source, index) => (
                <div className="work-source-row" key={source.url}>
                  <dt>Source {String(index + 1).padStart(2, "0")}</dt>
                  <dd>
                    <a href={source.url} target="_blank" rel="noreferrer">
                      <span>{source.publisher || source.title}</span>
                      <small>{source.title}</small>
                      <b aria-hidden="true">↗</b>
                    </a>
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        </section>
      )}

      <footer className="work-footer">
        <span>Research status: {video.researchStatus}</span>
        <Link href="/">Return to collection</Link>
      </footer>
    </main>
  );
}
