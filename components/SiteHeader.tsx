import Link from "next/link";
import PreferenceControls from "@/components/PreferenceControls";

type Props = {
  detail?: boolean;
};

export default function SiteHeader({ detail = false }: Props) {
  return (
    <header className="museum-site-header">
      <Link href="/" className="museum-wordmark">
        <span>MVHL</span>
        <strong>Music Video History Library</strong>
      </Link>

      <div className="header-actions">
        {detail ? (
          <Link className="header-text-link" href="/">
            Collection
          </Link>
        ) : (
          <nav>
            <a href="#collection">Collection</a>
          </nav>
        )}
        <PreferenceControls />
      </div>
    </header>
  );
}
