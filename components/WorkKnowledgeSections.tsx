"use client";

import Link from "next/link";
import { usePreferences } from "@/components/PreferencesProvider";
import type { KnowledgeGraphRelationship } from "@/types/music-video";

type Props = {
  technologies: KnowledgeGraphRelationship[];
  visualLanguages: KnowledgeGraphRelationship[];
};

export default function WorkKnowledgeSections({
  technologies,
  visualLanguages,
}: Props) {
  const { language } = usePreferences();
  const sections = [
    {
      key: "technology",
      title: language === "ja" ? "技術" : "Technology",
      route: "technology",
      items: technologies,
    },
    {
      key: "visual-language",
      title: language === "ja" ? "映像言語" : "Visual Language",
      route: "visual-language",
      items: visualLanguages,
    },
  ].filter((section) => section.items.length > 0);

  if (sections.length === 0) return null;

  return (
    <section className="work-caption work-knowledge">
      <div className="work-caption-index">
        <span>{language === "ja" ? "知識グラフ" : "Knowledge graph"}</span>
      </div>

      <div className="work-caption-primary work-knowledge-primary">
        {sections.map((section) => (
          <div className="work-knowledge-group" key={section.key}>
            <p className="museum-kicker">{section.title}</p>
            <div className="knowledge-tag-list">
              {section.items.map((item) => (
                <Link
                  href={`/${section.route}/${item.conceptSlug}`}
                  key={item.conceptId}
                >
                  {language === "ja"
                    ? item.conceptNameJa || item.conceptName
                    : item.conceptName}
                </Link>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
