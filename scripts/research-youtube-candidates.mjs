import fs from "node:fs/promises";

const manifest = JSON.parse(
  await fs.readFile("docs/research/canon/canon-5star-manifest.json", "utf8"),
);
const era = process.argv[2];
const works = era ? manifest.works.filter((work) => work.era === era) : manifest.works;
const destination = `/private/tmp/mvhl-youtube-candidates-${era ?? "all"}.json`;

function text(value) {
  return value?.simpleText ?? value?.runs?.map((run) => run.text).join("") ?? "";
}

function collectVideoRenderers(node, found = []) {
  if (!node || typeof node !== "object") return found;
  if (node.videoRenderer?.videoId) found.push(node.videoRenderer);
  for (const value of Object.values(node)) collectVideoRenderers(value, found);
  return found;
}

function extractInitialData(html) {
  for (const marker of ["var ytInitialData = ", "ytInitialData = "]) {
    const start = html.indexOf(marker);
    if (start === -1) continue;
    const jsonStart = start + marker.length;
    const end = html.indexOf(";</script>", jsonStart);
    if (end !== -1) return JSON.parse(html.slice(jsonStart, end));
  }
  throw new Error("ytInitialData was not found.");
}

const output = [];
for (const work of works) {
  const query = `${work.artist} ${work.title} official music video`;
  try {
    const response = await fetch(`https://www.youtube.com/results?search_query=${encodeURIComponent(query)}`, {
      headers: {
        "Accept-Language": "en-US,en;q=0.9",
        "User-Agent": "Mozilla/5.0",
      },
    });
    if (!response.ok) throw new Error(`YouTube search failed (${response.status}) for ${query}.`);
    const renderers = collectVideoRenderers(extractInitialData(await response.text()));
    const seen = new Set();
    const candidates = [];
    for (const video of renderers) {
      if (seen.has(video.videoId)) continue;
      seen.add(video.videoId);
      candidates.push({
        videoId: video.videoId,
        title: text(video.title),
        channel: text(video.ownerText),
        duration: text(video.lengthText),
        verifiedChannel: Boolean(video.ownerBadges?.some((badge) =>
          badge.metadataBadgeRenderer?.style === "BADGE_STYLE_TYPE_VERIFIED",
        )),
        url: `https://www.youtube.com/watch?v=${video.videoId}`,
        thumbnail: `https://i.ytimg.com/vi/${video.videoId}/maxresdefault.jpg`,
      });
      if (candidates.length === 5) break;
    }
    output.push({ artist: work.artist, title: work.title, era: work.era, candidates });
    process.stderr.write(`researched ${work.artist} — ${work.title}\n`);
  } catch (error) {
    output.push({ artist: work.artist, title: work.title, era: work.era, candidates: [], error: String(error) });
    process.stderr.write(`failed ${work.artist} — ${work.title}: ${error}\n`);
  }
  await fs.writeFile(destination, JSON.stringify(output, null, 2));
}

console.log(destination);
