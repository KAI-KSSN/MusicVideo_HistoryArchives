"use client";

import Link from "next/link";
import { usePreferences } from "@/components/PreferencesProvider";
import type {
  KnowledgeConcept,
  KnowledgeGraphRelationship,
} from "@/types/music-video";

type Props = {
  concept: KnowledgeConcept;
  relationships: KnowledgeGraphRelationship[];
};

const roleLabels: Record<string, { ja: string; en: string }> = {
  earliest_verified_adoption: { ja: "最初期の検証例", en: "Earliest verified adoption" },
  early_adoption: { ja: "初期採用例", en: "Early adoption" },
  breakthrough_use: { ja: "画期的な使用例", en: "Breakthrough use" },
  defining_use: { ja: "代表的な使用例", en: "Defining use" },
  modern_evolution: { ja: "現代的展開", en: "Modern evolution" },
  standard_use: { ja: "標準的な使用例", en: "Standard use" },
  pioneering_example: { ja: "先駆的な例", en: "Pioneering example" },
  defining_example: { ja: "代表例", en: "Defining example" },
  notable_example: { ja: "注目例", en: "Notable example" },
};

export default function ConceptDetail({ concept, relationships }: Props) {
  const { language } = usePreferences();
  const isTechnology = concept.type === "technology";
  const typeLabel = isTechnology
    ? language === "ja" ? "技術" : "Technology"
    : language === "ja" ? "映像言語" : "Visual Language";
  const description = language === "ja"
    ? concept.descriptionJa || concept.descriptionEn
    : concept.descriptionEn || concept.descriptionJa;
  const representativeWorks = relationships.filter(
    (relationship) => relationship.isPrimary,
  );

  function renderWorks(items: KnowledgeGraphRelationship[]) {
    return (
      <div className="concept-work-grid">
        {items.map((relationship) => {
          const fallbackThumbnail = relationship.youtubeId
            ? `https://i.ytimg.com/vi/${relationship.youtubeId}/hqdefault.jpg`
            : "";
          const thumbnail = relationship.thumbnailUrl || fallbackThumbnail;
          const role = roleLabels[relationship.relationshipRole];
          const note = language === "ja"
            ? relationship.noteJa || relationship.noteEn
            : relationship.noteEn || relationship.noteJa;

          return (
            <Link
              className="concept-work-card"
              href={`/videos/${relationship.workSlug}`}
              key={relationship.workId}
            >
              <div
                className="concept-work-image"
                style={thumbnail ? { backgroundImage: `url("${thumbnail}")` } : undefined}
              />
              <div className="concept-work-meta">
                <span>{relationship.releaseYear ?? "—"}</span>
                <p>{relationship.artist}</p>
                <h2>{relationship.workTitle}</h2>
                {role && <small>{role[language]}</small>}
                {note && <p className="concept-work-note">{note}</p>}
              </div>
            </Link>
          );
        })}
      </div>
    );
  }

  return (
    <>
      <section className="concept-hero">
        <p className="museum-kicker">{typeLabel}</p>
        <h1>{language === "ja" ? concept.nameJa || concept.name : concept.name}</h1>
        {description && <p className="concept-description">{description}</p>}
      </section>

      {representativeWorks.length > 0 && (
        <section className="concept-works concept-representative" id="representative-works">
          <header className="museum-section-header">
            <div>
              <p className="museum-kicker">
                {language === "ja" ? "代表作品" : "Representative Works"}
              </p>
              <h2>{representativeWorks.length}</h2>
            </div>
          </header>
          {renderWorks(representativeWorks)}
        </section>
      )}

      <section className="concept-works" id="related-works">
        <header className="museum-section-header">
          <div>
            <p className="museum-kicker">
              {language === "ja" ? "関連作品" : "Related Works"}
            </p>
            <h2>{relationships.length}</h2>
          </div>
        </header>

        {renderWorks(relationships)}
      </section>
    </>
  );
}
