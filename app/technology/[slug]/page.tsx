import { notFound } from "next/navigation";
import ConceptDetail from "@/components/ConceptDetail";
import SiteHeader from "@/components/SiteHeader";
import {
  getPublishedConceptBySlug,
  getPublishedConcepts,
} from "@/lib/knowledge-graph";

type Props = { params: Promise<{ slug: string }> };

export async function generateStaticParams() {
  const concepts = await getPublishedConcepts("technology");
  return concepts.map((concept) => ({ slug: concept.slug }));
}

export default async function TechnologyPage({ params }: Props) {
  const { slug } = await params;
  const result = await getPublishedConceptBySlug("technology", slug);

  if (!result) notFound();

  return (
    <main className="work-page concept-page">
      <SiteHeader detail />
      <ConceptDetail {...result} />
    </main>
  );
}
