const RETRY_DELAYS_MS = [250, 750];

function delay(milliseconds: number) {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}

function shouldRetryResponse(response: Response) {
  return response.status === 429 || response.status >= 500;
}

/**
 * Keeps public Supabase reads resilient to brief connection resets during
 * static generation without hiding persistent API or configuration errors.
 */
export async function fetchSupabasePublic(
  input: string,
  init: RequestInit,
  requestLabel: string,
): Promise<Response> {
  const attemptCount = RETRY_DELAYS_MS.length + 1;
  let lastError: unknown;

  for (let attempt = 0; attempt < attemptCount; attempt += 1) {
    try {
      const response = await fetch(input, init);

      if (!shouldRetryResponse(response) || attempt === attemptCount - 1) {
        return response;
      }

      lastError = new Error(`${requestLabel} returned ${response.status}.`);
    } catch (error) {
      lastError = error;

      if (attempt === attemptCount - 1) {
        break;
      }
    }

    await delay(RETRY_DELAYS_MS[attempt]);
  }

  throw new Error(`${requestLabel} failed after ${attemptCount} attempts.`, {
    cause: lastError,
  });
}
