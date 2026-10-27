---
name: twitter-alpha
description: 'Pull high-alpha ideas from a company or person''s Twitter circle. Use when the user says twitter-alpha, alpha from twitter, scrape their tweets, what is this founder posting, or wants patterns from a company circle on X. Differentiator vs deep-research: tweet-level signal from a 7-person circle, not a company brief.'
---

# twitter-alpha

Turn a company or person into a short list of the highest-signal ideas their circle is posting right now.

Read the `deepapi` skill before any search or scrape. All web, LinkedIn, and X work goes through DeepAPI. Never use built-in search, fetch, or a browser.

## Seed

Need a company or a person. If missing, ask once.

If the seed is a person, their current company is the company.

## Pick 7 people

Always 3 insiders + 4 outsiders. Name them before scraping tweets.

**3 insiders:** the most impactful people at the company (founders, CEO, president/CTO, CRO, VP eng, VP product). Prefer people who actually post.

**4 outsiders:** people the *seed actually talks to on X*. Not competitors you guessed. Not investors unless they show up in the timeline.

How to find outsiders:

1. Resolve the seed's X handle (company account plus founder handles).
2. `POST /v1/scrape/twitter/search` with those handles, `sort: "latest"`, `maxItems` 50+.
3. Count replies, retweets, quote-tweets, and @mentions. Rank other people by how often the seed engages them.
4. Take the top 4 who are not employees of the company.

If the seed has no X, use founder handles. If you still cannot build an engagement graph, say so and stop. Do not invent a peer set.

## Handles and fallback

Find each person's X handle with DeepAPI (`/v1/scrape/twitter/user`, `/v1/search/web` only as a last resort). Verify the bio matches the person.

No X, private X, or almost no posts → scrape LinkedIn posts instead (`POST /v1/scrape/linkedin/posts`). Keep them in the 7. Do not silently drop them.

Need 7 people with *some* posts (X or LinkedIn). If you cannot fill 7, say who is missing and why.

## Scrape

For each of the 7:

- X: `POST /v1/scrape/twitter/search` with their handle, `sort: "latest"`, `maxItems: 50`.
- No X: LinkedIn posts, cap at 50.

Follow DeepAPI polling. Skip empty RTs with no added text when scoring alpha. Keep originals, quote-tweets, and threads.

Also pull `POST /v1/scrape/twitter/user` for the handles you will scrape (follower counts help ranking, not the output).

## What to extract

Read all ~350 posts. Rank for *alpha*: a concrete claim, a non-obvious take, a number, a product/move, a hiring or market tell. Ignore congrats, logo spam, podcast plugs, and vague inspiration.

Prefer ideas that show up across more than one person. A single post can still make the list if it is clearly the strongest item.

## Output

Short. Plain English. No preamble dump. No "here's what I found."

Numbered list, 5-8 items max. Same shape every time:

```markdown
1. [Title of the idea](https://x.com/...) (~808k views)
   One sentence with the actual insight.
```

Rules:

- Title is the idea, not the person's name.
- Link the source post (or LinkedIn post).
- Put view counts in parentheses when X reports them. Omit if unknown (LinkedIn).
- One sentence under each title. No second paragraph.
- Do not paste tweet dumps, bios, or a recap of who the 7 people are unless the user asks.

If nothing is high-alpha, say that in two sentences. Do not pad the list.
