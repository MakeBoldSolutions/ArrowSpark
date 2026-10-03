// Showcase content collections. One durable source per fact: pages render from these and
// never restate a figure a collection holds. Any schema violation fails the build.
import { defineCollection } from 'astro:content';
import { file, glob } from 'astro/loaders';
import { z } from 'astro/zod';
import { parse as parseYaml } from 'yaml';
import { evidenceUrlProblem } from './lib/content-rules.mjs';

/** A permanent evidence link: commit-pinned file, merged PR, commit, or internal path. */
const evidenceUrl = z.string().superRefine((url, context) => {
  const problem = evidenceUrlProblem(url);
  if (problem) context.addIssue({ code: 'custom', message: `${url}: ${problem}` });
});

const source = z.object({ label: z.string().min(1), url: evidenceUrl }).strict();

/** YAML list, keyed by each item's "n" field. */
const numberedList = (text: string) =>
  Object.fromEntries((parseYaml(text) as Array<Record<string, unknown>>).map((item) => [String(item['n']), item]));

/** YAML document holding one record. */
const singleRecord = (text: string) => ({ main: parseYaml(text) as Record<string, unknown> });

const chapters = defineCollection({
  loader: glob({ pattern: '*.{md,mdx}', base: './src/content/chapters' }),
  schema: z
    .object({
      title: z.string().min(1),
      part: z.number().int().min(1).max(9),
      slug: z.string().regex(/^[a-z0-9-]+$/),
      description: z.string().min(1),
      spoiler: z.boolean(),
      status: z.enum(['draft', 'published']),
      sources: z.array(source),
      updated: z.coerce.date(),
    })
    .strict(),
});

const beats = defineCollection({
  loader: file('src/content/beats.yaml', { parser: numberedList }),
  schema: z
    .object({
      n: z.number().int().min(1),
      title: z.string().min(1),
      belief: z.string().min(1).nullable(),
      evidence: z.string().min(1),
      decision: z.string().min(1),
      sources: z.array(source).min(1),
      spoiler: z.boolean(),
    })
    .strict(),
});

const journey = defineCollection({
  loader: file('src/content/journey.yaml', { parser: numberedList }),
  schema: z
    .object({
      n: z.number().int().min(1),
      title: z.string().min(1),
      changed: z.string().min(1),
      learned: z.string().min(1),
      chapter: z.string().regex(/^[a-z0-9-]+$/).nullable(),
    })
    .strict(),
});

const evidence = defineCollection({
  loader: file('src/content/evidence.yaml', { parser: singleRecord }),
  schema: z
    .object({
      automated: z.array(
        z
          .object({ title: z.string().min(1), detail: z.string().min(1), source: evidenceUrl, command: z.string().min(1).optional() })
          .strict(),
      ),
      human: z.object({ baseline: z.string().min(1), sources: z.array(source).min(1) }).strict(),
      notClaimed: z.array(z.string().min(1)),
      limitations: z.array(
        z
          .object({
            item: z.string().min(1),
            class: z.enum(['accepted-limitation', 'deferred', 'not-performed']),
            source: evidenceUrl,
          })
          .strict(),
      ),
    })
    .strict(),
});

const lessons = defineCollection({
  loader: file('src/content/lessons.yaml', { parser: singleRecord }),
  schema: z
    .object({
      worked: z.array(z.object({ text: z.string().min(1), source: evidenceUrl }).strict()).min(1),
      didnt: z.array(z.object({ text: z.string().min(1), source: evidenceUrl }).strict()).min(1),
    })
    .strict(),
});

const facts = defineCollection({
  loader: file('src/content/facts.yaml', { parser: singleRecord }),
  schema: z
    .object({
      referenceKnot: z.array(
        z
          .object({ value: z.string().min(1), label: z.string().min(1), source: evidenceUrl, command: z.string().min(1).optional() })
          .strict(),
      ),
      clock: z
        .object({
          cutoffCommit: z.string().regex(/^[0-9a-f]{40}$/),
          source: evidenceUrl,
          items: z.array(z.object({ label: z.string().min(1), value: z.string().min(1), command: z.string().min(1) }).strict()).min(1),
        })
        .strict(),
    })
    .strict(),
});

export const collections = { chapters, beats, journey, evidence, lessons, facts };
