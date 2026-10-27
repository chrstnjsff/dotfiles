---
name: who-is-this
description: 'Deep-scrape a person across X, LinkedIn, GitHub, and the open web to judge if they are legit. Manual-only; invoke with /who-is-this. Use when the user says who-is-this, "who is this", "who is this guy", "research this person", "are they legit", "vet this founder", or drops a profile screenshot. Differentiator vs twitter-alpha: one-person background check, not a 7-person idea list. Differentiator vs deep-research: platform scrapes plus a short verdict, not a long cited memo.'
disable-model-invocation: true
---

# who-is-this

Figure out who a person is and whether their story holds.

Read the `deepapi` skill first. All search and scraping goes through DeepAPI. Never use built-in search, fetch, or a browser.

## Seed

Need a person. A name, handle, URL, or profile screenshot is enough.

If missing, ask once. Do not guess a different person.

Verify identity before going deep. Bio, company, location, and photo must match. If two people share the name, stop and ask.

## Research

Find their X, LinkedIn, and GitHub first (dedicated endpoints, not `site:` search). Then run these in parallel:

1. **GitHub activity.** `POST /v1/scrape/github/profile` with `includeRepos: true`, plus recent PRs (`POST /v1/scrape/github/search`, `type: "pulls"`, `query: "author:<username>"`, `sort: "updated"`).
2. **Last 10 LinkedIn posts.** `POST /v1/scrape/linkedin/posts`, `maxItems: 10`. Also scrape the LinkedIn profile if you have the slug.
3. **Deep research.** `POST /v1/research/deep` on who they are, what they have actually done, and whether the public story holds.
4. **50 newest X posts.** `POST /v1/scrape/twitter/search` with the handle, `sort: "latest"`, `maxItems: 50`. Also pull `POST /v1/scrape/twitter/user`.

Follow DeepAPI polling. If a platform is missing or private, say so. Do not invent a profile.

## What to extract

Scrape wide, report narrow. From everything you pulled, keep only the 3 facts that explain who this person is. Drop the rest, a full CV is a failure, not thoroughness.

Rules:

- Real track record beats bio. Jobs, products, exits, code, talks.
- Self-reported numbers stay labeled "their claim". Verified numbers say "verified".
- Note what they actually post about only if it changes the verdict.
- Name the honest archetype: builder, marketer, operator, researcher, grifter, investor, recruiter, hobbyist, etc. Pick the one that is true in practice, not the one in their bio.

Ignore congrats, logo spam, paid "king of X" press, and follower-count flexing.

## Output

Hard cap: 100 words after the header line. Plain English. Short sentences. No tables. No sub-bullets. No tweet dumps. No research narration. No "I found" / "I scraped".

```markdown
**Full name**, [@handle](https://x.com/handle) · [LinkedIn](url) · [GitHub](url) · [Site](url)

**Who:** One sentence. Where they are and what they do now.

**Track record:** Max 3 bullets. Only what explains who they are. Dates. Label claims vs verified.

**Verdict:** One line. The archetype, whether the story holds, and why.
```

Example of the right length (fictional):

```markdown
**Jane Doe**, [@janedoe](https://x.com/janedoe) · [LinkedIn](https://linkedin.com/in/janedoe) · [GitHub](https://github.com/janedoe)

**Who:** Berlin solo founder of Acme, an open-source Postgres proxy. Writes 90% of the commits herself.

**Track record:**
- 2024-now: Founder, Acme. 2.1K stars (verified), no funding, no revenue (her own post).
- 2019-2024: Backend engineer at Zalando and N26.
- "50K users" is her claim; nothing backs it.

**Verdict:** Solo builder, not a company yet. Real code, honest numbers, one unproven user claim.
```

Omit a missing profile link instead of faking it.

Follow-ups: answer in 1-3 sentences. Do not re-run the scrape unless the first pass missed that platform.
